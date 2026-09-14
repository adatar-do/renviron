\name{renviron_save}
\alias{renviron_save}
\title{Save a complete set of variables}
\usage{
renviron_save(.Renviron, confirm = TRUE, ...)
}
\arguments{
\item{.Renviron}{A named list or named character vector of scalar character values without NA or line breaks. list() creates an empty file.}
\item{confirm}{Request interactive confirmation before writing. Scripts must explicitly pass FALSE. Cancellation leaves the file and session unchanged.}
\item{...}{Arguments for renviron_path() in writers, or renviron_read() in queries/unset_all. Path functions reject unknown arguments. In scoped_path_r(), these are path components.}
}
\value{The saved path, invisibly, or NULL if cancelled.}
\description{Replace the entire file with R-compatible literal values after validating all input. Prepare a temporary file in the same directory and replace the destination, retaining existing file permissions. Does not change the current session.}
\details{Input values are literal, including dollar-brace expressions. Names must be portable identifiers. NUL bytes, invalid UTF-8, multiline values and encoded lines over 99900 bytes are rejected. The destination directory must exist and symbolic links are not accepted as write targets. New files use mode 0600 where supported; inherited Windows ACLs also apply. Existing permissions are retained. Snapshot checks detect intervening changes but do not provide a lock between concurrent writers. Coordinate one writer per file.}
\examples{
path <- tempfile()
renviron_save(list(RNV_SAVE_DEMO = "one=two", RNV_EMPTY = ""),
              .file = path, confirm = FALSE)
renviron_list(.file = path)
unlink(path)
}
