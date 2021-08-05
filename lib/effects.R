# effects.R: estimates treatment effects

# setup
rm(list=ls()[!"echo" %in% ls()])
source("./lib/load.R")
library(kableExtra)
library(survival)
library(survminer)

# reads 1A analysis data
d <- readRDS("./data/match")

