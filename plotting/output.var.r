#!/usr/bin/Rscript
library(mixOmics);

IMG.WIDTH <- 900;
IMG.HEIGHT <- 800;

###############################################################################
#
# Variable representation for the first 3 dimensions
#
# Note: This script has been modified from 'mixOmics.r' that was created for
#       the initial web-interface.
#
# Arguments:
#   result      object of class inheriting from mixOmics functions
#   xlabelVar   either a character vector of names for the individuals to be
#               plotted, or FALSE for no names
#   dataDir     path location to output the sample plots
###############################################################################
output.var <- function(result, xlabelVar, dataDir){
  #coord = [];
  ncomp <- result$ncomp;
  for (i in 1:ncomp) {
    if ((i+1) <= ncomp) {
      for (j in (i+1):ncomp) {
        comp = c(i,j);
        output <- paste(dataDir,
                    paste("variable_representation_dim",i,"-",j,".png",sep=""),
                    sep="/");
        png(output, width=IMG.WIDTH, height=IMG.HEIGHT);
        plot <- try(plotVar(result, comp=comp, Y.label=xlabelVar, 
                            X.label=xlabelVar, var.label=xlabelVar));
        if(class(plot) == "try-error") {
          sink(paste(dataDir, "warning.txt", sep="/"));
          cat("There was an error when trying to create the plotVar output ",
  output," its file won't be available. Here is the error message from R:\n");
          print(geterrmessage());
          sink();
        }
        #coord <- as.data.frame(plot);
        dev.off();
      }
    }
  } 
  #Write out the coordinates of the plots
  #write.csv(coord, file=paste(dataDir, "plotVar.csv", sep="/"));
}