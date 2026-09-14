\name{renviron_unset_all}
\alias{renviron_unset_all}
\title{Unset selected keys declared in a file}
\usage{
renviron_unset_all(...)
}
\arguments{
\item{...}{Arguments for renviron_path() in writers, or renviron_read() in queries/unset_all. Path functions reject unknown arguments. In scoped_path_r(), these are path components.}
}
\value{NULL, invisibly.}
\description{Read without loading and unset only the resulting keys in the current session. Does not modify the file or unrelated environment variables.}
\details{Reading supports quotes, equals signs, UTF-8, full-line comments and native R variable references with defaults. The optional export prefix is accepted as an extension. Bare KEY= is ignored; quoted empty values retain a declared key and an empty string in the returned list. Windows may represent empty process variables as unset. An unquoted expansion producing an empty value may be ignored by R and preserve an inherited value. A trailing hash belongs to the value. Reads start a separate R process with --vanilla and a 60-second timeout; reuse a returned list when querying many keys. Values are resolved, not raw file expressions.}
\examples{
path <- tempfile()
writeLines(character(), path)
renviron_unset_all(.file = path)
unlink(path)
}
