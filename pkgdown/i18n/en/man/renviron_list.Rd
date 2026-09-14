\name{renviron_list}
\alias{renviron_list}
\title{List names with masked values}
\usage{
renviron_list(.renviron = NULL, ...)
}
\arguments{
\item{.renviron}{A named list or named character vector. NULL reads the selected file. When supplied to a persistent editor, the modified list replaces the whole file.}
\item{...}{Arguments for renviron_path() in writers, or renviron_read() in queries/unset_all. Path functions reject unknown arguments. In scoped_path_r(), these are path components.}
}
\value{A named character vector containing ***** for each variable, or character() if there are no variables.}
\description{Return only names and a constant mask without loading session variables. The mask reveals neither value contents nor length. It is not encryption.}
\details{Reading supports quotes, equals signs, UTF-8, full-line comments and native R variable references with defaults. The optional export prefix is accepted as an extension. Bare KEY= is ignored; quoted empty values retain a declared key and an empty string in the returned list. Windows may represent empty process variables as unset. An unquoted expansion producing an empty value may be ignored by R and preserve an inherited value. A trailing hash belongs to the value. Reads start a separate R process with --vanilla and a 60-second timeout; reuse a returned list when querying many keys. Values are resolved, not raw file expressions.}
\examples{
renviron_list(list(RNV_EXAMPLE = "demo", RNV_EMPTY = ""))
}
