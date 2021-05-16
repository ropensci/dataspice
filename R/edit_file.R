#' Shiny apps for editing dataspice metadata tables
#'
#' Launch Shiny app for editing individual `dataspice` metadata tables. Use
#' `edit_*()` where `*` is one of the four `dataspice` metadata tables
#' **`attributes`, `biblio`, `access` or `creators`**.
#' @param metadata_dir the directory containing the `dataspice` metadata `.csv`
#'  files. Defaults to `data/metadata/` directory in **current project root**.
#'
#' @export
#' @examples
#' \dontrun{
#' edit_attributes()
#' edit_biblio()
#' edit_access()
#' edit_creators()
#'
#' # Specifying a different dataspice metadata directory
#' edit_attributes(metadata_dir = "analysis/data/metadata/"))
#'}
edit_attributes <- function(metadata_dir = "data/metadata") {
  edit_file(metadata_dir, "attributes.csv")
}

#' @inherit edit_attributes
#' @export
edit_biblio <- function(metadata_dir = file.path("data", "metadata")) {
  edit_file(metadata_dir, "biblio.csv")
}

#' @inherit edit_attributes
#' @export
edit_access <- function(metadata_dir = file.path("data", "metadata")) {
  edit_file(metadata_dir, "access.csv")
}

#' @inherit edit_attributes
#' @export
edit_creators <- function(metadata_dir = file.path("data", "metadata")) {
  edit_file(metadata_dir, "creators.csv")
}


