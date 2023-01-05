setwd("D:/my data/R/demo/Affinity")
library(limma)
library(stringr)
library(tidyverse)
library(drc)
library(progress)
library(outliers)
library(dplyr)
library(pheatmap)


# import ------------------------------------------------------------------

## import protein contaminants
contam <- read.csv("contamination_protein.csv",header = T)

## import dataset
data <- read.csv("original_R2HG_jurkat_dd.csv",header = T,na.strings = "Filtered")
data <-na.omit(data)

## one peptide assign to one uniProtId
data$last <- (regexpr(';', as.character(data$PG.UniProtIds))-1) # if no ";" then = -1
data$UID <- ifelse(data$last > 0, (substr(as.character(data$PG.UniProtIds),1,data$last)),
                   (as.character(data$PG.UniProtIds)))
data$last <- NULL
colnames(data)

## remove protein contaminants
data $is.con <- "no"
con_row <- which(data$UID %in% contam$UID)
data[con_row,]$is.con <- "yes"
table(data$is.con)
data<- subset(data,is.con=="no")




# experiment design -------------------------------------------------------

## set replication ***
n <- 4
colnames(data)

## arrange the data by concentration points
colnames(data)
data <- data[c(1:9,22:29,10:21,30)]

## rename colnames (# set concentration )*****
colnames(data) <- c("Gene.names","PG.ProteinDescriptions","Protein.IDs","Sequence", "PEP.PeptidePosition",paste0("NorIntensity_R2HG_",c(rep("000uM",n),rep("020uM",n),rep("200uM",n),rep("001mM",n),rep("005mM",n),rep("010mM",n)),c(paste0("_Rep",1:n))),"UID")
data_temp <- na.omit(data)




# CV calculation ----------------------------------------------------------

str(data_temp)
NorIntensity_col <- grep("NorIntensity", colnames(data_temp))
min(NorIntensity_col)

## change factor to numeric
for (i in min(NorIntensity_col):max(NorIntensity_col)) {
  data_temp[,i] <- as.numeric(as.character(data_temp[,i]))
}
str(data_temp)
colnames(data_temp)

## calculate outliers
for (i in c("000uM","020uM","200uM","001mM","005mM","010mM")) { #****
  grp=grep(i,colnames(data_temp))
  data_temp[,paste0("outliers_",i)]=apply(data_temp[,grp], 1, outlier)
}

## replace outliers with NA
for (a in c("000uM","020uM","200uM","001mM","005mM","010mM")) { #****
  for (i in  paste0(a,c("_Rep1","_Rep2","_Rep3","_Rep4"))) { #****
    grp=grep(i,colnames(data_temp))
    data_temp[,paste0("NorIntensity_R2HG_",i)] <- 
      ifelse(data_temp[,paste0("NorIntensity_R2HG_",i)]== data_temp[,paste0("outliers_",a)], NA,data_temp[,paste0("NorIntensity_R2HG_",i)])
  }
}

## calculate CV
Cal_CV=function(x){sd(x,na.rm = T)/mean(x,na.rm = T)}
for (i in c("R2HG_000uM","R2HG_020uM","R2HG_200uM","R2HG_001mM","R2HG_005mM","R2HG_010mM")) { #****
  grp=grep(i,colnames(data_temp))
  data_temp[,paste0("CV_",i)]=apply(data_temp[,grp], 1, Cal_CV)
}
getwd()

##export dataset without outliers ----------------------------------------------------------------
write.csv(file=paste0("export_R2HG_Jurkat_dd_remove_outliers",".csv"),data_temp,row.names = F)


## remove peptides with CV > 0.5
data <- read.csv("export_R2HG_Jurkat_dd_remove_outliers.csv",header = T,na.strings = "Filtered")
colnames(data)

data$max_cv <- apply(data[,c(37:42)],1,max)
data <- subset(data, data$max_cv<0.5)
head(data)
colnames(data)


# peptide level drc fitting ------------------------------------------

NorIntensity_col <- grep("NorIntensity", colnames(data))
min(NorIntensity_col)
##change factor to numeric 
for (i in min(NorIntensity_col):max(NorIntensity_col)) {
  data[,i] <- as.numeric(as.character(data[,i]))
}

##calculate average intensity
for (i in c("R2HG_000uM_","R2HG_020uM_","R2HG_200uM_","R2HG_001mM_","R2HG_005mM_","R2HG_010mM_")) { #****
  grp=grep(i,colnames(data))
  data[,paste0("Average_Intensity_",i)]=apply(data[,grp], 1,function(x)mean(x,na.rm = T))
}
head(data)

