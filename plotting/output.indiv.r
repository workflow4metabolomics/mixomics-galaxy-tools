#!/usr/bin/Rscript
library(mixOmics);

IMG.WIDTH <- 900;
IMG.HEIGHT <- 800;

###############################################################################
#
# Sample representation for the first 3 dimensions
#
# Note: This script has been modified from 'mixOmics.r' that was created for
#       the initial web-interface.
#
# Arguments:
#   result      object of class inheriting from mixOmics functions
#   col         character (or symbol) color to be used, possibly vector
#   classesName a character or expression vector of length ≥ 1 to appear in
#               the legend
#   xlabelIndiv either a character vector of names for the individuals to be
#               plotted, or FALSE for no names
#   dataDir     path location to output the sample plots
###############################################################################
output.indiv <- function(result, col, classesName, xlabelIndiv, dataDir){
  ncomp <- result$ncomp;
  for (i in 1:ncomp) {
    if ((i+1) <= ncomp) {
      for (j in (i+1):ncomp) {
        comp = c(i,j);
        output <- paste(dataDir, 
                        paste("sample_representation_dim",i,"-",j,".png",sep=""),
                        sep="/");
        png(paste(output, sep="/"), width=IMG.WIDTH, height=IMG.HEIGHT);
        if(length(classesName) > 1) { #!= "noclass"){
          layout(matrix(c(1,2), nrow=1, ncol=2), widths=c(0.7,0.3));
          #Tweak margins make right side smallest possible 
          #and disable clipping legend
          par(mar=c(5,4,4,0) + 0.1, xpd=T);
          plotIndiv <- try(plotIndiv(result, comp=comp, ind.names=xlabelIndiv,
                                     col=col, pch=16));
          #Create legend in 0,1 position
          plot(1:3, rnorm(3), pch = 1, lty = 1, ylim=c(-2,2), type="n",
               axes = FALSE, ann = FALSE);
          legend(1, 0, classesName, col=unique(col), pch=16, pt.cex=1, 
                 title="Legend");
        }
        else {
          plotIndiv <- try(plotIndiv(result, comp=comp, ind.names=xlabelIndiv,
                                     pch=16));
        }
        if(class(plotIndiv) == "try-error") {
          sink(paste(dataDir, "warning.txt", sep="/"));
          cat("There was an error when trying to create the plotIndiv output: ", 
              output," its file won't be available. Here is the error message from R:\n");
          print(geterrmessage());
          sink();
        }
        dev.off();
      }
    }
  }	
}