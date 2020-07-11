
crosswalk_Person <- function(creator) {
  list("individualName" = list(
    givenName = creator$givenName,
    surName = creator$familyName
  ),
  organizationName = ifelse("affiliation" %in% names(creator),
                            creator$affiliation$name,
                            list()),
  electronicMailAddress = creator$email,
  userId = creator$id # Will be invalid because we don't capture directory
  )
}

crosswalk_Organization <- function(creator) {
  list("organizationName" = creator$name)
}

crosswalk_creator <- function(creator) {
  if (!("type" %in% names(creator))) {
    warning("Failed to crosswalk creator", creator)
    return(list())
  }

  if (creator$type == "Person") {
    crosswalk_Person(creator)
  } else if (creator$type == "Organization") {
    crosswalk_Organization(creator)
  } else {
    warning("Failed to crosswalk creator", creator)

    list()
  }
}

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
                         )
                       )))
}

# Crosswalk mappings table for dataspice -> EML 2.2.0. Called by `crosswalk`
# from inside `as_emld`.
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
      pubDate
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
        beginDate = list(
          calendarDate = parts[[1]][1]),
        endDate = list(
          calendarDate = parts[[1]][2])))
    }
  ),
  "spatialCoverage" = list(
    from = "spatialCoverage",
    to = "boundingCoordinates",
    transform = function(coverage) {
      if (is.null(coverage)) {
        return(list())
      }

      parts <- coverage$geo$box

      if (length(parts) != 1 && length(parts[[1]]) != 4) {
        warning("Failed to parse spatialCoverage of '",
                coverage,
                "'. Excluded from EML.")
        return(list())
      }

      list(geographicDescription = "Placeholder",
           boundingCoordinates = list(
             westBoundingCoordinates = parts[[1]][4],
             eastBoundingCoordinates = parts[[1]][2],
             northBoundingCoordinates = parts[[1]][1],
             southBoundingCoordinates = parts[[1]][3]))
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
#' @param term (character) The term to crosswalk
#' @param verbose (logical) Whether or not to display extra information during
#' conversion. Defaults to `FALSE`.
#'
#' @return (list) The result of the crosswalk. May be an empty `list` on
#' failure.
crosswalk <- function(doc, term, verbose = FALSE) {
  if (!(term %in% names(mappings))) {
    warning("The term '", term, "', was not found in mappings table ",
            "and won't be included in the output.")

    return(list())
  }

  if (verbose) {
    message("Crosswalking '", term, "'")
  }

  info <- mappings[[term]]
  info$transform(doc[[info$from]])
}
