# Run from the extracted delivery: Rscript install.R path/to/library [source|win.binary]
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1L || length(args) > 2L) stop("Usage: Rscript install.R library [source|win.binary]")
script <- normalizePath(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)), winslash = "/")
root <- dirname(script)
type <- if (length(args) == 2L) args[[2]] else if (.Platform$OS.type == "windows") "win.binary" else "source"
if (!type %in% c("source", "win.binary")) stop("Unsupported archive type")
if (type == "win.binary" && .Platform$OS.type != "windows") stop("Windows binary requires Windows")
if (getRversion() < "4.1.0") stop("R >= 4.1.0 is required")
inventory <- read.dcf(file.path(root, "packages/inventory.dcf"))
row <- inventory[inventory[, "Type"] == type, , drop = FALSE]
if (nrow(row) != 1L) stop("Invalid archive inventory")
archive <- file.path(root, "packages", row[1, "File"])
if (!file.exists(archive) || is.na(tools::md5sum(archive)) ||
    unname(tools::md5sum(archive)) != unname(row[1, "MD5"])) stop("Archive integrity check failed")
deps <- read.delim(file.path(root, "external-dependencies.txt"), stringsAsFactors = FALSE, check.names = FALSE)
for (i in seq_len(nrow(deps))) {
  name <- deps$Package[[i]]
  installed <- tryCatch(as.character(utils::packageVersion(name)), error = function(e) NA_character_)
  if (is.na(installed)) stop("Missing external dependency: ", name)
  if (nzchar(deps$Minimum[[i]]) && utils::compareVersion(installed, deps$Minimum[[i]]) < 0)
    stop("External dependency is below the minimum: ", name)
}
lib <- path.expand(args[[1]])
if (!dir.exists(lib) && !dir.create(lib, recursive = TRUE)) stop("Cannot create destination library")
lib <- normalizePath(lib, winslash = "/")
utils::install.packages(archive, repos = NULL, type = type, lib = lib)
installed <- tryCatch(as.character(utils::packageVersion("renviron", lib.loc = lib)), error = function(e) "")
if (!identical(unname(installed), unname(row[1, "Version"]))) stop("Installed version verification failed")
cat("Installed renviron", installed, "from", type, "into", lib, "\n")
