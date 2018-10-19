#' Prepare attributes
#'
#' Extract `variableNames` from data file(s) and add them to `attributes.csv`. The
#' helper \code{\link{validate_file_paths}} can be used to create vectors of valid file paths
#' that can be checked and then passed as `data_path` argument to \code{\link{prep_attributes}}.
#' @param data_path character vector of either:
#'
#' 1. path(s) to the data file(s).
#' 2. single path to directory containing data file(s).
#' Currently only tabular `.csv` and `.tsv` files are supported. Alternatively attributes
#' returned using `names()` can be extracted from r object, stored as `.rds` files.
#' @param attributes_path path to the `attributes.csv`` file. Defaults to "data/metadata/attributes.csv".
#' @param ... parameters passed to `list.files()`. For example, use `recursive = TRUE`
#' to list files in a folder recursively or use `pattern` to filter files for patterns.
#' @return `prep_attributes()` updates the `attributes.csv` and writes to `attributes_path`.
#' `validate_file_paths()` returns a vector of valid file_paths detected from `data_path`.
#' @export
#' @examples
#' \dontrun{
#' create_spice()
#' # extract attributes from all `csv`, `tsv`, `rds` files in the data folder (non recursive)
#' prep_attributes()
#' # recursive
#' prep_attributes(recursive = T)
#' # extract attributes from a single file using file path
#' data_path <- system.file("example-dataset","BroodTables.csv", package = "dataspice")
#' prep_attributes(data_path)
#' # extract attributes from a single file by file path pattern matching
#' data_path <- system.file("example-dataset", package = "dataspice")
#' prep_attributes(data_path, pattern = "StockInfo")
#' # extract from a folder using folder path
#' data_path <- system.file("example-dataset", package = "dataspice")
#' prep_attributes(data_path)
#' # get vector of valid (existing) file paths
#' validate_file_paths(data_path)
#' }
prep_attributes <- function(data_path = here::here("data"),
                            attributes_path = here::here("data", "metadata",
                                                         "attributes.csv"),
                            ...){
  # list and validate file paths
  file_paths <- validate_file_paths(data_path, ...)
  # check and load attributes
  if(!file.exists(attributes_path)){
    stop("attribute file does not exist. Check path or run create_spice?")}
  attributes <- readr::read_csv(attributes_path, col_types = readr::cols())

  attributes <- dplyr::bind_rows(attributes,
                                 purrr::map_df(file_paths,
                                               ~extract_attributes(.x, attributes)))

  readr::write_csv(attributes, path = attributes_path)
}

#' @inherit prep_attributes
#' @export
validate_file_paths <- function(data_path, ...){
  if(length(data_path) == 1){
    if(is_dir(data_path)){
      file_paths <- list.files(data_path,
                               include.dirs = FALSE,
                               full.names = T,
                               ...)
      file_paths <- grep("*metadata/*", file_paths, invert = T, value = T)
      file_paths <- file_paths[!is_dir(file_paths)]
    }else{
      file_paths <- data_path
    }
    check_files <- file.exists(file_paths)
    if(any(!check_files)){
      warning("Invalid data_paths \n",
              paste0(file_paths[!check_files], "\n"),
              "files ignored")
      file_paths <- file_paths[check_files]
    }
    if(length(file_paths) == 0) {
      stop("no valid paths to data files detected.")
    }
  }
  file_paths
}

# check and extract variables from single file
extract_attributes <- function(file_path, attributes){
  fileName <- basename(file_path)
  ext <- tools::file_ext(fileName)
  if(!ext %in% c("csv", "tsv", "rds")){
    warning("cannot handle extension", ext," for fileName:",
            fileName, ", \n prep skipped")
    return()
  }
  if(fileName %in% unique(attributes$fileName)){
    warning("entries already exist in attributes.csv for fileName:",
            fileName, ", \n prep skipped")
    return()
  }

  # read data
  x <- switch(ext,
              csv = readr::read_csv(file_path, n_max = 1, col_types = readr::cols()),
              tsv =  readr::read_tsv(file_path, n_max = 1, col_types = readr::cols()),
              rds = readRDS(file_path))

  if(is.null(names(x))){
    warning("no attributes to extract attributes from fileName:",
            fileName, ", \n prep skipped")
    return()
  }

  message("The following variableNames have been added to the attributes file for fileName: ",
          fileName, "\n", paste(names(x), collapse = ", "), "\n \n")

  tibble::add_row(attributes[0,],
                  variableName = names(x),
                  fileName = fileName)

}

# checker whether a path is to a directory
is_dir <- function(path){tools::file_ext(path) == ""}
