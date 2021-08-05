# effects.R: estimates treatment effects

# setup
rm(list=ls()[!"echo" %in% ls()])
source("./lib/load.R")
library(kableExtra)
library(survival)
library(survminer)

# reads 1A analysis data
d <- readRDS("./data/outcs")
d$id <- paste0("i", d$id)

d <- merge(readRDS("./data/match"), 
           d, by="id")

# configuring time-to-event (tte) outcomes 
d$bin_full <- as.num(d$tte_full<=104)
d$bin_full[is.na(d$tte_full)] <- 0

d$tte_full[d$tte_full>104] <- 104
s <- surv
