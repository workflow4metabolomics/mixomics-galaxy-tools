#!/usr/bin/Rscript

###############################################################################
#
# BiPlot representation 
#
# Note: This script has been modified from 'mixOmics.r' that was created for
#       the initial web-interface.
#
# Arguments:
#   result      object of class inheriting from mixOmics functions
#   outputFile  path location to output file
###############################################################################

#TODO only redirect warnings, leave errors in STDERR
options(warn=-1);
suppressPackageStartupMessages(library(mixOmics));

IMG.WIDTH <- 800;
IMG.HEIGHT <- 800;


ARG_RESULT <- 1;
ARG_OUTPUTFILE <- 2;

args <- commandArgs(TRUE);
resultFile <- args[ARG_RESULT];
outputFile <- args[ARG_OUTPUTFILE];

## loading Rdata object
if (file.exists(resultFile)) {
   tryCatch({
      load(resultFile);
   }, warning = function(w) {
      print(paste("Warning: ", w));
   }, error = function(err) {
      stop(paste("ERROR occured when loading the result object:\n\n", err));
   });
}

col <- 'blue';
  
## plotting variables
bitmap(file=outputFile, type="png16m", width=IMG.WIDTH, height=IMG.HEIGHT, units="px");
tryCatch({
   plot <- biplot(result, cex=0.7);
}, warning = function(w) {
   print(paste("Warning: ", w));
}, error = function(err) {
   stop(paste("ERROR while generating the biplot:\n\n", err));
});
dev.off();
