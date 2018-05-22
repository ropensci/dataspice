#' write_spice
#'
#' @param path location of metadata files
#' @param ... additional arguments to write json\code{\link{jsonlite::toJSON}}
#'
#' @return a json-ld file at the path specified
#' @export
#' @importFrom readr read_csv
#' @importFrom purrr pmap

write_spice <- function(path = "data/metadata", ...) {

  biblio <- readr::read_csv(file.path(path, "biblio.csv"))
  attributes <- readr::read_csv(file.path(path, "attributes.csv"))
  access <- readr::read_csv(file.path(path, "access.csv"))
  creators <- readr::read_csv(file.path(path, "creators.csv"))

  variableMeasured <-
    purrr::pmap(attributes[ !names(attributes)=="fileName" ],
                dataspice:::PropertyValue)

  authors <- purrr::pmap(creators, dataspice:::Person)

  Dataset <- list(
    type = "Dataset",
    name = biblio$title,
    creator = authors,
    description = biblio$description,
    datePublished = biblio$datePublished,
    keywords = strsplit(biblio$keywords, ", ")[[1]],
    funder = biblio$funder,
    temporalCoverage = paste(biblio$startDate, biblio$endDate, sep="/"),
    license = biblio$license,
    spatialCoverage = list(
      type = "Place",
      name = biblio$geographicDescription,
      geo = list(
        type = "GeoShape",
        box = paste(biblio$northBoundCoord, biblio$eastBoundCoord,
                    biblio$southBoundCoord, biblio$westBoundCoord)
      )
    ),
    variableMeasured = variableMeasured)

write_jsonld(Dataset, file.path(path, "dataspice.json"))

}
