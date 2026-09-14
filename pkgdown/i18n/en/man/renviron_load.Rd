\name{renviron_load}
\alias{renviron_load}
\title{Load variables into the current session}
\usage{
renviron_load(
  scope = c("user", "project"),
  .file = ".Renviron",
  .vars = NULL,
  verbosity = 1,
  ...
)
}
\arguments{
\item{scope}{Scopes to search in order: user and project. The default order is user, then project. scoped_path_r() accepts a single scope and defaults to user.}
\item{.file}{A filename relative to the selected scope, or an explicit absolute path.}
\item{.vars}{Keys to return or load; NULL selects all. References are resolved against the full file before filtering.}
\item{verbosity}{0 suppresses the missing-file message; 1 shows it.}
\item{...}{Arguments for renviron_path() in writers, or renviron_read() in queries/unset_all. Path functions reject unknown arguments. In scoped_path_r(), these are path components.}
}
\value{The named list of loaded values, invisibly.}
\description{Read and validate the entire file before changing the session. Set only the selected keys; leave other session variables unchanged.}
\details{Reading supports quotes, equals signs, UTF-8, full-line comments and native R variable references with defaults. The optional export prefix is accepted as an extension. Bare KEY= is ignored; quoted empty values retain a declared key and an empty string in the returned list. Windows may represent empty process variables as unset. An unquoted expansion producing an empty value may be ignored by R and preserve an inherited value. A trailing hash belongs to the value. Reads start a separate R process with --vanilla and a 60-second timeout; reuse a returned list when querying many keys. Values are resolved, not raw file expressions.}
\examples{
path <- tempfile()
writeLines("RNV_LOAD_DEMO='sample'", path)
previous <- Sys.getenv("RNV_LOAD_DEMO", unset = NA_character_)
values <- renviron_load(.file = path, .vars = "RNV_LOAD_DEMO")
if (is.na(previous)) Sys.unsetenv("RNV_LOAD_DEMO") else
  Sys.setenv(RNV_LOAD_DEMO = previous)
unlink(path)
}
