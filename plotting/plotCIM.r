#!/usr/bin/Rscript

###############################################################################
#
# Clustered Image Maps Plots
#
# Note: This script has been modified from 'mixOmics.r' that was created for
#       the initial web-interface.
#
# Arguments:
#   result      object of class inheriting from mixOmics functions
#   outputFile  path location to output file
###############################################################################
cat('PlotCIM.r starting ... \n\n');
options(warn=-1);
suppressPackageStartupMessages(library(mixOmics));

IMG.WIDTH <- 800;
IMG.HEIGHT <- 800;
MARGIN <- c(5,6);

NUM_ARGS <- 4;
ARG_RESULT <- 1;
ARG_OUTPUTFILE <- 2;
ARG_COMP1 <- 3;
ARG_COMP2 <- 4;

args <- commandArgs(TRUE);
if (length(args) < NUM_ARGS) {
   stop("Not enough parameters passed in");
}
resultFile <- args[ARG_RESULT];
outputFile <- args[ARG_OUTPUTFILE];
comp <- c(as.numeric(args[ARG_COMP1]), as.numeric(args[ARG_COMP2]));

## loading Rdata object
if (file.exists(resultFile)) {
   tryCatch({
      load(resultFile);
   }, error = function(err) {
      stop(paste("ERROR occured when loading the result object:\n\n", err));
   });
}

## plotting variables
bitmap(file=outputFile, type="png16m", width=IMG.WIDTH, height=IMG.HEIGHT, units="px");
tryCatch({
   plot <- cim(result, comp = comp, margins = MARGIN);
}, error = function(err) {
   stop(paste("ERROR while generating the arrow plot:\n\n", err));
});
dev.off();
