#!/usr/bin/Rscript;

################################################################################
#
# MixOmics PLS function
#
# This script is written specifically for the mixOmics web-interface
# using the Galaxy workflow system.
#
# Expected parameters from the commandline
# input files:
#              fileX
#              fileY
# outputFiles:
#              loadingVectorsX
#              loadingVectorsY
#              latentVariablesX
#              latentVariablesY
#              result (Robject)
# params:
#              ncomp
#              mode
#              sparse
#              keepX (length = ncomp)
#              keepY (length = ncomp)
################################################################################

cat('\n\nRunning mixOmics_pls.r\n');

options(warn=-1);
suppressPackageStartupMessages(library(mixOmics));

ARG_FILE_X <- 1;
ARG_FILE_Y <- 2;
ARG_OUTPUTFILE <- 3;
ARG_RESULT_DATA <- 7;
ARG_NCOMP <- 8;
ARG_MODE <- 9;
ARG_SPARSE <- 10;
ARG_KEEPX <- 11;

cat("Parsing arguments...\n");
args <- commandArgs(TRUE);
fileX <- args[ARG_FILE_X];
fileY <- args[ARG_FILE_Y];
## TODO: Use composite datatype
loadingVectorsX <- args[ARG_OUTPUTFILE];
loadingVectorsY <- args[ARG_OUTPUTFILE+1];
latentVariablesX <- args[ARG_OUTPUTFILE+2];
latentVariablesY <- args[ARG_OUTPUTFILE+3];
resultfile <- args[ARG_RESULT_DATA];
ncomp <- as.numeric(args[ARG_NCOMP]);
mode <- tolower(args[ARG_MODE]);
sparsePLS <- as.logical(args[ARG_SPARSE]);


if (args[ARG_SPARSE]) {
   numArgsExpected = ARG_KEEPX + (ncomp * 2) - 1;
} else {
   numArgsExpected = ARG_KEEPX + ncomp;
}
cat('num arguments expected: ', numArgsExpected, '\n');
cat('num arguments passed: ', length(args), '\n');
if (length(args) < numArgsExpected) {
   cat("Not enough arguments passed in.\n\n");
   cat(args,'\n\n');
   stop("Stopping method");
}

cat('ARGUMENTS\n');
cat(args, '\n\n');
cat('fileX: ', fileX, '\n');
cat('fileY: ', fileY, '\n');
cat('outputfile: ', loadingVectorsX, '\n');
cat('resultfile: ', resultfile, '\n');
cat('ncomp: ', ncomp, '\n');
cat('mode: ', mode, '\n');
cat('sparsePLS: ', sparsePLS, '\n');
cat('------------------\n\n');

# loading files
tryCatch({
   X <- read.table(fileX, check.names=F, header=T, row.names=1);
   paste('Dim(X): ', dim(X));
}, error = function(err) {
   stop(paste("There was an error when trying to read the data (X).\n\n", err));
});
tryCatch({
   Y <- read.table(fileY, check.names=F, header=T, row.names=1);
   paste('Dim(Y): ', dim(Y));
}, error = function(err) {
   stop(paste("There was an error when trying to read the data (Y).\n\n", err));
});

# perform analysis
if (sparsePLS) {
   print('Sparse PLS');
   ARG_KEEPY <- ARG_KEEPX+ncomp;
   keepX <- abs(as.numeric(args[ARG_KEEPX:(ARG_KEEPY-1)]));
   keepY <- abs(as.numeric(args[ARG_KEEPY:(ARG_KEEPY-1+ncomp)]));

   cat('X start index: ', ARG_KEEPX, ' to ', (ARG_KEEPY-1), '\n');
   cat('Y start index: ', ARG_KEEPY, ' to ', (ARG_KEEPY-1+ncomp), '\n');
   cat('keepX: ', keepX, '\n');
   cat('keepY: ', keepY, '\n');

   tryCatch({
      result <- spls(X, Y, ncomp=ncomp, mode=mode, keepX=keepX, keepY=keepY);
   }, error = function(err) {
      stop(paste("There was an error when trying to run the sparse PLS function.\n\n",err));
   });
} else {
   print('PLS');
   tryCatch({
      result <- pls(X, Y, ncomp=ncomp, mode=mode);
   }, error = function(err) {
      stop(paste("There was an error when trying to run the PCA function.\n\n",err));
   });
}

# writing of numeric results in a csv file
cat("\n\nWriting output files\n");
write.table(result$loadings$X, file=loadingVectorsX, sep="\t");
write.table(result$loadings$Y, file=loadingVectorsY, sep="\t");
write.table(result$variates$X, file=latentVariablesX, sep="\t");
write.table(result$variates$Y, file=latentVariablesY, sep="\t");
tryCatch({
   save(result, file=resultfile);
}, warning = function(w) {
   print(paste("Warning:",w));
}, error = function(err) {
   stop(paste("ERROR saving result RData object:", err));
});
