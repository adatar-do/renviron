\name{renviron_delete}
\alias{renviron_delete}
\title{Delete one session variable and optionally its file assignment}
\usage{
renviron_delete(key, .renviron = NULL, in_place = FALSE, ..., confirm = TRUE)
}
\arguments{
\item{key}{One portable environment variable name.}
\item{.renviron}{A named list or named character vector. NULL reads the selected file. When supplied to a persistent editor, the modified list replaces the whole file.}
\item{in_place}{Also save the file. The default is FALSE. Add/delete still modify the selected session key.}
\item{...}{Arguments for renviron_path() in writers, or renviron_read() in queries/unset_all. Path functions reject unknown arguments. In scoped_path_r(), these are path components.}
\item{confirm}{Request interactive confirmation before writing. Scripts must explicitly pass FALSE. Cancellation leaves the file and session unchanged.}
}
\value{The remaining named list, invisibly, or the original list if cancelled.}
\description{Remove only the selected key. Editing, line preservation and cancellation follow renviron_add().}
\details{Without a supplied list, persistent add/delete edits only the selected key, removes its duplicate assignments, and retains other comments, blank lines and expressions. Line endings are normalized to LF and UTF-8. With a supplied list, the modified list replaces the whole document. Other dependent session variables are not recalculated. The returned list retains pre-edit resolved values except for the edited key; read again for recalculated file values.

Input values are literal, including dollar-brace expressions. Names must be portable identifiers. NUL bytes, invalid UTF-8, multiline values and encoded lines over 99900 bytes are rejected. The destination directory must exist and symbolic links are not accepted as write targets. New files use mode 0600 where supported; inherited Windows ACLs also apply. Existing permissions are retained. Snapshot checks detect intervening changes but do not provide a lock between concurrent writers. Coordinate one writer per file.}
\examples{
previous <- Sys.getenv("RNV_DELETE_DEMO", unset = NA_character_)
values <- renviron_delete("RNV_DELETE_DEMO", .renviron = list())
if (!is.na(previous)) Sys.setenv(RNV_DELETE_DEMO = previous)
}
