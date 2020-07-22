#####*********************************************************************************************
# Unsupervised Learning- Principal Component Analysis
#************************************************************
# Final Project
# Data Setup
# # 1. IMPORT DATA
# setwd("G:/My Drive/PhD/Class/Statistical Machine Learning/Final Project")
# setwd("us-opiate-prescriptions")
opioids = read.csv("data/opioids.csv")
info = read.csv("data/prescriber-info.csv")
overdose = read.csv("data/overdoses.csv")
class = read.csv("data/drugclass.csv")
cred = read.csv("data/credentials.csv")
spec = read.csv("data/specialty.csv")
colnames(class)[1] = "Drug.Name"

setwd("..")
setwd("Source Codes")
getwd()
source("SPM_Panel.R")
source("PCAplots.R")
source("FactorPlots.R")
source ("TestSet.R")
source ("pc.glm.R")
source("ROC.R")

setwd("..")
getwd()
class = read.csv("drugclass.csv")
colnames(class)[1] = "Drug.Name"

# Libraries
library(hashmap)
library(plyr)
library(plotly)

# add drug class to the info matrix
classunique=unique(class$Drug.Class)
info.drug = colnames(info[,6:255])
classmask = data.frame(row.names=classunique)

for (c in 1 : length(classunique)) {
  r = info[1,6:255]
  rownames(r) = classunique[c]
  for (k in 1:length(info.drug)) {
    if (info.drug[k] == class$Drug.Name[k] && class$Drug.Class[k] == classunique[c]){
      r[k] = 1
    } else {
      r[k] = 0
    }
  }
  classmask = rbind(classmask,r)
}

# Apply mask 
info.all = cbind(info,data.frame(t(as.matrix(classmask) %*% as.matrix(t(info[,6:255])))))
info.class = cbind(info.all[,1:5], info.all[,256:318])

# Clean up credentials - add in rows 
credunique=unique(cred$type)
credh = hashmap(cred$credential,cred$type)
credmat = as.data.frame(matrix(0,ncol=length(levels(credunique)),nrow=nrow(info.all)))
colnames(credmat) = levels(credunique)
for (k in 1:nrow(info.all)) {
  credmat[k,credh[[info.all$Credentials[k]]]]=1
}

info.all = cbind(info.all[,1:4],credmat,info.all[,5:length(info.all)])
info.class = cbind(info.class[,1:4],credmat,info.class[,5:length(info.class)])

# Clean up Specialty
specmat = as.data.frame(matrix(0,ncol=ncol(spec)-1,nrow=nrow(info.all)))
colnames(specmat) = colnames(spec)[2:ncol(spec)]

for (i in 1:(ncol(spec)-1)) {
  spech = hashmap(spec$Specialty,spec[,i+1])
  for (k in 1:nrow(info.all)) {
    specmat[k,i]=spech[[info.all$Specialty[k]]]
  }
}

info.all = cbind(info.all[,1:10],specmat,info.all[,11:length(info.all)])
info.class = cbind(info.class[,1:10],specmat,info.class[,11:length(info.class)])

# Add in death rates
OD.state = overdose[,2:4]
colnames(OD.state) <- c("Population", "Deaths", "State")

info.all <- merge(info.all, OD.state)
info.all$deathrate <- as.integer(info.all$Deaths) / as.integer(info.all$Population)
info.class <- merge(info.class, OD.state)
info.class$deathrate <- as.integer(info.class$Deaths) / as.integer(info.class$Population)

# Convert M to 1 and F to 2
info.all$Gender = revalue(info.all$Gender,c("M" = "1", "F" = "2"))
info.class$Gender = revalue(info.class$Gender,c("M" = "1", "F" = "2"))

info.all.back = info.all

# If you want to work with JUST numbers, use these dataframes
# info.all has ALL drug data and drug classification data
# info.class has just drug classification data

info.all$Specialty = NULL
info.all$Credentials = NULL
info.class$Specialty = NULL
info.class$Credentials = NULL

# *************************************************************************************************
# Unsupervised Learning_ Prinipal Component Analysis
library("FactoMineR")
info.practice.all <- info.all[,12:323]
for (i in c(1:length(colnames(info.practice.all)))) {
  if (typeof(info.practice.all[,i][2]) != "double") {
    info.practice.all[,i] = as.numeric(info.practice.all[,i])
    info.practice.all[,i] = sapply(info.practice.all[,i], as.numeric)
  }
}
Opioid.PC = prcomp(info.practice.all, cor = T)
summary(Opioid.pc)
biplot(Opioid.PC)

library("factoextra")
get_pca(Opioid.pc, element = c("var", "ind"))
fviz_eig(Opioid.pc)

screeplot(Opioid.pc, main = "Variance for PC of Metrics")
# plot(loadingsplot(Opioid.pc)) 
cum_prop <- cumsum(Opioid.pc$sdev^2 / sum(Opioid.pc$sdev^2))
last_index = min(which(cum_prop > 0.90))
Opioid.pc = princomp(info.practice.class, cor = T)
loadingsplot(Opioid.pc)
sort(Opioid.pc$loadings[,1])

