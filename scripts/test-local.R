source("renviron/scripts/bootstrap.R")
dir.create("artifacts/renviron-release", recursive = TRUE, showWarnings = FALSE)
result <- testthat::test_local("renviron", reporter = "summary", stop_on_failure = TRUE)
x <- as.data.frame(result)
jsonlite::write_json(list(tests = nrow(x), expectations = sum(x$nb),
  failed = sum(x$failed), warnings = sum(x$warning), skipped = sum(x$skipped)),
  "artifacts/renviron-release/tests.json", pretty = TRUE, auto_unbox = TRUE)
