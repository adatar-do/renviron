source("renviron/scripts/bootstrap.R")
release <- normalizePath("artifacts/renviron-release", winslash = "/")
rscript <- file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript")
reports <- list()
for (scenario in c("damaged-archive", "missing-dependency")) {
  fixture <- tempfile(paste0(scenario, "-"), tmpdir = release)
  dir.create(fixture)
  for (entry in c("install.R", "external-dependencies.txt", "packages"))
    file.copy(file.path(release, "bundle", entry), fixture, recursive = TRUE)
  if (scenario == "damaged-archive") {
    archive <- file.path(fixture, "packages/renviron_0.6.0.tar.gz")
    con <- file(archive, "ab"); writeBin(charToRaw("fixture-corruption"), con); close(con)
  } else {
    cat("renviron_missing_fixture_dependency\t\t0.0.0\n", file = file.path(fixture, "external-dependencies.txt"), append = TRUE)
  }
  lib <- file.path(fixture, "must-not-be-created")
  log <- file.path(fixture, "result.log")
  status <- system2(rscript, c("--vanilla", shQuote(file.path(fixture, "install.R")), shQuote(lib), "source"), stdout = log, stderr = log)
  output <- readLines(log, warn = FALSE)
  expected <- if (scenario == "damaged-archive") "Archive integrity check failed" else "Missing external dependency"
  stopifnot(status != 0L, !dir.exists(lib), any(grepl(expected, output, fixed = TRUE)))
  reports[[scenario]] <- list(rejected = TRUE, destination_created = FALSE, exit_status = status)
}
jsonlite::write_json(reports, file.path(release, "installer-preflight-audit.json"), auto_unbox = TRUE, pretty = TRUE)
cat("Installer rejected both invalid scenarios before creating a library\n")