# Different way of Analayzing the data with k-means clustering
Opioid.pca = PCA(info.practice.all,  graph = F)
print(Opioid.pca)
# Visualization
fviz_pca_biplot(Opioid.pca)

# Eigenvalues
library("factoextra")
eig.val <- get_eigenvalue(Opioid.pca)
eig.val
fviz_eig(Opioid.pca, addlabels = TRUE, ylim = c(0, 50))

var <- get_pca_var(Opioid.pca)
var

# Create a grouping variable using kmeans
# Create 3 groups of variables (centers = 3)
set.seed(123)
res.km <- kmeans(var$coord, centers = 3, nstart = 25)
grp <- as.factor(res.km$cluster)
# Color variables by groups
fviz_pca_var(Opioid.pca, col.var = grp, 
             palette = c("#0073C2FF", "#EFC000FF", "#868686FF","red", "green"),
             legend.title = "Cluster")


res.desc <- dimdesc(Opioid.pca, axes = c(1,2), proba = 0.05)
# Description of dimension 1
res.desc$Dim.1

#### ********************************************************************************************
# Create the dataframe of deaths and opiates 
Opideaths<-data.frame(info.all$Deaths, info.all$opiate)
#principal components on Opideaths
info.practice <- Opideaths
for (i in c(1:length(colnames(info.practice)))) {
  if (typeof(info.practice[,i][2]) != "double") {
    info.practice[,i] = as.numeric(info.practice[,i])
    info.practice[,i] = sapply(info.practice[,i], as.numeric)
  }
}
Opideaths.pc = prcomp(info.practice, cor = T)
par(mfrow=c(1,1))
biplot(Opideaths.pc, xlim  = c(-0.1,0.3), ylim  = c(-0.05, 0.05))
cumplot(Opideaths.pc)

# ggplot 
plot <- data.frame(PC1=Opideaths.pc$x[,1],PC2=Opideaths.pc$x[,2])
ggplot(plot, aes(x = Opideaths.pc$x[,1], y = Opideaths.pc$x[,2]))


#### ******************************************************************************************
# PCA on info.class
library(dplyr)
info.class1<-select(info.class, -c(State:NPI,Population:Deaths))

info.practice.class <- info.class1[,12:72]
for (i in c(1:length(colnames(info.practice.class)))) {
  if (typeof(info.practice.class[,i][2]) != "double") {
    info.practice.class[,i] = as.numeric(info.practice.class[,i])
    info.practice.class[,i] = sapply(info.practice.class[,i], as.numeric)
  }
}

Opioid.pc = prcomp(info.practice.class, cor = T)
# loadingsplot(Opioid.pc)
# sort(Opioid.pc$loadings[,1])

# head(info.full[,3:68])
par(mfrow=c(1,1))
biplot(Opioid.pc)

cumplot(Opioid.pc)
# loadingsplot(Opioid.pc)
cum_prop <- cumsum(Opioid.pc$sdev^2 / sum(Opioid.pc$sdev^2))
last_index = min(which(cum_prop > 0.90))

###
library(dplyr)
# Creating a binary values for opiate greater than 10 and less than 10
Opiatecolor<-ifelse(info.class$opiate>10,1,0)
plot <- data.frame(PC1=Opioid.pc$x[,1],PC2=Opioid.pc$x[,2], label=as.factor(Opiatecolor))

# colnames(plot) <- c("PC1", "PC2")
ggplot(plot, aes(PC1,PC2, color=label))+geom_point()


# Creating a binary values for opiate greater than 50 and less than 50
Opiatecolor<-ifelse(info.class$opiate>50,1,0)
plot <- data.frame(PC1=Opioid.pc$x[,1],PC2=Opioid.pc$x[,2], label=as.factor(Opiatecolor))

# colnames(plot) <- c("PC1", "PC2")
ggplot(plot, aes(PC1,PC2, color=label))+geom_point()

# Creating a binary values for opiate greater than 500 and less than 500
Opiatecolor<-ifelse(info.class$opiate>500,1,0)
plot <- data.frame(PC1=Opioid.pc$x[,1],PC2=Opioid.pc$x[,2], label=as.factor(Opiatecolor))

# colnames(plot) <- c("PC1", "PC2")
ggplot(plot, aes(PC1,PC2, color=label))+geom_point()

# Creating a binary values for opiate greater than 1000 and less than 1000
Opiatecolor<-ifelse(info.class$opiate>1000,1,0)
plot <- data.frame(PC1=Opioid.pc$x[,1],PC2=Opioid.pc$x[,2], label=as.factor(Opiatecolor))

# colnames(plot) <- c("PC1", "PC2")
ggplot(plot, aes(PC1,PC2, color=label))+geom_point()
#****************************************************************************************************
