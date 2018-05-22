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
                 "invalid path to data file")
    
})

prep_attributes(data_path, attributes_path)

test_that("attributes-extracted-correctly", {  
   attributes <- readr::read_csv(file.path(tmp, "metadata", "attributes.csv"))
    expect_equal(nrow(attributes), 34)
    expect_equal(unique(attributes$fileName), "BroodTables.csv")
    expect_equal(attributes$variableName, c("Stock.ID", "Species", "Stock", "Ocean.Region", "Region", "Sub.Region", 
                     "Jurisdiction", "Lat", "Lon", "UseFlag", "BroodYear", "TotalEscapement", 
                     "R0.1", "R0.2", "R0.3", "R0.4", "R0.5", "R1.1", "R1.2", "R1.3", 
                     "R1.4", "R1.5", "R2.1", "R2.2", "R2.3", "R2.4", "R3.1", "R3.2", 
                     "R3.3", "R3.4", "R4.1", "R4.2", "R4.3", "TotalRecruits"))
})

test_that("attributes-not-overwritten-for-same-file", {  
    expect_error(prep_attributes(data_path, attributes_path),
                                 "entries already exist in attributes.csv for fileName:BroodTables.csv")   
})


data_path <- system.file("example-dataset","SourceInfo.csv", package = "dataspice")

test_that("second-file-updates-correctly", {  
    expect_message(prep_attributes(data_path, attributes_path),
                   "The following variableNames have been added to the attributes file for fileName: ", 
                   "SourceInfo.csv", "\n \n", "Source.ID, Source")
    
    attributes <- readr::read_csv(file.path(tmp, "metadata", "attributes.csv"))
    expect_equal(attributes$variableName, c("Stock.ID", "Species", "Stock", "Ocean.Region", "Region", "Sub.Region", 
                                            "Jurisdiction", "Lat", "Lon", "UseFlag", "BroodYear", "TotalEscapement", 
                                            "R0.1", "R0.2", "R0.3", "R0.4", "R0.5", "R1.1", "R1.2", "R1.3", 
                                            "R1.4", "R1.5", "R2.1", "R2.2", "R2.3", "R2.4", "R3.1", "R3.2", 
                                            "R3.3", "R3.4", "R4.1", "R4.2", "R4.3", "TotalRecruits", "Source.ID", "Source"))
})