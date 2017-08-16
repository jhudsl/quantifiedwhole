# Trying out a spiral chart for a report. 

# library(tidyverse)
# 
# data <- read_csv('fitbit_data.csv')
# data <- read_csv('my_fitbit_data_big.csv')

chartWidth  <- 200 #mm
chartHeight <- 300 #mm

generateReport <- function(data){
  
  # data <- data %>% filter(type != 'heart rate')
  timeLabels <- c("midnight", "1 am",  "2",  "3",  "4",  "5",  "6",  "7",  "8",  "9",  "10", "11", "noon", "1 pm", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11")
  minsInDay  <- 24*60
  
  totalDays <- data$date %>% unique() %>% length()
  
  lineThickness <- ( chartWidth/ 6) /totalDays
  
  formatedData <- data %>% 
    arrange(date) %>% 
    mutate(day = as.integer(difftime(date, min(date), units = "days"))) %>% 
    mutate(minute = time/60,
           totalMins = ((day - 1)*minsInDay) + minute,
           posInDay = 2*minute/minsInDay) 
  
  maxTotalMins <- max(formatedData$totalMins)
  
  plot <- formatedData %>% 
    ggplot(aes(x = posInDay, y = totalMins, color = value, group = as.character(day))) + 
    viridis::scale_color_viridis(option = 'C') + 
    coord_polar() + 
    geom_line(size = lineThickness) +
    theme_minimal() + 
    facet_wrap(~type, ncol=1, strip.position = "bottom") +
    scale_x_continuous(breaks = 0:23/12, labels = timeLabels) +
    ylim(-maxTotalMins*0.75, maxTotalMins) +
    theme(
      axis.text.y = element_blank(),
      text = element_text(family = "Georgia"),
      strip.text = element_text(size = 14, vjust = 0.5),
      panel.grid.minor.y = element_blank(),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.x = element_blank()
    ) + 
    labs(x = "", y = "", color = "", title = "My Heartrate and Steps", subtitle = "Data gathered from my Fitbit and visualized using Quantified Whole")

  plot
}

# generateReport(data)
reportCSS <- "
.shiny-image-output img { 
  width: 90%; 
  border: 1px solid black; 
  box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
  margin-bottom: 35px;
}
"
activityReportUI <- function(id){
  ns <- NS(id)
  div(
    tags$style(type="text/css", reportCSS),
    imageOutput(ns('userReport'), width = "100%")
  )
}



activityReport <-  function(input, output, session, data){
  
  output$userReport <- renderImage({
    outfile <- tempfile(fileext = ".png")
    report <- generateReport(data)
    ggsave(outfile, report, width = chartWidth, height = chartWidth, units = "mm", dpi = 300)
    
     # Return a list containing information about the image
    list(src = outfile,
         contentType = "image/png",
         alt = "This is alternate text",
         width = "100%"
         )
  }, deleteFile = TRUE)
  
  result <- reactive({output$userReport})
  return(result)
  
}

