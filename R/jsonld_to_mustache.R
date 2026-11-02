#' Parse spatialCoverage section for use in a Leaflet map
#'
#' Also returns table rows for displaying spatial coverage properties.
#'
#' @param spatialCoverage (list) spatialCoverage section of the JSONLD
#'
#' @return (list) Template-specific variables for Leaflet and spatial coverage text
parse_spatialCoverage <- function(spatialCoverage) {
  # Keep the map available for every dataset; unsupported shapes have no
  # drawable polygon, but their coverage properties are still rendered.
  result <- list(spatialCoverageRows = spatial_coverage_rows(spatialCoverage),
                 mapcenterstring = "[0, 0]",
                 mappolystring = "[]")

  # The current map implementation understands only Schema.org GeoShape boxes.
  if (is.list(spatialCoverage) && !is.null(spatialCoverage$geo) &&
      is.list(spatialCoverage$geo) &&
      identical(spatialCoverage$geo$type %||% spatialCoverage$geo$`@type`, "GeoShape") &&
      is.character(spatialCoverage$geo$box) &&
      length(spatialCoverage$geo$box) == 1L) {
    coordinates <- suppressWarnings(as.numeric(
      stringr::str_split(stringr::str_trim(spatialCoverage$geo$box), "[[:space:]]+")[[1]]))
    if (length(coordinates) == 4L && all(is.finite(coordinates))) {
      map <- parse_GeoShape_box(spatialCoverage$geo$box)
      result$mapbox <- map$mapbox
      result$mapcenterstring <- map$mapcenterstring
      result$mappolystring <- map$mappolystring
    }
  }

  result
}

`%||%` <- function(x, y) if (is.null(x)) y else x

# Flatten nested JSON-LD properties into table rows while retaining their path.
spatial_coverage_rows <- function(x, prefix = "") {
  if (is.null(x) || !length(x)) {
    if (nzchar(prefix)) return(list())
    return(list(list(label = "Coverage", value = "No spatial coverage specified.")))
  }

  if (is.atomic(x)) {
    value <- paste(as.character(x), collapse = ", ")
    return(list(list(label = if (nzchar(prefix)) prefix else "Coverage",
                    value = value)))
  }

  if (!is.list(x)) {
    return(list(list(label = if (nzchar(prefix)) prefix else "Coverage",
                    value = as.character(x))))
  }

  if (is.null(names(x))) {
    rows <- list()
    for (i in seq_along(x)) {
      item_prefix <- if (nzchar(prefix)) paste0(prefix, " (", i, ")") else
        paste("Coverage", i)
      rows <- c(rows, spatial_coverage_rows(x[[i]], item_prefix))
    }
    return(rows)
  }

  rows <- list()
  for (field in names(x)) {
    value <- x[[field]]
    if (is.null(value)) next
    label <- gsub("([a-z])([A-Z])", "\\1 \\2", field)
    label <- paste0(toupper(substr(label, 1, 1)), substr(label, 2, nchar(label)))
    path <- if (nzchar(prefix)) paste(prefix, label, sep = " / ") else label
    rows <- c(rows, spatial_coverage_rows(value, path))
  }
  if (length(rows)) rows else
    list(list(label = "Coverage", value = "Spatial coverage information is provided."))
}

#' Parse spatialCoverage$geo$box section for use in a Leaflet map
#'
#' @param box (list) spatialCoverage$geo$box section of the JSONLD
#'
#' @return (list) Template-specific variables for Leaflet
parse_GeoShape_box <- function(box) {
  tokens <- stringr::str_split(stringr::str_trim(box), "[[:space:]]+")[[1]]
  tokens <- suppressWarnings(as.numeric(tokens))
  if (length(tokens) != 4L || any(!is.finite(tokens))) {
    stop(
      "Failed to parse box in spatialCoverage$geo$box of '",
      box, "'.",
      call. = FALSE)
  }

  list(
    mapbox = box,
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
