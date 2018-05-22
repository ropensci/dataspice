
#' Convert a list object to JSON-LD
#'
#' @param context JSON-LD context; "http://schema.org"
#' @inheritParams jsonlite::toJSON
#' @importFrom jsonlite toJSON write_json
#' @export
#'
#' @examples
#'
#' x <- Thing(url = "http://schema.org")
#' as_jsonld(x)
#'
as_jsonld <-  function(x,
                       context = "http://schema.org",
                       pretty = TRUE,
                       auto_unbox = TRUE,
                       ...){

  out <- c(setNames(context, "@context"), x)
  jsonlite::toJSON(out,
                   pretty = pretty,
                   auto_unbox = auto_unbox,
                   ...)

}


#' Write a list out as object to JSON-LD
#'
#' @param context JSON-LD context; "http://schema.org"
#' @inheritParams jsonlite::write_json
#' @inheritParams jsonlite::toJSON
#' @importFrom stats setNames
#' @export
#'
#' @examples
#' x <- Thing(url = "http://schema.org")
#' tmp <- tempfile()
#' write_jsonld(x, tmp)
#'
write_jsonld <-  function(x, path, context = "http://schema.org",
                          pretty = TRUE, auto_unbox = TRUE, ...){

  out <- c(setNames(context, "@context"), x)
  jsonlite::write_json(out,
                       path = path,
                       pretty = pretty,
                       auto_unbox = auto_unbox,
                       ...)
}

