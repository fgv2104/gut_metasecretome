library(ggplot2)
library(ggrepel)
library(reshape2)
library(dplyr)
library(ggtree)
library(gridExtra)
library(grid)
library(lattice)
library(svglite)
library(systemfonts)

#Identify MAGs of keystone microbiota


binarize <- FALSE

calcSpearmanDistMat <- function(inMatrix, ...) {
  #Get counts of each cazyme family
  data.geneNum.merge.stat <- data.frame(inMatrix %>% 
                                          group_by(assembly) %>% 
                                          summarise(CDScount = length(unique(CDS))),
                                        stringsAsFactors = F)
  rownames(data.geneNum.merge.stat) <- data.geneNum.merge.stat$assembly
  data.merge.stat <- data.frame(inMatrix %>% 
                                  group_by(assembly, CAZy_GH) %>% 
                                  summarise(count = n()),
                                stringsAsFactors = F)
  data.merge.stat.dcast <- dcast(data.merge.stat, assembly ~ CAZy_GH, fill = 0)
  rownames(data.merge.stat.dcast) <- data.merge.stat.dcast$assembly
  data.merge.stat.dcast <- data.merge.stat.dcast[,-1]
  
  #Binarize CAZyme data into presence/absence matrix
  #If we want to binarize the data, set it up here
  if (binarize == TRUE) {
    data.merge.stat.dcast <- ifelse(data.merge.stat.dcast[,2:ncol(data.merge.stat.dcast)] > 0, 1, 0)
  }
  #Normalize matrix
  data.merge.stat.dcast.normalize <- sweep(data.merge.stat.dcast, 1, data.geneNum.merge.stat[rownames(data.merge.stat.dcast),"CDScount"], "/")
  
  data.matrix.used <- data.merge.stat.dcast.normalize
  #Calculate spearman correlation
  data.merge.cor <- cor(t(data.matrix.used), method = "spearman")
  outDistMatrix = sqrt(2 - 2 * data.merge.cor)
  #Return distance matrix
  return(outDistMatrix)
}

#MDS
MDS <- function(distMatrix, ...) {
  data.merge.mds <- cmdscale(distMatrix, eig = TRUE, add = TRUE, k = 2)
  #Return MDS object
  return(data.merge.mds)
  
}

#Return dataframe with MDS components for each MAG and its phylum and family
compmetadf <- function(data.merge.mds, ...) {
  outputmds <- data.frame(assembly = rownames(data.merge.mds$points),
                          MDS1 = data.merge.mds$points[,1], MDS2 = data.merge.mds$points[,2],
                          phylum = assembly.metadata.df[rownames(data.merge.mds$points),"phylum"],
                          family = assembly.metadata.df[rownames(data.merge.mds$points),"family"],
                          #keystone_species = assembly.metadata.df[rownames(data.merge.mds$points),"keystone_species"],
                          stringsAsFactors = F)
  return(outputmds)
}


#Input from 20221005_metasecretome_notebooks/Figure4_v1.ipynb
data.merge <- read.table("Desktop/working/secstat_hmmer_orfid_df_v14.tsv", header=T, row.names=1, dec=".", sep="\t")
colnames(data.merge) <- c("assembly", "CDS", "CAZy_GH", "evalue")

secstatDistMat <- calcSpearmanDistMat(data.merge)

#nosecstatMat <- read.table("Desktop/working/seconly_hmmer_orfid_df_v12.tsv", header=T, row.names=1, dec=".", sep="\t")
#colnames(nosecstatMat) <- c("assembly", "CDS", "CAZy_GH", "evalue")
#nosecstatDistMat <- calcSpearmanDistMat(nosecstatMat)

#Metadata
data.tax.info <- read.table("Desktop/working/HGM_phy_fam.tsv", stringsAsFactors = F, header = T, sep = "\t")
colnames(data.tax.info) <- c("assembly", "Phylum","Family")
rownames(data.tax.info) <- data.tax.info$assembly
assembly.metadata.df <- data.frame(assembly = rownames(data.tax.info),
                                   phylum = data.tax.info[rownames(data.tax.info),"Phylum"],
                                   family = data.tax.info[rownames(data.tax.info),"Family"],
                                   row.names = rownames(data.tax.info),
                                   stringsAsFactors = F)

#Wrote some code adding metadata for HGM keystone species Desktop/working/20220506_keystone_species_mags.ipynb
# however there were no keystone species in our representative HGM 
# data.tax.info <- read.table("Desktop/working/HGM_phy_fam_keystone_species.tsv", stringsAsFactors = F, header = T, sep = "\t")
# colnames(data.tax.info) <- c("assembly", "Phylum","Family", "keystone_species")
# rownames(data.tax.info) <- data.tax.info$assembly
# assembly.metadata.df <- data.frame(assembly = rownames(data.tax.info),
#                                    phylum = data.tax.info[rownames(data.tax.info),"Phylum"],
#                                    family = data.tax.info[rownames(data.tax.info),"Family"],
#                                    keystone_species = data.tax.info[rownames(data.tax.info),"keystone_species"],
#                                    row.names = rownames(data.tax.info),
#                                    stringsAsFactors = F)

nosecstatMDS <- MDS(nosecstatDistMat)
secstatMDS <- MDS(secstatDistMat)

