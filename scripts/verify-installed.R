args <- commandArgs(trailingOnly = TRUE)
source("renviron/scripts/bootstrap.R")
.libPaths(c(args[[1]], .libPaths()))
library(renviron)
stopifnot(as.character(packageVersion("renviron")) == "0.6.0",
  normalizePath(find.package("renviron")) == normalizePath(file.path(args[[1]], "renviron")))
path <- tempfile("renviron-installed-")
keys <- c("RNV_INSTALLED", "RNV_DERIVED", "RNV_LITERAL", "RNV_EMPTY")
before <- Sys.getenv(keys, unset = NA_character_, names = TRUE)
local({
  on.exit({
    unlink(path)
    Sys.unsetenv(keys[is.na(before)])
    if (any(!is.na(before))) do.call(Sys.setenv, as.list(before[!is.na(before)]))
  })
  Sys.setenv(RNV_INSTALLED = "session", RNV_DERIVED = "session-derived")
  writeLines(c("# preserve", "RNV_INSTALLED='old'", "RNV_DERIVED='${RNV_INSTALLED}'"), path)
  stopifnot(renviron_get("RNV_INSTALLED", .file = path) == "old", Sys.getenv("RNV_INSTALLED") == "session")
  renviron_add("RNV_INSTALLED", "new=value", .file = path, in_place = TRUE, confirm = FALSE)
  stopifnot(readLines(path)[1] == "# preserve", Sys.getenv("RNV_DERIVED") == "session-derived",
    renviron_get("RNV_DERIVED", .file = path) == "new=value")
  renviron_load(.file = path, .vars = "RNV_DERIVED")
  stopifnot(Sys.getenv("RNV_DERIVED") == "new=value")
  renviron_delete("RNV_INSTALLED", .file = path, in_place = TRUE, confirm = FALSE)
  stopifnot(is.na(Sys.getenv("RNV_INSTALLED", unset = NA_character_)),
    !renviron_exists("RNV_INSTALLED", .file = path))
  values <- list(RNV_LITERAL = "a='b'\\${RNV_INSTALLED}\\", RNV_EMPTY = "")
  renviron_save(values, .file = path, confirm = FALSE)
  stopifnot(identical(renviron_read(.file = path), values))
  readRenviron(path)
  stopifnot(identical(as.list(Sys.getenv(names(values))), values))
})
jsonlite::write_json(list(package = "renviron", version = as.character(packageVersion("renviron")),
  r = as.character(getRversion()), library = find.package("renviron"),
  verified = c("namespace path", "read without session effects", "single-key edit", "preserved comments",
    "native expansion", "selective load", "delete", "literal round trip", "native reader compatibility")),
  args[[2]], pretty = TRUE, auto_unbox = TRUE)
cat("Installed package workflow passed\n")
