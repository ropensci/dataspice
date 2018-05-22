library(dplyr)

biblio <- readr::read_csv("inst/metadata-tables/biblio.csv")
attributes <- readr::read_csv("inst/metadata-tables/attributes.csv")
access <- readr::read_csv("inst/metadata-tables/access.csv")
creators <- readr::read_csv("inst/metadata-tables/creators.csv")


variableMeasured <- attributes  %>%
  select(-fileName) %>% 
  purrr::pmap(dataspice:::PropertyValue)

authors <- creators  %>%
  purrr::pmap(dataspice:::Person)


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
  
 
Dataset %>% jsonlite::toJSON(pretty=TRUE, auto_unbox = TRUE)


