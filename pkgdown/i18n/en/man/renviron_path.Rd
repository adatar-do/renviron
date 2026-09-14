\name{renviron_path}
\alias{renviron_path}
\title{Resolve the configuration file path}
\usage{
renviron_path(
  scope = c("user", "project"),
  .file = ".Renviron",
  verbosity = 1,
  ...,
  project = getwd(),
  user = path.expand("~")
)
}
\arguments{
\item{scope}{Scopes to search in order: user and project. The default order is user, then project. scoped_path_r() accepts a single scope and defaults to user.}
\item{.file}{A filename relative to the selected scope, or an explicit absolute path.}
\item{verbosity}{0 suppresses the missing-file message; 1 shows it.}
\item{...}{Arguments for renviron_path() in writers, or renviron_read() in queries/unset_all. Path functions reject unknown arguments. In scoped_path_r(), these are path components.}
\item{project}{Project directory, default getwd(). No project-root autodetection is performed.}
\item{user}{User directory, default the R home directory. Supplying it explicitly disables the R_ENVIRON_USER override in renviron_path().}
}
\value{An absolute path. If no file exists, return the first candidate path so a file can be created.}
\description{Search scopes in the supplied order without merging files or changing the active project. Project scope defaults to the current working directory.}
\details{An absolute .file takes precedence. Otherwise the first existing file in scope order is selected; no files are merged. If none exists, the first candidate is returned. R_ENVIRON_USER only redirects the default .Renviron in user scope when user is omitted. Custom filenames are not redirected. Use scope = c("project", "user") to prefer project files. Project scope means getwd() or the supplied project directory.}
\examples{
renviron_path("project", project = tempdir())
}
