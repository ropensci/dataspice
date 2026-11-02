#' Build a dataspice site
#'
#' @param path (character) Path to a JSON+LD file with dataspice metadata
#' @param template_path (character) Optional. Path to a template for
#'  \code{\link[whisker]{whisker.render}}
#' @param out_path (character) Optional. Path to write the site's `index.html`
#' to. Defaults to `docs/index.html`.
#' @param static_map (logical) Use a self-contained static map image instead of
#'  the default Leaflet map. Defaults to `FALSE`. The image includes latitude
#'  and longitude graticules and an Equal Earth locator inset.
#' @param static_map_method (character) Projection for the static map. Defaults
#'  to the built-in extent-aware method `"default"`. Other choices are
#'  `"crsuggest"`, `"projwiz"`, `"equalearth"`, or a custom
#'  PROJ string beginning with `"+proj="`. The default requires no projection-
#'  selection package.
#'
#' @section Lifecycle:
#' `static_map` is experimental. `r lifecycle::badge("experimental")`
#'
#' @return Nothing. Creates/overwrites `out_path`.
#' @export
#'
#' @examples
#' \dontrun{
#' # Create JSON+LD from a set of metadata templates
#' json <- write_json(biblio, access, attributes, creators)
#' build_site(json)
#' }
build_site <- function(
  path = file.path("data", "metadata", "dataspice.json"),
  template_path = system.file("template.html5", package = "dataspice"),
  out_path = file.path("docs", "index.html"),
  static_map = FALSE,
  static_map_method = "default"
) {
  stopifnot(is.logical(static_map))
  stopifnot(is.character(static_map_method))

  static_map_method <- tolower(trimws(static_map_method))
  if (!static_map_method %in% c(
    "default", "crsuggest", "projwiz", "equalearth"
  ) && !startsWith(static_map_method, "+proj=")) {
    stop(
      "`static_map_method` must be 'default', 'crsuggest', ",
      "'projwiz', 'equalearth', or a PROJ string beginning with '+proj='.",
      call. = FALSE
    )
  }

  if (static_map) {
    required_packages <- c("base64enc", "maps", "sf")
    if (identical(static_map_method, "crsuggest")) {
      required_packages <- c(required_packages, "crsuggest")
    } else if (identical(static_map_method, "projwiz")) {
      required_packages <- c(required_packages, "projWiz")
    }
    missing_packages <- required_packages[
      !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
    ]
    if (length(missing_packages)) {
      warning(
        paste0(
          "`static_map = TRUE` with method '",
          static_map_method,
          "' cannot create a static map because these suggested packages are ",
          "missing: ",
          paste(missing_packages, collapse = ", "),
          ". Install them with `install.packages(c(",
          paste(sprintf("\"%s\"", missing_packages), collapse = ", "),
          "))`. Continuing with the default Leaflet map."
        ),
        call. = FALSE
      )
      static_map <- FALSE
    }
  }

  data <- jsonld_to_mustache(path)
  data$staticmap <- static_map
  if (static_map) {
    data$staticmapdatauri <- static_map_data_uri(
      data$mapbox,
      method = static_map_method
    )
    place_name <- data$spatialCoverage$name
    if (
      is.null(place_name) ||
        !length(place_name) ||
        is.na(place_name) ||
        !nzchar(trimws(place_name))
    ) {
      place_name <- data$name
    }

    box <- as.numeric(strsplit(trimws(data$mapbox), "\\s+")[[1]])
    format_latitude <- function(value) {
      paste0(
        format(abs(value), trim = TRUE, scientific = FALSE),
        "\u00b0 ",
        if (value < 0) "S" else "N"
      )
    }
    format_longitude <- function(value) {
      paste0(
        format(abs(value), trim = TRUE, scientific = FALSE),
        "\u00b0 ",
        if (value < 0) "W" else "E"
      )
    }
    longitude_range <- if (box[4] <= box[2]) {
      paste(format_longitude(box[4]), "to", format_longitude(box[2]))
    } else {
      paste(
        format_longitude(box[4]),
        "eastward across the antimeridian to",
        format_longitude(box[2])
      )
    }
    data$staticmapalt <- paste0(
      "Map of ",
      place_name,
      ", covering ",
      format_latitude(box[3]),
      " to ",
      format_latitude(box[1]),
      " and ",
      longitude_range,
      "."
    )
  }

  out_dir <- dirname(out_path)

  if (!dir.exists(out_dir)) {
    dir.create(out_dir, recursive = TRUE)
  }

  output <- whisker::whisker.render(
    readLines(template_path),
    data
  )

  # Build site
  writeLines(output, out_path)
}
