#!/usr/bin/Rscript

###############################################################################
#
# Network Plot using mixOmics
#
# Note: This script has been modified from 'mixOmics.r' that was created for
#       the initial web-interface.
#
# Arguments:
#   result      object of class inheriting from mixOmics functions
#   outputFile  path location to output file
#   threshold   
###############################################################################

options(warn=-1);
suppressPackageStartupMessages(library(mixOmics));

IMG.WIDTH <- 800;
IMG.HEIGHT <- 800;

NUM_ARGS <- 3;
ARG_RESULT <- 1;
ARG_OUTPUTFILE <- 2;
ARG_THRESHOLD <- 3;

args <- commandArgs(TRUE);
if (length(args) < NUM_ARGS) {
   stop("Not enough parameters passed in");
}
resultFile <- args[ARG_RESULT];
outputFile <- args[ARG_OUTPUTFILE];
threshold <- abs(as.numeric(args[ARG_THRESHOLD]));
cat("Threshold: ", threshold);

## loading Rdata object
if (file.exists(resultFile)) {
   tryCatch({
      load(resultFile);
   }, error = function(err) {
      stop(paste("ERROR occured when loading the result object:\n\n", err));
   });
}

color.edge <- colorRampPalette(c("darkgreen","green","yellow","red","darkred"));
  
## plotting variables
bitmap(file=outputFile, type="png16m", width=IMG.WIDTH, height=IMG.HEIGHT, units="px");
tryCatch({
   plot <- network(result, comp=1:result$ncomp, threshold=threshold, keep.var=TRUE,
                  shape.node = c('rectangle', 'rectangle'),
                  color.node = c('white', 'pink'),
                  color.edge = color.edge(10), alpha = 3);
}, error = function(err) {
   stop(paste("ERROR while generating the Network plot:\n\n", err));
});
dev.off();
