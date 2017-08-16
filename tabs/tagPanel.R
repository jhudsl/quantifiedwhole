tagPanel <- function(){
  div(
    div(id = 'tag_visualization',
        dateRangeInput("desiredDaysPicker", "Date range:",
                       start = Sys.Date()-3,
                       end = Sys.Date()),
        
        taggingModuleUI('tagviz')
    ),
    div(id = "tag_downloading_animation",
        div(class = "centered", h1("We're fetching your data!")),
        div(class = "centered", helixLoader())
    )
  )
}