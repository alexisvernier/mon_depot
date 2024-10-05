 library(rjson)
library(rsconnect)

account <- 'sotteville'

credentials <- fromJSON(file="rsconnect.json")

app_name <- 'delinquance'
app_dir <- '.'

rsconnect::setAccountInfo(name=credentials$name, 
token=credentials$token, 
secret=credentials$secret)

rsconnect::deployApp(appName = app_name, 
                     appDir = app_dir, 
                     account = 'sotteville', 
                     forceUpdate = T,
                     launch.browser = T)