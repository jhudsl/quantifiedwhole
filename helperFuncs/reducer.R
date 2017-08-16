# source(here::here('shiny_app/helperFuncs/rredux.R'))
# Every single state entry will get passed an action. It's given reducer will then deal with it. 
# The default or initial value will be given as a default function parameter. This is because on startup
# the state will be run through with an empty action. 

alreadyDownloadedDays_reducer <- function(alreadyDownloadedDays = c(), action){
  if(action$type == "ADD_DOWNLOADED_DAYS"){
    newDays <- action$payload
    return(unique(c(state$alreadyDownloadedDays, newDays)))
  } else {
    return(alreadyDownloadedDays)
  }
}

desiredDays_reducer <- function(desiredDays = c(), action){
  if(action$type == "SET_DESIRED_DAYS"){
    newDesiredDays <- makeDateRange(action$payload)
    return(newDesiredDays)
  } else {
    return(desiredDays)
  }
}

daysProfile_reducer <- function(daysProfile = NULL, action){
  if(action$type == "ADD_DAYS_PROFILE"){
    newDaysProfile <- action$payload
    return(newDaysProfile)
  } else {
    return(daysProfile)
  }
}

activityTags_reducer <- function(activityTags = NULL, action){
  if(action$type == "SET_ACTIVITY_TAGS"){
    newActivityTags <- action$payload
    return(newActivityTags)
  } else {
    return(activityTags)
  }
}


userToken_reducer <- function(token = NULL, action){
  if(action$type == "ADD_FITBIT_TOKEN"){
    newToken <- action$payload
    return(newToken)
  } else if( action$type == "REMOVE_FITBIT_TOKEN" ){
    newToken <- NULL
    return(newToken)
  } else {
    return(token)
  }
}

userInfo_reducer <- function(info = list(name = NULL, id = NULL), action){
  if(action$type == "SET_USER_INFO"){
    # Currently we're just pulling this from their profile. 
    userName <- action$payload$firstName
    userID   <- action$payload$encodedId
    return(list(name = userName, id = userID))
  } else if( action$type == "REMOVE_USER_INFO" ){
    newInfo <- list(name = NULL, id = NULL)
    return(newInfo)
  } else {
    return(info)
  }
}

filePaths_reducer <- function(paths = list(raw = NULL, tags = NULL), action){
  if(action$type == "SET_FILE_PATHS"){
    newPaths <- action$payload
    return(newPaths)
  } else if( action$type == "REMOVE_FILE_PATHS" ){
    newPaths <- list(raw = NULL, tags = NULL)
    return(newInfo)
  } else {
    return(paths)
  }
}


# Takes the current state and runs the provided action through all of its componenets 
# Mutates state because that's how reactiveValues needs it, but keeps it all localized in one place 
# You could entirely provide the functionality in this function, however i think it's clearer to 
# break out into individual pure functions for each element. 
reducer <- function(type = "INITIALIZE", payload = NULL){
  print(paste("running the action", type))
  actionList <-  list(type = type, payload = payload)
  
  # if its first time we run all the reducers on their respective state components. 
  init = type == "INITIALIZE"
  
  if(type == "ADD_DOWNLOADED_DAYS" | init){
    state$alreadyDownloadedDays = alreadyDownloadedDays_reducer(state$alreadyDownloadedDays, actionList)
  }
  
  if(type == "SET_DESIRED_DAYS" | init){
    # A vector of dates we want to pull
    state$desiredDays = desiredDays_reducer(state$desiredDays, actionList)
  }
  
  if(type == "ADD_DAYS_PROFILE" | init){
    # Data from the desiredDays
    state$daysProfile = daysProfile_reducer(state$daysProfile, actionList)
  }
  
  if(type == "SET_ACTIVITY_TAGS" | init){
    # Data on activity tags. Supplied by our viz (but also previous tags eventually.)
    state$activityTags = activityTags_reducer(state$activityTags, actionList)
  }
 
  if(type %in% c("ADD_FITBIT_TOKEN", "REMOVE_FITBIT_TOKEN") | init ){
    # Oauth token for fitbits api.
    state$userToken = userToken_reducer(state$userToken, actionList)
  }
  
  if(type %in% c("REMOVE_USER_INFO", "SET_USER_INFO") | init) {
    # Name and fitbit id of the user from the fitbit api. 
    state$userInfo = userInfo_reducer(state$userInfo, actionList)
  }
  
  if(type %in% c("SET_FILE_PATHS", "REMOVE_FILE_PATHS") | init){
    # Where we want to store the data from the user. 
    state$filePaths = filePaths_reducer(state$filePaths, actionList)
  }
  
  # print(reactiveValuesToList(state))
}
# 
# isolate({reducer()})
# isolate({reducer(type = "ADD_FITBIT_TOKEN", payload = "oihadoifahdoiufhasp9dufhadioufhadiufh")})
# isolate({reducer(type = "ADD_DOWNLOADED_DAYS", payload = c(1,2,3))})
