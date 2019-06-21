options(stringsAsFactors = FALSE)

## load the packages
library(tidyverse)
library(mongolite)

## connect to the datastore in mongo
m = mongo(url = "mongodb://localhost:27017", 
          collection = "pbp", 
          db = "nhl")
m$info()

## how many records
m$count()

## get all of the records -- all records by default -- select *
games = m$find()
glimpse(games)

gid = data.frame()



######################## iterators via mongolite
## iterator -- limit is the number of records to limit for the full iteration
## iterator is a named list = sweet
## it <- m$iterate('{}', limit = 1)

##  ^^^^^^^^^^^^^^^^

######################## create the gamedata flat file
it <- m$iterate('{}')
game_data = data.frame()

## iterate and do the things
while (!is.null(x<-it$one())){
  ####### game data
  tmp_gd = data.frame(id = x$gamePk, 
                      link = x$link,
                      season = x$gameData$game$season,
                      type = x$gameData$game$type,
                      start = x$gameData$datetime$dateTime,
                      end = x$gameData$datetime$dateTime)
  game_data <<- bind_rows(game_data, tmp_gd)
}

######################## create the venue flat file

it <- m$iterate('{}')
venue_data = data.frame()

## iterate and do the things
while (!is.null(x<-it$one())){
  # if the key isnt there, default value -- not great, but simple to grok
  if (is_null(x$gameData$venue$id)){
    x$gameData$venue$id = -999
  }
  ####### game data
  tmp_df = data.frame(gid = x$gamePk, 
                      id = x$gameData$venue$id,
                      name = x$gameData$venue$name,
                      link = x$gameData$venue$link)
                      
  venue_data <<- bind_rows(venue_data, tmp_df)
}


######################## create the teams

it <- m$iterate('{}', limit = 1)
team_data = data.frame()

## iterate and do the things
while (!is.null(x<-it$one())){
  if (is_null(x$gameData$venue$id)){
    x$gameData$venue$id = -999
  }
  ####### game data
  tmp_df = data.frame(gid = x$gamePk, 
                      away_id = )
  
  team_data <<- bind_rows(team_data, tmp_df)
}



######################## create the players




######################## create the plays


































tmp_game = games[9, ]
