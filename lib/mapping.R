# Title: mapping.R
# Objective: mapping for DREAM y-codes and branch codes

# setup
rm(list=ls()[!"echo" %in% ls()])
source("./lib/load.R")

# import map of branches to identify most frequent branches and use them as propensity score factors
branches <- unique(readxl::read_xlsx("./raw/Dansk-Branchekode-2007-(DB07)-v3-2014.xlsx")[,c("HOVEDGRUPPEKODE", "HOVEDGRUPPE")])
colnames(branches) <- c("code", "labl")
branches$code <- stringr::str_pad(branches$code, 2, pad="0")

y_codes <- 
  list(
      "none" =c("N/A"),
      "dgp"  =c("111", "115", "213", "217"),
      "edu"  =c("651", "652", "521"),
      "sgdp" =c("774", "890", "893", "897", "899"),
      "baby" =c("881"),
      "flex" =c("740", "771"), #740 is also unemployed
      "disab"=c("783"), 
      "pens" =c("998", "621", "996"),
      "cash" =c("130", "133", "140", "143", "700", "723", "727", "730", "733", "870"), 
      "reval"=c("755", "764", "810", "817", "873")
    )

mapping <- list(branches=branches,
             y_codes=y_codes)
saveRDS(mapping, "./data/mapping")
