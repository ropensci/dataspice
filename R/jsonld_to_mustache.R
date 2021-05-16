#' Parse spatialCoverage section for use in a Leaflet map
#'
#' @param spatialCoverage (list) spatialCoverage section of the JSONLD
#'
#' @return (list) Template-specific variables for Leaflet
parse_spatialCoverage <- function(spatialCoverage) {
  json <- list(showmap = "geo" %in% names(spatialCoverage) &&
                 "type" %in% names(spatialCoverage$geo),
               isgeoshape = ifelse(
                 spatialCoverage$geo$type == "GeoShape",
                 TRUE,
                 FALSE),
               isgeopoints = ifelse(
                 spatialCoverage$geo$type == "GeoPoints",
                 TRUE,
                 FALSE))

  if (json$isgeoshape) {
    json <- c(json, parse_GeoShape_box(spatialCoverage$geo$box))
  } else if (json$isgeopoints) {
    json <- c(json, parse_GeoShape_box(spatialCoverage$geo$points))

  } else {
    stop("Specified spatialCoverage not supported.", call. = FALSE)
  }

  json
}

#' Parse spatialCoverage$geo$box section for use in a Leaflet map
#'
#' @param box (list) spatialCoverage$geo$box section of the JSONLD
#'
#' @return (list) Template-specific variables for Leaflet
parse_GeoShape_box <- function(box) {
  tokens <- stringr::str_split(box, " ")

  if (!length(tokens) == 1) {
    stop(
      "Failed to parse box in spatialCoverage$geo$box of '",
      box, "'.",
      call. = FALSE)
  }

  tokens <- vapply(tokens[[1]], as.numeric, 0.0, USE.NAMES = FALSE)

  list(
    mapcenterstring =
      paste0(
        "[",
        (tokens[1] + tokens[1] + tokens[3] + tokens[3]) / 4,
        ", ",
        (tokens[2] + tokens[2] + tokens[4] + tokens[4]) / 4,
        "]"),
    mappolystring =
      paste0(
        "[",
        "[ ", tokens[1], ", ", tokens[2], "], ",
        "[ ", tokens[3], ", ", tokens[2], "], ",
        "[ ", tokens[3], ", ", tokens[4], "], ",
        "[ ", tokens[1], ", ", tokens[4], "]",
        "]"))
}

parse_GeoShape_points <- function(points) {
  stop("Not implemented.", call. = FALSE)
}

#' Convert JSONLD to a list suitable for Mustache templating
#'
#' @param path (character) Path to file on disk to convert
#'
#' @return (list) Mustache-appropriate list
jsonld_to_mustache <- function(path) {
  json <- jsonlite::read_json(path)

  # Append the raw JSON+LD to the data so we can insert it into the <head> tag
  json$jsonld <- readChar(path, nchars = file.size(path))

  # Split keywords from comma-separated to a list
  json$keywords <- lapply(
    stringr::str_split(json$keywords, ","),
    stringr::str_trim)

  # Split temporal coverage on the /
  tc <- stringr::str_split(json$temporalCoverage, "/")[[1]]
  json$beginDate <- tc[1]
  json$endDate <- tc[2]

  json <- c(json, parse_spatialCoverage(json$spatialCoverage))

  json
}
