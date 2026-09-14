\name{renviron_exists}
\alias{renviron_exists}
\title{Check whether a variable is declared}
\usage{
renviron_exists(key, .renviron = NULL, ...)
}
\arguments{
\item{key}{One portable environment variable name.}
\item{.renviron}{A named list or named character vector. NULL reads the selected file. When supplied to a persistent editor, the modified list replaces the whole file.}
\item{...}{Arguments for renviron_path() in writers, or renviron_read() in queries/unset_all. Path functions reject unknown arguments. In scoped_path_r(), these are path components.}
}
\value{TRUE or FALSE.}
\description{Check key presence, including a declared empty value, without modifying the session.}
\details{Reading supports quotes, equals signs, UTF-8, full-line comments and native R variable references with defaults. The optional export prefix is accepted as an extension. Bare KEY= is ignored; quoted empty values retain a declared key and an empty string in the returned list. Windows may represent empty process variables as unset. An unquoted expansion producing an empty value may be ignored by R and preserve an inherited value. A trailing hash belongs to the value. Reads start a separate R process with --vanilla and a 60-second timeout; reuse a returned list when querying many keys. Values are resolved, not raw file expressions.}
\examples{
renviron_exists("RNV_EXAMPLE", .renviron = list(RNV_EXAMPLE = ""))
}