## normalize to "average_0nM"
for (i in c("000uM","020uM","200uM","001mM","005mM","010mM")) {#***
  data[,paste0("ratio_",i,"_000uM")]=data[,paste0("Average_Intensity_R2HG_",i,"_")]/data[,paste0("Average_Intensity_R2HG_","000uM_")]
}

## log2 transformed
for (i in c("000uM","020uM","200uM","001mM","005mM","010mM")) {#***
  data[,paste0("log_Average_",i,"_000uM")]=log(data[,paste0("Average_Intensity_R2HG_",i,"_")]/data[,paste0("Average_Intensity_R2HG_","000uM_")],2)
}



colnames(data)
## select ratio column to fit drc
library(dplyr)
library(tidyverse)
Sim_tan_cal <- data %>% dplyr::select(Sequence,PEP.PeptidePosition,Gene.names,PG.ProteinDescriptions,Protein.IDs,contains("ratio"))
colnames(Sim_tan_cal)
does_dependent_calEC50 <- Sim_tan_cal %>% gather(concentration,Ratio,paste0("ratio_","000uM","_000uM"):paste0("ratio_","010mM","_000uM"))


##reset state counter
state <- c(0)
subset_target <- Sim_tan_cal

## add progress bar for monitoring
pb <- progress_bar$new(total = length(subset_target$Sequence))
subset_target$EC50<-0
subset_target$R2<-0
subset_target$lower <- 0
subset_target$upper <- 0
EC50.col <- grep("EC50",colnames(subset_target))
R2.col <- grep("R2",colnames(subset_target))
lower.col <- grep("lower",colnames(subset_target))
upper.col <- grep("upper",colnames(subset_target))

for (peptide in subset_target$Sequence) {
  pb$tick()
  state <- state + 1
  #*****
  data_peptide <- data.frame(conc=c(log10(0),log10(2e-5),log10(2e-4),log10(1e-3),log10(5e-3),log10(1e-2)),ratio=does_dependent_calEC50[does_dependent_calEC50$Sequence==peptide,]$Ratio)
  data_peptide <- na.omit(data_peptide)
  peptide_drm <- tryCatch(
    drm(ratio~conc,data=data_peptide,fct = LL.4(),logDose = 10),
    error=function(e){ print("Correlation LL.4 failed, L.4 backup performed");return(NA)}
  )
  
  
  # export PEC50
  subset_target[state,EC50.col] <- tryCatch(
    round(-log(coef(peptide_drm)[[4]],base =10),digits = 4),
    error=function(e){return(NA)}
  )
  
  # export lower
  subset_target[state,lower.col] <- tryCatch(
    as.numeric(coef(peptide_drm)[2]),
    error=function(e){return(NA)}
  )
  
  # export upper
  subset_target[state,upper.col] <- tryCatch(
    as.numeric(coef(peptide_drm)[3]),
    error=function(e){return(NA)}
  )
  
  
  # export R
  subset_target[state,R2.col] <- tryCatch(
    round((cor(data_peptide$ratio, fitted(peptide_drm), method = "pearson"))^2,digits = 4),
    error=function(e){return(NA)}
  )
  
}


## export all peptides affinity --------------------------------------------
write.csv(file = paste0("export_R2HG_Jurkat_allPeptide_affinity",".csv"),subset_target,row.names = F)



# select protein of interest ----------------------------------------------------

## import
data_final <- read.csv("export_R2HG_allPeptide_affinity_Jurkat.csv",header = T,na.strings = "Filtered")

target <-  read.csv("proteins_of_interest.csv",header = T)

## filter
colnames(data_final)
colnames(target)
data_final$ target <- ifelse(data_final$Protein.IDs %in% target$UID,"yes","no")
table(data_final$target)

data_final <- subset(data_final,target=="yes")
colnames(data_final)



# import peptide-level bayes results --------------------------------------

name <- "10mM"
R2HG_Jurkat_10mM <- read.csv(paste0("export_bayes_R2HG_Jurkat_rep4_",name,"_inRun24",".csv"),header = T)
colnames(R2HG_Jurkat_10mM)
R2HG_Jurkat_10mM <- R2HG_Jurkat_10mM[c(2,3,13)]
colnames(R2HG_Jurkat_10mM)<- c("log2FC_10mM","log10pvaue_10mM","sequence")

name <- "5mM"
R2HG_Jurkat_5mM <- read.csv(paste0("export_bayes_R2HG_Jurkat_rep4_",name,"_inRun24",".csv"),header = T)
R2HG_Jurkat_5mM <- R2HG_Jurkat_5mM[c(2,3,13)]
colnames(R2HG_Jurkat_5mM)<- c("log2FC_5mM","log10pvaue_5mM","sequence")


