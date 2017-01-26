#!/usr/bin/Rscript;

################################################################################
#
# MixOmics PCA function
#
################################################################################
sink(stdout(), type='message');
suppressPackageStartupMessages(library(mixOmics));

ARG_FILE_X <- 1;
ARG_OUTPUTFILE <- 2;
ARG_NCOMP <- 3;
ARG_SPARSE <- 4;
ARG_CENTER <- 5;
ARG_SCALE <- 6;
ARG_KEEPX <- 7;

args <- commandArgs(TRUE);
fileX <- args[ARG_FILE_X];
outputfile <- args[ARG_OUTPUTFILE];
ncomp <- as.numeric(args[ARG_NCOMP]);
sparsePCA <- as.logical(args[ARG_SPARSE]);
center <- as.logical(args[ARG_CENTER]);
scaled <- as.logical(args[ARG_SCALE]);

col <- 'black';
classesName <- 'noclass';


cat('ARGUMENTS\n');
cat('fileX: ', fileX, '\n');
cat('outputfile: ', outputfile, '\n');
cat('ncomp: ', ncomp, '\n');
cat('sparsePCA: ', sparsePCA, '\n');
cat('center: ', center, '\n');
cat('scaled: ', scaled, '\n');
cat('------------------\n\n');


X <- try(read.table(fileX, check.names=F, header=T));
if (class(X) == "try-error") {
   cat("There was an error when trying to read the data. Here is the error message from R:\n");
   print(geterrmessage());
   #sink();
   return();
}
if (sparsePCA) {
   cat('Sparse PCA\n');
   keepX <- abs(as.numeric(args[ARG_KEEPX:(ARG_KEEPX-1+ncomp)]));
   result <- try(spca(X, ncomp=ncomp, keepX=keepX, center=center, scale.=scaled));
   if (class(result) == "try-error") {
      cat("There was an error when trying to run the sparse PCA function. Here is the error message from R:\n");
      print(geterrmessage());
      #sink();
      return();
   }
} else {
   cat('Normal PCA\n');
   result <- try(pca(X, ncomp=ncomp, center=center, scale.=scaled));
   if (class(result) == "try-error") {
      cat("There was an error when trying to run the PCA function. Here is the error message form R:\n");
      print(geterrmessage());
      return();
   }
}

# writing of numeric results in a csv file
write.csv(result$rotation, file=outputfile);
