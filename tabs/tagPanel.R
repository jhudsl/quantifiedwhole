tagPanel <- function(){
  div(
    div(id = "tag_downloading_animation",
        div(class = "centered", h1("We're fetching your data!")),
        div(class = "centered", helixLoader())
    ),
    div(id = 'tag_visualization',
        fluidRow(
          column(3, style = 'padding: 10px',
            dateRangeInput("desiredDaysPicker",
                          label = 'Select Date Range', 
                          start = Sys.Date() - 3,
                          end = Sys.Date() 
            )
          ),
          column(3,
            actionButton("submitDates", "Grab Data")
          ),
          column(1,
            h3("Steps", id = "stepsLegend"),
            offset = 2
          ),
          column(2,
            h3("Heart Rate", id = "hrLegend")
          )
        ),
        taggingModuleUI('tagviz')
    )
  )
}