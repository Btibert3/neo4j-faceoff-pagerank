import hockey_scraper
import requests
import pandas as pd
from py2neo import Graph, Node, Relationship

# get the 2018/19 gameids
URL = "http://www.nicetimeonice.com/api/seasons/20182019/games"
resp = requests.get(URL)
data = resp.json()

# list of games
games = pd.DataFrame(data)
gids = list(games.gameID)

# game_data = scraped_data = hockey_scraper.scrape_games([int(gids[1])], False, data_format='Pandas')
# game_pbp = game_data['pbp']
# game_pbp.to_pickle("hs-game-pbp.pkl")

#-------------

# connect to neo4j
driver = Graph(user="neo4j", password="password")
driver.schema.create_uniqueness_constraint("Game", "id")
driver.schema.create_uniqueness_constraint("Play", "id")

## nhl game data
GURL = "http://statsapi.web.nhl.com/api/v1/game/{}/feed/live".format(gids[1])
resp = requests.get(GURL)
game = resp.json()
game.keys()

## create the game node
gid = game['gamePk']
g = Node("Game", id=gid)
driver.create(g)

## get the plays
plays = game['liveData']['plays']['allPlays']

## test code for parsing
# index = 169
# play_data = plays[index]
# play = play_data['result']
# play.update(play_data['about'])
# del play['goals']
# del play['strength']
# play.update(play_data['about']['goals'])
# play.update(play_data['coordinates'])
# play['id'] = "{}_{}".format(gid, index+1)
# p = Node.cast(play)  ## cast from a dict
# p.add_label("Play") ## add the label I want
# driver.create(p) ## create the node
# r = Relationship(g, "HAD_PLAY", p)
# driver.create(r)

for index, play_data in enumerate(plays):
  ## here
  play = play_data['result']
  play.update(play_data['about'])
  if 'goals' in play.keys():
    del play['goals']    
  if 'strength' in play.keys():
    del play['strength']    
  play.update(play_data['about']['goals'])
  play.update(play_data['coordinates'])
  play['id'] = "{}_{}".format(gid, index+1)
  p = Node.cast(play)  ## cast from a dict
  p.add_label("Play") ## add the label I want
  driver.create(p) ## create the node
  r = Relationship(g, "HAD_PLAY", p)
  driver.create(r)
  print("finished {}".format(index))