#Variance explained
nosecstatMDS.eigenvalues <- nosecstatMDS$eig
nosecstatMDS.variance <- 100 * nosecstatMDS.eigenvalues / sum(nosecstatMDS.eigenvalues)

secstatMDS.eigenvalues <- secstatMDS$eig
secstatMDS.variance <- 100 * secstatMDS.eigenvalues / sum(secstatMDS.eigenvalues)

nosecstatMDSresultdf <- compmetadf(nosecstatMDS)
secstatMDSresultdf <- compmetadf(secstatMDS)


#pdf("Desktop/working/figures/CAZy_GH_analysis.MDS_HGM_nosecstat_nonbinarized_v8.pdf", height = 5, width = 7)
ggplot(nosecstatMDSresultdf, aes(x = MDS1, y = MDS2, color = phylum)) + #keystone_species)) +
  geom_point(alpha = 0.9, size = 1.2) +
  #scale_shape_manual(values = c(16, 16, 8, 16)) +
  scale_color_manual(values = c("darkgreen","blue","gray","lightblue","pink","brown","red","purple","orange","yellow","lightgreen")) +
  #scale_color_manual(values = c("#66c2a5","#fc8d62","#8da0cb","#e78ac3","#a6d854","#ffd92f")) + 
  #scale_color_manual(values = c("darkgreen","blue","gray")) +
  #theme(plot.title = element_text(hjust = 0.5)) +
  theme_classic() +
  labs(x = paste("MDS1 (CAZy_GH categories) (", round(nosecstatMDS.variance[1], digits = 1), "%)", sep = "", collapse = NULL), 
       y = paste("MDS2 (CAZy_GH categories) (", round(nosecstatMDS.variance[2], digits = 1), "%)", sep = "", collapse = NULL),
       title = "HGM phyla secreted proteins only")

#dev.off()
#pdf("Desktop/working/figures/CAZy_GH_analysis.MDS_HGM_secstat_nonbinarized_v8.pdf", height = 5, width = 7)
ggplot(secstatMDSresultdf, aes(x = MDS1, y = MDS2, color = phylum)) +
  geom_point(alpha = 0.9, size = 1.2) +
  #scale_shape_manual(values = c(16, 16, 8, 16)) +
  scale_color_manual(values = c("darkgreen","blue","gray","lightblue","pink","brown","red","purple","orange","yellow","lightgreen")) +
  #scale_color_manual(values = c("#66c2a5","#fc8d62","#8da0cb","#e78ac3","#a6d854","#ffd92f")) + 
  #theme(plot.title = element_text(hjust = 0.5)) +
  theme_classic() +
  labs(x = paste("MDS1 (CAZy_GH categories) (", round(secstatMDS.variance[1], digits = 1), "%)", sep = "", collapse = NULL), 
       y = paste("MDS2 (CAZy_GH categories) (", round(secstatMDS.variance[2], digits = 1), "%)", sep = "", collapse = NULL),
       title = "HGM phyla")

#save the plot in a variable image to be able to export to svg
image=ggplot(secstatMDSresultdf, aes(x = MDS1, y = MDS2, color = phylum)) +
  geom_point(alpha = 0.9, size = 1.2) +
  #scale_shape_manual(values = c(16, 16, 8, 16)) +
  scale_color_manual(values = c("darkgreen","blue","gray","lightblue","pink","brown","red","purple","orange","yellow","lightgreen")) +
  #scale_color_manual(values = c("#66c2a5","#fc8d62","#8da0cb","#e78ac3","#a6d854","#ffd92f")) + 
  #theme(plot.title = element_text(hjust = 0.5)) +
  theme_classic() +
  labs(x = paste("MDS1 (CAZy_GH categories) (", round(secstatMDS.variance[1], digits = 1), "%)", sep = "", collapse = NULL), 
       y = paste("MDS2 (CAZy_GH categories) (", round(secstatMDS.variance[2], digits = 1), "%)", sep = "", collapse = NULL),
       title = "HGM phyla")

ggplot(secstatMDSresultdf, aes(x = MDS1, y = MDS2, color = phylum)) +
  geom_point(alpha = 0.9, size = 1.2) +
  #scale_shape_manual(values = c(16, 16, 8, 16)) +
  scale_color_manual(values = c("darkgreen","blue","gray","lightblue","pink","brown","red","purple","orange","yellow","lightgreen")) +
  #scale_color_manual(values = c("#66c2a5","#fc8d62","#8da0cb","#e78ac3","#a6d854","#ffd92f")) + 
  #theme(plot.title = element_text(hjust = 0.5)) +
  theme_classic() +
  labs(x = paste("MDS1 (CAZy_GH categories) (", round(secstatMDS.variance[1], digits = 1), "%)", sep = "", collapse = NULL), 
       y = paste("MDS2 (CAZy_GH categories) (", round(secstatMDS.variance[2], digits = 1), "%)", sep = "", collapse = NULL),
       title = "HGM phyla")
#This actually save the plot in a image
ggsave(file="Desktop/working/figures/CAZy_GH_analysis.MDS_HGM_secstat_nonbinarized_v10.svg", plot=image, height = 5, width = 7)

dev.off()
