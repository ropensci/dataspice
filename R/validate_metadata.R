#' Validate biblio.csv
#'
#' @param biblio (data.frame) A \code{data.frame} read in from \code{biblio.csv}
#'
#' @return Nothing. Side-effect: Can \code{stop} execution if validation fails.
validate_biblio <- function(biblio) {
  stopifnot(is.data.frame(biblio))

  if (nrow(biblio) <= 0) {
    print(biblio)
    stop(call. = FALSE,
         "biblio.csv must have at least one row of data")
  }
}

#' Validate attributes.csv
#'
#' @param attributes (data.frame) A \code{data.frame} read in from
#' \code{attributes.csv}
#'
#' @return Nothing. Side-effect: Can \code{stop} execution if validation fails.
validate_attributes <- function(attributes) {
  stopifnot(is.data.frame(attributes))

  if (nrow(attributes) <= 0) {
    stop(call. = FALSE,
         "attributes.csv must have at least one row of data")
  }
}

#' Validate access.csv
#'
#' @param access (data.frame) A \code{data.frame} read in from \code{access.csv}
#'
#' @return Nothing. Side-effect: Can \code{stop} execution if validation fails.
validate_access <- function(access) {
  stopifnot(is.data.frame(access))

  if (nrow(access) <= 0) {
    stop(call. = FALSE,
         "access.csv must have at least one row of data")
  }
}

#' Validate creators.csv
#'
#' @param creators (data.frame) A \code{data.frame} read in from \code{creators.csv}
#'
#' @return Nothing. Side-effect: Can \code{stop} execution if validation fails.
validate_creators <- function(creators) {
  stopifnot(is.data.frame(creators))

  if (nrow(creators) <= 0) {
    stop(call. = FALSE,
         "creators.csv must have at least one row of data")
  }
}
