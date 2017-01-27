#!/usr/bin/Rscript

###############################################################################
#
# mixOmics Arrow Plots (s.match)
#
# This script is written specifically for the mixOmics web-interface
# using the Galaxy system.
#
# Version: 1.0
#
# Author (wrapper): Xin-Yi Chua
# Author (mixOmics.s.match): Daniel Chessel from ade4 R package, modified by Kim-Anh Lê Cao.
#
# Arguments:
#   result      object of class inheriting from mixOmics functions
#   outputFile  path location to output file
###############################################################################

#TODO only redirect warnings, leave errors in STDERR
options(warn=-1);
suppressPackageStartupMessages(library(mixOmics));

##set to use the Xvfbd display
display <- Sys.getenv("DISPLAY");
cat("was DISPLAY", display,"\n");
cat("capabilities():\n");
capabilities();
#Sys.setenv(DISPLAY=":2");
#cat("changed to DISPLAY", Sys.getenv("DISPLAY"), "\n");
#cat("capabilities():\n", capabilities(), "\n");

IMG.WIDTH <- 800;
IMG.HEIGHT <- 800;

ARG_RESULT <- 1;
ARG_OUTPUTFILE <- 2;
ARG_COMP1 <- 3;
ARG_COMP2 <- 4;
ARG_CLASSESFILE <- 5;

args <- commandArgs(TRUE);
cat("Arguments parsed in\n");
args;

resultFile <- args[ARG_RESULT];
outputFile <- args[ARG_OUTPUTFILE];
comp <- c(as.numeric(args[ARG_COMP1]), as.numeric(args[ARG_COMP2]));
classesFile <- args[ARG_CLASSESFILE];

## loading Rdata object
if (file.exists(resultFile)) {
   tryCatch({
      load(resultFile);
   }, error = function(err) {
      stop(paste("ERROR occured when loading the result object:\n\n", err));
   });
}

## loading class data
if (file.exists(classesFile)) {
print("Loading Class File");
   tryCatch({
      classes <- as.matrix(read.table(classesFile),header=TRUE);
   }, warning = function(w) {
      print(paste("Warning: ", w));
   }, error = function(err) {
      stop(paste("ERROR while loading classesFile:\n\n", err));
   });
   col <- as.numeric(as.factor(classes));
} else {
   col <- rep('black', length(result$variates$X[, comp]));
}
cat('col=', col, '\n');


## plotting arrow plot
tryCatch({
   bitmap(file=outputFile, type="png16m", width=IMG.WIDTH, height=IMG.HEIGHT, units="px");
   s.match(result$variates$X[, comp], result$variates$Y[, comp], clabel=0.75, col=col);
   invisible(dev.off());
}, error = function(err) {
   stop(paste("ERROR while generating the arrow plot:\n\n", err));
});

## reset display
#Sys.setenv(DISPLAY=display);
