#!/usr/bin/env Rscript

library(rmarkdown)
library(yaml)
library(stringr)
library(dplyr)
library(tidyr)
library(MSnbase)

args = commandArgs(trailingOnly=TRUE)

####################################
## collect arguments
if (length(args)<2) {
  #print(usage)
  stop("At least the first two arguments must be supplied (input csv and input mzTab).n", call.=FALSE)
}
if (length(args)<=2) {
  # contrasts
  args[3] = "pairwise"
}
if (length(args)<=3) {
  # default control condition
  args[4] = ""
}
if (length(args)<=4) {
  # default output prefix
  args[5] = "edgeR"
}

csv_input <- args[1]
mzTab_input <- args[2]
contrast_str <- args[3]
control_str <- args[4]
out_prefix <- "spectralCounts"
folder <- dirname(mzTab_input)
filename <- basename(mzTab_input)
mzTab_output <- paste0(folder,'/',out_prefix,filename)

## TODO make these do something useful
# message("renderscript output:")
# message(paste0(args[1], "\n"))
# message(paste0(args[2], "\n"))
# message(paste0(args[3], "\n"))
# message(paste0(getwd(), "\n"))
# message(paste0(list.files(), "\n"))

#####################################
## prepare contrast matrix
data <- read.csv(csv_input, stringsAsFactors = FALSE)

lvls <- levels(as.factor(data$Condition))
if (length(lvls) == 1)
{
  print("Only one condition found. No contrasts to be tested. If this is not the case, please check your experimental design.")
} else {
  if (contrast_str == "pairwise")
  {
    if (control_str == "")
    {
      l <- length(lvls)
      contrast_mat <- matrix(nrow = l * (l-1) / 2, ncol = l)
      rownames(contrast_mat) <- rep(NA, l * (l-1) / 2)
      colnames(contrast_mat) <- lvls
      c <- 1
      for (i in 1:(l-1))
      {
        for (j in (i+1):l)
        {
          comparison <- rep(0,l)
          comparison[i] <- -1
          comparison[j] <- 1
          contrast_mat[c,] <- comparison
          rownames(contrast_mat)[c] <- paste0(lvls[i],"-",lvls[j])
          c <- c+1
        }
      }
    } else {
      control <- which(as.character(lvls) == control_str)
      if (length(control) == 0)
      {
        stop("Control condition not part of found levels.n", call.=FALSE)
      }
      
      l <- length(lvls)
      contrast_mat <- matrix(nrow = l-1, ncol = l)
      rownames(contrast_mat) <- rep(NA, l-1)
      colnames(contrast_mat) <- lvls
      c <- 1
      for (j in setdiff(1:l,control))
      {
        comparison <- rep(0,l)
        comparison[i] <- -1
        comparison[j] <- 1
        contrast_mat[c,] <- comparison
        rownames(contrast_mat)[c] <- paste0(lvls[i],"-",lvls[j])
        c <- c+1
      }
    }
  } else {
    print("Specific contrasts not supported yet.")
    exit(1)
  }
  
  #print ("Contrasts to be tested:")
  #print (contrast_mat)
}

######################################
## prepare counts

## Reconfigure contrast matrix for edgeR so there will be a unique 
## bioreplicate-condition identifier
csv2mzTab <- data %>%
  select(Condition, BioReplicate, Run, Reference) %>%
  unique() %>%
  mutate(msRun = paste0("ms_run[", Run, "]")) %>%
  mutate(conditionRep = paste0(Condition, "_", BioReplicate))

## conditionRep will be the same for technical replicates and fractions.
## They will be column names in the count matrix which means technical replicates 
## and fractions will be pooled.

## collect PSMs
MzTabRes <- MzTab(mzTab_input)
PSMtable <- psms(MzTabRes) %>%
  mutate(msRun = sapply(strsplit(spectra_ref, ':'), '[', 1)) %>%
  inner_join(csv2mzTab, by = "msRun") %>%
  pivot_wider(id_cols = "accession", names_from = "conditionRep", 
              values_from = PSM_ID, values_fn = list(PSM_ID = length))


#####################################
## call markdown
for(whichContrast in 1:nrow(contrast_mat)){
  rmarkdown::render('spectralCounting.Rmd', 
                    output_file = paste0(make.names(rownames(contrast_mat)[whichContrast]), '.html'))
}


#rmarkdown::render('spectralCounting.Rmd')


