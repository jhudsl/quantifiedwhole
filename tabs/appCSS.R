appCSS <- "
body {
  font-family: 'optima';
}

.container-fluid { 
  max-width: 1000px;
  margin: 0 auto;
}

#welcome_header {
  display: flex;
  flex-wrap: wrap;
  padding: 15px 0px;
  justify-content: space-between;
}

#login_bar {
  display: flex;
  align-items: center;
  border: 1px solid dimgrey;
  padding: 10px;
  border-radius: 8px;
  background: aliceblue;
}

#login_bar button {
  margin: 0px 10px;
  box-shadow: 1px 1px 3px 0px;
  background: snow;
  border-radius: 7px;
  height: 40px;
  padding: 0px 10px;
}

#login_bar div {
  padding: 10px;
}

@media (max-width: 550px) {
  #login_bar {
    width: 100%;
  }
}

.centered {
  display: flex;
  justify-content: center;
}

.disabled {
  background-color: lightgrey !important;
  color: darkgrey !important;
  cursor: default !important;
  border-color: #aaa !important;
}
"