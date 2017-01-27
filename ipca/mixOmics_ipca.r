#!/usr/bin/Rscript;

################################################################################
#
# mixOmics PLS function
#
# This script is written especially for the mixOmics web-interface powered 
# using the Galaxy system.
#
# Version: 1.0
#
# Author (wrapper): Xin-Yi Chua
# Author (mixOmics.pls): Sébastien Déjean, Ignacio González and Kim-Anh Lê Cao.
#
# Parameters
#     fileX          path to datafile
#
################################################################################

#TODO: Allow error messages to occur on stderr()
options(warn=-1);
suppressPackageStartupMessages(library(mixOmics));

ARG_INFILE_X <- 1;
ARG_OUTFILE_RESULT <-2;
ARG_OUTFILE_LV <- 3;
ARG_OUTFILE_PC <- 4;
ARG_OUTFILE_KURTOSIS <- 5;
ARG_NCOMP <- 6;
ARG_MODE <- 7;
ARG_SPARSE <- 8;
ARG_KEEPX <- 9; #must be last as it is dependent on ncomp

args <- commandArgs(TRUE);

cat("ARGUMENTS passed in\n\n");
args

fileX <- args[ARG_INFILE_X];
resultFile <- args[ARG_OUTFILE_RESULT];
loadingVectorFile <- args[ARG_OUTFILE_LV];
principalCompFile <- args[ARG_OUTFILE_PC];
kurtosisFile <- args[ARG_OUTFILE_KURTOSIS];
ncomp <- as.numeric(args[ARG_NCOMP]);
mode <- tolower(args[ARG_MODE]);
sparseIPCA <- as.logical(args[ARG_SPARSE]);

## Loading data
if (file.exists(fileX)) {
   tryCatch({
      X <- read.table(fileX, check.names=F, header=T);
   }, warning = function(w) {
      print("WARNING");
      print(w);
   }, error = function(err) {
      stop(paste("ERROR occured when loading the data into R.\n\n", err));
   });
}

## Perform (s)IPCA
if (sparseIPCA) {
   keepX <- abs(as.numeric(args[ARG_KEEPX:(ARG_KEEPX - 1 + ncomp)]));
   cat("Parsed keepX: ", keepX, "\n");
   tryCatch({
      result <- suppressWarnings(sipca(X, ncomp=ncomp, mode=mode, keepX=keepX));
   }, warning = function(w) {
      print("WARNING");
      print(w);
   }, error = function(err) {
      stop(paste("ERROR occured when trying to run the sparse IPCA function.\n\n",err));
   });
} else {
   tryCatch({
      result <- suppressWarnings(pca(X, ncomp=ncomp, mode=mode));
   }, warning = function(w) {
      print("WARNING");
      print(w);
   }, error = function(err) {
      stop(paste("ERROR occured when trying to run the IPCA function",err));
   });
}

## output results to CSV file
write.table(result$loadings, file=loadingVectorFile, sep="\t");
write.table(result$x, file=principalCompFile, sep="\t");
write.table(result$kurtosis, file=kurtosisFile, sep="\t");
tryCatch({
   save(result, file=resultFile);
}, warning = function(w) {
   print("WARNING");
   print(w);
}, error = function(err) {
   stop(paste("ERROR occured when trying to save the result as a Robject.\n\n",err));
});
