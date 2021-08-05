# name: IBBIS_incl_1A.R
# objc: compile a index for whole IBBIS population, including the 1A addon.
# --    This population contains: id, cpr, assessment date, estimated date of sickleave (sgdp.date).
# --    To control the quality, we compare local indexes with existing indexes from IBBISmaster, 
# --    where the INT group members are cross-classified in both sources.

# setup
rm(list=ls()[!ls() %in% "echo"])
source("./lib/load.R")
library(tidyverse)

# read IBBIS main data (rct + master file) and stack with the 1A population
e <- bind_rows(readRDS("./data/ctrls")[,c("cpr", "id", "index", "treat", "study", "sickleavedate")],
               readRDS("./data/1A")[,c("cpr", "id", "index", "treat", "study")])

# merge with ctrls derived from the IBBIS-INT groups
e <- merge(e, 
           readRDS("./data/entry"), 
           by="id", all=F)

# get demographics from cpr
e$male <- as.num(substr(e$cpr, 09, 10))
e$male <- ifelse(e$male/2!=round(e$male/2), 1, ifelse(e$male/2==round(e$male/2), 0, NA))

e$age <- substr(e$cpr, 1, 6)
e$age <- paste0(substr(e$age, 1, 2), "-", substr(e$age, 3, 4), "-", ifelse(substr(e$age, 5, 6)>"20", "19", "20"), substr(e$age, 5, 6))
e$age <- floor(as.num(as.Date(e$index.x)-as.Date(e$age, "%d-%m-%Y"))/365.25)

# kill cpr number, not use full from here on
e$cpr <- NULL

# check concordance
plot(as.num(e$index.x), as.num(e$index.y)) # should match 100%
plot(as.num(e$index.w), as.num(e$index.y)) # should match within week
summary(as.num(e$index.x)-as.num(e$index.y)) # should be 0
summary(as.num(e$index.w)-as.num(e$index.y)) # should be a few days (within weekdays)
summary(as.num(e$index.w)-as.num(e$sgdp.date)) # difference would be measurement error since we infer it (same method) for both groups
summary(as.num(e$sickleavedate)-as.num(e$sgdp.date)) # Diff from empirical (inferred) to reported (partially missing by design) should be around -21. OK.

# we need to add background covariates from DREAM as other socio-demographic registry sources are not viable in local environment
d <- readRDS("./data/process_dream")
d <- d[d$id %in% e$id,]
u <- d[d$time==0,c("id", "unempl")] # grab unempl measured at baseline for later join 

d <- data.table(d[d$time<0 & d$time>= -104,], key=c("id", "time")) # we only use two years lookback

mapping <- readRDS("./data/mapping")

# branch code attachment
codes <- unique(mapping$branches$code)

for (c in codes){
  if (sum(substr(d$b, 1, 2)==c, na.rm=T)==0){next}
  name <- paste0("b_", c)
  d[, (name) := as.num(substr(b, 1, 2)==c)]
  d[, (name) := as.num(sum(get(name), na.rm=T)>=1), by="id"]
}

bs <- paste0("b_", codes)
bs <- bs[bs %in% colnames(d)]

# y-code attachment
codes <- mapping$y_codes

for (c in names(codes)){
  cs <- codes[[c]]
  if (sum(d$y %in% cs, na.rm=T)==0){next}
  
  name <- paste0("y_", c)
  d[, (name) := as.num(y %in% cs)]
  d[, (name) := sum(get(name), na.rm=T), by="id"]
}

ys <- paste0("y_", names(codes))
ys <- ys[ys %in% colnames(d)]

d <- unique(as.data.frame(d)[,c("id", bs, ys)])
d[sapply(d, is.infinite)] <- NA

# drop branches with prevalence < 5%
drop <- sapply(d[,bs], function(x) mean(x, na.rm=T))
d[,bs[drop<.05]] <- NULL
bs <- bs[bs %in% colnames(d)]

# merge with dream covariates 
e <- merge(e, d, by="id")
e <- merge(e, u, by="id") # ... and unempl rate at baseline
e$id <- as.chr(paste0("i", e$id)) # not publishing actual ids

# basic data description
d <- e
tab <- data.frame(var=colnames(d), stringsAsFactors = F)
tab$uniques <- sapply(d, function(x) length(unique(x)))
tab$NAs <- sapply(d, function(x) sum(is.na(x)))
tab$chars <- sapply(d, function(x) paste0(unlist(names(table(nchar(trimws(x))))), collapse=", "))
tab$mean <- sapply(d, function(x) round(mean(x, na.rm=T), 2))
tab$min <- sapply(d, function(x) round(min(as.num(x), na.rm=T), 1))
tab$max <- sapply(d, function(x) round(max(as.num(x), na.rm=T), 1))
print(tab)
writexl::write_xlsx(tab, "./out/desc.xlsx")
 
# wrap up for analysis purposes
e$index <- e$index.x
e <- e[,c("id", "index", "study", "treat", "male", "age", "unempl", bs, ys)]

saveRDS(e, "./data/compiled")
