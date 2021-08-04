# Title: process_dream.R
# Objective: derive key index variables from DREAM

# setup
rm(list=ls()[!"echo" %in% ls()])
source("./lib/load.R")

# reads main data, which includes DREAM data and all relevant keys:
d <- readRDS("./data/compile_pop")

# add monthly unemployment rate (Statistics Denmark)
u <- readxl::read_excel(Sys.getenv("unempl"), skip = 2)[,3:4]
u$year <- as.num(substr(u$...3, 1, 4))
u$mmonth <- as.num(substr(u$...3, 6, 7))
colnames(u) <- c("period", "unempl", "year", "month")
u <- u[,c("year", "month", "unempl")]

# indices of dream wide variables
cs <- colnames(d)
bs <- cs[grepl("branche_", cs)]
ys <- cs[startsWith(cs, "y_0") | startsWith(cs, "y_1") | startsWith(cs, "y_2")]

# build grid of dates
dates <- seq(as.Date("2008-01-01"), as.Date("2021-01-01"), 1)
dates <- dates[lubridate::wday(dates)==7]
dates <- data.frame(date=dates, stringsAsFactors = F)

# attach to dateweeks observed in DREAM
dgrid <- substr(ys, 3, 6)
dgrid <- dgrid[substr(dgrid, 1, 1) %in% c("0", "1", "2")]
dgrid <- ISOweek::ISOweek2date(paste0("20", substr(dgrid, 1, 2), "-W", substr(dgrid, 3, 4), "-6"))
dgrid <- data.frame(date=dgrid, month=month(dgrid), year=year(dgrid))
dgrid <- dgrid[order(dgrid$date),]
dgrid <- merge(dgrid, dates, by="date", all.y=T)

# extract b-codes (signifying employment)
b <- data.table::data.table(d[,c("id", "index", bs)])
b <- data.table::melt.data.table(b, id.vars=c("id", "index"), variable.name="time", value.name="b")
b$time <- gsub("branche_", "b_", as.chr(b$time))
b$year <- as.num(substr(b$time, 3, 6))
b$month <- as.num(substr(b$time, 8, 9))
b$index.w <- ISOweek::date2ISOweek(b$index)
b$index.w <- paste0(substr(b$index.w, 1, 9), "6")
b$index.w <- ISOweek::ISOweek2date(b$index.w)

# check that index/week mapping ok
plot(b$index [b$id>7000], b$index.w[b$id>7000]) 

b <- merge(dgrid, b, by=c("year", "month"), all=T)
b$time <- as.num(floor((b$date-b$index.w)/7))
b <- b[b$time>= -110 & b$time<=110,]
b <- merge(b, u, by=c("year", "month"), all=T)

# extract y-codes
y <- data.table::data.table(d[,c("id", "index", ys)])
y <- data.table::melt.data.table(y, id.vars=c("id", "index"), variable.name="time", value.name="y")
y$time <- as.chr(y$time)
y$year <- as.num(paste0("20", substr(y$time, 3, 4)))
y$week <- as.num(substr(y$time, 5, 6))
y$date <- ISOweek::ISOweek2date(paste0(y$year, "-W", stringr::str_pad(y$week, 2, pad="0"), "-6"))
y$time <- NULL
y[is.na(y), y := "N/A"] # hardcoding NAs are important, as they consitute a value. Regular NAs added while merging or similar are not valid values

# join y and b codes in weekly indexes
e <- merge(b, y, by=c("id", "index", "year", "date"))

# save long data
saveRDS(e, "./data/process_dream")


