library(shiny)
library(tidyverse)
library(lubridate)
# devtools::install_github("jhudsl/fitbitr", force = TRUE)
library(fitbitr)
library(base64enc)
library(V8)
library(shinyjs)
library(rdrop2)

# UI elements
source('tabs/appCSS.R')
source('tabs/helixLoader.R')
source('tabs/welcomePanel.R')
source('tabs/tagPanel.R')
source('tabs/reportPanel.R')
source('tabs/downloadPanel.R')

# Server-side helpers
source('helperFuncs/makeDesiredDays.R')
source('helperFuncs/showAndHideFuncs.R')
source('helperFuncs/reportGenerator.R')
source("helperFuncs/dropboxHelpers.R")
source("helperFuncs/firebaseHelpers.R")
source("helperFuncs/apiLimitMessage.R")

# Set dev to false if deploying to shinyapps. Dev = true uses Nick's api info that is setup for local development. 
dev <- TRUE

# Load all the super secret api info. 
if(dev){
  source("helperFuncs/loadApiCredentials_dev.R")
} else {
  source("helperFuncs/loadApiCredentials.R")
}

ui <- fluidPage(
  useShinyjs(),
  extendShinyjs(text = tabDisableJS),
  title = "Quantified Whole",
  tags$head(
    tags$style(type="text/css", appCSS)
  ),
  tabsetPanel(id = "tabset",
    tabPanel( "Welcome",           welcomePanel() ),
    tabPanel( "Tag Your Data",     tagPanel() ),
    tabPanel( "Shareable Report",  reportPanel() ),
    tabPanel( "Download Your Data",downloadPanel() )
  )
)

server <- function(input, output) {
  
  ############################################# Initializations #############################################
  # These are all things that get run once at the start of a given user's session. 
  # They set up the framework for the subsequent reactive sections. 
  
  # Initialize the app state here. 
  state <- isolate({reactiveValues()})
  
  # Call reducer script to set up reducer function with state context. 
  source("helperFuncs/reducer.R", local = TRUE)
  
  # Run state through empty reducer to initialize
  isolate({reducer()})

  # Start with the tabs disabled as the user isn't logged in yet.
  disableTabs()

  # Fitbit authentication button. 
  loginButton <- callModule(shinyLogin, "fitbit_login", api_info = fitbitApiInfo)
  
  # Initialize a holder for the user tags function. This allows us to be able to 
  # call an observerEvent on it but also call it within another observe event as well. Hacky and probably not the best way.
  userTags <- callModule(taggingModule, 'tagviz', data = state$daysProfile)
  
  
  ############################################# Event Observers #############################################
  # Here we watch for things that can happen as our app is running, sending the results to the appropriate
  # reducer functions. Reducers go at the end after whatever intermediary logic we need beforehand. 
  
  # Watch for the user logging in. 
  observeEvent(loginButton(), {
    # Unlock the tabs and also show a loader for downloading data. 
    enableTabs()
    showLoader()
    
    # Set the state for the user token to its returned value.
    reducer(type = "ADD_FITBIT_TOKEN", payload = loginButton())
    reducer(type = "SET_DESIRED_DAYS", payload = input$desiredDaysPicker)
  })
  
  
  observeEvent(state$userToken, {
    # Grab users name and id from api and send it to app state
    userInfo <- tryApi(getUserInfo, state$userToken)
    req(querySuccess(userInfo)) #stop if the query failed. User will have popup telling them what happened. 

    # Get our user metadata from firebase. 
    userStats <- findUserInFirebase(firebaseToken, userInfo)
    
    # Find what days they have already downloaded. 
    previouslyDownloaded <- getAlreadyDownloadedDays(userStats)
    
    # Set the user info in the state and also add previously downloaded days. 
    reducer(type = "SET_USER_INFO", payload = userInfo)
    reducer(type = "ADD_DOWNLOADED_DAYS", payload = previouslyDownloaded)
  })
  
  
  observeEvent(input$desiredDaysPicker, {
    # We require user token because otherwise this will fire at startup and we will 
    # accidentally try and grab data with not api token.
    req(state$userToken) 
    # If the user has logged in and subsequently changed the date range from the default update data. 
    reducer(type = "SET_DESIRED_DAYS", payload = input$desiredDaysPicker)
  })
  
  observeEvent(state$desiredDays, {
    # Reshow the loader as we're going to start downloading data. 
    showLoader()

    # We need to try catch here in case the user goes over the api limit. 
    profile <- tryApi(getPeriodProfile, token = state$userToken, desired_days = state$desiredDays)
    req(querySuccess(profile))
    
    # Set up the dropbox file upload temp locations.
    # Eventually if storage becomes an issue we may want to optimize this by not re-downloading duplicates.
    dbFileNames <- fileNamer(state$userInfo$id, state$desiredDays[1], tail( state$desiredDays,n=1))
    
    reducer(type = "ADD_DAYS_PROFILE", payload = profile)
    reducer(type = "SET_FILE_PATHS", payload = list(raw = dbFileNames("raw"), tags = dbFileNames("tag")))
  })
  
  
  # When the user's day profile downloads...
  observeEvent(state$daysProfile, {
    # The downloading is done so we can hide the loader icon. 
    hideLoader()
    
    # Set up call module with the new data. Double arrow so it impacts the previous userTags variable
    userTags <<- callModule(taggingModule, 'tagviz', data = state$daysProfile)

    # Update the user report
    output$reportPlot <- callModule(activityReport, 'userReport',state$daysProfile)
    
    # Upload the raw data to dropbox.
    uploadDataToDropbox(state$daysProfile, dbToken, state$filePaths$raw)
    
    # Add newly downloaded dates to the already downloaded list.
    reducer(type = "ADD_DOWNLOADED_DAYS", payload = state$desiredDays)
  })
  
  # userTags() will fire when the user has created a new tag. 
  observeEvent(userTags(), {
    print(userTags())
    reducer(type = "SET_ACTIVITY_TAGS", payload = userTags())
  })
  
  # After new tags have been added to the state send them to dropbox as well. 
  observeEvent(state$activityTags, {
    print(state$activityTags)
    uploadDataToDropbox(state$activityTags, dbToken, state$filePaths$tags)
  })
  
  ############################################# Output Bindings #############################################
  # This is where the actual UI is bound. Basically these just watch our state and make the screen look
  # like is should for a given scenario. 
  
  output$userName <- renderText({ 
    # They have no name but they have a token means they went over api limit
    if(is.null(state$userInfo$name) && !is.null(state$userToken)){
      return("Try back shortly!")
    } else if (!is.null(state$userInfo$name)) {
      return(sprintf("Welcome back %s!", state$userInfo$name))
    } else {
      return("Login to get tagging!")
    }
  })
  
  # Update the downloads page with actual data.
  output$displayRaw <- renderTable(state$daysProfile %>% head())
  
  # Tag data table and download button
  output$displayTags <- renderTable(state$activityTags)
  
  output$downloadTags <- downloadHandler(
    filename = "my_activity_tags.csv",
    content = function(file) {
      write.csv(state$activityTags, file)
    }
  )
  
  # Raw data table and download button
  output$downloadRaw <- downloadHandler(
    filename = "my_fitbit_data.csv",
    content = function(file) {
      write.csv(state$daysProfile, file)
    }
  )
 
}

# Run the application
shinyApp( ui = ui, server = server, options = c("port" = 1410) )
