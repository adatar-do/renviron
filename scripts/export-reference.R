source("renviron/scripts/bootstrap.R")
dir.create("artifacts/renviron-release", recursive = TRUE, showWarnings = FALSE)
pkgload::load_all("renviron", quiet = TRUE)
plain <- function(x) paste(unlist(x), collapse = "")
docs <- list()
for (file in list.files("renviron/man", "\\.Rd$", full.names = TRUE)) {
  fields <- list()
  for (node in tools::parse_Rd(file)) {
    tag <- attr(node, "Rd_tag")
    if (!is.null(tag) && tag %in% c("\\name", "\\alias", "\\usage", "\\examples"))
      fields[[substring(tag, 2)]] <- c(fields[[substring(tag, 2)]], plain(node))
  }
  docs[[basename(file)]] <- fields
}
api <- list()
for (name in setdiff(getNamespaceExports("renviron"), "%>%")) {
  fn <- get(name, asNamespace("renviron"))
  if (is.function(fn)) api[[name]] <- list(parameters = names(formals(fn)))
}
jsonlite::write_json(list(docs = docs, api = api), "artifacts/renviron-release/reference.json",
  auto_unbox = TRUE, pretty = TRUE)
