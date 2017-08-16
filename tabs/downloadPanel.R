downloadPanel <- function(){
  div(id = "download_panel",
    fluidRow(
      column(width = 5,
             h3("Supplied Tags"),
             tableOutput("displayTags"),
             downloadButton('downloadTags')
      ),
      column(width = 5, offset = 2,
             h3("Raw Data"),
             tableOutput("displayRaw"),
             downloadButton('downloadRaw')
      )
    )
  )
}
