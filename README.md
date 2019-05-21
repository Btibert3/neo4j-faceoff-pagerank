# About

Pagerank for NHL faceoffs (mark's tennis post) using neo4j in docker, apoc, etc.

## Docker

```
docker-compose up -d
```

which comes with:

- neo4j - parse the logs into a graph model
- mongo - to hold the original json files and cache for ETL
- mongo express (port 8081)


## data

http://statsapi.web.nhl.com/api/v1/game/2018030311/feed/live

nicetimeonice api

faceoffs have flag (for this season) winner and loser

