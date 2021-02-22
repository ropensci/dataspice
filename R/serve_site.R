#' Serve site
#'
#' @param path (character) Optional. Directory to serve. Defaults to
#'  \code{docs}.
#'
#' @return Nothing.
#' @export
#'
#' @examples
#' \dontrun{
#' # Build your site
#' json <- write_json(biblio, access, attributes, creators)
#' build_site(json)
#'
#' # Serve it
#' serve_site()
#' }
serve_site <- function(path = "docs") {
  if (!requireNamespace("servr")) {
    stop("Please install 'servr' to serve your site: install.packages('servr')",
         call. = FALSE)
  }

  servr::httd("docs")
}
