#!/usr/bin/Rscript

################################################################################
#
# mixOmics Pheatmap Multilevel
#
# This script is written specifically for the mixOmics web-interface
# using the Galaxy system.
#
# Version: 1.0
# 
# Author (wrapper): Xin-Yi Chua
# Author (mixOmics.pheatmap.multilevel): Ravio Kolde (pheatmap) modified by
#                                        Benoit Liquet, Kim-And Le Cao
#
# Arguments:
#   result           result Robject from mixOmics multilevel functions
#   outputFile       path to output file
#   col_sample       vector of colours indicating the color of each individual
#   col_stimulation  vector of colors indicating teh color of each condition
#   clusting_method  clustering method used
#   show_rownames    boolean specifying if row names are shown
#   show_colnames    boolean specifying if column names are shown
#
################################################################################

cat('Plot Pheatmap Multilevel\n\n');
options(warn=-1);
suppressPackageStartupMessages(library(mixOmics));

IMG.WIDTH <- 1200;
IMG.HEIGHT <- 1600;
MARGIN <- c(5,6);

NUM_ARGS <- 
ARG_RESULT <- 1;
ARG_OUTPUTFILE <- 2;
ARG_SAMPLE <- 3;
ARG_STIMULATION <- 4;

args <- commandArgs(TRUE);
args;
if (length(args) < NUM_ARGS) {
  stop("Not enough parameters");
}
resultFile <- args[ARG_RESULT];
outputFile <- args[ARG_OUTPUTFILE];
sampleFile <- args[ARG_SAMPLE];
stimulationFile <- args[ARG_STIMULATION];

## loading Rdata object
if (file.exists(resultFile)) {
  tryCatch({
    load(resultFile);
  }, error = function(err) {
    stop(paste("ERROR occured when loading the result object:\n\n", err));
  });
};

sample <- unlist(read.table(sampleFile));
stimulation <- unlist(read.table(stimulationFile));

## plotting variables
bitmap(file=outputFile, type="png16m", width=IMG.WIDTH, height=IMG.HEIGHT, units="px");
tryCatch({
  plot <- pheatmap.multilevel(result, col_sample=sample, col_stimulation=stimulation);
}, error = function(err) {
  if (!file.exists(outputFile) && file.info(outputFile)$size >= 0) {
    stop(paste("ERROR while generating the pheatmap.multilevel plot:\n\n", err));
  }
});
dev.off();
