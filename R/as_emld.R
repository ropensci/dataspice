#' Convert `dataspice` metadata to EML
#'
#' Performs an imperfect conversion of `dataspice` metadata to EML 2.2.0. It's
#' very likely you will get validation errors and need to fix them afterwards.
#'
#' @param spice (list)
#' @param verbose (logical) Whether or not to display extra information during
#' conversion. Defaults to `FALSE`.
#'
#' @return (emld) The conerted `emld` object
#' @export
#'
#' @examples
#' spice <- system.file("examples", "annual-escapement.json", package = "dataspice")
#' as_emld(spice)
as_emld <- function(spice, verbose = FALSE) {
  if (is.character(spice)) {
    doc <- jsonlite::read_json(spice)
  } else if (is.list(spice)) {
    doc <- spice
  }

  out <- list(dataset = list(
    title = crosswalk(doc, "name", verbose),
    creator = crosswalk(doc, "creator", verbose),
    abstract = crosswalk(doc, "description", verbose),
    pubDate = crosswalk(doc, "datePublished", verbose),
    coverage = list(
      temporalCoverage = crosswalk(doc, "temporalCoverage", verbose),
      geographicCoverage = crosswalk(doc, "spatialCoverage", verbose)
    ),
    contact = crosswalk(doc, "creator", verbose),
    dataTable = c(
      crosswalk(doc, "distribution", verbose)
    )
  ))

  # Warn about variableMeasured not being crosswalked
  if ("variableMeasured" %in% names(doc)) {
    warning("variableMeasured not converted to EML because we don't have ",
            "enough information. Use `create_attributes` to start building ",
            "an attributes table.")
  }

  EML::as_emld(out)
}
