# Internal validation never includes configuration values in diagnostics.
rv_scalar <- function(x, what, empty = FALSE) {
  if (!is.character(x) || length(x) != 1L || is.na(x) ||
      (!empty && !nzchar(x)) || grepl("[\r\n]", x))
    stop(what, " must be one non-missing, single-line string.", call. = FALSE)
  invisible(x)
}

rv_flag <- function(x, what) {
  if (!is.logical(x) || length(x) != 1L || is.na(x))
    stop(what, " must be TRUE or FALSE.", call. = FALSE)
}

rv_keys <- function(x, scalar = FALSE) {
  if (!is.character(x) || anyNA(x) || (scalar && length(x) != 1L) ||
      any(!grepl("^[A-Za-z_][A-Za-z0-9_]*$", x)))
    stop("Keys must be portable environment variable names.", call. = FALSE)
  invisible(x)
}

rv_key_id <- function(x) if (.Platform$OS.type == "windows") tolower(x) else x

rv_values <- function(x) {
  if (is.character(x)) x <- as.list(x)
  if (!is.list(x) || (length(x) && is.null(names(x))))
    stop("Variables must be a named list or character vector.", call. = FALSE)
  if (!length(x)) return(list())
  rv_keys(names(x))
  if (anyDuplicated(rv_key_id(names(x))))
    stop("Variable names must be unique on this platform.", call. = FALSE)
  for (value in x) rv_scalar(value, "Each value", empty = TRUE)
  x
}

rv_select <- function(x, keys) {
  if (is.null(keys)) return(x)
  rv_keys(keys)
  selected <- x[rv_key_id(names(x)) %in% rv_key_id(keys)]
  if (!length(selected)) list() else selected
}

rv_bytes <- function(path) {
  if (!file.exists(path)) return(NULL)
  if (dir.exists(path)) stop("The environment path is a directory.", call. = FALSE)
  tryCatch(readBin(path, "raw", n = file.info(path)$size),
    error = function(e) stop("Cannot read the environment file.", call. = FALSE))
}

rv_document <- function(path) {
  bytes <- rv_bytes(path)
  if (is.null(bytes)) return(list(bytes = NULL, lines = character(),
    normalized = character(), keys = character(), active = character()))
  if (any(bytes == as.raw(0L))) stop("NUL bytes are not supported.", call. = FALSE)
  text <- rawToChar(bytes)
  if (!validUTF8(text)) stop("The environment file must contain valid UTF-8.", call. = FALSE)
  text <- sub("^\ufeff", "", text)
  lines <- strsplit(text, "\n", fixed = TRUE)[[1L]]
  lines <- sub("\r$", "", lines)
  normalized <- lines
  keys <- rep(NA_character_, length(lines))
  active <- character()
  for (i in seq_along(lines)) {
    line <- trimws(lines[[i]])
    if (!nzchar(line) || startsWith(line, "#")) next
    if (nchar(line, type = "bytes") > 99900L)
      stop("Environment line ", i, " exceeds the supported length.", call. = FALSE)
    line <- sub("^export[ \t]+", "", line)
    equal <- regexpr("=", line, fixed = TRUE)[[1L]]
    key <- if (equal > 0L) trimws(substr(line, 1L, equal - 1L)) else ""
    if (!grepl("^[A-Za-z_][A-Za-z0-9_]*$", key))
      stop("Invalid assignment on line ", i, ".", call. = FALSE)
    keys[[i]] <- key
    normalized[[i]] <- line
    # Native R ignores a bare KEY=; KEY='' explicitly sets an empty string.
    if (nzchar(trimws(substring(line, equal + 1L)))) active <- c(active, key)
  }
  active <- active[!duplicated(rv_key_id(active), fromLast = TRUE)]
  list(bytes = bytes, lines = lines, normalized = normalized, keys = keys, active = active)
}

rv_parse <- function(document) {
  if (!length(document$active)) return(list())
  # Delegate the grammar to R itself. --vanilla prevents startup files from
  # running in the worker; only this snapshot is read. No parent mutation.
  result <- tryCatch(callr::r(function(lines, keys) {
    path <- tempfile("renviron-read-")
    on.exit(unlink(path), add = TRUE)
    writeLines(lines, path, useBytes = TRUE)
    Sys.chmod(path, "0600")
    bad <- FALSE
    ok <- withCallingHandlers(readRenviron(path), warning = function(w) {
      bad <<- TRUE
      invokeRestart("muffleWarning")
    })
    if (!ok || bad) stop("Native environment parsing failed.")
    # Keep the declared key even where the platform represents an empty
    # variable as unset. A scalar Sys.getenv() needs names = TRUE explicitly.
    as.list(Sys.getenv(keys, unset = "", names = TRUE))
  }, args = list(document$normalized, document$active), env = Sys.getenv(),
    cmdargs = c("--vanilla", "--slave"), system_profile = FALSE,
    user_profile = FALSE, timeout = 60),
    error = function(e) stop("Cannot parse the environment file in isolated R.", call. = FALSE))
  result
}

rv_literal <- function(value) {
  # Native R expands references before stripping quotes. Adjacent quoted
  # sections break the raw ${ sequence without changing the literal value.
  body <- sub("\\\\+$", "", value)
  trailing <- nchar(value) - nchar(body)
  body <- gsub('"', '\\"', body, fixed = TRUE)
  body <- gsub("${", '$""{', body, fixed = TRUE)
  # Trailing slashes are outside the quoted section so the closing quote
  # cannot be escaped. N+1 unquoted slashes decode to N literal slashes.
  paste0('"', body, '"', if (trailing) strrep("\\", trailing + 1L) else "")
}

rv_lines <- function(values) {
  values <- rv_values(values)
  result <- vapply(names(values), function(key) paste0(key, "=", rv_literal(values[[key]])), character(1))
  if (any(nchar(result, type = "bytes") > 99900L))
    stop("Encoded value exceeds the supported line length.", call. = FALSE)
  unname(result)
}

rv_confirm <- function(confirm) {
  rv_flag(confirm, "confirm")
  if (!confirm) return(TRUE)
  if (!interactive()) stop("Confirmation requires interactive R; use confirm = FALSE in scripts.", call. = FALSE)
  identical(tolower(trimws(readline("Save changes to the selected environment file? (yes/no): "))), "yes")
}

rv_write <- function(path, lines, expected) {
  if (!dir.exists(dirname(path))) stop("The destination directory does not exist.", call. = FALSE)
  if (fs::is_link(path)) stop("Writing through a symbolic link is not supported.", call. = FALSE)
  if (!identical(rv_bytes(path), expected))
    stop("The environment file changed; read it again before saving.", call. = FALSE)
  tmp <- tempfile(".renviron-write-", tmpdir = dirname(path))
  on.exit(unlink(tmp), add = TRUE)
  old_mode <- if (!is.null(expected)) file.info(path)$mode else "0600"
  tryCatch({
    writeLines(enc2utf8(lines), tmp, useBytes = TRUE)
    Sys.chmod(tmp, old_mode)
    if (!identical(rv_bytes(path), expected)) stop("Concurrent change")
    fs::file_move(tmp, path)
  }, error = function(e) stop("Cannot save the environment file; the original was retained.", call. = FALSE))
  invisible(path)
}

rv_set <- function(values) {
  if (length(values) && !all(do.call(Sys.setenv, values)))
    stop("The operating system rejected an environment update.", call. = FALSE)
  invisible(values)
}

rv_lookup <- function(key, values) {
  index <- match(rv_key_id(key), rv_key_id(names(values)))
  if (is.na(index)) NULL else values[[index]]
}
