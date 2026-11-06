#' Build a dataspice site
#'
#' @param path (character) Path to a JSON+LD file with dataspice metadata
#' @param template_path (character) Optional. Path to a template for
#'  \code{\link[whisker]{whisker.render}}
#' @param out_path (character) Optional. Path to write the site's `index.html`
#' to. Defaults to `docs/index.html`.
#' @param static_map (logical) Use a self-contained static map image instead of
#'  the default Leaflet map. Defaults to `FALSE`. The image includes latitude
#'  and longitude graticules and an Equal Earth locator inset. This argument is
#'  experimental and may change.
#' @param static_map_method (character) Projection for the static map. Defaults
#'  to the built-in extent-aware method `"default"`. Other choices are
#'  `"crsuggest"`, `"equalearth"`, or a custom
#'  PROJ string beginning with `"+proj="`. This argument is experimental and may
#'  change.
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

  static_map_method <- trimws(static_map_method)
  method_key <- tolower(static_map_method)
  if (method_key %in% c(
    "default", "crsuggest", "equalearth"
  )) {
    static_map_method <- method_key
  } else if (!startsWith(method_key, "+proj=")) {
    stop(
      "`static_map_method` must be 'default', 'crsuggest', ",
      "'equalearth', or a PROJ string beginning with '+proj='.",
      call. = FALSE
    )
  }

  if (static_map) {
    required_packages <- c("base64enc", "maps", "sf")
    if (identical(static_map_method, "crsuggest")) {
      required_packages <- c(required_packages, "crsuggest")
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
  bbox <- NULL
  if (static_map) {
    geo_type <- data$spatialCoverage$geo$type
    if (is.null(geo_type)) {
      geo_type <- data$spatialCoverage$geo$`@type`
    }
    if (identical(geo_type, "GeoPoints")) {
      stop(
        paste0(
          "`static_map = TRUE` requires a four-coordinate GeoShape box; ",
          "GeoPoints coverage cannot be rendered as a static map."
        ),
        call. = FALSE
      )
    }
    bbox <- parse_static_map_box(data$mapbox)
  }
  data$staticmap <- static_map
  if (static_map) {
    data$staticmapdatauri <- static_map_data_uri(
      bbox,
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
    longitude_range <- if (bbox$west <= bbox$east) {
      paste(format_longitude(bbox$west), "to", format_longitude(bbox$east))
    } else {
      paste(
        format_longitude(bbox$west),
        "eastward across the antimeridian to",
        format_longitude(bbox$east)
      )
    }
    data$staticmapalt <- paste0(
      "Map of ",
      place_name,
      ", covering ",
      format_latitude(bbox$south),
      " to ",
      format_latitude(bbox$north),
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
