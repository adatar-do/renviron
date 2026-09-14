\name{renviron_read}
\alias{renviron_read}
\title{Read variables without changing the session}
\usage{
renviron_read(
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
\value{A named list, invisibly. Missing and empty files return list(). Invalid assignments stop with a line number and no value in the diagnostic.}
\description{Parse an environment file using the native R reader in an isolated process. References are resolved in file order using the inherited session environment. No startup profiles are executed and no parent variables are changed.}
\details{Reading supports quotes, equals signs, UTF-8, full-line comments and native R variable references with defaults. The optional export prefix is accepted as an extension. Bare KEY= is ignored; quoted empty values retain a declared key and an empty string in the returned list. Windows may represent empty process variables as unset. An unquoted expansion producing an empty value may be ignored by R and preserve an inherited value. A trailing hash belongs to the value. Reads start a separate R process with --vanilla and a 60-second timeout; reuse a returned list when querying many keys. Values are resolved, not raw file expressions.}
\examples{
path <- tempfile()
writeLines(c("RNV_DEMO='one=two'", "RNV_COPY='${RNV_DEMO}'"), path)
values <- renviron_read(.file = path)
stopifnot(identical(values$RNV_COPY, "one=two"))
unlink(path)
}
