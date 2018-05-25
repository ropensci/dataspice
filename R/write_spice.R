#' write_spice
#'
#' @param path location of metadata files
#' @param ... additional arguments to [jsonlite::toJSON()]
#'
#' @return a json-ld file at the path specified
#' @export
#' @importFrom readr read_csv
#' @importFrom purrr pmap
#' @importFrom dplyr rename
write_spice <- function(path = "data/metadata", ...) {

  biblio <- readr::read_csv(file.path(path, "biblio.csv"))
  attributes <- readr::read_csv(file.path(path, "attributes.csv"))
  access <- readr::read_csv(file.path(path, "access.csv"))
  creators <- readr::read_csv(file.path(path, "creators.csv"))

  # Validate the CSVs
  validate_biblio(biblio)
  validate_attributes(attributes)
  validate_access(access)
  validate_creators(creators)


  #fileName,name,contentUrl,fileFormat
  access <- access[ !names(access)=="fileName" ]

  distribution <- purrr::pmap(access,
    function(name = NULL, contentUrl = NULL, fileFormat = NULL){
    list(type = "DataDownload",
         name = name,
         contentUrl = contentUrl,
         fileFormat = fileFormat)
  })

  attributes <- attributes[ !names(attributes)=="fileName" ]
  attributes <- dplyr::rename(attributes, value = variableName)
  variableMeasured <-
    purrr::pmap(attributes,
                PropertyValue)

  authors <- purrr::pmap(creators, Person)


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
    variableMeasured = variableMeasured,
    distribution = distribution)

  write_jsonld(Dataset, file.path(path, "dataspice.json"))


}
