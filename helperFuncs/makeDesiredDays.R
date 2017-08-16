

# Takes a number of days to pull and a day at which to start pulling and returns an array of dates
# in character format starting at startDay and going back numberOfDays days.
makeDesiredDays <- function(numberOfDays = 7, startDay = Sys.Date()){
  
  endDay <- startDay - lubridate::days(numberOfDays)
  
  as.character(seq(startDay, endDay, "-1 days"))
}

makeDateRange <- function(dateArray){
  as.character(seq(dateArray[2], dateArray[1], "-1 days"))
}
