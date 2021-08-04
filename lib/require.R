# requirements:

# CRAN packages
require <- c("tidyverse", "data.table", "lubridate")
there <- installed.packages()[,"Package"]

for (r in require[!require %in% there]){
  install.packages(r)
}

# non-CRAN
devtools::install_github("socioskop/ttools")
