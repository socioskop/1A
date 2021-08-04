# match.R: identifies a matched comparison group.

# setup
rm(list=ls()[!"echo" %in% ls()])
source("./lib/load.R")

# reads 1A analysis data
d <- readRDS("./data/1A_compiled")
d$n <- 1

# store tables in list:
o <- list()

# specifying variables
xs <- c("n", colnames(d)[!colnames(d) %in% c("id", "study", "n")])
num <- c("age", "unempl", xs[startsWith(xs, "y_")])
bin <- c("male", xs[startsWith(xs, "b_")])

# crude comparison table, before matching
o[["t0"]] <- ttools::ttabulate(d, xs, "treat", num, bin=bin, cal.date = "index", show.na = T, cens=0)
writexl::write_xlsx(o, "./out/t1.xlsx")

