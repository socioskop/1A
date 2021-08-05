# Title: get_ctrls.R
# Objective: load in the indices of the basic IBBIS RCT cohorts 

# setup
rm(list=ls()[!ls() %in% "echo"])
source("./lib/load.R")

# read index dates
load(Sys.getenv("ibbis_master"), x <- new.env()); x <- x$ibbismaster
load(Sys.getenv("ibbis_rct"), d <- new.env()); d <- d$ibbisRCTgrand

# fix hardcoded NAs
d <- d %>% 
  mutate(across(where(is.character), ~na_if(., "")))

# generate ids
d$id <- stringr::str_pad(d$pnumber, 4, pad="0")
d$index <- as.Date(d$asscompldate)
d$treat <- d$randomresultpseudo
d$study <- d$rctallocationopen

# just needs cpr/id which is added in later step
key <- readxl::read_xlsx(Sys.getenv("dream_keys"))
d$cpr <- gsub("-", "", key$cprnumber[match(d$id, key$pnumber)])

# reduce
ctrls <- d[d$treat=="INT" & !is.na(d$treat),c("cpr", "id", "index", "treat", "study", "sickleavedate")]

# save cohort index
saveRDS(ctrls, "./data/ctrls")

# save all data for further reduction before export
saveRDS(d, "./data/IBBIS")


