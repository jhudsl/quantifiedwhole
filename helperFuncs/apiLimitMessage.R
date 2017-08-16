apiLimitMessage <- function(){
  showModal(modalDialog(
    title = "Uh Oh",
    "Looks like we got overzelous and tried to pull too much data. Currently we're limited in how much data we can pull per-hour. Try back a little later and we should be good.",
    easyClose = TRUE
  ))
}

tryApi <- function(queryFunc, ...){
  tryCatch(queryFunc(...),
           error = function(c) { 
             apiLimitMessage()
             disableTabs()
             return(NULL)
           }
  )
}

querySuccess <- function(val) !is.null(val)