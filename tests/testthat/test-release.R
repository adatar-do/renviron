fixture_file <- function(lines = character()) {
  path <- tempfile("renviron-fixture-")
  writeLines(enc2utf8(lines), path, useBytes = TRUE)
  withr::defer(unlink(path), envir = parent.frame())
  path
}

test_that("native reading resolves equals, quoting, defaults, duplicates and Unicode", {
  withr::local_envvar(c(RNV_BASE = "inherited", RNV_EMPTY = "", RNV_ABSENT = NA,
    RNV_COPY = "parent", RNV_CHAIN = NA, RNV_DUP = NA, RNV_UTF = NA, RNV_HASH = NA,
    RNV_DEFAULT = NA, RNV_NESTED = NA, RNV_DASH = NA, RNV_COLON = NA,
    RNV_SLASH = NA, RNV_QUOTE = NA, RNV_BARE = NA))
  path <- fixture_file(c("# settings", "", "RNV_BASE='a=b=='",
    "RNV_COPY='${RNV_BASE}'", "RNV_CHAIN=${RNV_COPY}/tail",
    "RNV_DEFAULT=${RNV_ABSENT:-fallback}",
    "RNV_NESTED=${RNV_ABSENT-${RNV_BASE}}", "RNV_DASH=${RNV_EMPTY-other}",
    "RNV_COLON=${RNV_EMPTY:-other}", "RNV_DUP='first'", "RNV_DUP='last'",
    "RNV_UTF='República Dominicana'", "RNV_HASH=value # literal",
    "RNV_SLASH='C:\\path\\folder'", "RNV_QUOTE=\"a\\\"b\"", "RNV_BARE="))
  values <- renviron_read(.file = path)
  expect_identical(Sys.getenv("RNV_BASE"), "inherited")
  expect_identical(Sys.getenv("RNV_COPY"), "parent")
  expect_identical(values$RNV_BASE, "a=b==")
  expect_identical(values$RNV_COPY, "a=b==")
  expect_identical(values$RNV_CHAIN, "a=b==/tail")
  expect_identical(values$RNV_DEFAULT, "fallback")
  expect_identical(values$RNV_NESTED, "a=b==")
  expect_identical(values$RNV_DUP, "last")
  expect_identical(values$RNV_UTF, "República Dominicana")
  expect_identical(values$RNV_HASH, "value # literal")
  expect_null(values$RNV_BARE)
  readRenviron(path)
  expect_identical(values, as.list(Sys.getenv(names(values))))
})

test_that("literal writes survive the package and native R readers", {
  values <- c("", "plain", "a=b==", " padded ", "á ñ 中文", "#hash", "a'b",
    'a"b', "C:\\folder\\", "\\'", "\\\"", "${RNV_SERIAL}", "$x${RNV_SERIAL}",
    "${MISSING:-fallback}", "'\"\\$", "a\tb", "\\\\", "${A}-${B}")
  env <- stats::setNames(as.list(values), paste0("RNV_SERIAL_", seq_along(values)))
  withr::local_envvar(c(stats::setNames(rep(NA_character_, length(env)), names(env)), RNV_SERIAL = "not literal"))
  path <- fixture_file()
  expect_identical(renviron_save(env, .file = path, confirm = FALSE), renviron_path(.file = path))
  expect_identical(renviron_read(.file = path), env)
  expect_true(all(is.na(Sys.getenv(names(env), unset = NA_character_))))
  readRenviron(path)
  expect_identical(as.list(Sys.getenv(names(env))), env)
  expect_silent(renviron_save(list(), .file = path, confirm = FALSE))
  expect_identical(readLines(path), character())
})

