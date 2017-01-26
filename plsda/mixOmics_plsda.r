#!/usr/bin/Rscript;

################################################################################
#
# MixOmics PLS-DA function
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
#              latentVariablesX
#              latentVariablesY
#              variableNamesX
#              variableNamesY
#              variableNamesIndiv
#              result (Robject)
# params:
#              ncomp
#              sparse
#              keepX (length = ncomp)
################################################################################
options(warn=-1);
suppressPackageStartupMessages(library(mixOmics));

ARG_FILE_X <- 1;
ARG_FILE_Y <- 2;
ARG_OUTPUTFILE <- 3;
ARG_RESULT_DATA <- 9;
ARG_NCOMP <- 10;
ARG_SPARSE <- 11;
ARG_KEEPX <- 12;

args <- commandArgs(TRUE);
cat(length(args), " arguments passed in\n");
fileX <- args[ARG_FILE_X];
fileY <- args[ARG_FILE_Y];
#TODO: Use composite datatype
loadingVectorsX <- args[ARG_OUTPUTFILE];
latentVariablesX <- args[ARG_OUTPUTFILE+1];
latentVariablesY <- args[ARG_OUTPUTFILE+2];
variableNamesX <- args[ARG_OUTPUTFILE+3];
variableNamesY <- args[ARG_OUTPUTFILE+4];
variableNamesIndiv <- args[ARG_OUTPUTFILE+5];
resultfile <- args[ARG_RESULT_DATA];
ncomp <- as.numeric(args[ARG_NCOMP]);
sparsePLSDA <- as.logical(args[ARG_SPARSE]);

cat('ARGUMENTS\n');
cat('fileX: ', fileX, '\n');
cat('fileY: ', fileY, '\n');
cat('outputfile: ', loadingVectorsX, '\n');
cat('resultfile: ', resultfile, '\n');
cat('ncomp: ', ncomp, '\n');
cat('sparsePLS-DA: ', sparsePLSDA, '\n');
cat('------------------\n\n');

# loading files
tryCatch({
   X <- as.matrix(read.table(fileX, check.names=F, header=T));
}, error = function(err) {
   stop(paste("There was an error when trying to read the data (X).\n\n", err));
});
tryCatch({
   Y <- as.factor(as.matrix(read.table(fileY, check.names=F, header=T)));
}, error = function(err) {
   stop(paste("There was an error when trying to read the data (Y).\n\n", err));
});

# perform analysis
if (sparsePLSDA) {
   print('Sparse PLS-DA\n');
   keepX <- abs(as.numeric(args[ARG_KEEPX:(ARG_KEEPX-1+ncomp)]));
   cat("KeepX: ", keepX, "\n");
   tryCatch({
      result <- splsda(X, Y, ncomp=ncomp, keepX=keepX);
   }, error = function(err) {
      stop(paste("There was an error when trying to run the sparse PLS-DA function.\n\n",err));
   });
} else {
   print('PLS-DA\n');
   tryCatch({
      result <- plsda(X, Y, ncomp=ncomp);
   }, error = function(err) {
      stop(paste("There was an error when trying to run the PLS-DA function.\n\n",err));
   });
}

# writing of numeric results in a csv file
cat("\n\nWriting output files\n");
write.table(result$loadings$X, file=loadingVectorsX, sep="\t");
write.table(result$variates$X, file=latentVariablesX, sep="\t");
write.table(result$variates$Y, file=latentVariablesY, sep="\t");
write.table(result$names$X, file=variableNamesX, sep="\t");
write.table(result$names$Y, file=variableNamesY, sep="\t" );
write.table(result$names$indiv, file=variableNamesIndiv, sep="\t");
tryCatch({
   save(result, file=resultfile);
}, error = function(err) {
   stop(paste("ERROR saving result RData object.\n\n", err));
});
