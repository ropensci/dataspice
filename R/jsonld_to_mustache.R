#' Convert JSONLD to a list suitable for Mustache templating
#'
#' @param path (character) Path to file on disk to convert
#'
#' @return (list) Mustache-appropriate list
#' @export
#'
#' @examples
#' \dontrun{
#' json_path <- "myjson.json
#' data <- jsonld_to_mustache(json_path)
#' whisker::whisker_render("{{ keywords }}", data)
#' }
jsonld_to_mustache <- function(path) {
  json <- jsonlite::read_json(path)

  # Append the raw JSON+LD to the data so we can insert it into the <head> tag
  json$jsonld <- readChar(path, nchars = file.size(path))

  # Split keywords from comma-separated to a list
  json$keywords <- lapply(stringr::str_split(json$keywords, ","), stringr::str_trim)

  # Split temporal coverage on the /
  tc <- stringr::str_split(json$temporalCoverage, "/")[[1]]
  json$beginDate <- tc[1]
  json$endDate <- tc[2]

  json <- c(json, parse_geographic_coverage)

  json
}

parse_geographic_coverage <- function(geographicCoverage) {
  json <- list()
  json$mapcenterstring <- "[50, -150]"
  json$mappolystring <- "[[78, -131],[78, -171],[47, -171],[47, -131]]"
  json
}
