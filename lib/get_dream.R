# Title: get_dream.R
# Objective: load in DREAM database and pick relevant variables

# setup
rm(list=ls()[!ls() %in% "echo"])
source("./lib/load.R")

# load data
load(Sys.getenv("dream"), d <- new.env()); d <- d$dreamfu24raw
d$id <- stringr::str_pad(d$pnumber, 4, pad="0")

c <- colnames(d)
ys <- c[substr(c, 1, 2)=="y_"]
bs <- c[substr(c, 1, 8)=="branche_"]

# adding id for controls
key <- readxl::read_xlsx(Sys.getenv("dream_keys"))
d$cpr <- gsub("-", "", key$cprnumber[match(d$id, key$pnumber)])

# still needs cpr from the 1A cohort 
key <- readxl::read_excel(Sys.getenv("1A_keys"))
d$cpr[d$id %in% key$pnumber] <- gsub("-", "", key$cprnumber)[match(d$id[d$id %in% key$pnumber], gsub("-", "", key$pnumber))]

# wrapping up
d <- d[,c("id", "cpr", ys, bs)]
saveRDS(d, "./data/dream")



