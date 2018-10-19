#' @inherit prep_attributes
#' @param access_path path to the `access.csv` file. Defaults to "data/metadata/access.csv".
#' @export
prep_access <- function(data_path = here::here("data"),
                        access_path = here::here("data", "metadata",
                                                 "access.csv"),
                                                 ...){
  # check and load attributes
  if(!file.exists(access_path)){
    stop("access file does not exist. Check path or run create_spice?")}
  access <- readr::read_csv(access_path, col_types = readr::cols())

  # list and validate file paths
  file_paths <- validate_file_paths(data_path, ...)
  fileNames <- basename(file_paths) %>%
    check_fileNames(table = access)

  if(length(fileNames) == 0){
    return()
  }
  fileTypes <- tools::file_ext(fileNames)

  access <- tibble::add_row(access,
                            fileName = fileNames,
                            name = basename(tools::file_path_sans_ext(fileNames)),
                            contentUrl = NA,
                            fileFormat = fileTypes)


  readr::write_csv(access, path = access_path)
  message("The following fileNames have been added to the access file: ",
          paste(basename(fileNames), collapse = ", "))
}

