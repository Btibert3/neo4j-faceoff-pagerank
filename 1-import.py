# import hockey_scraper
# 
# # get the season
# hockey_scraper.scrape_seasons([2018], True)

# # imports
# # from py2neo import Graph
# from neo4j import GraphDatabase
# import requests
# import pandas as pd
# 
# both drivers not working
# 
# # # connect
# # driver = GraphDatabase.driver("bolt://localhost:7687", auth=("neo4j", "password"))
# # 
# # # get the 2018/19 gameids
# # URL = "http://www.nicetimeonice.com/api/seasons/20182019/games"
# # resp = requests.get(URL)
# # data = resp.json()
# # 
# # # put into pandas df
# # game_ids = pd.DataFrame(data)
# # 
# # # set the constraints
# # # graph.schema.create_uniqueness_constraint('Game', 'id')
# # # db.schema.create_uniqueness_constraint('Game', 'id')
# # with driver.session() as session:
# #   session.
# # 
