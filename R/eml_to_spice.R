get_entities <- function(eml,
                         entities = c(
                           "dataTable",
                           "spatialRaster",
                           "spatialVector",
                           "storedProcedure",
                           "view",
                           "otherEntity"),
                         level_id = "entityName") {
    entities <- entities[entities %in% names(eml$dataset)]

    # look for specific fields to determine if the entity needs to be listed
    # ("boxed") or not
    level_cond <- paste0(
      "~",
      paste(sprintf("!is.null(.x$%s)", level_id),
      collapse = " | "))
    purrr::map(entities, ~EML::eml_get(eml, .x)) %>%
        # restructure so that all entities are at the same level
        # use level id to determine if .x should be listed or not
        purrr::map_if(eval(parse(text = level_cond)), list) %>%
        unlist(recursive = FALSE)
}

get_access_spice <- function(x) {
    x %>%
        unlist() %>%
        tibble::enframe() %>%
        dplyr::mutate(name = dplyr::case_when(
            grepl("objectName", name) ~ "fileName",
            grepl("entityName", name) ~ "name",
            grepl("url", name) ~ "contentUrl",
            grepl("formatName", name) ~ "encodingFormat"
        )) %>%
        stats::na.omit() %>%
        dplyr::filter(value != "download") %>% #often also included as url
        tidyr::spread(name, value)
}

#' Get access from EML
#'
#' Return EML access in the dataspice access.csv format.
#'
#' @param eml (emld) an EML object
#' @param path (character) folder path for saving the table to disk
es_access <- function(eml, path = NULL) {
    entities <- get_entities(eml)
    access_entities <- lapply(entities, get_access_spice)

    out <- dplyr::bind_rows(access_entities)

    #reorder
    fields <- c("fileName", "name", "contentUrl", "encodingFormat")
    out <- out[, fields[fields %in% colnames(out)]]

    if (!is.null(path)) {
        if (!dir.exists(path)) {
            dir.create(path)
        }
        readr::write_csv(out, file.path(path, "access.csv"))
    }

    return(out)
}

get_attributes_spice <- function(x) {
  #reformat attributes to tabular format specified in dataspice
  #input a dataTable or otherEntity

  objName <- EML::eml_get(x, "objectName")
  objName <- ifelse(length(objName) == 2, objName[[1]], NA)

  attrList <- EML::eml_get(x, "attributeList")

  if (length(attrList) <= 1) {
    out <- dplyr::tibble(fileName = objName,
                         variableName = NA,
                         description = NA,
                         unitText = NA)
  } else {
    attr <- EML::get_attributes(attrList)

    if(is.null(attr$attributes$unit)) {
      attr$attributes$unit <- NA
    }

    #set datetime format as unitText if available
    if(!is.null(attr$attributes$formatString)) {
      na_units <- is.na(attr$attributes$unit)
      attr$attributes$unit[na_units] <- attr$attributes$formatString[na_units]
    }

    #get missing value info in text form:
    missing_val <- dplyr::tibble(
      missingValueCode = c(attr$attributes$missingValueCode, "NA"),
      missingValueCodeExplanation = c(
        attr$attributes$missingValueCodeExplanation,
        "NA")) %>%
      dplyr::distinct() %>%
      stats::na.omit()

    missing_val_text <- paste(missing_val$missingValueCode,
                              missing_val$missingValueCodeExplanation,
                              sep = " = ",
                              collapse = "; ")

    out <- dplyr::tibble(fileName = objName,
                         variableName = attr$attributes$attributeName,
                         description = paste0(
                           attr$attributes$attributeDefinition,
                           "; missing values: ",
                           missing_val_text),
                         unitText = attr$attributes$unit)
  }

  return(out)
}

#' Get attributes from EML
#'
#' Return EML attributes in the dataspice attributes.csv format.
#'
#' @param eml (emld) an EML object
#' @param path (character) folder path for saving the table to disk
#'
#' @importFrom readr write_csv
es_attributes <- function(eml, path = NULL) {
  entities <- get_entities(eml)
  attr_tables <- lapply(entities, get_attributes_spice)

  out <- dplyr::bind_rows(attr_tables) %>%
    dplyr::filter(!is.na(variableName))

  if(!is.null(path)) {
    if(!dir.exists(path)) {
      dir.create(path)
    }
    readr::write_csv(out, file.path(path, "attributes.csv"))
  }

  return(out)
}

