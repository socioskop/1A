# effects.R: estimates treatment effects

# setup
rm(list=ls()[!ls() %in% "echo"])
source("./lib/load.R")
library(kableExtra)
library(survival)
library(survminer)
library(ggpubr)
library(ggplot2)
library(foreach)

# reads 1A analysis data
d <- merge(readRDS("./data/match"), 
           readRDS("./data/o/outcs"), by="id")
d <- merge(d, readRDS("./data/o/in06"), by="id")
d <- merge(d, readRDS("./data/o/in12"), by="id")
d <- merge(d, readRDS("./data/o/at06"), by="id")
d <- merge(d, readRDS("./data/o/at12"), by="id")

# configuring 6 months (26 weeks) time-to-event (tte) outcomes 
d$bin_full06 <- as.numeric(NA)
d$tte_full06 <- as.numeric(d$tte_full)
d$bin_full06 <- as.num(d$tte_full06<=26) # upper limit/horizon is 26 weeks (~2)
d$bin_full06[is.na(d$tte_full06)] <- 0

d$tte_full06[d$tte_full06>26] <- 26
d$tte_full06[d$bin_full06==0] <- 26

# configuring 12 months (52 weeks) time-to-event (tte) outcome 
d$bin_full12 <- as.numeric(NA)
d$tte_full12 <- as.numeric(d$tte_full)
d$bin_full12 <- as.num(d$tte_full12<=52) # upper limit/horizon is 52 weeks (~2)
d$bin_full12[is.na(d$tte_full12)] <- 0

d$tte_full12[d$tte_full12>52] <- 52
d$tte_full12[d$bin_full12==0] <- 52

# estimate treatment effects:

# plot employment over time to get a feel and check data integrity
f <- as.rdf(readRDS("./data/o/full"))
f$match <- d$match[match(f$id, d$id)]
f$treat <- d$treat[match(f$id, d$id)]
f$treat[f$treat=="INT"] <- "ctrl"
f$treat[f$treat=="ONE"] <- "1A"
f$match[f$match=="ONE"] <- "1A"

plot = list()
for (cond in c("treat", "match")){
  f$cond <- f[[cond]]
  g <- aggregate(full~time+cond, f[!is.na(f[cond]),], mean)
  plot[[paste0(cond, "_g")]] <- 
    ggplot(g)+
    geom_line(mapping=aes(time, full, color=cond), size=1.5)+
    labs(color = "", title=NULL, subtitle=ifelse(cond=="match", "Matched controls", "No matching"), x="Weeks", y="Proportion in stable return to work")+
    theme_bw()+ylim(c(0, .75))+xlim(c(0, 52))
}

u <- aggregate(unempl~time+match, f, mean)
plot[["unempl"]] <- ggplot(u)+
  geom_line(mapping=aes(time, unempl, color=match), size=1.5)+
  labs(color = "", title=NULL, subtitle="", x="Weeks", y="Avg. unemployment rate at baseline")+
  theme_bw()+ylim(c(2.5, 5))+xlim(c(0, 52))

ggarrange(plotlist = plot, common.legend = T, vjust = T, hjust = T, align = "v", ncol = 3)
ggsave("./out/proportions.png", scale=1.2, width=9, height=3.5)
rm(list=c("f", "g", "u", "plot"))

print(list("unempl rate and condition overlap: " =table(d$unempl, d$treat)))

      