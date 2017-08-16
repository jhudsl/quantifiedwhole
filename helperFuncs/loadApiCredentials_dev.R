####### Code using serialized rds files ##########
firebaseToken <- readRDS("apiCredentials/firebaseToken.rds")
dbToken <- readRDS("apiCredentials/dbToken.rds")

# Local version
# fitbitApiInfo <- readRDS("apiCredentials/fitbitApiInfo_dev.rds")

# deployed to nstrayer/quantifiedwhole
fitbitApiInfo <- readRDS("apiCredentials/fitbitApiInfo_dev_shinyapps.rds")

# saveRDS(fitbitApiInfo, "apiCredentials/fitbitApiInfo_dev_shinyapps.rds")