test_that("metacharacter combinations round-trip through native R", {
  alphabet <- c("a", "'", '"', "\\", "$", "{", "}", " ")
  combinations <- expand.grid(alphabet, alphabet, stringsAsFactors = FALSE)
  values <- as.list(paste0(combinations[[1]], combinations[[2]], "${RNV_SUFFIX}"))
  names(values) <- paste0("RNV_COMBO_", seq_along(values))
  withr::local_envvar(stats::setNames(rep(NA_character_, length(values)), names(values)))
  path <- fixture_file()
  renviron_save(values, .file = path, confirm = FALSE)
  readRenviron(path)
  for (key in names(values)) expect_identical(Sys.getenv(key), values[[key]])
})

test_that("selective load resolves the whole file but changes only selected keys", {
  withr::local_envvar(c(RNV_ONE = "old-one", RNV_TWO = "old-two", RNV_OTHER = "keep"))
  path <- fixture_file(c("RNV_ONE='new'", "RNV_TWO='${RNV_ONE}=suffix'"))
  result <- renviron_load(.file = path, .vars = "RNV_TWO")
  expect_identical(result, list(RNV_TWO = "new=suffix"))
  expect_identical(Sys.getenv("RNV_ONE"), "old-one")
  expect_identical(Sys.getenv("RNV_TWO"), "new=suffix")
  expect_identical(Sys.getenv("RNV_OTHER"), "keep")
  expect_identical(renviron_load(.file = path, .vars = character()), list())
})

test_that("queries never mutate the session or fall back to unrelated values", {
  withr::local_envvar(c(RNV_QUERY = "session", RNV_ABSENT = "session-only", RNV_EMPTY = "session-empty"))
  path <- fixture_file(c("RNV_QUERY='file'", "RNV_EMPTY=''"))
  expect_identical(renviron_get("RNV_QUERY", .file = path), "file")
  expect_null(renviron_get("RNV_ABSENT", .file = path))
  expect_identical(renviron_get("RNV_EMPTY", .file = path), "")
  expect_true(renviron_exists("RNV_EMPTY", .file = path))
  expect_false(renviron_exists("RNV_ABSENT", .file = path))
  expect_identical(renviron_list(.file = path), c(RNV_QUERY = "*****", RNV_EMPTY = "*****"))
  expect_identical(Sys.getenv("RNV_QUERY"), "session")
  expect_identical(Sys.getenv("RNV_EMPTY"), "session-empty")
  expect_identical(renviron_get("RNV_QUERY", list(RNV_QUERY = "list")), "list")
  expect_identical(Sys.getenv("RNV_QUERY"), "session")
  expect_identical(renviron_list(list()), character())
})

test_that("scope ordering and explicit paths select one deterministic file", {
  root <- withr::local_tempdir()
  user <- file.path(root, "user"); project <- file.path(root, "project")
  dir.create(user); dir.create(project)
  user_file <- file.path(user, ".Renviron"); project_file <- file.path(project, ".Renviron")
  expect_identical(renviron_path(user = user, project = project), as.character(fs::path_abs(user_file)))
  writeLines("RNV_SCOPE='project'", project_file)
  expect_identical(renviron_get("RNV_SCOPE", user = user, project = project), "project")
  writeLines("RNV_SCOPE='user'", user_file)
  expect_identical(renviron_get("RNV_SCOPE", user = user, project = project), "user")
  expect_identical(renviron_get("RNV_SCOPE", scope = c("project", "user"), user = user, project = project), "project")
  withr::local_envvar(c(R_ENVIRON_USER = project_file))
  expect_identical(renviron_path("user"), as.character(fs::path_abs(project_file)))
  expect_identical(renviron_path("user", user = user), as.character(fs::path_abs(user_file)))
  expect_identical(renviron_path("project", .file = user_file), as.character(fs::path_abs(user_file)))
  custom <- renviron_path("user", .file = "custom.env", user = user)
  expect_identical(custom, as.character(fs::path_abs(file.path(user, "custom.env"))))
  expect_false(identical(renviron_path("user", .file = "custom.env"), as.character(fs::path_abs(project_file))))
  withr::local_dir(project)
  # Compare physical directories across macOS symlinks and Windows short paths.
  expect_identical(normalizePath(renviron_path("project"), winslash = "/"),
                   normalizePath(project_file, winslash = "/"))
  custom_path <- scoped_path_r("project", "custom.env")
  expect_identical(normalizePath(dirname(custom_path), winslash = "/"),
                   normalizePath(project, winslash = "/"))
  expect_identical(basename(custom_path), "custom.env")
  expect_identical(scoped_path_r("user", "ignored", envvar = "R_ENVIRON_USER"), as.character(fs::path_abs(project_file)))
})

