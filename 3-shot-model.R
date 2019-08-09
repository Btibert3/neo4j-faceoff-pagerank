options(stringsAsFactors = FALSE)

## the packages
library(tidyverse)
devtools::install_github("keithmcnulty/neo4jshell")
library(neo4jshell)

## get the moneypuck data
MP_URL = "http://peter-tanner.com/moneypuck/downloads/shots_2018.zip"
if(!dir.exists("datasets")) {dir.create("datasets")}
download.file(MP_URL, destfile = "datasets/201819.zip")
unzip("datasets/201819.zip", exdir = "datasets/")

## read in the shot data
shots <- read_csv("datasets/shots_2018.csv")
View(head(shots, 25))

## query the shot data