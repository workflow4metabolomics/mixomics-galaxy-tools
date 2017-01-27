#!/usr/bin/Rscript

###############################################################################
#
# Variable representation for the first 3 dimensions
#
# This script is written specifically for the mixOmics web-interface
# using the Galaxy system.
#
# Version: 1.0
#
# Author (wrapper): Xin-Yi Chua
# Author (mixOmics.plotVar): Sébastien Déjean and Ignacio González.
#
# Arguments:
#   result      object of class inheriting from mixOmics functions
#   outputFile  path location to output file
#   comp1       component index to show on the x-axis dimension
#   comp2       component index to show on the y-axis dimension
#   xlabelVar   either a character vector of names for the individuals to be
#               plotted, or FALSE for no names
###############################################################################

#TODO only redirect warnings, leave errors in STDERR
options(warn=-1);
suppressPackageStartupMessages(library(mixOmics));

IMG.WIDTH <- 800;
IMG.HEIGHT <- 800;


ARG_RESULT <- 1;
ARG_OUTPUTFILE <- 2;
ARG_COMP1 <- 3
ARG_COMP2 <- 4;
ARG_XLABELVAR <- 5;

args <- commandArgs(TRUE);

cat("Arguments parsed in\n");
args;

resultFile <- args[ARG_RESULT];
outputFile <- args[ARG_OUTPUTFILE];
comp <- c(as.numeric(args[ARG_COMP1]), as.numeric(args[ARG_COMP2]));
xlabelVar <- as.logical(args[ARG_XLABELVAR]);

## loading Rdata object
if (file.exists(resultFile)) {
   tryCatch({
      load(resultFile);
   }, warning = function(w) {
      print(paste("Warning: ", w));
   }, error = function(err) {
      stop(paste("ERROR occured when loading the result object:\n\n", err));
      return();
   });
}

## plotting variables
bitmap(file=outputFile, type="png16m", width=IMG.WIDTH, height=IMG.HEIGHT, units="px");
tryCatch({
   if ("Y" %in% names(result)) {
     if ("keepX" %in% names(result)) {
       cex = 0.75;
     }
     plot <- plotVar(result, comp=comp, var.label=xlabelVar, X.label=xlabelVar, Y.label=xlabelVar);
   } else if ("kurtosis" %in% names(result)) {
     ##IPCA function
     if (xlabelVar) { 
       cex = rep(0.75,1); 
     }
     plot <- plotVar(result, comp=comp, var.label=xlabelVar);
   } else {
     plot <- plotVar(result, comp=comp, var.label=xlabelVar, pch=c(16), col=c('red'));
   }
}, warning = function(w) {
   print(paste("Warning: ", w));
}, error = function(err) {
   stop(paste("ERROR while generating the Variables plot:\n\n", err ));
   return();
});
invisible(dev.off());
