# title:  get_1A
# Objective: retrieve time and id indexes for the IBBIS 1A cohort. This is used to build the full population

# setup
rm(list=ls()[!ls() %in% "echo"])
source("./lib/load.R")

# read index dates
d <- readxl::read_excel(Sys.getenv("1A"))
colnames(d) <-  c("id", "henv.dato", "cpr", "udr.dato", "diagnose", "samtykke", "beh.start", "MBSRstart", "beh.slut", "eftervrn.slut")
d$id <- stringr::str_pad(d$id, 4, pad="0")
d$cpr <- gsub("-", "", d$cpr)
d$index <- as.Date(d$udr.dato)
d$treat <- "ONE"
d$study <- "ONE"

# fixing ids, that start with 0 but should be 7k
d$id[startsWith(d$id, "0")] <- paste0("7", substr(d$id, 2, 4))

# reduce
d <- d[,c("cpr", "id", "index", "treat", "study")]

# save cohort index
saveRDS(d, "./data/1A")
