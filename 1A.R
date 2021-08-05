# R master run file for IBBIS 1A pipeline

# setup
rm(list=ls())
source("./lib/require.R")

# set echo or not
echo=T

# skip build phase?
skip=T

# log
con = file(paste0("./log/1A_", Sys.time(), ".log"))

sink(file=con, append=T)
print(paste0("init at ", Sys.time()))

if (!skip){
  # get 1A population data (id + index date)
  source("./lib/get_1A.R", 
         echo = echo, print.eval = echo, max.deparse.length = 1e5)
  
  # get control population data (id + index date)
  source("./lib/get_ctrls.R", 
         echo = echo, print.eval = echo, max.deparse.length = 1e5)
  
  # load and cut dream data
  source("./lib/get_dream.R", 
         echo = echo, print.eval = echo, max.deparse.length = 1e5)
  
  # compile the two populations to one and add dream data
  source("./lib/compile_pop.R", 
         echo = echo, print.eval = echo, max.deparse.length = 1e5)
  
  # process dream: convert index date to treatment inclusion date
  source("./lib/process_dream.R", 
         echo = echo, print.eval = echo, max.deparse.length = 1e5)
  
  # build date of entry from dream
  source("./lib/build_entry.R", 
         echo = echo, print.eval = echo, max.deparse.length = 1e5)
  
  # build outcomes from dream
  source("./lib/build_outcs.R", 
         echo = echo, print.eval = echo, max.deparse.length = 1e5)
  
  # build mapping/dictionaries
  source("./lib/mapping.R", 
         echo = echo, print.eval = echo, max.deparse.length = 1e5)
  
  # compile data for analysis
  source("./lib/compile.R", 
         echo = echo, print.eval = echo, max.deparse.length = 1e5)
} else {print("skipping build phase...")}

# post SAP-commitment:
# matching
source("./lib/match.R",
       echo = echo, print.eval = echo, max.deparse.length = 1e5)

# done
print(paste0("done at ", Sys.time()))
sink()
