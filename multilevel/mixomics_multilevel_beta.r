#!/usr/bin/env Rscript

###############################################################################
#
# mixOmics multilevel function
#
# This script is written specifically for the mixOmics web-interface
# using the Galaxy system.
#
# R-Package: mixOmics
#
# Version: 1.1
#
# Author (wrapper): Xin-Yi Chua (xinyi.chua@qfab.org)
# Author (mixOmics.multilevel): Benoit Liquet, Kim-Anh Le Cao
# Author (warpper & .r adaptation for workflow4metabolomics.org): Yann GUITTON
# 
# Expected parameters from the commandline
# input files:
#             dataMatrix
#             sampleMetadata
# params:
#             respL (respL for one level & respL1 & respL2 for 2 levels)
# output files:
#             dataMatrix (after multilevel correction )
#             result (Robject) 
################################################################################

#Redirect all stdout to the log file
log_file=file("metams.log", open = "wt")
sink(log_file)
sink(log_file, type = "out")

library(batch) #necessary for parseCommandArgs function

source_local <- function(fname) {
    argv <- commandArgs(trailingOnly = FALSE)
    base_dir <- dirname(substring(argv[grep("--file=", argv)], 8))
    source(paste(base_dir, fname, sep="/"))
}
print("first loadings OK")


listArguments = parseCommandArgs(evaluate=FALSE) #interpretation of arguments given in command line as an R list of objects
print(listArguments)

## libraries
##----------

cat('\n\nRunning mixOmics_multilevel.r\n');

options(warn=-1);
suppressPackageStartupMessages(library(mixOmics));


## constants
##----------

modNamC <- "Multilevel" ## module name

topEnvC <- environment()
flgC <- "\n"

## functions
##----------

flgF <- function(tesC,
                 envC = topEnvC,
                 txtC = NA) { ## management of warning and error messages

    tesL <- eval(parse(text = tesC), envir = envC)

    if(!tesL) {

        sink(NULL)
        stpTxtC <- ifelse(is.na(txtC),
                          paste0(tesC, " is FALSE"),
                          txtC)

        stop(stpTxtC,
             call. = FALSE)

    }

} ## flgF


## log file
##---------

sink(argVc["information"])

cat("\nStart of the '", modNamC, "' Galaxy module call: ",
    format(Sys.time(), "%a %d %b %Y %X"), "\n", sep="")


## arguments
##----------

## loading files and checks
xMN <- t(as.matrix(read.table(argVc["dataMatrix_in"],
                              check.names = FALSE,
                              header = TRUE,
                              row.names = 1,
                              sep = "\t")))

samDF <- read.table(argVc["sampleMetadata_in"],
                    check.names = FALSE,
                    header = TRUE,
                    row.names = 1,
sep = "\t")
flgF("identical(rownames(xMN), rownames(samDF))", txtC = "Sample names (or number) in the data matrix (first row) and sample metadata (first column) are not identical; use the 'Check Format' module in the 'Quality Control' section")





if (listArguments[["respL2"]]!="NULL"){
  cat("\n\nMultilevel (two levels)\n");
  tryCatch({
    result <- withinVariation();
  }, error = function(err) {
    stop(paste("There was an error when trying to run the Multilevel (two levels) function.\n\n",err));
  });
} else {
    cat("\n\nMultilevel (one level)\n");
  tryCatch({
    result <- withinVariation();
  }, error = function(err) {
    stop(paste("There was an error when trying to run the Multilevel (one level) function.\n\n",err));
  });
}



if (exists("result")) {
  ## writing output files
  cat("\n\nWriting output files\n\n");
  write.table(result$loadings$X, file=loadingVectorsX, sep="\t");
  write.table(result$loadings$Y, file=loadingVectorsY, sep="\t");
  write.table(result$variates$X, file=latentVariablesX, sep="\t");
  write.table(result$variates$Y, file=latentVariablesY, sep="\t");
  tryCatch({
    save(result, file=resultfile);
  }, warning = function(w) {
    print(paste("Warning: ", w));
  }, error = function(err) {
    stop(paste("ERROR saving result RData object:", err));
  });
}

## Closing
##--------

cat("\nEnd of '", modNamC, "' Galaxy module call: ",
    as.character(Sys.time()), "\n", sep = "")

sink()

#options(stringsAsFactors = strAsFacL)

rm(list = ls())