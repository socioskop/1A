# match.R: identifies a matched comparison group.

# setup
rm(list=ls()[!ls() %in% "echo"])
source("./lib/load.R")
library(kableExtra)
library(magrittr)
library(optmatch)

# reads 1A analysis data
d <- readRDS("./data/compiled")
d$n <- 1

# store output tables in list
o <- list()

# specifying variables
xs <- c("n", colnames(d)[!colnames(d) %in% c("id", "study", "n")])
num <- c("age", "unempl", xs[startsWith(xs, "y_")])
bin <- c("male", xs[startsWith(xs, "b_")])

# crude comparison table, before matching
o[["t1_pre"]] <- ttools::ttabulate(d, xs, "treat", num, bin=bin, cal.date = "index", show.na = T, cens=0)

# also print table to png for easy viewing
knitr::kable(o[["t1_pre"]],
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
prds <- xs[!xs %in% c("n", "id", "index", "treat", "unempl", "age")] # unempl not a p-score factor
form <- paste0("as.num(treat=='ONE')~poly(age, 2)+", paste0(prds, collapse="+"))
m <- glm(form, binomial, d)
print(list("fit is reasonable: "=summary(m)))

# get predictions / propensity score
d$p <- predict(m)

# prepare input vectors for optimal matching
p <- d$p
names(p) <- rownames(d)
z <- as.num(d$treat=='ONE')
names(z) <- d$treat

match <- optmatch::pairmatch(p, z=z, controls=2, data=d)
d$match <- as.num(rownames(d) %in% names(match[!is.na(match)]))
d$match <- ifelse(d$match==1 & d$treat=="ONE", "ONE", ifelse(d$match==1 & d$treat=="INT", "ctrl", NA))

# crude comparison table, after matching
o[["t1_post"]] <- ttools::ttabulate(d, xs, "match", num, bin=bin, cal.date = "index", show.na = T, cens=0)
writexl::write_xlsx(o, "./out/t1.xlsx")
# works really well for first attempt. Might keep it here, seems reasonable.

# also print table to png for easy viewing
knitr::kable(o[["t1_post"]],
             format = "html",
             align = "lrrlrlr" ,
             escape = F, row.names = F, caption = "Balance between groups before matcing") %>% 
  kable_styling(
    full_width = F,
    bootstrap_options = c("hover", "condensed" , "bordered"),
    font_size = 14,
    position = "left"
  ) %>% footnote(
    general = paste0("ctrl is the matched comparison group (2:1), ONE is the 1A treatment group"),
    footnote_as_chunk = F,
    escape = T, general_title = ""
  ) %>% kableExtra::as_image(file = "./out/t1_match.png")

saveRDS(d, "./data/match")
