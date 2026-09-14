source("renviron/scripts/bootstrap.R")
workspace <- normalizePath(".", winslash = "/")
release <- file.path(workspace, "artifacts/renviron-release")
root <- file.path(release, "package")
version <- unname(read.dcf("renviron/DESCRIPTION")[1, "Version"])
tarball <- file.path(root, paste0("renviron_", version, ".tar.gz"))
r <- file.path(R.home("bin"), if (.Platform$OS.type == "windows") "R.exe" else "R")
rscript <- file.path(R.home("bin"), if (.Platform$OS.type == "windows") "Rscript.exe" else "Rscript")
run <- function(cmd, args) if (system2(cmd, args) != 0L) stop("Distribution command failed")
old <- getwd(); setwd(root)
if (.Platform$OS.type == "windows") {
  lib <- file.path(root, "binary-library"); dir.create(lib, showWarnings = FALSE)
  run(r, c("CMD", "INSTALL", "--build", paste0("--library=", shQuote(lib)), shQuote(tarball)))
}
setwd(old)
bundle <- file.path(release, "bundle"); dir.create(file.path(bundle, "packages"), recursive = TRUE, showWarnings = FALSE)
files <- c(tarball, if (.Platform$OS.type == "windows") file.path(root, paste0("renviron_", version, ".zip")))
types <- c("source", if (.Platform$OS.type == "windows") "win.binary")
for (file in files) file.copy(file, file.path(bundle, "packages"), overwrite = TRUE)
inventory <- data.frame(Package = "renviron", Version = version, Type = types, File = basename(files),
  MD5 = unname(tools::md5sum(files)))
write.dcf(inventory, file.path(bundle, "packages/inventory.dcf"))
db <- installed.packages()
deps <- unique(c("callr", "fs", "magrittr", unlist(tools::package_dependencies(c("callr", "fs", "magrittr"),
  db = db, which = c("Depends", "Imports", "LinkingTo"), recursive = TRUE))))
deps <- sort(setdiff(deps, c("R", rownames(db)[db[, "Priority"] %in% c("base", "recommended")])))
external <- data.frame(Package = deps, Minimum = ifelse(deps == "callr", "3.7.0", ""), Validated = db[deps, "Version"])
write.table(external, file.path(bundle, "external-dependencies.txt"), sep = "\t", row.names = FALSE, quote = FALSE)
invisible(file.copy("renviron/scripts/install-bundle.R", file.path(bundle, "install.R"), overwrite = TRUE))
for (type in types) {
  label <- if (type == "source") "source" else "binary"
  lib <- file.path(root, paste0(label, "-installed"))
  run(rscript, c("--vanilla", shQuote(file.path(bundle, "install.R")), shQuote(lib), type))
  run(rscript, c("--vanilla", shQuote(file.path(workspace, "renviron/scripts/verify-installed.R")),
    shQuote(lib), shQuote(file.path(release, paste0(label, "-install-audit.json")))))
}
cat("Built distribution and verified independent installed libraries\n")
