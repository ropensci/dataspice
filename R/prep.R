#' Prepare attributes
#'
#' Extract variableNames for a given data file and add them to the attributes.csv
#' @param data_path path to the data file. Currently only tabular csv and tsv files are supported.
#' @param attributes_path path to the attributes.csv file. Defaults to "data/metadata/attributes.csv".
#' @param ... parameters passed to readr::read_*() functions
#'
#' @return the functions writes out the updated attributes.csv file to attributes_path.
#' @export
prep_attributes <- function(data_path,
                            attributes_path = here::here("data", "metadata",
                                                         "attributes.csv"),
                            ...){

    if(!file.exists(data_path)){stop("invalid path to data file")}
    if(!file.exists(attributes_path)){
        stop("attribute file does not exist. Check path or run create_spice?")}

    attributes <- readr::read_csv(attributes_path, col_types = readr::cols())
    fileName <- basename(data_path)
    ext <- tools::file_ext(fileName)

    if(fileName %in% unique(attributes$fileName)){
        stop("entries already exist in attributes.csv for fileName:",
             fileName)
    }

    # read data
    x <- switch(ext,
                csv = readr::read_csv(data_path, n_max = 1, col_types = readr::cols(), ...),
                tsv =  readr::read_tsv(data_path, n_max = 1, col_types = readr::cols(), ...))

    attributes <- tibble::add_row(attributes,
                                  variableName = names(x),
                                  fileName = fileName)
    readr::write_csv(attributes, path = attributes_path)
    message("The following variableNames have been added to the attributes file for fileName: ",
            fileName, "\n \n", paste(names(x), collapse = ", "))
}

