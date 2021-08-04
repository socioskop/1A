# Title: compile_pop.R
# Objective: 1st level compilation + adding id/cpr key + cut to relevant observations

# setup
rm(list=ls()[!"echo" %in% ls()])
source("./lib/load.R")

# load and stack IBBIS1A and controls
p <- bind_rows(readRDS("./data/1A"),
               readRDS("./data/ctrls"))
if (length(unique(p$cpr))<nrow(p)){stop("dupes present, need fixing...")} else {print("population is defined, no dupes")}
saveRDS(p, "./data/pop")

# adding DREAM components and verifying coverage
d <- readRDS("./data/dream")
if (sum(!(p$cpr %in% d$cpr))){stop("some individuals not linked to DREAM db")} else {print("all individuals linked to DREAM db")}
d <- d[d$cpr %in% p$cpr & d$id %in% p$id,]
if (sum(!p$cpr %in% d$cpr)){stop("some individuals not linked to DREAM db")} else {print("all individuals linked to DREAM db")}
if (sum(!p$id %in% d$id)){stop("some ids not linked to DREAM db")} else {print("all ids linked to DREAM db")}

# add dream data to cases+ctrls cohort
d <- merge(p, d, by=c("id", "cpr"))
saveRDS(d, "./data/compile_pop")