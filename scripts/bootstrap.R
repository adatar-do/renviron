# Workspace libraries are optional conveniences; installed dependencies work in CI.
paths<-c("artifacts/endomer-release/package/zip-installed",
 "artifacts/enhogar-2022-release/package/zip-installed","artifacts/enft-release/package/zip-installed",
 "artifacts/encft-integration/package/zip-installed","artifacts/dmisc-release/package/zip-installed",
 "artifacts/dmisc-release/library","artifacts/labeler/bilingual/package/labeler.Rcheck")
.libPaths(c(paths,.libPaths()))
Sys.setenv(RENV_CONFIG_AUTOLOADER_ENABLED="false",NOT_CRAN="true")
if(.Platform$OS.type=="windows")Sys.setenv(LC_ALL="English_United States.utf8")
Sys.setenv(R_LIBS=paste(normalizePath(.libPaths(),winslash="/"),collapse=.Platform$path.sep))
