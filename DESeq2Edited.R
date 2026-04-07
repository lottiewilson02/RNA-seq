################################################################################
# Setup and loading dependencies
################################################################################

# Installing DESeq2

if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}
BiocManager::install("DESeq2")
BiocManager::install("apeglm")

#installing Bioconductor for volcano plots
if (!requireNamespace('BiocManager', quietly = TRUE)) {
  install.packages('BiocManager')
}

BiocManager::install('EnhancedVolcano')

library(EnhancedVolcano)

# Loading DESeq2

library("DESeq2")

# Point to the working dir

setwd("C:/Users/c21010903/OneDrive - Cardiff University/PhD/Gene network/Glen Files/GlenFeatCounts/AB_Glen_gene_featcounts")
getwd() #check that you are now in the correct working directory

# Create dataframe containing output from 3-featureCounts.sh
#featcount <- list.files(
  #pattern = " *.markdup.featurecount")


# Create tables to tell DESeq2 what the variables are
# The number of samplesheets (coldata) you need will depend on the number of
# timepoints/variables you want to compare
coldata <- data.frame(
  sample = c("GA-S2", "GA-S6", "GA-S13", "GD-S8", "GD-S21", "GA-S31"),
  genotype = factor(c("GA", "GA", "GA", "GD", "GD", "GD")),
  replicate = factor(c("1", "2", "3",
                "1", "2", "3")))

################################################################################
# Main CMDs
################################################################################

  # Read the data from standard input

##DONT RUN THESE LINES TO INPUT DATA - USE FILE FROM 'MERGINGFILESSCRIPTTHATWORKS' SCRIPT
 # data <-as.matrix(read.csv(
  #  file = paste ("MJ_Glen_gene_Merge.csv", sep = ""),
   # header = TRUE, 
    #row.names = 1,
    #sep = ","))
  
  # Use dds to combine the coldata and countdata matrix
  # State the variable/factor being analysed using the "design" flag
  
  dds <- DESeqDataSetFromMatrix(
    countData = combined_df, 
    colData = coldata,
    design = ~ genotype)
  
  dds
  
  # As R will automatically choose the reference level for the variable/factor,
  # the control group needs to be defined and releveled
  
  dds$genotype <- relevel(
    dds$genotype, 
    ref = "GD")
  
  # Run the DESeq command on the DESeq dataset
  dds <- DESeq(dds)
  dds
  # Generate a results table, and specify the contrast we want to build
  
  res <- results(
    dds,
    contrast=c(
      "genotype",
      "GD",
      "GA"))
  
  resultsNames(dds) #This shows the coefficients you need to use - the "control" always comes last ie. GA in this script
  #OR...
  
  #res <- results(
   # dds,
    #name = "genotype_GD_vs_GA")
  
  # Log fold change shrinkage for visualisation can be done using different models
  
  resLFC <- lfcShrink(
    dds, 
    coef= "genotype_GA_vs_GD",
    type="apeglm")
  
  resLFC

  #OR...
  
  #resNorm <- lfcShrink(
   # dds, 
    #coef = "genotype_GA_vs_GD", 
    #type = "normal")
  
  #resNorm
  
  # Plotting the normalised results with MA
  # Set the probability and log fold change thresholds
  
  xlim <- c(1,1e5); ylim <- c(-1,1)
  plotMA(
    resLFC, 
    xlim=xlim, 
    ylim=ylim, 
    main="apeglm")
  
  # The plot can be used to identify the rownumber of individual genes
  # interactively
  
 # idx <- identify(
  #  res$baseMean, 
   # res$log2FoldChange)
  
 # rownames(res)[idx]
  
  # Extract all genes (independent of differential expression)
  
  write.csv(resLFC, (
      file = paste(
      "MJGlen_GAvsGD_DESeq2_Log2FC1.csv", 
      sep = "")))
  
  # Extract significant upregulated and down regulated genes into separate
  # datasets
  
  upreg <- subset(
    resLFC, 
    log2FoldChange >=1 & padj <0.05)
  
  upreg <- upreg[ , c(-1,-3)]
  
  downreg <-subset(
    resLFC, 
    log2FoldChange <=-1 & padj <0.05)
  
  downreg <- downreg[ , c(-1,-3)]
  
  #write csv file of for up and down regulated gene IDs
  
  write.csv(upreg, (
    file = paste( 
      "ABGlen_GAvsGD_upreg_Log2FC1.csv", 
      sep = "")))
  
  write.csv(downreg, (
    file = paste(
      "ABGlen_GAvsGD_downreg_Log2FC1.csv", 
      sep = "")))
  
## MAKING VOLCANO PLOT - VISUALISE DIFFERENTIAL GENE EXPRESSION 
  # Log2Fold change (magnitude of change) on x-axis, negative log10 of the adjusted p-value (statistical significance) on y-axis
EnhancedVolcano(resLFC,
  lab = rownames(resLFC),
  x = 'log2FoldChange',
  y = 'pvalue',
  title = 'Autumn Bliss, Glen Ample vs Glen Dee',
  )
  

  
  
  
  
  
  
  
  
  
  
  
  
