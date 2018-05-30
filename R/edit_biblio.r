#' Shiny App for editing the metadata biblio table
#'
#' @param filepath the filepath leading to the biblio.csv file
#' @param outdir The directory to save the edited biblio info to
#' @param outfilename The filename to save with. Defaults to biblio.csv.
#'
#' @import shiny
#' @import rhandsontable

#' @export
#'
#' @examples
#' \dontrun{
#' editTable()
#'
#'}

edit_biblio <- function(filepath="./inst/metadata-tables/biblio.csv",
                         outdir=getwd(),
                         outfilename="biblio"){
  ui <- shinyUI(fluidPage(

    titlePanel("Populate the Biblio Metadata Table"),
    sidebarLayout(
      sidebarPanel(
        helpText("Shiny app to read in the dataspice metadata templates and populate with usersupplied data"),

        h6('fileName = the name of the input data file(s). Do Not Change.'),
        h6("variableName = the name of the measured variable. Do Not Change."),
        h6('Description = a written description of what that measured variable is'),
        h6("unitText = the units the variable was measured in"),

        br(),

        wellPanel(
          h3("Save table"),
          div(class='row',
              div(class="col-sm-6",
                  actionButton("save", "Save"))
          )
        ),
        
        plotOutput("bbmap")

      ),

      mainPanel(
        wellPanel(
          uiOutput("message", inline=TRUE)
        ),
        rHandsontableOutput("hot"),
        br()

      )
    )
  ))

  server <- shinyServer(function(input, output) {

    values <- reactiveValues()

    dat <- readr::read_csv(file = filepath,
                    col_types = "ccccccccccccccc")
    
    output$hot <- rhandsontable::renderRHandsontable({
      rows_to_add <- as.data.frame(matrix(nrow=1,
                                          ncol=ncol(dat)))

      colnames(rows_to_add) <- colnames(dat)
      DF <- dplyr::bind_rows(dat, rows_to_add)

      rhandsontable::rhandsontable(DF,
                    useTypes = TRUE,
                    stretchH = "all")
    })

    ## Save
    observeEvent(input$save, {
      finalDF <- hot_to_r(input$hot)
      utils::write.csv(finalDF, file=file.path(outdir,
                sprintf("%s.csv", outfilename)),
                row.names = FALSE)
    })

    
    ## bounding box map
    
    output$bbmap <- renderPlot({
      world <- ggplot2::map_data("world")
      ggplot2::ggplot()+
        ggplot2::geom_map(data=world, map=world,
                          aes(x=long, y=lat, map_id=region),
                          color="black",fill="#7f7f7f")
    })
    
    
    ## Message
    output$message <- renderUI({
      if(input$save==0){
        helpText(sprintf("This table will be saved in folder \"%s\" once you press the Save button.", outdir))
      }else{
        outfile <- "biblio.csv"
        fun <- 'read.csv'
        list(helpText(sprintf("File saved: \"%s\".",
                              file.path(outdir, outfile))),
             helpText(sprintf("Type %s(\"%s\") to get it.",
                              fun, outfile)))
      }
    })

  })

  ## run app
  runApp(list(ui=ui, server=server))
  return(invisible())
}