R2HG_Jurkat_bayes_conc2 <- left_join(R2HG_Jurkat_10mM,R2HG_Jurkat_5mM,by="sequence")
R2HG_Jurkat_bayes_conc2 $ is.signif <- ifelse(R2HG_Jurkat_bayes_conc2$log10pvaue_10mM >2 |R2HG_Jurkat_bayes_conc2$log10pvaue_5mM >2, "yes","no")
colnames(R2HG_Jurkat_bayes_conc2)
names(R2HG_Jurkat_bayes_conc2)[3]<- "Sequence" 

## combine bayes results with peptide affinity data 
data_final <- full_join(data_final,R2HG_Jurkat_bayes_conc2,by="Sequence")




# select qualified peptides calculate IC50--------------------------------------------


colnames(data_final)
str(data_final)

## change factor to number
for (i in c(2,6:15)) {
  data_final[,i] <- as.numeric(as.character(data_final[,i]))
}

## candidate peptides filtering
data_qualified <- subset(data_final,  R2>0.9&  ratio_010mM_000uM < 0.75 & is.signif=="yes")




# protein-level drc fitting -----------------------------------------------

data_Plot <- data_qualified %>% gather(concentration,Ratio,paste0("ratio_","000uM","_000uM"):paste0("ratio_","010mM","_000uM"))
head(data_Plot)
data_Plot[data_Plot=="ratio_000uM_000uM"] <- log10(0)
data_Plot[data_Plot=="ratio_004uM_000uM"] <- log10(4e-6)
data_Plot[data_Plot=="ratio_020uM_000uM"]<- log10(2e-5)
data_Plot[data_Plot=="ratio_040uM_000uM"]<- log10(4e-5)
data_Plot[data_Plot=="ratio_200uM_000uM"]<- log10(2e-4)
data_Plot[data_Plot=="ratio_400uM_000uM"]<- log10(4e-4)
data_Plot[data_Plot=="ratio_001mM_000uM"]<- log10(1e-3)
data_Plot[data_Plot=="ratio_002mM_000uM"]<- log10(2e-3)
data_Plot[data_Plot=="ratio_005mM_000uM"]<- log10(5e-3)
data_Plot[data_Plot=="ratio_010mM_000uM"]<- log10(1e-2)

str(data_Plot)
colnames(data_Plot)

## transfer concentration to numberic
data_Plot[,16]<- as.numeric(as.character(data_Plot[,16]))

protein_plot <- aggregate(x=data_Plot$Ratio,by=list(concentration=data_Plot$concentration,Genes=data_Plot$Gene.names),mean)
colnames(protein_plot)
names(protein_plot)[3]<-"Ratio"
colnames(protein_plot)
export_protein <- spread(protein_plot, concentration, Ratio)


export_protein$EC50<-0
export_protein$R2<-0
export_protein$lower <- 0
export_protein$upper <- 0
EC50.col <- grep("EC50",colnames(export_protein))
R2.col <- grep("R2",colnames(export_protein))
lower.col <- grep("lower",colnames(export_protein))
upper.col <- grep("upper",colnames(export_protein))

pb <- progress_bar$new(total = length(export_protein$Genes))
state <- c(0)

for (proteins in export_protein$Genes) {
  pb$tick()
  state <- state + 1
  #*****
  data_proteins <- protein_plot[(protein_plot$Genes==proteins),]
  protein_drm <- tryCatch(
    drm(Ratio~concentration,data=data_proteins,fct = LL.4(),logDose = 10),
    error=function(e){ print("Correlation LL.4 failed, L.4 backup performed");return(NA)}
  )
  
  
  # export EC50
  export_protein[state,EC50.col] <- tryCatch(
    round(10^6*coef(protein_drm)[[4]],digits = 4),
    error=function(e){return(NA)}
  )
  
  # export lower
  export_protein[state,lower.col] <- tryCatch(
    as.numeric(coef(protein_drm)[2]),
    error=function(e){return(NA)}
  )
  
  # export upper
  export_protein[state,upper.col] <- tryCatch(
    as.numeric(coef(protein_drm)[3]),
    error=function(e){return(NA)}
  )
  
  
  # export R
  export_protein[state,R2.col] <- tryCatch(
    round(cor(data_proteins$Ratio, fitted(protein_drm), method = "pearson"),digits = 4),
    error=function(e){return(NA)}
  )
  
}
colnames(export_protein)
names(export_protein)[2:7]<- c("0","20uM","200uM","1mM","5mM","10mM")


## export target protein EC50 ----------------------------------------------
write.csv(file = paste0("export_R2HG_Jurkat_target_protein_affinity",".csv"),export_protein,row.names = F)
getwd()
