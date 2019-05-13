options(stringsAsFactors = FALSE)

## load the packages
library(neo4r)
library(httr)
library(jsonlite)
library(dplyr)

## connect to the neo4j database
con = neo4j_api$new(url = "http://localhost:7474", 
                    user = "neo4j", 
                    password = "password")
con$ping() == 200

## get the games for 2018/19 season as a df using jsonlite
URL = "http://www.nicetimeonice.com/api/seasons/20182019/games"
games_raw = GET(URL) %>% content(., as = "text")
games = jsonlite::fromJSON(games_raw)