test_that("editing a key preserves comments and unresolved expressions", {
  withr::local_envvar(c(RNV_EDIT = "session", RNV_DEPENDENT = "session-other", RNV_KEEP = "untouched"))
  lines <- c("# configuración", "RNV_EDIT='old'", "", "RNV_DEPENDENT=${RNV_EDIT:-fallback}",
    "RNV_KEEP='keep=me'", "export RNV_EDIT='duplicate'", "# final")
  path <- fixture_file(lines)
  result <- renviron_add("RNV_EDIT", "new=value", .file = path, in_place = TRUE, confirm = FALSE)
  expect_identical(readLines(path, encoding = "UTF-8"), c(lines[1], 'RNV_EDIT="new=value"', lines[3:5], lines[7]))
  expect_identical(Sys.getenv("RNV_EDIT"), "new=value")
  expect_identical(Sys.getenv("RNV_DEPENDENT"), "session-other")
  expect_identical(Sys.getenv("RNV_KEEP"), "untouched")
  expect_identical(result$RNV_EDIT, "new=value")
  expect_identical(renviron_get("RNV_DEPENDENT", .file = path), "new=value")
  renviron_delete("RNV_EDIT", .file = path, in_place = TRUE, confirm = FALSE)
  expect_identical(readLines(path, encoding = "UTF-8"), lines[c(1, 3, 4, 5, 7)])
  expect_true(is.na(Sys.getenv("RNV_EDIT", unset = NA_character_)))
  before <- readBin(path, "raw", file.info(path)$size)
  renviron_add("RNV_EDIT", "temporary", .file = path)
  expect_identical(readBin(path, "raw", file.info(path)$size), before)
  renviron_delete("RNV_EDIT", .file = path)
  expect_identical(readBin(path, "raw", file.info(path)$size), before)
})

test_that("a supplied list intentionally replaces the complete file", {
  withr::local_envvar(c(RNV_REPLACE = NA))
  path <- fixture_file(c("# old", "RNV_OLD='old'"))
  renviron_add("RNV_REPLACE", "new", .renviron = list(RNV_BASE = "base"),
    .file = path, in_place = TRUE, confirm = FALSE)
  expect_identical(renviron_read(.file = path), list(RNV_BASE = "base", RNV_REPLACE = "new"))
  expect_false(any(grepl("# old", readLines(path))))
})

test_that("cancellation and write failures leave the current session intact", {
  withr::local_envvar(c(RNV_CANCEL = "session"))
  path <- fixture_file("RNV_CANCEL='file'")
  testthat::local_mocked_bindings(rv_confirm = function(confirm) FALSE)
  expect_null(renviron_save(list(RNV_CANCEL = "changed"), .file = path))
  expect_identical(renviron_add("RNV_CANCEL", "changed", .file = path, in_place = TRUE), list(RNV_CANCEL = "file"))
  renviron_delete("RNV_CANCEL", .file = path, in_place = TRUE)
  expect_identical(readLines(path), "RNV_CANCEL='file'")
  expect_identical(Sys.getenv("RNV_CANCEL"), "session")
})

test_that("noninteractive confirmation and atomic write failure retain original data", {
  withr::local_envvar(c(RNV_FAIL = "session"))
  path <- fixture_file("RNV_FAIL='original'")
  expect_error(renviron_save(list(RNV_FAIL = "new"), .file = path), "Confirmation requires")
  testthat::local_mocked_bindings(rv_write = function(...) stop("write failed"))
  expect_error(renviron_add("RNV_FAIL", "new", .file = path, in_place = TRUE, confirm = FALSE), "write failed")
  expect_identical(readLines(path), "RNV_FAIL='original'")
  expect_identical(Sys.getenv("RNV_FAIL"), "session")
})

