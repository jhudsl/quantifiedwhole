
tabDisableJS <- "
shinyjs.disableTab = function(selector) {
  var tab = $(selector.selector);
  tab.bind('click.tab', function(e) {
    e.preventDefault();
    return false;
  });
  tab.attr('title', 'Need to be logged in!')
  tab.addClass('disabled');
}


shinyjs.enableTab = function(selector) {
  var tab = $(selector.selector);
  tab.attr('title', '')
  tab.unbind('click.tab');
  tab.removeClass('disabled');
}
"


#Spinning helix loader
hideLoader <- function(){
  print("hiding loader")
  shinyjs::hide(selector = "#tag_downloading_animation", anim = TRUE)
}

showLoader <- function(){
  print("showing loader")
  shinyjs::show(selector = "#tag_downloading_animation")
}


disableTabs <- function(){
  js$disableTab(selector = ".nav li a[data-value='Tag Your Data']")
  js$disableTab(selector = ".nav li a[data-value='Shareable Report']")
  js$disableTab(selector = ".nav li a[data-value='Download Your Data']")
}

enableTabs <- function(){
  js$enableTab(selector = ".nav li a[data-value='Tag Your Data']")
  js$enableTab(selector = ".nav li a[data-value='Shareable Report']")
  js$enableTab(selector = ".nav li a[data-value='Download Your Data']")
}