# Shiny apps for editing dataspice metadata tables
#' @importFrom dplyr "%>%"
edit_file <- function(metadata_dir = "data/metadata", file) {

  filepath <- file.path(metadata_dir, file)

  if (!file.exists(filepath)) {
    stop("File '", filepath, "' does not exist. Run create_spice() first.",
         call. = FALSE)
  }

  file_choices <- c(
    "attributes.csv",
    "biblio.csv",
    "access.csv",
    "creators.csv")
  file <- match.arg(file, file_choices)

  ui <- shiny::shinyUI(
    shiny::fluidPage(
      shiny::titlePanel(paste0("Populate the ", file, " table")),
      shiny::helpText("Interactive application to read in ",
                      shiny::code("dataspice"),
                      "metadata templates and populate with your own ",
                      "metadata."),

      # Header panel
      shiny::wellPanel(
        shiny::fluidRow(
          shiny::column(8,
                        shiny::uiOutput("message", inline = TRUE)
          ),
          shiny::column(4, align = "right",
                 shiny::actionButton("save", "Save Changes"))
        )
      ),
      # side panel
      shiny::sidebarLayout(
        # side panel contains reference details. conditional on file.
        shiny::sidebarPanel(
          if (file == "attributes.csv") {
            list(
              shiny::h4("Variable metadata"),
              shiny::h6(
                "fileName: The name of the input data file(s). ",
                "Don't change this."
              ),
              shiny::h6(
                "variableName: The name of the measured variable. ",
                "Don't change this."
              ),
              shiny::h6(
                "description: A written description of the variable measured."
              ),
              shiny::h6(
                "unitText: The units in which the variable was measured."
              ),
              shiny::helpText(
                "Use",
                shiny::code("prep_attributes()"),
                "to extract",
                shiny::strong("variableName"),
                " from data files.")
            )
          },
          if (file == "biblio.csv") {
            list(
              shiny::h4("Bibliographic metadata"),
              shiny::h6("title: Title of the dataset(s) described."),
              shiny::h6(
                "description: Description of the dataset(s) ",
                "described (aka abstract)."
              ),
              shiny::h6(
                "datePublished: The date published in ISO 8601 format ",
                "(YYYY-MM-DD)."
              ),
              shiny::h6(
                "citation: Citation to a related work, such as a reference ",
                "publication."
              ),
              shiny::h6(
                "keywords: Keywords, separated by commas, associated with the ",
                "dataset(s) described."
              ),
              shiny::h6(
                "license: License under which (meta)data are published."
              ),
              shiny::h6(
                "funder: Name of funders associated with the work through ",
                "which data where generated."
              ),

              shiny::br(),
              shiny::h4(
                "Spatial Coverage metadata"
              ),
              shiny::h6(
                "geographicDescription: Description of the area of study. ",
                "i.e., Crater Lake."
              ),
              shiny::h6(
                "northBoundCoord: Southern latitudinal boundary of the data ",
                "coverage area. For example 37.42242."
              ),
              shiny::h6(
                "eastBoundCoord: Eastern longitudinal boundary of the data ",
                "coverage area. For example -122.08585."
              ),
              shiny::h6(
                "southBoundCoord: Northern latitudinal boundary of the data ",
                "coverage area."
              ),
              shiny::h6(
                "westBoundCoord: Western longitudinal boundary of the data ",
                "coverage area."
              ),
              shiny::h6(
                "wktString: Well-known Text (WKT) formatted representation of ",
                "geometry. see:",
                shiny::a(
                  href = "https://ropensci.org/tutorials/wellknown_tutorial/",
                  "pkg",
                  shiny::code("wellknown")
                ),
                "for details."),
              shiny::helpText(
                "To provide a single point to describe the spatial aspect of ",
                "the dataset, provide the same coordinates for east-west and ",
                "north-south boundary definition."),
              shiny::br(),
              shiny::h4("Temporal Coverage metadata"),
              shiny::h6(
                "startDate: The start date of the data temporal ",
                "coverage in ISO 8601 format (YYYY-MM-DD)."
              ),
              shiny::h6(
                "endDate: The end date of the data temporal coverage ",
                "in ISO 8601 format (YYYY-MM-DD)."
              ),
              shiny::br(),
              shiny::plotOutput("bbmap")
            )},
          if (file == "access.csv") {
            list(
              shiny::h6(
                "fileName: The filename of the input data file(s). ",
                "Don't change this."
                ),
              shiny::h6("name: A human readable name for the file."),
              shiny::h6(
                "contentUrl: A url to where the data is hosted, ",
                "if applicable"
              ),
              shiny::h6(
                "encodingFormat: The file format, such as Excel, or CSV"
              )
            )},
          if (file == "creators.csv") {
            list(
              shiny::h6("id: ORCID or another ID."),
              shiny::h6("name: The name of the creator."),
              shiny::h6("affilitation: Affiliation of the creator.")
            )}
        ),
        shiny::mainPanel(
          # table editing helptext
          shiny::helpText("Right-click on the table to delete/insert rows.",
                   "Double-click on a cell to edit"),
          # table
          rhandsontable::rHandsontableOutput("hot"),
          shiny::br()
        )
      )
    )
  )

  server <- shiny::shinyServer(function(input, output) {


    ## bounding box map
    if (file == "biblio.csv" && requireNamespace("maps", quietly = TRUE)) {
      output$bbmap <- shiny::renderPlot({
        world <- ggplot2::map_data("world")
        ggplot2::ggplot() +
          ggplot2::geom_map(data = world, map = world,
                            ggplot2::aes(x = long, y = lat, map_id = region),
                            color = "black",fill = "#7f7f7f")
      })
    }

    values <- shiny::reactiveValues()

    dat <- readr::read_csv(file = filepath,
                           col_types = readr::cols(
                             .default = readr::col_character()
                           ))
    # pad if no data
    if (nrow(dat) == 0) {
      dat <- dplyr::add_row(dat)
    }

    output$hot <- rhandsontable::renderRHandsontable({
      rhandsontable::rhandsontable(dat,
                    useTypes = TRUE,
                    stretchH = "all") %>%
        rhandsontable::hot_context_menu(allowColEdit = FALSE)
    })

    ## Save
    shiny::observeEvent(input$save, {
      finalDF <- rhandsontable::hot_to_r(input$hot)
      # remove padding if none edited
      finalDF[!apply(is.na(finalDF) | finalDF == "", 1, all),] %>%
        readr::write_csv(filepath)
    })


    ## Message
    output$message <- shiny::renderUI({
      if (input$save == 0) {
        shiny::helpText("This table will be saved as file: ", shiny::code(file),
                 "in directory:", shiny::code(metadata_dir),
                 " once you press the ",
                 shiny::strong("Save Changes"),
                 "button.")
      }else{
        list(shiny::helpText("File saved at path:", shiny::code(filepath)),
             shiny::helpText("Use", shiny::code(
               paste0("readr::read_csv('",filepath,"')")),
              "to read it."))
      }
    })

  })

  ## run app
  shiny::runApp(list(ui = ui, server=server))

  invisible(NULL)
}