test_that("replacement detects stale snapshots and missing destination directories", {
  path <- fixture_file("RNV_RACE='old'")
  snapshot <- rv_document(path)
  writeLines("RNV_RACE='new'", path)
  expect_error(rv_write(path, "RNV_RACE='ours'", snapshot$bytes), "changed")
  expect_identical(readLines(path), "RNV_RACE='new'")
  missing <- file.path(tempfile(), "config.env")
  expect_error(renviron_save(list(RNV_RACE = "new"), .file = missing, confirm = FALSE), "directory")
  expect_false(file.exists(missing))
})

test_that("missing, empty, comments-only, export and BOM files have clear contracts", {
  path <- tempfile()
  expect_message(result <- renviron_read(.file = path), "not found")
  expect_identical(result, list())
  expect_silent(renviron_read(.file = path, verbosity = 0))
  path <- fixture_file()
  expect_identical(renviron_read(.file = path), list())
  writeLines(c("# comment", "  "), path)
  expect_identical(renviron_read(.file = path), list())
  writeLines(enc2utf8("\ufeffexport RNV_EXPORT='a=b'"), path, useBytes = TRUE)
  expect_identical(renviron_read(.file = path), list(RNV_EXPORT = "a=b"))
})

test_that("invalid assignments fail before loading or writing without exposing values", {
  withr::local_envvar(c(RNV_VALID = "parent"))
  path <- fixture_file(c("RNV_VALID='change'", "sensitive-fragment-without-equals"))
  before <- readLines(path)
  for (operation in list(function() renviron_load(.file = path),
                        function() renviron_add("RNV_VALID", "change", .file = path, in_place = TRUE, confirm = FALSE),
                        function() renviron_delete("RNV_VALID", .file = path, in_place = TRUE, confirm = FALSE))) {
    error <- tryCatch(operation(), error = identity)
    expect_s3_class(error, "error")
    expect_match(conditionMessage(error), "line 2")
    expect_false(grepl("sensitive-fragment", conditionMessage(error)))
  }
  expect_identical(Sys.getenv("RNV_VALID"), "parent")
  expect_identical(readLines(path), before)
})

test_that("invalid arguments and values are rejected before persistence", {
  path <- fixture_file("RNV_VALID='original'")
  invalid <- list(list(A = NA_character_), list(A = c("x", "y")), list(A = 1),
    list(A = NULL), list(A = "line\nbreak"), list(A = "line\rbreak"),
    list("unnamed"), stats::setNames(list("x"), "BAD=KEY"),
    stats::setNames(list("x", "y"), c("A", "A")))
  for (env in invalid) expect_error(renviron_save(env, .file = path, confirm = FALSE))
  expect_identical(readLines(path), "RNV_VALID='original'")
  expect_error(renviron_get(c("A", "B"), .renviron = list()), "Keys")
  expect_error(renviron_read(.file = path, .vars = NA_character_), "Keys")
  expect_error(renviron_path(scope = character()), "scope")
  expect_error(renviron_path(scope = c("user", "user")), "scope")
  expect_error(renviron_path(scope = "invalid"), "scope")
  expect_error(renviron_path(.file = NA_character_), ".file", fixed = TRUE)
  expect_error(renviron_path(verbosity = NA), "verbosity")
  expect_error(renviron_path(unknown = 1), "Unknown")
  expect_error(renviron_add("A", "x", list(), in_place = NA), "in_place")
  expect_error(renviron_save(list(A = "x"), .file = path, confirm = NA), "confirm")
  expect_error(renviron_read(.file = tempdir()), "directory")
})

