context("test-eml_to_spice")
library(dplyr)

eml_path <- system.file("example-dataset/broodTable_metadata.xml", package = "dataspice")
eml <- EML::read_eml(eml_path)

test_that("Access tabular format matches EML", {
  eml_access <- es_access(eml)

  objectNames <- EML::eml_get(eml, "objectName") %>% paste(collapse = " ")
  urls <- EML::eml_get(eml, "url") %>% paste(collapse = " ")
  formatNames <- EML::eml_get(eml, "formatName") %>% paste(collapse = " ")

  expect_true(all(stringr::str_detect(objectNames, eml_access$fileName),
                  na.rm = TRUE))
  expect_true(all(stringr::str_detect(urls, eml_access$contentUrl),
                  na.rm = TRUE))
  expect_true(all(stringr::str_detect(formatNames, eml_access$encodingFormat),
                  na.rm = TRUE))
})


test_that("Attributes tabular format matches EML", {
  eml_attributes <- es_attributes(eml)

  objectNames <- EML::eml_get(eml, "objectName") %>% paste(collapse = " ")
  attributeNames <- EML::eml_get(eml, "attributeName") %>% paste(collapse = " ")

  expect_true(all(stringr::str_detect(objectNames, eml_attributes$fileName),
                  na.rm = TRUE))
  expect_true(all(stringr::str_detect(attributeNames, eml_attributes$variableName),
                  na.rm = TRUE))

  standardUnits <- EML::eml_get(eml, "standardUnit")
  customUnits <- EML::eml_get(eml, "customUnit")
  formatStrings <- EML::eml_get(eml, "formatString")
  unitText <- paste(standardUnits, customUnits, formatStrings, collapse = " ")

  expect_true(all(stringr::str_detect(unitText, eml_attributes$unitText),
                  na.rm = TRUE))

  #description = description + missing vals
})

#additional tests:
#units match defintions/etc
#entity names match attributes

test_that("Biblio tabular format matches EML", {
  eml_biblio <- es_biblio(eml)

  #title
  expect_equal(eml$dataset$title,
               eml_biblio$title)

  #date published
  expect_equal(eml$dataset$pubDate,
               eml_biblio$datePublished)

  #license/intellectual rights
  expect_equal(eml$dataset$intellectualRights[[1]],
               eml_biblio$license)

  #funding/funder
  expect_equal(paste(unlist(eml$dataset$project$funding), collapse = "; ") %>% nchar(),
               eml_biblio$funder %>% nchar())

  #geographic coverage
  expect_equal(eml$dataset$coverage$geographicCoverage$geographicDescription,
               eml_biblio$geographicDescription)

  #check coordinates via sum instead of one-by-one
  expect_equal(eml$dataset$coverage$geographicCoverage$boundingCoordinates %>%
                 unlist() %>%
                 as.numeric() %>%
                 sum(),
               eml_biblio %>%
                 select(contains("Coord")) %>%
                 as.numeric() %>%
                 sum())

  #temporal coverage
  expect_equal(eml$dataset$coverage$temporalCoverage$rangeOfDates$beginDate$calendarDate,
               eml_biblio$startDate)
  expect_equal(eml$dataset$coverage$temporalCoverage$rangeOfDates$endDate$calendarDate,
               eml_biblio$endDate)
})

test_that("Creators tabular format matches EML", {
  eml_creators <- es_creators(eml)

  orcids <-  EML::eml_get(eml, "userId") %>% paste(collapse = " ")
  givenNames <- EML::eml_get(eml, "givenName") %>% paste(collapse = " ")
  surNames <- EML::eml_get(eml, "surName") %>% paste(collapse = " ")
  affiliations <- EML::eml_get(eml, "organizationName") %>% paste(collapse = " ")
  emails <- EML::eml_get(eml, "electronicMailAddress") %>% paste(collapse = " ")

  # expect_true(all(stringr::str_detect(orcids, eml_creators$id),
  #                 na.rm = TRUE))
  # doesn't work if no orcids available

  expect_true(all(stringr::str_detect(
    paste(
      EML::eml_get(eml, "givenName"),
      EML::eml_get(eml, "surName"),
      collapse = " "),
    eml_creators$name),
    na.rm = TRUE))

  expect_true(all(stringr::str_detect(affiliations, eml_creators$affiliation),
                  na.rm = TRUE))

  expect_true(all(stringr::str_detect(emails, eml_creators$email),
                  na.rm = TRUE))
})

test_that("eml_to_spice files write to disk", {
  dir_path <- tempdir()
  eml_to_spice(eml, dir_path)

  files <- list.files(dir_path,
                      pattern = "access|attributes|biblio|creators",
                      full.names = TRUE)

  expect_true(any(grepl("access.csv", files)))
  expect_true(any(grepl("attributes.csv", files)))
  expect_true(any(grepl("biblio.csv", files)))
  expect_true(any(grepl("creators.csv", files)))

  file.remove(files)
})

test_that("eml_to_spice returns a list of tibbles", {
  spice_ex <- eml_to_spice(eml)

  expect_equal(length(spice_ex), 4)

  tbl_lgl <- spice_ex %>% purrr::map(class) %>% purrr::map(~"tbl" %in% .)
  expect_true(all(unlist(tbl_lgl)))
})

