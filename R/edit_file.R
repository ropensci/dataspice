#' Shinyapps for editing dataspice metadata tables
#'
#' Launch shinyapp for editing individual `dataspice` metadata tables. Use `edit_*()` where `*`
#' is one of the four `dataspice` metadata tables **`attributes`, `biblio`, `access` or `creators`**.
#' @param metadata_dir the directory containing the `dataspice` metadata `.csv` files. Defaults to
#'   `data/metadata/` directory in **current project root**.
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


# Shinyapps for editing dataspice metadata tables
#' @import shiny
#' @import rhandsontable
#' @import ggplot2
#' @importFrom dplyr "%>%"
edit_file <- function(metadata_dir = "data/metadata",
                      file = c("attributes.csv", "biblio.csv", "access.csv", "creators.csv")){

  filepath <- file.path(metadata_dir, file)

  if (!file.exists(filepath)) {
    stop("File '", filepath, "' does not exist. Run create_spice() first.",
         call. = FALSE)
  }

  file <- match.arg(file)

  ui <- shinyUI(
    fluidPage(
      titlePanel(paste0("Populate the ", file," table")),
      helpText("Interactive application to read in ", code("dataspice"),
               "metadata templates and populate with your own metadata."),

      # Header panel
      wellPanel(
        fluidRow(
          column(8,
                 uiOutput("message", inline=TRUE)
          ),
          column(4, align="right",
                 actionButton("save", "Save Changes"))
        )
      ),
      # side panel
      sidebarLayout(
        # side panel contains reference details. conditional on file.
        sidebarPanel(
          if (file == "attributes.csv"){
            list(
              h4("Variable metadata"),
              h6("fileName: The name of the input data file(s). Don't change this."),
              h6("variableName: The name of the measured variable. Don't change this."),
              h6("description: A written description of the variable measured."),
              h6("unitText: The units the variable was measured in."),
              helpText("Use", code("prep_attributes()"), "to extract", strong("variableName"), " from data files.")
            )
          },
          if (file == "biblio.csv"){
            list(
              h4("Bibliographic metadata"),
              h6("title: Title of the dataset(s) described."),
              h6("description: Description of the dataset(s) described (aka abstract)."),
              h6('datePublished: The date published in ISO 8601 format (YYYY-MM-DD).'),
              h6("citation: Citation to a related work, such as a reference publication."),
              h6("keywords: Keywords, separated by commas, associated with the dataset(s) described."),
              h6("license: License under which (meta)data are published."),
              h6("funder: Name of funders associated with the work through which data where generated."),

              br(),
              h4("Spatial Coverage metadata"),
              h6("geographicDescription: Description of the area of study. i.e., Crater Lake."),
              h6("northBoundCoord: Southern latitudinal boundary of the data coverage area. For example 37.42242."),
              h6("eastBoundCoord: Eastern longitudinal boundary of the data coverage area. For example -122.08585."),
              h6("southBoundCoord: Northern latitudinal boundary of the data coverage area."),
              h6("westBoundCoord: Western longitudinal boundary of the data coverage area."),
              h6("wktString: Well-known Text (WKT) formatted representation of geometry. see:",
                 a(href="https://ropensci.org/tutorials/wellknown_tutorial/", "pkg", code("wellknown")), "for details."),
              helpText("To provide a single point to describe the spatial
                             aspect of the dataset, provide the same coordinates
                             for east-west and north-south boundary definition."),
              br(),
              h4("Temporal Coverage metadata"),
              h6("startDate: The start date of the data temporal coverage in ISO 8601 format (YYYY-MM-DD)."),
              h6("endDate: The end date of the data temporal coverage in ISO 8601 format (YYYY-MM-DD)."),
              br(),
              plotOutput("bbmap")
            )},
          if (file == "access.csv"){
            list(
              h6("fileName: The filename of the input data file(s). Don't change this."),
              h6("name: A human readable name for the file."),
              h6('contentUrl: A url to where the data is hosted, if applicable'),
              h6("encodingFormat: The file format, such as Excel, or CSV")
            )},
          if (file == "creators.csv"){
            list(
              h6("id: ORCID or another ID."),
              h6("name: The name of the creator."),
              h6("affilitation: Affiliation of the creator.")
            )}
        ),
        mainPanel(
          # table editing helptext
          helpText("Right-click on the table to delete/insert rows.",
                   "Double-click on a cell to edit"),
          # table
          rHandsontableOutput("hot"),
          br()
        )
      )
    )
  )

  server <- shinyServer(function(input, output) {


    ## bounding box map
    if (file == "biblio.csv" && requireNamespace("maps", quietly = TRUE)){
      output$bbmap <- renderPlot({
        world <- ggplot2::map_data("world")
        ggplot2::ggplot() +
          ggplot2::geom_map(data=world, map=world,
                            aes(x=long, y=lat, map_id=region),
                            color="black",fill="#7f7f7f")
      })
    }

    values <- reactiveValues()

    dat <- readr::read_csv(file = filepath,
                           col_types = readr::cols(
                             .default = readr::col_character()
                           ))
    # pad if no data
    if(nrow(dat) == 0){
      dat <- dplyr::add_row(dat)
    }

    output$hot <- renderRHandsontable({
      rhandsontable(dat,
                    useTypes = TRUE,
                    stretchH = "all") %>%
        hot_context_menu(allowColEdit = FALSE)
    })

    ## Save
    observeEvent(input$save, {
      finalDF <- hot_to_r(input$hot)
      # remove padding if none edited
      finalDF[!apply(is.na(finalDF) | finalDF == "", 1, all),] %>%
        readr::write_csv(path = filepath)
    })


    ## Message
    output$message <- renderUI({
      if(input$save==0){
        helpText("This table will be saved as file: ", code(file),
                 "in directory:", code(metadata_dir),
                 " once you press the ",
                 strong("Save Changes"),
                 "button.")
      }else{
        list(helpText("File saved at path:", code(filepath)),
             helpText("Use", code(paste0("readr::read_csv('",filepath,"')")) ,
                      "to read it."))
      }
    })

  })

  ## run app
  runApp(list(ui=ui, server=server))
  return(invisible())
}
