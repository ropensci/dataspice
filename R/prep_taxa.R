#' Prepare taxonomy coverage for biblio
#'
#' Extract taxa for a given data file and add them to the biblio.csv
#' @param data_path path to the data file. Currently only tabular csv and tsv files are supported.
#' @param biblio_path path to the biblio.csv file. Defaults to "data/metadata/biblio.csv".
#' @param ... parameters passed to readr::read_*() functions
#'
#' @return the functions writes out the updated biblio.csv file to biblio_path.
#' @export
prep_taxa <- function(data_path,
                      biblio_path = here::here("data", "metadata",
                                               "biblio.csv"),
                      ...){

  if(!file.exists(data_path)){stop("invalid path to data file")}
  if(!file.exists(biblio_path)){
    stop("biblio file does not exist. Check path or run create_spice or edit_biblio?")}

  biblio <- readr::read_csv(biblio_path, col_types = readr::cols())
  fileName <- basename(data_path)
  ext <- tools::file_ext(fileName)

  if(NROW(biblio)<1){
    stop("biblio file is not populated. Check path or run create_spice or edit_biblio?")
  }

  # read data
  x <- switch(ext,
              csv = readr::read_csv(data_path, n_max = 1, col_types = readr::cols(), ...),
              tsv =  readr::read_tsv(data_path, n_max = 1, col_types = readr::cols(), ...))

  taxonCoverage <- unique(x[grepl("species|tax", names(x), ignore.case = T)])
  taxonCoverage <- unlist(taxonCoverage[grepl("[0-9]", taxonCoverage)==F])

  if(NROW(taxonCoverage) > 0) {

    if(NROW(taxonCoverage) < 5) {

      biblio$keywords[1] <- paste(biblio$keywords[1],
                                  taxonCoverage,
                                  sep = ", ")

    } else {

      taxonCoverage2 <- taxize::lowest_common(taxonCoverage,
                                              db = "col",
                                              rows = 1)$name

      # Not sure how to handle "Error in if (x[1, "rank"] == "no rank")"
      biblio$keywords[1] <- paste(biblio$keywords[1],
                                  taxonCoverage2,
                                  sep = ", ")

      message("To link scientific names to taxonIDs, try taxize::gnr_resolve")

    }

    # deduplicate keywords
    keywords <- unique(unlist(strsplit(biblio$keywords, split = ", ")))
    biblio$keywords <- paste(keywords, collapse = ", ")

    readr::write_csv(biblio, path = biblio_path)

    message("The following taxonCoverage has been added to 'keywords' in the biblio file: ",
            "\n", paste(unlist(taxonCoverage), collapse = ", "))
  }
}
