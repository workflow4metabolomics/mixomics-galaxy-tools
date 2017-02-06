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

# ----- LOG FILE -----
log_file=file("multilevelout.log", open = "wt")
sink(log_file)
sink(log_file, type = "out")


# ----- PACKAGE -----
cat("\tPACKAGE INFO\n")

pkgs=c("mixOmics","batch")
for(pkg in pkgs) {
  suppressPackageStartupMessages( stopifnot( library(pkg, quietly=TRUE, logical.return=TRUE, character.only=TRUE)))
  cat(pkg,"\t",as.character(packageVersion(pkg)),"\n",sep="")
}
source_local <- function(fname){ argv <- commandArgs(trailingOnly = FALSE); base_dir <- dirname(substring(argv[grep("--file=", argv)], 8)); source(paste(base_dir, fname, sep="/")) }
cat("\n\n");

library(batch) #necessary for parseCommandArgs function


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
withinVariation<-function (X, design) 
{
    X = as.matrix(X)
    rep.measures = factor(design[, 1])
    factors = design[, -1, drop = FALSE]
    if (any(summary(as.factor(rep.measures)) == 1)) 
        stop("A multilevel analysis can not be performed when at least one some sample is not repeated.")
    if ((ncol(factors) == 0) | (ncol(factors) == 1)) {
        message("Splitting the variation for 1 level factor.")
        indiv.names = rownames(X)
        rownames(X) = as.character(rep.measures)
        X.mean.indiv = matrix(apply(X, 2, tapply, rep.measures, 
            mean, na.rm = TRUE), nrow = length(unique(rep.measures)), 
            ncol = dim(X)[2], dimnames = list(levels(as.factor(rep.measures)), 
                colnames(X)))
        Xb = X.mean.indiv[as.character(rep.measures), ]
        Xw = X - Xb
        dimnames(Xw) = list(indiv.names, colnames(X))
    }
    else {
        message("Splitting the variation for 2 level factors.")
        Xm = colMeans(X)
        Xs = apply(X, 2, tapply, rep.measures, mean, na.rm = TRUE)
        Xs = Xs[rep.measures, ]
        xbfact1 = apply(X, 2, tapply, paste0(rep.measures, factors[, 
            1]), mean, na.rm = TRUE)
        xbfact1 = xbfact1[paste0(rep.measures, factors[, 1]), 
            ]
        xbfact2 = apply(X, 2, tapply, paste0(rep.measures, factors[, 
            2]), mean, na.rm = TRUE)
        xbfact2 = xbfact2[paste0(rep.measures, factors[, 2]), 
            ]
        Xmfact1 = apply(X, 2, tapply, factors[, 1], mean, na.rm = TRUE)
        Xmfact1 = Xmfact1[factors[, 1], ]
        Xmfact2 = apply(X, 2, tapply, factors[, 2], mean, na.rm = TRUE)
        Xmfact2 = Xmfact2[factors[, 2], ]
        Xw = X + Xs - xbfact1 - xbfact2 + Xmfact1 + Xmfact2
        Xw = sweep(Xw, 2, 2 * Xm)
        dimnames(Xw) = dimnames(X)
    }
    return(invisible(Xw))
}
 ##end withinVariation to be removed after mixOmics package properly installed   
    
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

##sink(argVc["information"])

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
    result <- withinVariation(xMN, design=samDF[,c(listArguments[["respL1"]],listArguments[["respL2"]])]);
  }, error = function(err) {
    stop(paste("There was an error when trying to run the Multilevel (two levels) function.\n\n",err));
  });
} else {
    cat("\n\nMultilevel (one level)\n");
  tryCatch({
    result<-withinVariation(xMN, design=samDF[,c(listArguments[["respL"]])]);
  }, error = function(err) {
    stop(paste("There was an error when trying to run the Multilevel (one level) function.\n\n",err));
  });
}



if (exists("result")) {
  ## writing output files
  cat("\n\nWriting output files\n\n");
  ##write.table(result, file=loadingVectorsX, sep="\t");
 
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