#' Get biblio from EML
#'
#' Return EML biblio in the dataspice biblio.csv format.
#'
#' @param eml (emld) an EML object
#' @param path (character) folder path for saving the table to disk
es_biblio <- function(eml, path = NULL) {
  biblio_eml <- eml %>%
    unlist() %>%
    tibble::enframe() %>%
    dplyr::mutate(name = dplyr::case_when(
      grepl("dataset.title", name) ~ "title",
      grepl("abstract", name) ~ "description",
      grepl("pubDate", name) ~ "datePublished",
      grepl("packageId", name) ~ "identifier",
      grepl("keyword", name) ~ "keywords",
      grepl("intellectual", name) ~ "license",
      grepl("fund", name) ~ "funder",
      grepl("geographicDescription", name) ~ "geographicDescription",
      grepl("northBoundingCoordinate", name) ~ "northBoundCoord",
      grepl("eastBoundingCoordinate", name) ~ "eastBoundCoord",
      grepl("southBoundingCoordinate", name) ~ "southBoundCoord",
      grepl("westBoundingCoordinate", name) ~ "westBoundCoord",
      #wktString?
      grepl("beginDate|singleDateTime", name) ~ "startDate",
      grepl("endDate", name) ~ "endDate"
    )) %>%
    stats::na.omit() %>%
    dplyr::group_by(name) %>%
    dplyr::summarize(value = paste(value, collapse = "; ")) %>%
    tidyr::spread(name, value)

  #reorder
  fields <- c("title",
    "description",
    "datePublished",
    "citation",
    "keywords",
    "license",
    "funder",
    "geographicDescription",
    "northBoundCoord",
    "eastBoundCoord",
    "southBoundCoord",
    "westBoundCoord",
    "wktString",
    "startDate",
    "endDate")


  out <- biblio_eml[, fields[fields %in% colnames(biblio_eml)]]

  if(!is.null(path)) {
    if(!dir.exists(path)) {
      dir.create(path)
    }
    readr::write_csv(out, file.path(path, "biblio.csv"))
  }

  return(out)
}

#' Get creators from EML
#'
#' Return EML creators in the dataspice creators.csv format.
#'
#' @param eml (emld) an EML object
#' @param path (character) folder path for saving the table to disk
#'
#' @importFrom purrr discard
#' @importFrom tibble enframe
#' @importFrom tidyr spread
es_creators <- function(eml, path = NULL) {
  people <- get_entities(eml,
                         entities = c(
                           "creator",
                           "contact",
                           "associatedParty",
                           "metadataProvider"),
                         level_id = c("individualName", "organizationName"))
  if(!is.null(names(people))) {
    people <- people[names(people) == ""]
  }

  people_parsed <- lapply(people, function(x) {x %>%
      unlist() %>%
      tibble::enframe() %>%
      dplyr::mutate(name = dplyr::case_when(
        grepl("userId.userId", name) ~ "id",
        grepl("givenName", name) ~ "givenName",
        grepl("surName", name) ~ "familyName",
        grepl("organizationName", name) ~ "affiliation",
        grepl("electronicMailAddress", name) ~ "email"
      )) %>%
      stats::na.omit() %>%
      # merge fields together if duplicated (ex: givenName1 & givenName2)
      dplyr::group_by(name) %>%
      dplyr::summarize(value = paste(value, collapse = " ")) %>%
      tidyr::spread(name, value) %>%
      # Merge givenName and familyName into name
      dplyr::mutate(name = paste(givenName, familyName)) %>%
      dplyr::select(-givenName, -familyName)
  })

  out <- dplyr::bind_rows(people_parsed) %>%
    dplyr::distinct()

  fields <- c("id", "name", "affiliation", "email")
  out <- out[, fields[fields %in% colnames(out)]]

  if(!is.null(path)) {
    if(!dir.exists(path)) {
      dir.create(path)
    }
    readr::write_csv(out, file.path(path, "creators.csv"))
  }

  return(out)
}

#' Create dataspice metadata tables from EML
#'
#' @param eml (emld) An EML object
#' @param path (character) Folder path for saving the tables to disk
#'
#' @return A list with names `attributes`, `access`, `biblio`, and `creators`.
#' Optionally, if `path` is specified, saves the four tables as `CSV` files.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # First, load up an example EML record
#' library(EML)
#'
#' eml_path <- system.file(
#'  file.path("example-dataset", "broodTable_metadata.xml"),
#'  package = "dataspice")
#' eml <- read_eml(eml_path)
#'
#'
#' # Generate the four dataspice tables
#' my_spice <- eml_to_spice(eml)
#'
#' # Or save them as a file
#' # Generate the four dataspice tables
#' eml_to_spice(eml, ".")
#' }
eml_to_spice <- function(eml, path = NULL) {
  out <- list(attributes = es_attributes(eml, path),
              access = es_access(eml, path),
              biblio = es_biblio(eml, path),
              creators = es_creators(eml, path))

  invisible(out)
}
