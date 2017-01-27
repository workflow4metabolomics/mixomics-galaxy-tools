#!/usr/bin/Rscript;

################################################################################
#
# mixOmics RCC function
#
# This script is written specifically for the mixOmics web-interface
# using the Galaxy system.
#
# Version: 1.0
# 
# Author (wrapper): Xin-Yi Chua
# Author (mixOmics.rcc): Sébastien Déjean, Ignacio González
#
# Expected parameters from the commandline
# input files:
#              fileX
#              fileY
# params:
#              lambda1
#              lambda2
#              ncomp
# outputFiles:
#              correlation
#              variatesX
#              variatesY
#              result (Robject)
################################################################################
options(warn=-1);
suppressPackageStartupMessages(library(mixOmics));

ARG_FILE_X <- 1;
ARG_FILE_Y <- 2;
ARG_LAMBDA_1 <- 3;
ARG_LAMBDA_2 <- 4;
ARG_OUTPUTFILE <- 5;
ARG_RESULT_DATA <- 8;
ARG_NCOMP <- 9;

args <- commandArgs(TRUE);
cat(length(args), " arguments passed in\n");
fileX <- args[ARG_FILE_X];
fileY <- args[ARG_FILE_Y];
lambda1 <- abs(as.numeric(args[ARG_LAMBDA_1]));
lambda2 <- abs(as.numeric(args[ARG_LAMBDA_2]));

## should not happen from Galaxy as xml can set value to minimum = 1
if (lambda1 == 0 || lambda2 == 0){
   stop(paste("ERROR:\n",
      "Lambda 1 or 2 is equal to zero, please change its value to a positive non-null one.\n"));
}

##TODO: Use composite datatype
correlation <- args[ARG_OUTPUTFILE];
variatesX <- args[ARG_OUTPUTFILE+1];
variatesY <- args[ARG_OUTPUTFILE+2];
resultfile <- args[ARG_RESULT_DATA];
ncomp <- as.numeric(args[ARG_NCOMP]);

cat('ARGUMENTS\n');
cat('fileX: ', fileX, '\n');
cat('fileY: ', fileY, '\n');
cat('lambda 1: ', lambda1, '\n');
cat('lambda 2: ', lambda2, '\n');
cat('ncomp: ', ncomp, '\n');
cat('------------------\n\n');

## loading files
tryCatch({
   X <- data.matrix(read.table(fileX, check.names=F, header=T));
   cat("Dim(X): ", dim(X), "\n");
   cat("Class(X): ", class(X), "\n");
}, error = function(err) {
   stop(paste("There was an error when trying to read the data (X).\n\n", err));
});
tryCatch({
   Y <- data.matrix(read.table(fileY, check.names=F, header=T));
   cat("Dim(Y): ", dim(Y), "\n");
   cat("Class(Y): ", class(Y), "\n");
}, error = function(err) {
   stop(paste("There was an error when trying to read the data (Y).\n\n", err));
});

## perform analysis
print('RCCA\n');
tryCatch({
   result <- rcc(X, Y, ncomp=ncomp, lambda1 = lambda1, lambda2 = lambda2);
}, error = function(err) {
   stop(paste("There was an error when trying to run the PLS-DA function.\n\n",err));
});

## writing of numeric results in a csv file
cat("\n\nWriting output files\n");
write.csv(result$cor, file=correlation);
write.csv(result$loadings$X, file=variatesX);
write.csv(result$loadings$Y, file=variatesY);
tryCatch({
   save(result, file=resultfile);
}, error = function(err) {
   stop(paste("ERROR saving result RData object.\n\n", err));
});
