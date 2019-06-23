options(stringsAsFactors = FALSE)

## load the packages
library(tidyverse)
library(neo4r)

## connect to the neo4j datastore
graph =  neo4j_api$new(
  url = "http://localhost:7474", 
  user = "neo4j", 
  password = "password"
)
graph$ping()

## what do we have
CYPHER = "
CALL apoc.meta.stats 
yield labelCount, 
      relTypeCount, 
      propertyKeyCount, 
      nodeCount, 
      relCount, 
      labels, 
      relTypes, 
      stats
"
db_stats = call_neo4j(CYPHER, graph, output = "json")
x = jsonlite::fromJSON(db_stats)[[1]]
x$row
x$meta


## event types
CYPHER = "
MATCH (p:Play)
WITH  p
RETURN p.eventTypeId, count(*) as total
LIMIT 5
"
event_types = call_neo4j(CYPHER, graph, type="row", output="json")
library(RNeo4j)
g = startGraph("http://localhost:7474/db/data/", username="neo4j", password="password")
cypher(g, CYPHER)
