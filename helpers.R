options(stringsAsFactors = FALSE)

## function to collect the game and return json
collect_game = function(gid) {
  # build the game url
  PBPURL = "http://statsapi.web.nhl.com/api/v1/game/%s/feed/live"
  gurl = sprintf(PBPURL, gid)
  # try to the game
  raw_pbp = tryCatch(GET(gurl), error=function(e) e)
  if (inherits(raw_pbp, "error")) {
    cat("ERROR: problem retrieving game ", gid, "\n")
    next
  }
  # parse the game 
  pbp_txt = content(raw_pbp, as="text")
  pbp = fromJSON(pbp_txt)
  if ("message" %in% names(pbp)) {
    cat("ERROR: problem retrieving game ", gid, "\n")
    next
  }
  # livedata are the plays, gamedata is the metadata for the game (players, teams)
  return(pbp)
}



# 
# 
# 
# ## function to parse the data into 1 large dataframe by extracting out
# ## the parsed list-dataframes in a list
# ## game object saved
# parse_game = function(pbp) {
#   # extract the gameid and compontents
#   gid = pbp$gamePk
#   playsdf = pbp$liveData$plays$allPlays
#   results = playsdf$result
#   about = playsdf$about
#   coords = playsdf$coordinates
#   players = playsdf$players
#   team = playsdf$team
# 
#   # # put on the gameids as the joining factor
#   # results$gid = gid
#   # about$gid = gid
#   # coords$gid = gid
#   # players$gid = gid
#   # team$gid = gid
#   results$rid = 1:nrow()
#   
#   # cleanup
#   result$strength = NULL
#   about$goals = NULL
#   
#   # build the dataset
#   df = cbind(results, about)
#   df = cbind(df, coords)
#   
#   
# }
# 
# 
# 
# 
# 
# 
# # look into purr stuff
# gid = pbp$gamePk
# playsdf = pbp$liveData$plays$allPlays
# pbp_result = playsdf$result
# pbp_result[1:5,]
# pbp_about = playsdf$about
# pbp_about[1:5, ]
# pbp_coords = playsdf$coordinates
# pbp_coords[1:5, ]
# pbp_team = playsdf$team
# pbp_team[1:5, ]
# pbp_players = playsdf$players
# pbp_players[1:5]
# 
# 
