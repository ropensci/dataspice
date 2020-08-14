#' Convert `dataspice` metadata to EML
#'
#' Performs an (imperfect) conversion of `dataspice` metadata to EML. It's
#' very likely you will get validation errors and need to fix them afterwards
#' but `spice_to_eml` is a good way to a richer metadata schema (EML) when
#' you're already using `dataspice` but need a richer metadata schema.
#'
#' @param spice (list) Your `dataspice` metadata. Uses
#' `data/metadata/dataspice.json` by default.
#'
#' @return (emld) The crosswalked `emld` object
#' @export
#'
#' @examples
#' # Load an example dataspice JSON that comes installed with the package
#' spice <- system.file(
#'   "examples", "annual-escapement.json",
#'   package = "dataspice")
#'
#' # And crosswalk it to EML
#' spice_to_eml(spice)
#'
#' # We can also create dataspice metadata from scratch and crosswalk it to EML
#' myspice <- list(
#'   name = "My example spice",
#'   creator = "Me",
#'   contact = "Me")
#' spice_to_eml(myspice)
spice_to_eml <- function(spice = file.path("data", "metadata", "dataspice.json")) {
  if (is.character(spice)) {
    if (!file.exists(spice)) {
      stop("Could not find dataspice JSON file at the path '", spice, "'")
    }

    doc <- jsonlite::read_json(spice)
  } else if (is.list(spice)) {
    doc <- spice
  } else {
    stop("spice must be either a path or a list object")
  }

  out <- list(
    dataset = list(
      title = crosswalk(doc, "name"),
      creator = crosswalk(doc, "creator"),
      abstract = crosswalk(doc, "description"),
      pubDate = crosswalk(doc, "datePublished"),
      coverage = list(
        temporalCoverage = crosswalk(doc, "temporalCoverage"),
        geographicCoverage = crosswalk(doc, "spatialCoverage")
      ),
      contact = crosswalk(doc, "creator"),
      dataTable = c(
        crosswalk(doc, "distribution")
      )
    ))

  # Warn about variableMeasured not being crosswalked
  if ("variableMeasured" %in% names(doc)) {
    warning("variableMeasured not crosswalked to EML because we don't have ",
            "enough information. Use `crosswalk_variables` to create the ",
            "start of an EML attributes table. See ?crosswalk_variables for ",
            "help.", call. = FALSE)
    message("You might want to run EML::eml_validate on the result at ",
            "this point and fix what validations errors are produced.",
            "You will commonly need to set `packageId`, `system`, and provide ",
            "`attributeList` elements for each `dataTable`.")
  }

  EML::as_emld(out)
}
