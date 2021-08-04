# name: IBBIS_incl_1A.R
# objc: compile a index for whole IBBIS population, including the 1A addon.
# --    This population contains: id, cpr, assessment date, estimated date of sickleave (sgdp.date).
# --    To control the quality, we compare local indexes with existing indexes from IBBISmaster, 
# --    where the INT group members are cross-classified in both sources.

# setup
rm(list=ls()[!"echo" %in% ls()])
source("./lib/load.R")
library(tidyverse)

# 
# read IBBIS main data (rct + master file) and stack with the 1A population
e <- bind_rows(readRDS("./data/IBBIS")[,c("cpr", "id", "index", "treat", "study", "sickleavedate")],
               readRDS("./data/1A")[,c("cpr", "id", "index", "treat", "study")])

# merge with ctrls derived from the IBBIS-INT groups
e <- merge(e, 
           readRDS("./data/entry"), 
           by="id", all=T)

# get demographics from cpr
e$male <- as.num(substr(e$cpr, 09, 10))
e$male <- ifelse(e$male/2!=round(e$male/2), 1, ifelse(e$male/2==round(e$male/2), 0, NA))

e$age <- substr(e$cpr, 1, 6)
e$age <- paste0(substr(e$age, 1, 2), "-", substr(e$age, 3, 4), "-", ifelse(substr(e$age, 5, 6)>"20", "19", "20"), substr(e$age, 5, 6))
e$age <- floor(as.num(as.Date(e$index.x)-as.Date(e$age, "%d-%m-%Y"))/365.25)

# kill cpr number, not use full from here on
e$cpr <- NULL
e$id <- as.chr(e$id)

# check concordance
plot(as.num(e$index.x), as.num(e$index.y)) # should match 100%
plot(as.num(e$index.w), as.num(e$index.y)) # should match within week
summary(as.num(e$index.x)-as.num(e$index.y)) # should be 0
summary(as.num(e$index.w)-as.num(e$index.y)) # should be a few days
summary(as.num(e$index.w)-as.num(e$sgdp.date))
summary(as.num(e$sickleavedate)-as.num(e$sgdp.date)) # Diff from empirical (inferred) to reported (partially missing by design) should be around -21. OK.

# we need to add background covariates from DREAM as other socio-demographic registry sources are not viable in local environment
d <- readRDS("./data/process_dream")
d <- data.table(d[d$time<0 & d$time>= -104,], key=c("id", "time")) # we only use two years lookback

# import map of branches to identify most frequent branches and use them as propensity score factors
dict <- unique(readxl::read_xlsx("./raw/Dansk-Branchekode-2007-(DB07)-v3-2014.xlsx")[,c("HOVEDGRUPPEKODE", "HOVEDGRUPPE")])
colnames(dict) <- c("code", "labl")
dict$code <- stringr::str_pad(dict$code, 2, pad="0")
codes <- unique(dict$code)

for (c in codes){
  if (sum(substr(d$b, 1, 2)==c, na.rm=T)==0){next}
  name <- paste0("b", c)
  d[, (name) := as.num(substr(b, 1, 2)==c)]
  d[, (name) := max(get(name)), by="id"]
}


# wrap up for analysis purposes
saveRDS(e, "./data/1A_compiled")

# describe string data
d <- e
tab <- data.frame(var=colnames(d), stringsAsFactors = F)
tab$uniques <- sapply(d, function(x) length(unique(x)))
tab$NAs <- sapply(d, function(x) sum(is.na(x)))
tab$chars <- sapply(d, function(x) paste0(unlist(names(table(nchar(trimws(x))))), collapse=", "))
tab$mean <- sapply(d, function(x) round(mean(x), 1))
tab$min <- sapply(d, function(x) round(min(as.num(x)), 1))
tab$max <- sapply(d, function(x) round(max(as.num(x)), 1))
writexl::write_xlsx(tab, "./out/desc_pop.xlsx")

