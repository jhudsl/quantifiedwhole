# A few functions that make interacting with our firebase database easier. 
# Reference for these functions is available at https://firebase.google.com/docs/reference/rest/database/.

# Basic status code checker. 200 is the good one.
# In the future this may be expanded to deal with other situations
checkStatusCode <- function(queryReturn){
  if( httr::status_code(queryReturn) != 200) {
    stop("Something seems to have gone wrong")
  } else {
    "all good"
  }
}


# Defines what we store per individual in our firebase database. 
# We have all the demographic info inside fitbit so we will just grab their name 
# and also store info on when they logged in and what days weve downloaded for them. 
# This way when they return we won't redownload days and we'll know to look for tags already made. 
userInfoTemplate <- function(userInfoList){
  
  userId <- userInfoList$encodedId
  putBody <- list()
  putBody[[userId]] <- list(
    fullName = userInfoList$fullName,
    firstName = userInfoList$firstName,
    logins = c( as.character(Sys.Date()) ),
    daysPulled = c()
  )
  
  putBody
}


# Takes firebase token and the list of user info returned by the fitbit api and 
# sets up a new user in the users/ section of our firebase database. 
addUser <- function(firebase_token, userInfoList){
  
  # Set up list for basic user info structure.  
  putBody <- userInfoTemplate(userInfoList)
  
  queryUrl <- "https://fitbitdatadonation.firebaseio.com/users.json"
  
  httr::PUT(
    url = queryUrl,
    body = putBody,
    config = httr::config(token = firebase_token),
    encode = "json"
  ) 
}


# Queries our users section of the database and trys to fetch a users info. 
# If there is no response we create a new user entry into the database. 
findUserInFirebase <- function(firebase_token, userInfo){
  
  queryUrl <- sprintf("https://fitbitdatadonation.firebaseio.com/users/%s.json", userInfo$encodedId)
  
  result <- httr::GET(
    url = queryUrl,
    config = httr::config(token = firebase_token),
    encode = "json"
  ) %>% httr::content()
  
  # If our query returns empty.
  if(is.null(result)){
    result <- addUser(firebase_token, userInfo)
  }
  
  # Add a login to their profile
  addLoginTime(firebase_token, userInfo$encodedId)
  
  # Return the info we have on them from firebase (Doesn't include the latest login we just added)
  result
}

# Adds a login instance to a users records. Defaults to moment of call. 
addLoginTime <- function(firebase_token, userId, loginTime = as.character(Sys.time())) {
  
  queryUrl <- sprintf("https://fitbitdatadonation.firebaseio.com/users/%s/logins.json", userId)
  
  newLogin <- httr::POST(
    url = queryUrl,
    body = list(time = loginTime),
    config = httr::config(token = firebase_token),
    encode = "json"
  ) 

  checkStatusCode(newLogin)
 
  return("successfully updated logins")
}

# returns a vector of login times for a user. 
getLoginTimes <- function(firebaseUserData){
  firebaseUserData$logins %>% unlist() %>% as.vector()
}

getAlreadyDownloadedDays <- function(firebaseUserData){
  firebaseUserData$pulledDays %>% unlist() %>% as.vector()
}



