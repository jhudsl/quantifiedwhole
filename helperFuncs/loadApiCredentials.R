# This file uses the library secret to encript server-side tokens 
# for both dropbox and firebase. It is sourced in our app.js file
# and thus loads the tokens from the vault at the initialization 
# of the shiny instance. Since both tokens are httr oauth ones
# they will auto-refresh when they get stale if the shiny instance
# runs for a long time. 

# We are using the R package secrets to encript our api values. 
# No need to be scared about commiting something bad anymore! 


# This is the location of our "vault" in the project directory. 

# If you need to add a user you do it here. 
# add_user('n.strayer@vanderbilt.edu', local_key()$pubkey, vault = vault)

## This is the logic to get a token and then store it. The most important "secret" part of this is the json file. 
# firebase_token <- googleAuthR::gar_auth_service(
#   json_file="fitbitdatadonation-firebase-adminsdk-p35yx-30b97f62d7.json",
#   scope = c("https://www.googleapis.com/auth/firebase.database", "https://www.googleapis.com/auth/userinfo.email"))
# 

# add_secret("firebaseToken", firebase_token, users = c("n.strayer@vanderbilt.edu"), vault = vault)
# firebaseToken <- get_secret("firebaseToken", key = local_key(), vault = vault)

## Dropbox api stuff
# add_secret("dbToken", dbToken, users = c("n.strayer@vanderbilt.edu"), vault = vault)
# dbToken <- get_secret("dbToken", key = local_key(), vault = vault)


######## Code using encription #########
# library(secret)
# vault <- here::here("apiVault")
# firebaseToken <- get_secret("firebaseToken", key = local_key(), vault = vault)
# dbToken <- get_secret("dbToken", key = local_key(), vault = vault)


####### Code using serialized rds files ##########
firebaseToken <- readRDS("apiCredentials/firebaseToken.rds")
dbToken <- readRDS("apiCredentials/dbToken.rds")
fitbitApiInfo <- readRDS("apiCredentials/fitbitApiInfo.rds")
