options(stringsAsFactors = FALSE)

## load the packages
library(neo4r)
library(httr)
library(jsonlite)
library(dplyr)
library(RNeo4j)

## Neo4j database locally
# IMPORT = "/Users/btibert/Library/Application Support/Neo4j Desktop/Application/neo4jDatabases/database-ceeee7f5-c21e-4d03-8e51-564ece0f16b1/installation-3.5.3/import"


## connect to the neo4j database with neo4r
con = neo4j_api$new(url = "http://localhost:7474", 
                    user = "neo4j", 
                    password = "password")
con$ping() == 200

## connect to the graph with RNeo4j
graph = startGraph("http://localhost:7474/db/data/",
                   username = "neo4j",
                   password = "password")

## get the games for 2018/19 season as a df using jsonlite
URL = "http://www.nicetimeonice.com/api/seasons/20182019/games"
games_raw = GET(URL) %>% content(., as = "text")
games = jsonlite::fromJSON(games_raw)


## set the constraints using neo4r
call_neo4j("CREATE CONSTRAINT ON (n:Game) ASSERT n.id IS UNIQUE;", con)

## source the helpers
source("helpers.R")

## for each game, parse into neo4j
## 1000000% hacky, but not looking for elegance right now, just want data for a post
start = Sys.time()
for (game in games$gameID) {
  # get the pseudo-parsed nhl game json into R
  x = collect_game(game)
  
  # create the game node using RNeo4j
  g = getOrCreateNode(graph, "Game", id = x$gamePk)
  
  # extract the data elements
  playsdf = x$liveData$plays$allPlays
  results = playsdf$result
  about = playsdf$about
  coords = playsdf$coordinates
  players = playsdf$players
  team = playsdf$team
  
  # write the results data
  results$strength = NULL
  results$gid = x$gamePk
  results$rid = 1:nrow(results)
  tmp_j = toJSON(results, dataframe="rows")
  tmp_l = rjson::fromJSON(tmp_j)
  for (i in 1:length(tmp_l)) {
    # create the node using RNeo4j from a list
    # that was cleansed for empty keys
    x_list = tmp_l[[i]]
    p = createNode(graph, "Play", x_list)
    createRel(g, "HAD_PLAY", p)
    if (i > 1) {
      cql = sprintf("MATCH (p2:Play {rid: %d}) RETURN p2", i-1)
      p2 = getSingleNode(graph, cql)
      createRel(p2, "NEXT_PLAY", p)
    }
  }
  
  # 
  
}
Sys.time - start




