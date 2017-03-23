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
# Version: 1.2.2
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
#             trans (need log2 or log10 transformation made before withinVar)
#             scaling
#             centering
# output files:
#             dataMatrix_out (after withinVariation correction )
#             result (Robject) 
################################################################################

#Redirect all stdout to the log file
log_file=file("multilevel.log", open = "wt")
sink(log_file)
sink(log_file, type = "output")

# ----- PACKAGE -----
cat("\tPACKAGE INFO\n")

pkgs=c("mixOmics","batch","pcaMethods")
for(pkg in pkgs) {
  suppressPackageStartupMessages( stopifnot( library(pkg, quietly=TRUE, logical.return=TRUE, character.only=TRUE)))
  cat(pkg,"\t",as.character(packageVersion(pkg)),"\n",sep="")
}


source_local <- function(fname) {
    argv <- commandArgs(trailingOnly = FALSE)
    base_dir <- dirname(substring(argv[grep("--file=", argv)], 8))
    source(paste(base_dir, fname, sep="/"))
}

#load transformation function
source_local("transformation_script.R")

print("first loadings OK")


listArguments = parseCommandArgs(evaluate=FALSE) #interpretation of arguments given in command line as an R list of objects
print(listArguments)

## libraries
##----------

cat('\n\nRunning mixomics_multilevel.r\n');

options(warn=-1);
##suppressPackageStartupMessages(library(mixOmics)); #not needed?


## constants
##----------

modNamC <- "Multilevel" ## module name

topEnvC <- environment()
flgC <- "\n"

## functions
##----------For manual input of function
##--end function

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


cat("\nStart of the '", modNamC, "' Galaxy module call: ",
    format(Sys.time(), "%a %d %b %Y %X"), "\n", sep="")


## arguments
##----------

## loading files and checks
xMN <- t(as.matrix(read.table(listArguments[["dataMatrix_in"]],
                              check.names = FALSE,
                              header = TRUE,
                              row.names = 1,
                              sep = "\t")))

samDF <- read.table(listArguments[["sampleMetadata_in"]],
                    check.names = FALSE,
                    header = TRUE,
                    row.names = 1,
sep = "\t")
flgF("identical(rownames(xMN), rownames(samDF))", txtC = "Sample names (or number) in the data matrix (first row) and sample metadata (first column) are not identical; use the 'Check Format' module in the 'Quality Control' section")

##Here Add transformation scripts if trans<>none
if (listArguments[["transfo"]]=="go"){
cat("\n Start transformation with trans=",listArguments[["trans"]]," scale=",listArguments[["scale"]]," center=",listArguments[["center"]],"\n", sep="")
  if (listArguments[["trans"]]<>"none"){
     metC <- listArguments[["trans"]]
     xMN <- transformF(datMN = xMN, ## dataMatrix
                           metC = metC) ## transformation method
  }					   
     xMN<-prep(xMN, scale=listArguments[["scale"]],center=listArguments[["center"]])
}


##end tranformation

if (listArguments[["respL2"]]!="NULL"){
  cat("\n\nMultilevel (two levels)\n");
  flgF("((listArguments[['respL1']] %in% colnames(samDF)) || (listArguments[['respL2']] %in% colnames(samDF)))", txtC = paste("Level argument (",listArguments[['respL2']]," ,",listArguments[['respL1']], ") must be one of the column names (first row) of your sample metadata", sep = ""))

  tryCatch({
    result <- withinVariation(xMN, design=samDF[,c(listArguments[["repmeasure"]],listArguments[["respL1"]],listArguments[["respL2"]])]);
  }, error = function(err) {
    stop(paste("There was an error when trying to run the Multilevel (two levels) function.\n\n",err));
  });
} else {
    cat("\n\nMultilevel (one level)\n");
	flgF("(listArguments[['respL']] %in% colnames(samDF))", txtC = paste("Level argument (",listArguments[['respL']],") must be one of the column names (first row) of your sample metadata", sep = ""))

  tryCatch({
     result <- withinVariation(xMN, design=samDF[,c(listArguments[["repmeasure"]], listArguments[["respL"]])]);
  }, error = function(err) {
    stop(paste("There was an error when trying to run the Multilevel (one level) function.\n\n",err));
  });
}


##saving

if (exists("result")) {
  ## writing output files
  cat("\n\nWriting output files\n\n");
  ## transpose matrix 
  
  datDF <- cbind.data.frame(dataMatrix = colnames(xMN),
                          as.data.frame(t(result)))
  write.table(datDF,
            file = "dataMatrix_out.tsv",
            quote = FALSE,
            row.names = FALSE,
   sep = "\t")
  
  tryCatch({
    save(result, file="multilevel.RData");
  }, warning = function(w) {
    print(paste("Warning: ", w));
  }, error = function(err) {
    stop(paste("ERROR saving result RData object:", err));
  });
}

## ending
##-------

cat("\nEnd of the '", modNamC, "' Galaxy module call: ",
    format(Sys.time(), "%a %d %b %Y %X"), "\n", sep = "")

sink()

# options(stringsAsFactors = strAsFacL)


rm(list = ls())
