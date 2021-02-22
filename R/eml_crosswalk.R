#' Crosswalk functions for `as_eml`

#' Crosswalk a Schema.org/Person
#' @param creator (list) A creator
crosswalk_Person <- function(creator) {
  list("individualName" = list(
    givenName = creator$givenName,
    surName = creator$familyName
  ),
  organizationName = ifelse("affiliation" %in% names(creator),
                            creator$affiliation,
                            list()),
  electronicMailAddress = creator$email,
  userId = creator$id # Will be invalid because we don't capture directory
  )
}
#' Crosswalk a Schema.org/Organization
#' @param creator (list) A creator
crosswalk_Organization <- function(creator) {
  list("organizationName" = creator$name)
}

#' Crosswalk a Schema.org/creator
#' @param creator (list) A creator
crosswalk_creator <- function(creator) {
  if (!("type" %in% names(creator))) {
    warning("Failed to crosswalk creator ",
            creator,
            " because it needs a type.")
    return(list())
  }

  if (creator$type == "Person") {
    crosswalk_Person(creator)
  } else if (creator$type == "Organization") {
    crosswalk_Organization(creator)
  } else {
    warning("Failed to crosswalk creator ",
            creator, "
            because it needs a type of Person or Organization")

    list()
  }
}

#' Crosswalk a Schema.org/distribution
#' @param distribution (list) A distribution
crosswalk_distribution <- function(distribution) {
  list(entityName = distribution$name,
       physical = list(objectName = distribution$name,
                       dataFormat = list(
                         externallyDefinedFormat = list(
                           formatName = distribution$encodingFormat
                         )),
                       distribution = list(
                         online = list(
                           url = distribution$contentUrl
                         ))))
}

#' Convert a date(time) of unknown format into EML
#'
#' A quick and dirty crosswalk of an unknown date(time) input to EML that really
#' only works for ISO8601 input. All other formats will fail and be returned
#' as-is as a `calendarDate`. From there the user will need to do a conversion
#' themselves.
#'
#' @param input (character) Some unknown date(time) input
#'
#' @return (list) A `list` with members `calendarDate` and `time`. `time` will
#' be `NULL` if parsing fails or if the time string inside `input` isn't
#' ISO8601
crosswalk_datetime <- function(input) {
  if (!is.character(input) || nchar(input) < 0) {
    return(list(calendarDate = NULL, time = NULL))
  }

  match <- gregexpr("(\\d{4}-\\d{2}-\\d{2})[ T](\\d+:\\d+:\\d+.*)",
                    input,
                    perl = TRUE)[[1]]

  # Fail by returning the result as a calendarDate
  if (attr(match, "match.length") == -1) {
    return(list(calendarDate = input, time = NULL))
  }

  result <- list(calendarDate = NULL,
                 time = NULL)

  capture_start <- attr(match, "capture.start")[1,]
  capture_length <- attr(match, "capture.length")[1,]

  if (capture_start[1] >= 1) {
    result$calendarDate <- substr(input,
                                  capture_start[1],
                                  capture_start[1] + capture_length[1] - 1)
  }

  if (capture_start[2] >= 1) {
    result$time <- substr(input,
                          capture_start[2],
                          capture_start[2] + capture_length[2] - 1)
  }

  result
}

# Crosswalk mappings table for dataspice -> EML 2.2.0. Called by `crosswalk`
# from inside `as_eml`.
mappings <- list(
  "name" = list(
    from = "name",
    to = "title",
    transform = function(title) {
      title
    }
  ),
  "description" = list(
    from = "description",
    to = "abstract",
    transform = function(abstract) {
      abstract
    }
  ),
  "datePublished" = list(
    from = "datePublished",
    to = "pubDate",
    transform = function(pubDate) {
      out <- crosswalk_datetime(pubDate)

      out$dateTime
    }
  ),
  "keywords" = list(
    from = "keywords",
    to = "keywordSet",
    transform = function(keywords) {
      lapply(keywords, function(keyword) {
        list("keyword" = keyword)
      })
    }
  ),
  "creator" = list(
    from = "creator",
    to = "creator",
    transform = function(creators) {
      lapply(creators, function(creator) {
        crosswalk_creator(creator)
      })
    }
  ),
  "temporalCoverage" = list(
    from = "temporalCoverage",
    to = "temporalCoverage",
    transform = function(coverage) {
      if (is.null(coverage)) {
        return(list())
      }

      parts <- strsplit(coverage, "/")

      if (length(parts) != 1 && length(parts[[1]]) !=  2) {
        warning("Failed to parse temporalCoverage of '",
                coverage,
                "'. Excluded from EML.")
        return(list())
      }

      list(rangeOfDates = list(
        beginDate = crosswalk_datetime(parts[[1]][[1]]),
        endDate = crosswalk_datetime(parts[[1]][[1]])))
    }
  ),
  "spatialCoverage" = list(
    from = "spatialCoverage",
    to = "boundingCoordinates",
    transform = function(coverage) {
      if (is.null(coverage)) {
        return(list())
      }

      parts <- strsplit(coverage$geo$box, "[ ]+")

      if (length(parts) != 1 && length(parts[[1]]) != 4) {
        warning("Failed to parse spatialCoverage of '",
                coverage,
                "'. Excluded from EML.")
        return(list())
      }

      list(geographicDescription = "Placeholder",
           boundingCoordinates = list(
             westBoundingCoordinate = parts[[1]][4],
             eastBoundingCoordinate = parts[[1]][2],
             northBoundingCoordinate = parts[[1]][1],
             southBoundingCoordinate = parts[[1]][3]))
    }
  ),
  "distribution" = list(
    from = "distribution",
    to = "dataTable",
    transform = function(dist) {
      lapply(dist, crosswalk_distribution)
    }
  )
)

#' Crosswalk a term
#'
#' @param doc (list) A `dataspice` document as a `list`
#' @param term (character) The term to crosswalk.
#'
#' @return (list) The result of the crosswalk. May be an empty `list` on
#' failure.
crosswalk <- function(doc, term) {
  if (!(term %in% names(mappings))) {
    warning("The term '", term, "', was not found in mappings table ",
            "and won't be included in the output.")

    return(list())
  }

  info <- mappings[[term]]
  info$transform(doc[[info$from]])
}

#' Crosswalk `dataspice` variables to EML
#'
#' See \code{\link[EML]{set_attributes}} for more information on what must be
#' filled out after this is run in order to get a valid EML `attributeList`.
#'
#' @param spice (list) Your `dataspice` metadata
#'
#' @return (data.frame) A partial EML attributes table
#'
#' @examples
#' \dontrun{
#' # Load an example dataspice JSON that comes installed with the package
#' spice <- system.file(
#'   "examples", "annual-escapement.json",
#'   package = "dataspice")
#'
#' # Convert it to EML (notice the warning)
#' eml_doc <- suppressWarnings({spice_to_eml(spice)})
#' attributes <- crosswalk_variables(spice)
#'
#' # Now fill in the attributes data.frame. See `EML::set_attributes`.
#'
#' # And last, set the attributes on our EML document
#' eml_doc$dataset$dataTable[[1]]$attributeList <-
#'   EML::set_attributes(attributes)
#' }
crosswalk_variables <- function(spice) {
  if (is.character(spice)) {
    doc <- jsonlite::read_json(spice)
  } else if (is.list(spice)) {
    doc <- spice
  }

  if (!("variableMeasured" %in% names(doc))) {
    stop("Input document contains no variables")
  }

  do.call(rbind, lapply(doc$variableMeasured, function(var) {
    data.frame(attributeName = var$name,
               attributeDefinition = var$description)
  }))
}
