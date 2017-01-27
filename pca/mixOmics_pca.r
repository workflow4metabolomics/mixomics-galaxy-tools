#!/usr/bin/Rscript;

################################################################################
#
# mixOmics PCA function
#
# This script is written especially for the mixOmics web-interface powered
# using the Galaxy system.
#
# Version: 1.0
# 
# Author (wrapper): Xin-Yi Chua
# Author (mixOmics.pca): Ignacio González
#
# Parameters
#     fileX                path to datafile
#     loadingVectorsFile   path to loading vectors loadingVectorFile
#     principleCompFile    path to principal components outputfile 
#     resultData           path to the Robject data file
#     ncomp                number of components
#     center               center the data around zero, see mixOmics help
#     scale                scale the data to have unit variance before
#                          performing the analysis, see mixOmics help
#     sparse               for sparse_PCA
#     keepX                used for sparse_PCA, see mixOmics help
################################################################################

# TODO: Allow error messages to occur on stderr()
options(warn=-1);
suppressPackageStartupMessages(library(mixOmics));

ARG_INFILE_X <- 1;
ARG_OUTFILE_LV <- 2;
ARG_OUTFILE_PC <- 3;
ARG_OUTFILE_RESULT <- 4;
ARG_NCOMP <- 5;
ARG_CENTER <- 6;
ARG_SCALE <- 7;
ARG_SPARSE <- 8;
ARG_KEEPX <- 9;

args <- commandArgs(TRUE);

cat("ARGUMENTS passed in\n\n");
args;

fileX <- args[ARG_INFILE_X];
loadingVectorFile <- args[ARG_OUTFILE_LV];
principalCompFile <- args[ARG_OUTFILE_PC];
resultFile <- args[ARG_OUTFILE_RESULT];
ncomp <- as.numeric(args[ARG_NCOMP]);
center <- as.logical(args[ARG_CENTER]);
scaled <- as.logical(args[ARG_SCALE]);
sparsePCA <- as.logical(args[ARG_SPARSE]);

## Loading data
if (file.exists(fileX)) {
   tryCatch({
      X <- read.table(fileX, check.names=F, header=T);
   }, warning = function(w) {
      print("WARNNING:");
      print(w);
   }, error = function(err) {
      stop(paste("ERROR occured when loading the data into R.\n\n", err));
   });
}

## Perform PCA
if (sparsePCA) {
   keepX <- abs(as.numeric(args[ARG_KEEPX:(ARG_KEEPX - 1 + ncomp)]));
   cat("Parsed keepX: ", keepX, '\n');
   tryCatch({
      result <- spca(X, ncomp=ncomp, keepX=keepX, center=center, scale.=scaled);
   }, warning = function(w) {
      print("WARNNING:");
      print(w);
   }, error = function(err) {
      stop(paste("ERROR occured when trying to run the sparse PCA function.\n\n",err));
   });
} else {
   tryCatch({
      result <- pca(X, ncomp=ncomp, center=center, scale.=scaled);
   }, warning = function(w) {
      print("WARNING:");
      print(w);
   }, error = function(err) {
      stop(paste("ERROR occured when trying to run the PCA function.",err));
   });
}

## pcatune
tryCatch({
   pcatune <- pcatune(X, center=center, scale.=scaled);
}, warning = function(w) {
   print("WARNING");
   print(w);
}, error = function(err) {
   stop(paste("ERROR occured when trying to run the pcatune function.\n\n",err));
});
# TODO: print this to log or output
print("\n\nResult from pcatune\n");
print(pcatune);


## Output results to CSV file
write.table(result$rotation, file=loadingVectorFile, sep="\t");
write.table(result$x, file=principalCompFile, sep="\t");
tryCatch({
   save(result, file=resultFile);
}, warning = function(w) {
   print("WARNING");
   print(w);
}, error = function(err) {
   stop(paste("ERROR occured when trying to save the result as a Robject.\n\n",err));
});
