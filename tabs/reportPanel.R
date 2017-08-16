
reportPanel <- function(){
  div(id = "report_panel",
      p("Here's a high-res plot of your activity over the past week for you to share with everyone!",
        style = "padding-top: 25px;"),
      hr(),
      activityReportUI('userReport')
  )
}