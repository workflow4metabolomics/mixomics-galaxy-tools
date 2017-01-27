#!/usr/bin/Rscript

###############################################################################
#
# mixOmics multilevel function
#
# This script is written specifically for the mixOmics web-interface
# using the Galaxy system.
#
# R-Package: mixOmics
#
# Version: 1.0
#
# Author (wrapper): Xin-Yi Chua (xinyi.chua@qfab.org)
# Author (mixOmics.multilevel): Benoit Liquet, Kim-Anh Le Cao
#
# Expected parameters from the commandline
# input files:
#             fileX
#             fileY (if method = spls) LAST ARGUMENT!
#             cond
#             sample
# params:
#             ncomp
#             keepX
#             method
# output files:
#             loadingVectorsX
#             loadingVectorsY
#             latentVariablesX
#             latentVariablesY
#             result (Robject) 
################################################################################

cat('\n\nRunning mixOmics_multilevel.r\n');

options(warn=-1);
suppressPackageStartupMessages(library(mixOmics));

ARG_FILE_X <- 1;
ARG_COND <- 2;
ARG_SAMPLE <- 3;
ARG_OUTPUTFILE <- 4;
ARG_RESULT_DATA <- 8;
ARG_NCOMP <- 9;
ARG_METHOD <- 10;
ARG_KEEPX <- 11; 
#ARG_FILE_Y is the last parameter

verbose <- TRUE;

cat("Parsing arguments...\n");
args <- commandArgs(TRUE);
method <- args[ARG_METHOD];
fileX <- args[ARG_FILE_X];
file.cond <- args[ARG_COND];
file.sample <- args[ARG_SAMPLE];
loadingVectorsX <- args[ARG_OUTPUTFILE];
loadingVectorsY <- args[ARG_OUTPUTFILE+1];
latentVariablesX <- args[ARG_OUTPUTFILE+2];
latentVariablesY <- args[ARG_OUTPUTFILE+3];
resultfile <- args[ARG_RESULT_DATA];
ncomp <- as.numeric(args[ARG_NCOMP]);

if (verbose) {
  cat('num arguments passed: ', length(args), '\n');
}

if (verbose) {
  cat('ARGUMENTS\n');
  cat(args, '\n\n');
  cat('fileX: ', fileX, '\n');
  cat('file.cond: ', file.cond, '\n');
  cat('file.sample: ', file.sample, '\n');
  cat('outputfile: ', loadingVectorsX, '\n');
  cat('resultfile: ', resultfile, '\n');
  cat('ncomp: ', ncomp, '\n');
  cat('method: ', method, '\n');
}

## loading files
loadData <- function(file, ...) {
  if (!file.exists(file)) {
    stop(paste("File (", file, ") does not exists.\n\n"));
  }

  cat("\nLoading: ", file, "... ");
  tryCatch({
    tmp <- read.table(file, check.names=F, header=T, row.names=1);
    cat('Dim: ', dim(tmp), "\n");
    return(tmp);
  }, error = function(err) {
    stop(paste("There was an error when trying to read data (X).\n\n", err));
  });
}
X <- loadData(fileX);
sample <- unlist(loadData(file.sample));
cond <- as.factor(unlist(loadData(file.cond)));

## Parse remaining parameters
keepX <- abs(as.numeric(args[ARG_KEEPX:(ARG_KEEPX-1+ncomp)]));

## Perform analysis
if (method == 'spls') {
  cat("\n\nMultilevel (sPLS)\n");
  fileY <- args[length(args)];
  Y <- loadData(fileY);

  ARG_KEEPY <- ARG_KEEPX+ncomp;
  keepY <- abs(as.numeric(args[ARG_KEEPY:(ARG_KEEPY-1+ncomp)]));

  if (verbose) {
    cat('X start index: ', ARG_KEEPX, ' to ', (ARG_KEEPY-1), '\n');
    cat('Y start index: ', ARG_KEEPY, ' to ', (ARG_KEEPY-1+ncomp), '\n');
    cat('keepX: ', keepX, '\n');
    cat('keepY: ', keepY, '\n');
  }

  tryCatch({
    result <- multilevel(X, Y, cond=cond, sample=sample, ncomp=ncomp, method=method, keepX=keepX, keepY=keepY);
  }, error = function(err) {
    stop(paste("There was an error when trying to run the Multilevel (sPLS) function.\n\n",err));
  });
} else if (method == 'splsda') {
  cat("\n\nMultilevel (sPLS-DA)\n");
  tryCatch({
    result <- multilevel(X, cond=cond, sample=sample, ncomp=ncomp, method=method, keepX=keepX);
  }, error = function(err) {
    stop(paste("There was an error when trying to run the Multilevel (sPLS-DA) function.\n\n",err));
  });
}

if (exists("result")) {
  ## writing output files
  cat("\n\nWriting output files\n\n");
  write.table(result$loadings$X, file=loadingVectorsX, sep="\t");
  write.table(result$loadings$Y, file=loadingVectorsY, sep="\t");
  write.table(result$variates$X, file=latentVariablesX, sep="\t");
  write.table(result$variates$Y, file=latentVariablesY, sep="\t");
  tryCatch({
    save(result, file=resultfile);
  }, warning = function(w) {
    print(paste("Warning: ", w));
  }, error = function(err) {
    stop(paste("ERROR saving result RData object:", err));
  });
}
