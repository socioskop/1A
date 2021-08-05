# requirements:

# CRAN packages
require <- c("tidyverse", "data.table", "lubridate", "readxl", "stringr", "optmatch", "kableExtra", "survival", "survminer", "ggplot2", "ggpubr", "foreach")
there <- installed.packages()[,"Package"]

for (r in require[!require %in% there]){
  install.packages(r)
}

# non-CRAN
devtools::install_github("socioskop/ttools")

# ad-hoc functions
boot.glm <- function(model, data, group, rep=1000){
  
  boot.hA = matrix(NA, nrow=rep, ncol=1)
  boot.h0 = matrix(NA, nrow=rep, ncol=1)
  
  e <- data; rm("data")
  
  bs <- foreach(i = seq(rep)) %do% {
    hA = e[sample(nrow(e), size=nrow(e), replace=T),]
    hAfit <- coef(summary(update(model, data=hA)))
    est.hA <- hAfit[grepl(group, rownames(hAfit)),1]
    
    h0=h1
    h0$group <- sample(h0$group, length(h0$group))
    h0fit <- coef(summary(update(model, data=h0)))
    est.h0 <- h0fit[grepl(group, rownames(h0fit)),1]
    return(data.frame(est.h0=est.h0, est.hA=est.hA))
  }
  
  return(do.call(dplyr::bind_rows, bs))
}
