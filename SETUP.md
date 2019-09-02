# About

This document is aimed at helping us get started to replicate the data captured via this repo, locally.

## Requirements

While possible in the cloud, this will assume we are developing locally.

- R / RStudio
- Docker

### Docker

Below are the paths to install Docker locally for both Windows and Mac.  These guides should be 
straight forward enough but if you have a hiccup, don't hesistate to reach out.

For example, on my local Macbook, I know that I have Docker running via a service in my toolbar shown below.

<img src="https://monosnap.com/file/vMoaGecqhRtcgykXXOaAY6mmDsamJr" width="800" />

#### Windows

https://docs.docker.com/docker-for-windows/install/

##### Mac

https://docs.docker.com/docker-for-mac/install/


#### Docker Compose

While Docker allows us to create reproducible compute environments, we can take this a step further and stitch these environments together into a "group" of services that can talk to each other but can be started and run in concert.

This is called Docker Compose.

We can include multiple containters in the same file and network them together.  This runs as a service on our machine and allows us to spin up complicated environments in a reproducible way.

> We do this via a `docker-compose.yml` file.  

Moreover, not only should this work locally, but we can use the same file when spinning up cloud environments.

## Local Data Setup

Once the tools above are confirmed to be installed and running, we can now setup the R environment and get the Docker containers running locally so that we can log the data into data stores for proper data storage.

### R

```
# install.packages("devtools") #if not already installed
# install.packages("tidyverse") #if not already installed
library(tidyverse)
install.packages("mongolite")
library(mongolite)
install.packages("httr")
library(httr)
devtools::install_github("neo4j-rstats/neo4r")
library(neo4r)
```

Above should get you installed with the libraries needed for your R session locally.


### Docker Compose

After cloning the repo locally, and being inside the project as your working directory.  

> NOTE:  RStudio Desktop has a terminal that should allow us to run the command locally from within the IDE.

```
docker-compose up -d
```

The above command should, the first time, install the tooling and infrastructure necessary to run the `docker-compose.yml` file in this repo.

This includes:

- Neo4j, which includes, by default, a web-based (even when running locally) tool to manage our database.
- MongoDB: a NoSQL document-oriented data store that we will use to cache the results of parsing the data from the NHL (unofficial) API for data and stats, as well as a service that does publish NHL data via APIs online.
- MongoExpress: A web-based tool to manage our MongoDB database server.

Test MongoDB:

```
http://localhost:8081/
```

Visit above in a web browser, like Chrome, to see the MongoExpress tool.  If a screen like below, but not exactly, loads, you should be good to go:


<img src="https://monosnap.com/file/XGGSU1jJsCquz6VKQ9BbJjttRBgVMO" width="800" />


Test Neo4j:

The `Neo4j` database, which is a graph-database, does take a minute or two to spin up on our machines.  You should be able to see the Neo4j Desktop tool, which is running on your local machine, in a web browser at the URL below:

```
http://localhost:7474/browser/
```

And see something similar to below:

<img src="https://monosnap.com/file/9k4d2IkXEZpFiTSGVbQqUVnumWv8kf" width="800" />


## Data Import

Assuming above is good to go, we can run through the scripts:

1.  `1-import.R`
1.  `2-explore.R` if you want to poke around.  

The shot model file is not yet complete, but at the very least, the `import` file should work.

The code itself is intended to be run interactively, and not as a program or via `source`.  If/when run interactively, this might help catch local setup issues or bugs in the crawling process.

