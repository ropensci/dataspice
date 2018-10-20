context("test-prep_attributes.R")

tmp <- tempdir()
# on.exit(unlink(tmp, recursive = TRUE))
create_spice(tmp)
attributes_path <- file.path(tmp, "metadata", "attributes.csv")
data_path <- system.file("example-dataset","BroodTables.csv", package = "dataspice")

test_that("erroneous-paths-throw-correct-errors", {
    expect_error(prep_attributes(data_path,
                                 attributes_path = file.path(tmp, "metadata",
                                                             "non-existent-folder",
                                                             "attributes.csv")),
                 "attribute file does not exist. Check path or run create_spice?")

    expect_error(prep_attributes(data_path = "non-existent-path",
                                 attributes_path),
                 "no valid paths to data files detected.")

})

prep_attributes(data_path, attributes_path)

test_that("attributes-extracted-correctly", {
   attributes <- readr::read_csv(file.path(tmp, "metadata", "attributes.csv"))
    expect_equal(nrow(attributes), 34)
    expect_equal(unique(attributes$fileName), "BroodTables.csv")
    expect_equal(attributes$variableName, brood_attributes)
})

test_that("attributes-not-overwritten-for-same-file", {
    expect_warning(prep_attributes(data_path, attributes_path),
                   "Entries already exist in attributes.csv for fileNames: BroodTables.csv\n files ignored")
})


data_path <- system.file("example-dataset","SourceInfo.csv", package = "dataspice")

test_that("second-file-updates-correctly", {
    expect_message(prep_attributes(data_path, attributes_path),
                   "The following variableNames have been added to the attributes file for fileName: ",
                   "SourceInfo.csv", "\n \n", "Source.ID, Source")

    attributes <- readr::read_csv(attributes_path)
    expect_equal(attributes$variableName, brood_info_attributes)
    expect_equal(nrow(attributes), length(brood_info_attributes))

})

readr::read_csv(attributes_path)[0,] %>%
  readr::write_csv(attributes_path)
data_path <- system.file("example-dataset", package = "dataspice")

test_that("full-folder-attributes-prepped-correctly", {
  suppressWarnings(prep_attributes(data_path, attributes_path))
  attributes <- readr::read_csv(attributes_path)
  expect_equal(attributes$variableName, full_attributes)
  expect_equal(nrow(attributes), length(full_attributes))
})

