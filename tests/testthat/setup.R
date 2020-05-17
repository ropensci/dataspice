
brood_attributes <- c("Stock.ID", "Species", "Stock", "Ocean.Region", "Region", "Sub.Region",
                      "Jurisdiction", "Lat", "Lon", "UseFlag", "BroodYear", "TotalEscapement",
                      "R0.1", "R0.2", "R0.3", "R0.4", "R0.5", "R1.1", "R1.2", "R1.3",
                      "R1.4", "R1.5", "R2.1", "R2.2", "R2.3", "R2.4", "R3.1", "R3.2",
                      "R3.3", "R3.4", "R4.1", "R4.2", "R4.3", "TotalRecruits")

brood_info_attributes <- c(brood_attributes, "Source.ID", "Source")

full_attributes <- c(brood_info_attributes, "Stock.ID", "Species", "Stock", "Date.data.obtained",
                     "Date.data.incorporated", "Ocean.Region", "Region", "Sub.Region",
                     "Jurisdiction", "Lat", "Lon", "Source.ID", "Comment")
