# data <- read_csv('fitbit_data.csv')
# dbToken <-  readRDS("./shiny_app/storage-drop.rds")
# uniqueID <- "oiashdfoiahjf"
# type <- "raw"

fileNamer <- function(userId, start, end) {
  function(type){
    tempfile(pattern = sprintf("%s_%s_%s_%s_", userId, type, start, end), fileext = ".csv")
  }
}


uploadDataToDropbox <- function(data, dbToken, csvDest){
  try({
    # Make sure if we're uploading no tags to not try and write list to csv. 
    if(length(data) == 0){
      write_csv(dplyr::data_frame(), csvDest) #write the csv to server
    } else {
      write_csv(data, csvDest)
    }
    drop_upload(csvDest, "apps/fitbitDonation/userData/", dtoken = dbToken) #upload to dropbox too.
  })
}



