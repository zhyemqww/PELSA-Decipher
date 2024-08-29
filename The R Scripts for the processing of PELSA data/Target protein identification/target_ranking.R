setwd("D:/my data/R/demo/Target protein identification")

library(dplyr)
library(tidyverse)


# Import Bayes results ----------------------------------------------------

pelsa_k562 <- read.csv("export_bayes_protein_stau_K562.csv",header = T)
pelsa_hela <- read.csv("export_bayes_protein_stau_HeLa.csv",header = T)


# Group into stabilized and destabilized ----------------------------------

## hela
pelsa_hela $ alteration <- ifelse(pelsa_hela$Log2FC <0, "stabilized","destabilized")
pelsa_hela <- arrange(pelsa_hela,desc(alteration))
pelsa_hela$kinase.count <-0
table(pelsa_hela$is.kinase=="yes")
pelsa_hela$kinase.count[pelsa_hela$is.kinase=="yes"]<- c(1:254)
pelsa_hela$rank <-c(1:nrow(pelsa_hela))


## k562
pelsa_k562 $ alteration <- ifelse(pelsa_k562$Log2FC <0, "stabilized","destabilized")
pelsa_k562 <- arrange(pelsa_k562,desc(alteration))
pelsa_k562$kinase.count <-0
table(pelsa_k562$is.kinase=="yes")
pelsa_k562$kinase.count[pelsa_k562$is.kinase=="yes"]<- c(1:254)
pelsa_k562$rank <-c(1:nrow(pelsa_k562))



# Ranking -----------------------------------------------------------------

## HeLa
str(pelsa_hela)
pelsa_hela$rank <- as.numeric(pelsa_hela$rank)
for (i in pelsa_hela$rank) {
  pelsa_hela[i,]$kinase.count <- ifelse(pelsa_hela[i,]$kinase.count==0,pelsa_hela[i-1,]$kinase.count,pelsa_hela[i,]$kinase.count)
  i<-i+1                
}

## K562
str(pelsa_k562)
pelsa_k562$rank <- as.numeric(pelsa_k562$rank)
for (i in pelsa_k562$rank) {
  pelsa_k562[i,]$kinase.count <- ifelse(pelsa_k562[i,]$kinase.count==0,pelsa_k562[i-1,]$kinase.count,pelsa_k562[i,]$kinase.count)
  i<-i+1                
}


# Export results ----------------------------------------------------------

write.csv(file=paste0("export_target_ranking_K562_stau",".csv"),pelsa_k562,row.names = F)
write.csv(file=paste0("export_target_ranking_HeLa_stau",".csv"),pelsa_hela,row.names = F)
