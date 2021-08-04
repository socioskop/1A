# match.R: identifies a matched comparison group.

# setup
rm(list=ls()[!"echo" %in% ls()])
source("./lib/load.R")
library(kableExtra)
library(magrittr)

# reads 1A analysis data
d <- readRDS("./data/1A_compiled")
d$n <- 1

# store output tables in list
o <- list()

# specifying variables
xs <- c("n", colnames(d)[!colnames(d) %in% c("id", "study", "n")])
num <- c("age", "unempl", xs[startsWith(xs, "y_")])
bin <- c("male", xs[startsWith(xs, "b_")])

# crude comparison table, before matching
o[["t0"]] <- ttools::ttabulate(d, xs, "treat", num, bin=bin, cal.date = "index", show.na = T, cens=0)
writexl::write_xlsx(o, "./out/t1.xlsx")

# also print table to png for easy viewing
knitr::kable(o[["t0"]],
             format = "html",
             align = "lrrlrlr" ,
             escape = F, row.names = F, caption = "Balance between groups before matcing") %>% 
  kable_styling(
    full_width = F,
    bootstrap_options = c("hover", "condensed" , "bordered"),
    font_size = 14,
    position = "left"
  ) %>% footnote(
    general = paste0("INT is the comparison groups (IBBIS integrated groups), ONE is the 1A treatment group"),
    footnote_as_chunk = F,
    escape = T, general_title = ""
  ) %>% kableExtra::as_image(file = "./out/t1_crude.png")

# estimating propensity score:
# - using simple logit regression to avoid overfitting 
# - we might switch the model or stratify according to e.g. gender in order to have a reasonable balance after matching
form <- xs[!xs %in% c("n", "id", "index", "treat")]
form <- paste0("as.num(treat=='ONE')~", paste0(form, collapse="+"))
m <- glm(form, binomial, d)
print(list("fit has issues: "=summary(m)))

# 
