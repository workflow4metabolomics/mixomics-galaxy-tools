#!/usr/bin/Rscript

###############################################################################
#
# Correlation Plot
#
# Note: This script has been modified from 'mixOmics.r' that was created for
#       the initial web-interface.
#
# Arguments:
#   fileX       path location to dataset X
#   fileY       path location to dataset Y
#   outputFile  path location to output file
###############################################################################
cat('PlotCIM.r starting ... \n\n');
options(warn=-1);
suppressPackageStartupMessages(library(mixOmics));

IMG.WIDTH <- 800;
IMG.HEIGHT <- 800;

NUM_ARGS <- 3;
ARG_FILEX <- 1;
ARG_FILEY <- 2;
ARG_OUTPUTFILE <- 3;

args <- commandArgs(TRUE);
if (length(args) < NUM_ARGS) {
   stop("Not enough parameters passed in");
}
fileX <- args[ARG_FILEX];
fileY <- args[ARG_FILEY];
outputFile <- args[ARG_OUTPUTFILE];

## Loading in data files
tryCatch({
   X <- read.table(fileX, check.names=F, header=T);
}, error=function(err) {
   stop(paste("There was an error when trying to read in the data(X).\n", err));
});
tryCatch({
   Y <- read.table(fileY, check.names=F, header=T);
}, error=function(err) {
   stop(paste("There was an error when trying to read in the data(Y).\n", err));
});

## plotting variables
bitmap(file=outputFile, type="png16m", width=IMG.WIDTH, height=IMG.HEIGHT, units="px");
tryCatch({
   plot <- imgCor(X, Y, X.names = FALSE, Y.names = FALSE, cexCol=0.7);
}, error = function(err) {
   stop(paste("ERROR while generating the Correlation Plot:\n\n", err));
});
dev.off();
