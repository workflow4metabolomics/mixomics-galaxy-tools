#!/usr/local/bin/Rscript

###############################################################################
#
# Sample representation for the first 3 dimensions
#
# This script is written specifically for the mixOmics web-interface
# using the Galaxy system.
#
# Version: 1.0
#
# Author (wrapper): Xin-Yi Chua
# Author (plotIndiv): Sébastien Déjean, Ignacio González.
#
# Arguments:
#   result      object of class inheriting from mixOmics functions
#   outputFile  path to output file
#   classesFile path to file containing the class label for each row of the data
#               will use this class information to create a colour vector and
#               legend
#   xlabelIndiv either a character vector of names for the individuals to be
#               plotted, or FALSE for no names
###############################################################################
options(warn=-1);
suppressPackageStartupMessages(library(mixOmics));

##set to use the Xvfbd display
display <- Sys.getenv("DISPLAY");
cat("DISPLAY=", display, "\n");
cat("capabilities():\n");
capabilities();

IMG.WIDTH <- 6;#900;
IMG.HEIGHT <- 5;#800;

args <- commandArgs(TRUE);

ARG_RESULT <- 1;
ARG_OUTPUTFILE <- 2;
ARG_XLABELINDIV <- 3;
ARG_COMP1 <- 4;
ARG_COMP2 <- 5;
ARG_CLASSESFILE <- match("-class" %in% args);
if (!is.na(ARG_CLASSESFILE)) {
  ARG_CLASSESFILE <- ARG_CLASSEFILE + 1;
  classesFile <- args[ARG_CLASSESFILE];
} else {
  classesFile <- "";
}
## plot other dimensions
ARG_MULTIDIM <- match("-mutli" %in% args);
if (!is.na(ARG_MULTIDIM)) {
  ARG_MULTIDIM <- ARG_MUTLIDIM + 1;
  dims <- args[ARG_MULTIDIM:length(args)];
}


cat("Arguments parsed in\n");
args;

resultFile <- args[ARG_RESULT];
outputFile <- args[ARG_OUTPUTFILE];
comp <- c(as.numeric(args[ARG_COMP1]), as.numeric(args[ARG_COMP2]));
xlabelIndiv <- as.logical(args[ARG_XLABELINDIV]);

## loading result object
print("Loading Robject File");
if (file.exists(resultFile)) {
   tryCatch({
      load(resultFile);
      print("loaded file, current objects:");
      ls();
   }, warning = function(w) {
      print(paste("Warning: ", w));
   }, error = function(err) {
      stop(paste("ERROR occured when trying to load RData object:\n\n", err));
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
   classesName <- unique(classes);
} else {
   col <- 'black';
   classesName <- 'noclass';
}

## plotting samples
bitmap(file=outputFile, type="png16m", res=150, width=IMG.WIDTH, height=IMG.HEIGHT, units="in");
if (length(classesName) > 1) { 
	layout(matrix(c(1,2), nrow=1, ncol=2), widths=c(0.7,0.3));
   ## Tweak margins make right side smallest possible and disable clipping legend
   par(mar=c(5,4,4,0) + 0.1, xpd=T);
   cat("ind.names=", xlabelIndiv, "\n");
   plotIndiv <- try(plotIndiv(result, comp=comp, ind.names=xlabelIndiv, col=col, pch=16));
   ## Create legend in 0,1 position
   plot(1:3, rnorm(3), pch = 1, lty = 1, ylim=c(-2,2), type="n", axes = FALSE, ann = FALSE);
   legend(1, 0, classesName, col=unique(col), pch=16, pt.cex=1, title="Legend");
} else {
   tryCatch({
      plotIndiv(result, comp=comp, ind.names=xlabelIndiv, pch=16);
   }, warning = function(w) {
      print(paste("Warning: ",w));
   }, error = function(err) {
      stop(paste("ERROR occured when plotting samples:\n\n", err));
   });
}
invisible(dev.off());
