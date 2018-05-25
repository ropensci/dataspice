#' Put metadata templates within a `metadata` subdirectory
#'
#'
#' @param dir Directory containing data, within which a `metadata` subdirectory
#'   will be created. Defaults to `data`.
#' @export
#'
#' @examples
#' \dontrun{
#' create_spice()
#'
#' # Create templates from the data in a folder other than `data`
#' create_spice("my_data")
#' }
create_spice <- function(dir = "data") {
  path <- file.path(dir, "metadata")
  fs::dir_create(path)
  template_folder <- system.file("templates/", package = "dataspice")
  templates <- file.path(template_folder, list.files(template_folder))
  file.copy(templates, path)
  invisible(templates)
}
