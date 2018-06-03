#' Shiny App for editing the metadata biblio table
#'
#' @param filepath the filepath to the dataspice biblio.csv file. Defaults to current
#'   <project_root>/data/metadata/biblio.csv.
#'
#' @import shiny
#' @import rhandsontable
#' @import ggplot2
#' @export
#'
#' @examples
#' \dontrun{
#' edit_biblio()
#'
#'}

edit_biblio <- function(filepath = here::here("data", "metadata", "biblio.csv")){
  ui <- shinyUI(fluidPage(

    titlePanel("Populate the Biblio Metadata Table"),
    helpText("Shiny app to read in the", code("dataspice"), "metadata templates and populate with user supplied metadata"),

    sidebarLayout(
      sidebarPanel(
        h4("Bibliographic metadata"),
        h6('title = text: Title of the dataset(s) described.'),
        h6("description = text: Description of the dataset(s) described"),
        h6('datePublished = text: The date published in ISO 8601 format (YYYY-MM-DD)'),
        h6("citation = text: citation for the dataset(s) described"),
        h6("keywords = text: keywords, separated by commas, associated with the dataset(s) described"),
        h6("license = text: license under which data are published"),
        h6("funder = text: Name of funders associated with the work through which data where generated"),

        br(),
        h4("Spatial Coverage metadata"),
        h6('geographicDescription = text: Description of the area of study'),
        h6("northBoundCoord = numeric or text: southern latitudinal boundary of the data coverage area. For example 37.42242 (WGS 84)"),
        h6("eastBoundCoord = numeric or text: eastern longitudinal boundary of the data coverage area. For example -122.08585 (WGS 84)"),
        h6("southBoundCoord = numeric or text: northern latitudinal boundary of the data coverage area."),
        h6("westBoundCoord = numeric or text: western longitudinal boundary of the data coverage area."),
        helpText("To provide a single point to describe the spatial aspect of the dataset, provide the same coordinates for east-west and north-south boundary definition"),
        br(),
        h4("Temporal Coverage metadata"),
        h6("wktString = text: ??"),
        h6('startDate = text: The start date of the data temporal coverage in ISO 8601 format (YYYY-MM-DD)'),
        h6("endDate = text: The end date of the data temporal coverage in ISO 8601 format (YYYY-MM-DD)"),

        plotOutput("bbmap")

      ),

      mainPanel(
        wellPanel(
          uiOutput("message", inline=TRUE)),
        fluidRow(
          column(8,
                 h3("biblio.csv", style = "vertical-align: text-bottom;")),
          column(4,
                 wellPanel(
                  # h3("Save table"),
                   actionButton("save", "Save Changes"))
          )
        ),
        helpText("Right-click on the table to delete/insert rows.",
                 "Double-click on a cell to edit"),
        rHandsontableOutput("hot"),
        br()

      )
    )
  ))

  server <- shinyServer(function(input, output) {

    values <- reactiveValues()

    dat <- readr::read_csv(file = filepath,
                    col_types = "ccccccccccccccc")

    # pad if no data
    if(nrow(dat) == 0){
      dat <- dplyr::add_row(dat)
    }

    output$hot <- rhandsontable::renderRHandsontable({
      rhandsontable(dat,
                    useTypes = TRUE,
                    stretchH = "all")
    })

    ## Save
    observeEvent(input$save, {
      finalDF <- hot_to_r(input$hot)
      readr::write_csv(
        # remove padding if none edited
        dplyr::filter_all(finalDF, dplyr::any_vars(!is.na(.))),
        path = filepath)
    })


    ## bounding box map

    output$bbmap <- renderPlot({
      world <- ggplot2::map_data("world")
      ggplot2::ggplot() +
        ggplot2::geom_map(data=world, map=world,
                          aes(x=long, y=lat, map_id=region),
                          color="black",fill="#7f7f7f")
    })


    ## Message
    output$message <- renderUI({
      outfile <- basename(filepath)
      outdir <- gsub(outfile, "", filepath)
      if(input$save==0){
        helpText("This table will be saved as file: ", code(outfile),
                 "in directory:", code(outdir),
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
