#' Put metadata templates within a `metadata` subdirectory
#'
#'
#' @param dir Directory containing data, within which a `metadata` subdirectory
#'   will be created
#' @export
#'
#' @examples
#' \dontrun{
#' create_spice(dir = "data")
#' }
create_spice <- function(dir) {
  path <- file.path(dir, "metadata")
  fs::dir_create(path)
  template_folder <- system.file("templates/", package = "dataspice")
  templates <- file.path(template_folder, list.files(template_folder))
  file.copy(templates, path)
  invisible(templates)
}
