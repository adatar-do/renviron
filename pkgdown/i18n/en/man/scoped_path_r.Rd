\name{scoped_path_r}
\alias{scoped_path_r}
\title{Construct a path in a single scope}
\usage{
scoped_path_r(
  scope = c("user", "project"),
  ...,
  envvar = NULL,
  project = getwd(),
  user = path.expand("~")
)
}
\arguments{
\item{scope}{Scopes to search in order: user and project. The default order is user, then project. scoped_path_r() accepts a single scope and defaults to user.}
\item{...}{Arguments for renviron_path() in writers, or renviron_read() in queries/unset_all. Path functions reject unknown arguments. In scoped_path_r(), these are path components.}
\item{envvar}{Optional environment variable that overrides the user-scoped path.}
\item{project}{Project directory, default getwd(). No project-root autodetection is performed.}
\item{user}{User directory, default the R home directory. Supplying it explicitly disables the R_ENVIRON_USER override in renviron_path().}
}
\value{An absolute path.}
\description{Compatibility helper for one scope. Use renviron_path() to search multiple scopes. Does not activate or change a project.}
\details{An absolute .file takes precedence. Otherwise the first existing file in scope order is selected; no files are merged. If none exists, the first candidate is returned. R_ENVIRON_USER only redirects the default .Renviron in user scope when user is omitted. Custom filenames are not redirected. Use scope = c("project", "user") to prefer project files. Project scope means getwd() or the supplied project directory.}
\examples{
scoped_path_r("project", "example.env", project = tempdir())
}
