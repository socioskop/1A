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

# configuring 6 months (26 weeks) time-to-event (tte) outcomes 
d$bin_full06 <- as.numeric(NA)
d$tte_full06 <- as.numeric(d$tte_full)
d$bin_full06 <- as.num(d$tte_full06<=26) # upper limit/horizon is 26 weeks (~2)
d$bin_full06[is.na(d$tte_full06)] <- 0

d$tte_full06[d$tte_full06>26] <- 26
d$tte_full06[d$bin_full06==0] <- 26

# configuring 12 months (52 weeks) time-to-event (tte) outcome 
d$bin_full12 <- as.numeric(NA)
d$tte_full12 <- as.numeric(d$tte_full)
d$bin_full12 <- as.num(d$tte_full12<=52) # upper limit/horizon is 52 weeks (~2)
d$bin_full12[is.na(d$tte_full12)] <- 0

d$tte_full12[d$tte_full12>52] <- 52
d$tte_full12[d$bin_full12==0] <- 52


