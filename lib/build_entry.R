# Title: build_entry
# Objective: build inclusion dates from dream data. Definitions are tricky to implement, lots of View() required to assert.

# setup
rm(list=ls()[!"echo" %in% ls()])
source("./lib/load.R")

# reading processed dream data (still long format)
e <- readRDS("./data/process_dream")
e <- data.table(e, key=c("id", "time"))

# approximate first week of eligibility (3 weeks after first sgdp transfer) (sgdp: 'Sygedagpenge', sickness benefit)
e[, sgdp      := as.num(substr(y, 1, 2)=="89" | substr(y, 1, 3)=="774"), by="id"]
e[, sgdp      :=
    dplyr::lead(
      as.num(
        sgdp==1 
        & dplyr::lag(sgdp, 1)==1
        & dplyr::lag(sgdp, 2)==1
        & dplyr::lag(sgdp, 3)==1), 3
    )]
e[, sgdp.init := as.num(sgdp==1 & dplyr::lag(sgdp)!=1), by="id"] # identify first entry
e[, sgdp.id   := cumsum(sgdp.init), by="id"]                     # give sgdp streaks a running id
e[sgdp.init==1, sgdp.date := as_date(date)]                      # identify first date in each id
e[,sgdp.dist  := as.num(sgdp.date-as_date(index.w))]             # get their distance from inferred index week

# restric initiations to the latest before week of assessment (index.w)
e$sgdp.date <- NA
e[sgdp.dist<=1, sgdp.dist.max := max(sgdp.dist, na.rm=T), by="id"] # index should be prior to sgdp initiation
e[, sgdp.dist.max := max(sgdp.dist.max, na.rm=T), by="id"]         # get max initiation distance within individuals 
e[sgdp.dist==sgdp.dist.max, sgdp.date := date, by="id"]            # get latest sgdp.date from the instances just before index w
e[, sgdp.date := as_date(max(sgdp.date, na.rm=T)+21), by="id"]     # we add three weeks to emulate a probable inclusion date 

# keep only those with valid baseline dates (one is removed because of single constant pension benefit)
f <- e[e$date==e$sgdp.date & is.finite(e$sgdp.date)]
print(paste0("individuals lost without valid sgdp date: ", length(unique(e$id))-length(unique(f$id))))

# reduce
f <- unique(f[,c("id", "index", "index.w", "sgdp.date")])

saveRDS(f, "./data/entry")
