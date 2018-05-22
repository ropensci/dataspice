#' Shiny App for editing the metadata creator table
#'
#' @param DF the imported creator.csv dataframe
#' @param numCreators the number of creators that need to be included, defauls to 10
#' @import shiny
#' @export
#'
#' @examples
#' \dontrun{
#' editTable(DF = creator)
#'
#'}

editCreators <- function(DF,
                           outdir=getwd(),
                           outfilename="creator",
                         numCreators=10){
  ui <- shinyUI(fluidPage(

    titlePanel("Populate the Creators Metadata Table"),
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
        )

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



    output$hot <- renderRHandsontable({

      rows_to_add <- as.data.frame(matrix(nrow=numCreators,
                                          ncol=ncol(DF)))

      colnames(rows_to_add) <- colnames(DF)
      DF <- rows_to_add
      DF$name <- as.character(DF$ï..name)
      DF$type <- as.character(DF$type)
      DF$id <- as.character(DF$id)
      DF$givenName <- as.character(DF$givenName)
      DF$familyName <- as.character(DF$familyName)
      DF$affilitation <- as.character(DF$affilitation)
      DF$email <- as.character(DF$email)
      rhandsontable(DF,
                    useTypes = TRUE,
                    stretchH = "all")
    })

    ## Save
    observeEvent(input$save, {
      finalDF <- hot_to_r(input$hot)
      write.csv(finalDF, file=file.path(outdir,
                                        sprintf("%s.csv", outfilename)),
                row.names = FALSE)
    })

    ## Message
    output$message <- renderUI({
      if(input$save==0){
        helpText(sprintf("This table will be saved in folder \"%s\" once you press the Save button.", outdir))
      }else{
        outfile <- "creator.csv"
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
