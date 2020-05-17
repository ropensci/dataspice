#' Prepare access
#'
#' Extract `fileNames` from data file(s) and add them to `access.csv`. The
#' helper \code{\link{validate_file_paths}} can be used to create vectors of valid file paths
#' that can be checked and then passed as `data_path` argument to \code{\link{prep_access}}.
#' @param data_path character vector of either:
#'
#' 1. path(s) to the data file(s).
#' 2. single path to directory containing data file(s).
#' Currently only tabular `.csv` and `.tsv` or `.rds` files are supported.
#' @param access_path path to the `access.csv` file. Defaults to "data/metadata/access.csv".
#' @param ... parameters passed to `list.files()`. For example, use `recursive = TRUE`
#' to list files in a folder recursively or use `pattern` to filter files for patterns.
#' @return Updates `access.csv` and writes to `access_path`.
#' @export
prep_access <- function(data_path = "data",
                        access_path = "data/metadata/access.csv",
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
                            encodingFormat = fileTypes)


  readr::write_csv(access, path = access_path)
  message("The following fileNames have been added to the access file: ",
          paste(basename(fileNames), collapse = ", "))
}

