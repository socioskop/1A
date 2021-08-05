# Title: build_outcs
# Objective: build dream derived return to work outcomes. All relative to index date.
# for now, just rough measures. All outcomes are scrambled to maintain blinding as long as we are pre-SAP

# setup
rm(list=ls()[!"echo" %in% ls()])
source("./lib/load.R")

# read raw dream data and derived entry dates
e <- readRDS("./data/process_dream")[,c("id", "year", "month", "date", "b", "y", "unempl")]
i <- readRDS("./data/entry")

# scramble! - make sure no groups are revealed before we are ready
# group allocation is left out for now but can be inferred from id range. We redraw id's for now.
i$id <- i$id[sample(1:nrow(i), size = nrow(i))]

# load data
e <- data.table(e, key=c("id", "date"))
e$sgdp.date <- i$sgdp.date[match(e$id, i$id)]

# relative time counter since sgdp.date
e$time <- as.num(as_date(e$date)-as_date(e$sgdp.date))
e$time <- floor(e$time/7)

# employment definition
e[, full := as.num(
  (y=="N/A" | (y=="771")) # no income transfer apart from flexjob (771) accepted
  & !is.na(b)
  )]

# stable employment definition
e[, full := 
    dplyr::lead(
      as.num(full==1
             & dplyr::lag(full, 1)==1
             & dplyr::lag(full, 2)==1
             & dplyr::lag(full, 3)==1)
      , 3), by="id"]
e[is.na(full), full := 0]

# make the stable definition run to the actual end of each streak
e[, n := 1:.N, by="id"]
e[, full := TTR::runMax(full, 4), by="id"]

# initiation and streak id'ing
e[, full.init := as.num(full==1 & dplyr::lag(full)!=1), by="id"]
e[time<0, full.init := 0] # can't start before sgdp.date
e[, full.id := cumsum(full.init), by="id"]

# identify date of first return to stable employment
e[full.init==1 & full.id==1, full.date := date]
e[, full.date := min(full.date, na.rm=T), by="id"]

# count time to event as relative to index date
e[date==full.date, tte_full := time, by="id"]
e[               , tte_full := min(tte_full, na.rm=T), by="id"]
e[!is.finite(tte_full), tte_full := NA]

# wrap up and save outcome and sgdp-index as constants per individual
e <- e[,c("id", "sgdp.date", "full.date", "tte_full")]
e <- unique(e)

saveRDS(e, "./data/outcs")
