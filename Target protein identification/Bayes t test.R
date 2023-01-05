
setwd("D:/my data/R/demo/Target protein identification")
library(dplyr)
library(tidyr)
library(limma)


# Import data ------------------------------------------------------------------

## k562 staurosproine
data <- read.csv("Original_stau_k562.csv",header = T,na.strings = "Filtered")
## hela staurosporine
data <- read.csv("Original_stau_hela.csv",header = T,na.strings = "Filtered")


data <-na.omit(data)
colnames(data)

## import protein contaminants such as albumin
contam <- read.csv("contamination_protein.csv",header = T) #can't read txt,fasta from uniprot




# experiment setting ------------------------------------------------------

columnnames <-c("Genes","Name","PG.UID","Sequence","Position",
                "vehicle_1", "vehicle_2",
                "vehicle_3","vehicle_4",
                "drug_1","drug_2","drug_3","drug_4","UID",
                "cv_vehicle","cv_drug")
design <- model.matrix(~ 0+factor(c(0,0,0,0,1,1,1,1))) #0=Vehicle; 1=Drug
colnames(design) <- c("V","D") #0=Vehicle; 1=Drug


## one peptide was assigned to one protein

data$last <- (regexpr(';', as.character(data$PG.UniProtIds))-1) # if no ";" then = -1
data$UID <- ifelse(data$last > 0, (substr(as.character(data$PG.UniProtIds),1,data$last)),
                   (as.character(data$PG.UniProtIds)))
data$last <- NULL
colnames(data)


# calculate CV -----------------------------------------------------------

Cal_CV=function(x){sd(x)/mean(x)}
veh_col=grep("_0uM_",colnames(data))
drug_col=grep("_20uM_",colnames(data))
data$CV_Vehicle=apply(data[,veh_col],1,Cal_CV)
data$CV_drug=apply(data[,drug_col],1,Cal_CV)


# Peptide level bayes statistical analysis -------------------------------------------


## intensity log2 transform
data.DIA <- grep("Quantity", colnames(data))
data[,data.DIA] <- log((data[,data.DIA]),base=2)


## Use limma for empirical bayes functions unnormized
intensity <- grep("Quantity",colnames(data))
data<- setNames(data, columnnames)
colnames(data)
data$OD <- 1:nrow(data)
fit <- lmFit(data[,intensity], design)
fit <- eBayes(fit) ##Apply empirical Bayes smoothing to the standard errors.
contrast <- makeContrasts("D-V", levels=design)
fit2 <- contrasts.fit(fit, contrast)
fit2 <- eBayes(fit2, trend = TRUE)
ptopf <- topTableF(fit2, adjust="BH",genelist = data[,c("OD")],number=Inf)
ptopf$rank <- 1:length(ptopf$F)
ptopf$numfp <- ptopf$rank * ptopf$adj.P.Val


##this table reports the moderated t-statistic
t.stat <- topTable(fit2, adjust="BH",genelist = data[,"OD"], coef=1,p.value=1, number=Inf)
nms <- grep("logFC", colnames(t.stat)) 
colnames(t.stat)[nms] <-  "Log2FC"	#change column names
t.stat$Log10P.Value <- -log(t.stat$P.Value,base=10)
t.stat$Log10adj.P.Val <- -log(t.stat$adj.P.Val,base=10)
t.statNMS <-t.stat[c("ID","Log2FC","Log10P.Value","Log10adj.P.Val","P.Value","adj.P.Val","AveExpr","t","B") ]   
t.stat <- t.statNMS
colnames(t.stat)
colnames(data)
names(data)[17]<- "ID"
data.analysis <- merge(t.stat, data, by = "ID",all = T, sort=F)
colnames(data.analysis)
data.analysis <- data.analysis[order(-data.analysis$Log10adj.P.Val),]



# Remove protein contaminants ------------------------------------------
data.analysis$is.con <- "no"
con_row <- which(data.analysis$UID %in% contam$UID)
data.analysis[con_row,]$is.con <- "yes"
table(data.analysis$is.con)
data.analysis<- subset(data.analysis,is.con=="no")


# Annotate proteins of interest ------------------------------------------
data_kinase <- read.csv("kinase_hub.csv",header = T)
data.analysis$is.kinase <- "no"
colnames(data_kinase)
kinase_row <-which(data.analysis$UID%in%data_kinase$UniprotID)
data.analysis[kinase_row,]$is.kinase <-"yes"
table(data.analysis$is.kinase)

## export peptide bayes results ------------------------------------------
write.csv(file=paste0("export_bayes_PELSA_stau_rep4_K562_Peptides",".csv"),data.analysis,row.names = F)



# Protein level bayes calculation ---------------------------------------------

k562_peptide_bayes <- read.csv("export_bayes_PELSA_stau_rep4_K562_Peptides.csv",header = T)
k562_p1st_bayes <- k562_peptide_bayes[!duplicated(k562_peptide_bayes$UID),]

## export protein bayes result-----------------------------------------------------------------------
write.csv(file=paste0("export_bayes_protein_stau_K562",".csv"),k562_p1st_bayes,row.names = F)