test_that("unset_all only clears selected declared variables and never writes", {
  withr::local_envvar(c(RNV_CLEAR = "one", RNV_RETAIN = "two", RNV_UNRELATED = "three"))
  path <- fixture_file(c("RNV_CLEAR='file'", "RNV_RETAIN='file'"))
  before <- readLines(path)
  expect_null(renviron_unset_all(.file = path, .vars = "RNV_CLEAR"))
  expect_true(is.na(Sys.getenv("RNV_CLEAR", unset = NA_character_)))
  expect_identical(Sys.getenv("RNV_RETAIN"), "two")
  expect_identical(Sys.getenv("RNV_UNRELATED"), "three")
  expect_identical(readLines(path), before)
})

test_that("the worker does not execute user profiles or startup environment files", {
  withr::local_envvar(c(RNV_STARTUP = "parent", RNV_PROFILE = NA))
  startup <- fixture_file("RNV_STARTUP='startup'")
  profile <- fixture_file('Sys.setenv(RNV_PROFILE = "executed")')
  withr::local_envvar(c(R_ENVIRON_USER = startup, R_PROFILE_USER = profile))
  path <- fixture_file(c("RNV_RESULT='${RNV_STARTUP}'", "RNV_NO_PROFILE='${RNV_PROFILE:-not-executed}'"))
  expect_identical(renviron_read(.file = path), list(RNV_RESULT = "parent", RNV_NO_PROFILE = "not-executed"))
  expect_identical(Sys.getenv("RNV_STARTUP"), "parent")
  expect_true(is.na(Sys.getenv("RNV_PROFILE", unset = NA_character_)))
})

test_that("new files, empty lists and named character vectors are supported", {
  withr::local_envvar(c(RNV_CREATE = NA))
  path <- tempfile(); withr::defer(unlink(path))
  result <- renviron_add("RNV_CREATE", "new", .file = path, in_place = TRUE, confirm = FALSE)
  expect_identical(result, list(RNV_CREATE = "new"))
  expect_identical(renviron_read(.file = path), result)
  renviron_delete("RNV_CREATE", .file = path, in_place = TRUE, confirm = FALSE)
  expect_identical(renviron_read(.file = path), list())
  renviron_save(c(RNV_CREATE = "vector"), .file = path, confirm = FALSE)
  expect_identical(renviron_get("RNV_CREATE", .file = path), "vector")
})

test_that("a replacement failure preserves the original and removes its temporary file", {
  path <- fixture_file("RNV_ATOMIC='old'")
  before <- rv_bytes(path)
  temporaries <- list.files(dirname(path), pattern = "^\\.renviron-write-", all.files = TRUE)
  testthat::local_mocked_bindings(file_move = function(...) stop("simulated rename failure"), .package = "fs")
  expect_error(renviron_save(list(RNV_ATOMIC = "new"), .file = path, confirm = FALSE), "original was retained")
  expect_identical(rv_bytes(path), before)
  expect_identical(list.files(dirname(path), pattern = "^\\.renviron-write-", all.files = TRUE), temporaries)
})

test_that("worker errors do not disclose values", {
  path <- fixture_file("RNV_SENSITIVE='invented-private-value'")
  testthat::local_mocked_bindings(r = function(...) stop("invented-private-value"), .package = "callr")
  error <- tryCatch(renviron_read(.file = path), error = identity)
  expect_identical(conditionMessage(error), "Cannot parse the environment file in isolated R.")
})

test_that("NUL, invalid UTF-8 and overlong assignments fail before changes", {
  path <- fixture_file()
  writeBin(as.raw(c(65, 61, 0, 66)), path)
  expect_error(renviron_read(.file = path), "NUL")
  writeBin(as.raw(c(65, 61, 255)), path)
  expect_error(renviron_read(.file = path), "UTF-8")
  writeLines(paste0("RNV_LONG=", strrep("a", 100000)), path)
  expect_error(renviron_read(.file = path), "length")
  expect_error(renviron_save(list(RNV_LONG = strrep("a", 100000)), .file = path, confirm = FALSE), "length")
})
