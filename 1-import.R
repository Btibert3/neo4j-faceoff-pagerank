options(stringsAsFactors = FALSE)

## load the packages
library(tidyverse)
library(mongolite)
library(httr)
library(neo4r)

## connect to the datastore in mongo
m = mongo(url = "mongodb://localhost:27017", 
          collection = "pbp", 
          db = "nhl")
m$info()

## connect to the neo4j datastore
graph =  neo4j_api$new(
  url = "http://localhost:7474", 
  user = "neo4j", 
  password = "password"
)
graph$ping()


######################## get the games for a season
URL = "http://www.nicetimeonice.com/api/seasons/20182019/games"
games = jsonlite::fromJSON(URL)

## for each game, try to get the game JSON file, and if so, save to mongodb
for (i in 1:nrow(games)) {
  tmp = games[i, ]
  gid = tmp$gameID
  GURL = sprintf("http://statsapi.web.nhl.com/api/v1/game/%s/feed/live", gid)
  resp = GET(GURL)
  pbp = content(resp, as="text")
  m$insert(pbp)
}

## how many records
m$count()


######################## iterators via mongolite
## iterator -- limit is the number of records to limit for the full iteration
## iterator is a named list = sweet
## it <- m$iterate('{}', limit = 1)

##  ^^^^^^^^^^^^^^^^

######################## GAME data
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

## write the dataset for import
write_csv(game_data, "neo4j/import/game_data.csv")

## add the constraints and import
CYPHER = "
LOAD CSV WITH HEADERS FROM 'file:///game_data.csv' as row 
with row
MERGE (n:Game {id:row.id})
ON CREATE SET n += row
"
call_neo4j("CREATE CONSTRAINT ON (n:Game) ASSERT n.id IS UNIQUE;", graph)
call_neo4j(CYPHER, graph)


######################## VENUE data

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

## write the dataset for import
write_csv(venue_data, "neo4j/import/venue_data.csv")

## add the constraints and import
CYPHER = "
LOAD CSV WITH HEADERS FROM 'file:///venue_data.csv' as row 
WITH row
MERGE (n:Venue {id:row.id})
ON CREATE SET n.name = row.name, n.link = row.link
WITH row, n
MATCH (g:Game {id:row.gid})
CREATE (g)-[:PLAYED_AT]->(n)
"
call_neo4j("CREATE CONSTRAINT ON (n:Venue) ASSERT n.id IS UNIQUE;", graph)
call_neo4j(CYPHER, graph)


######################## create the teams

resp = jsonlite::fromJSON("http://statsapi.web.nhl.com/api/v1/teams")
teams = resp$teams
colnames(teams$division) = paste0("division_", colnames(teams$division))
teams = cbind(teams, teams$division)
teams$division = NULL
colnames(teams$conference) = paste0("conference_", colnames(teams$conference))
teams = cbind(teams, teams$conference)
teams$conference = NULL
colnames(teams$franchise) = paste0("franchise_", colnames(teams$franchise))
teams = cbind(teams, teams$franchise)
teams$franchise = NULL
teams$venue = NULL

it <- m$iterate('{}')
team_game = data.frame()

## iterate and do the things
while (!is.null(x<-it$one())){
  tmp_df = data.frame(gid = x$gamePk, 
                      away_id = x$gameData$teams$away$id,
                      home_id = x$gameData$teams$home$id)
  
  team_game <<- bind_rows(team_game, tmp_df)
}

######################## PLAYER data

it <- m$iterate('{}')
players = data.frame()

## iterate and do the things
z = 1
while (!is.null(x<-it$one())){
  # huge list of players
  gid = x$gamePk
  tmp_players = x$gameData$players
  for (i in 1:length(tmp_players)) {
    # player is a list
    tmp_player = tmp_players[[i]]
    # break out the current team to append
    if ("currentTeam" %in% names(tmp_player)) {
      cteam = as_tibble(tmp_player$currentTeam)
      colnames(cteam) = paste0("team_", colnames(cteam))
      tmp_player$currentTeam = NULL
    }
    if ("primaryPosition" %in% names(tmp_player)) {
      # get the position data
      cpos = as_tibble(tmp_player$primaryPosition)
      colnames(cpos) = paste0("position_", colnames(cpos))
      tmp_player$primaryPosition = NULL
    }
    # put the dataframe together for the player
    player = as_tibble(tmp_player)
    if (exists("cteam")){
      player = cbind(player, cteam)
    }
    if (exists("cpos")) {
      player = cbind(player, cpos)
    }
    player$gid = gid
    # append
    players <<- bind_rows(players, player)
  }
  cat("finished ", z, "\n")
  z = z + 1
  rm(gid, tmp_players, i, tmp_player, cteam, cpos, player)
}


######################## PLAYS data

it <- m$iterate('{}')
pbp = data.frame()
pbp_players = data.frame()
pbp_team = data.frame()

## iterate and do the things
abc = 1
while (!is.null(x<-it$one())){
  gid = x$gamePk
  plays = x$liveData$plays$allPlays
  for (i in 1:length(plays)) {
    play = plays[[i]]
    pid = sprintf("%s_%s", gid, i)
    result = as_tibble(play$result)
    goals = as_tibble(play$about$goals)
    play$about$goals = NULL
    about = as_tibble(play$about)
    if (length(play$coordinates) > 0) {
      coords = as_tibble(play$coordinates)
    }
    if ("players" %in% names(play)) {
      play_players = data.frame()
      for (p in 1:length(play$players)) {
        tmp_player = play$players[[p]]
        tmp_plyr = data.frame(pid = tmp_player$player$id, ptype = tmp_player$playerType)
        play_players = bind_rows(play_players, tmp_plyr)
        rm(tmp_player, tmp_plyr)
      }
      play_players$gid = gid
      play_players$pid = pid
      pbp_players = bind_rows(pbp_players, play_players)
      rm(play_players)
    }
    if ("team" %in% names(play)) {
      tmp_play_team = as_tibble(play$team)
      tmp_play_team$gid = gid
      tmp_play_team$pid = pid
      pbp_team = bind_rows(pbp_team, tmp_play_team)
      rm(tmp_play_team)
    }
    # put together the play
    tmp_pbp = cbind(about, result)
    tmp_pbp = cbind(tmp_pbp, goals)
    tmp_pbp$gid = gid
    tmp_pbp$pid = pid
    if (exists("coords")){
      tmp_pbp = cbind(tmp_pbp, coords)
    }
    if ("strength" %in% colnames(tmp_pbp)) {
      tmp_pbp$strength = NULL
    }
    # bind the data
    pbp = bind_rows(pbp, tmp_pbp)
    # cleanup
    rm(play, pid, result, goals, about)
  }
  cat("finished ", abc, "\n")
  abc = abc + 1
}


































