#' Build a dataspice site
#'
#' @param path (character) Path to a JSON+LD file with dataspice metadata
#' @param template_path (character) Optional. Path to a template for \code{\link[whisker]{whisker.render}}
#'
#' @return Nothing. Creates/overwrites \code{docs/index.html}
#' @export
#'
#' @examples
#' \dontrun{
#' # Create JSON+LD from a set of metadata templates
#' json <- write_json(biblio, access, attributes, creators)
#' build_site(json)
#' }
build_site <- function(path = "data/metadata/dataspice.json",
                       template_path = system.file("template.html5",
                                                   package = "dataspice")) {
  data <- jsonld_to_mustache(path)

    # Make docs dir if not present
  if (!file.exists("docs")) {
    dir.create("docs")
  }

  output <- whisker::whisker.render(
    readLines(template_path),
    data)

  # Build site
  writeLines(output, "docs/index.html")
}
