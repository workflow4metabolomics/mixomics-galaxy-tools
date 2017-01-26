#!/usr/bin/Rscript
library(mixOmics);

IMG.WIDTH <- 900;
IMG.HEIGHT <- 800;



###############################################################################
#
# BiPlot representation
#
# Note: This script has been modified from 'mixOmics.r' that was created for
#       the initial web-interface.
#
# Arguments:
#   result      object of class inheriting from mixOmics functions
#   dataDir     path location to output the sample plots
###############################################################################
output.biplot <- function(result, dataDir){
  output <- paste(dataDir, "biplot.png", sep="/");
  png(output, width=IMG.WIDTH, height=IMG.HEIGHT);
  plot <- try(biplot(result, cex=0.7));
  if(class(plot) == "try-error") {
    sink(paste(dataDir, "warning.txt", sep="/"));
    cat("There was an error when trying to create the biplot output, its file ",
        output, " won't be available. Here is the error message from R:\n");
    print(geterrmessage());
    sink();
  }
  dev.off();
}



###############################################################################
#
# Network representation and saving in a graphml file
#
# Note: This script has been modified from 'mixOmics.r' that was created for
#       the initial web-interface.
#
# Arguments:
#   result      object of class inheriting from mixOmics functions
#   threshold   
#   cytoscape   export network to cytoscape format
#   dataDir     path location to output the sample plots
###############################################################################
output.network <- function(result, threshold, cytoscape, dataDir){
  output <- paste(dataDir, "network.png", sep="/");
  
  color.edge <- colorRampPalette(c("darkgreen", "green", "yellow",
                                   "red", "darkred"));
  png(output, width=IMG.WIDTH, height=IMG.HEIGHT);
  gr <- try(network(result, comp = 1:result$ncomp, threshold=threshold, 
          keep.var=TRUE, shape.node = c("rectangle", "rectangle"),
          color.node=c("white", "pink"), color.edge=color.edge(10), alpha=3));
  if(class(gr) == "try-error") {
    sink(paste(dataDir, "warning.txt", sep="/"));
    cat("There was an error when trying to create the Correlation network 
        output, its file won't be available. Here is the error message 
        from R:\n");
    print(geterrmessage());
    sink();
  }
  dev.off();
  if(cytoscape) try(write.graph(gr$gR, 
                                file=paste(dataDir,"network.graphml", sep="/"),
                                format = "graphml"));
}



###############################################################################
#
# Heatmap representation
#
# Note: This script has been modified from 'mixOmics.r' that was created for
#       the initial web-interface.
#
# Arguments:
#   result      object of class inheriting from mixOmics functions
#   dataDir     path location to output the sample plots
###############################################################################
output.cor <- function(result, dataDir){
  output <- paste(dataDir, "imgCor.png", sep="/");
  png(output, width=IMG.WIDTH, height=IMG.HEIGHT);
  plot <-try(imgCor(X, Y, X.names = FALSE, Y.names = FALSE, , cexCol=0.7));
  if(class(plot) == "try-error") {
    sink(paste(dataDir, "warning.txt", sep="/"));
    cat("There was an error when trying to create the Image Correlation output,
        its file won't be available. Here is the error message from R:\n");
    print(geterrmessage());
    sink();
  }
  dev.off();
}



###############################################################################
#
# Clustered Image Map representation
#
# Note: This script has been modified from 'mixOmics.r' that was created for
#       the initial web-interface.
#
# Arguments:
#   result      object of class inheriting from mixOmics functions
#   dataDir     path location to output the sample plots
###############################################################################
output.cim <- function(result, dataDir){
  output <- paste(dataDir, "cim.png", sep="/");
  png(output, width=IMG.WIDTH, height=IMG.HEIGHT);
  plot <- try(cim(result, comp = 1:3, margins = c(5, 6));
  if(class(plot) == "try-error") {
    sink(paste(dataDir, "warning.txt", sep="/"));
    cat("There was an error when trying to create the Clustered Image Map output,
        its file won't be available. Here is the error message from R:\n");
    print(geterrmessage());
    sink();
  }
  dev.off()
}



###############################################################################
#
# S.Match representation
#
# Note: This script has been modified from 'mixOmics.r' that was created for
#       the initial web-interface.
#
# Arguments:
#   result      object of class inheriting from mixOmics functions
#   col
#   dataDir     path location to output the sample plots
###############################################################################
output.s.match <- function(result, col, dataDir){
  output <- paste(dataDir, "s_match.png", sep="/");
  
  if(col == 'black') {
    col <- rep('black', length(result$variates$X[, c(1,2)]))
  }
  png(output, width=IMG.WIDTH, height=IMG.HEIGHT);
  plot <- try(s.match(result$variates$X[, c(1,2)], result$variates$Y[, c(1,2)],
                      clabel=1.25, col=col))
  if(class(plot) == "try-error") {
    sink(paste(dataDir, "warning.txt", sep="/"));
    cat("There was an error when trying to create the S.Match output, its file
         won't be available. Here is the error message from R:\n");
    print(geterrmessage());
    sink();
  }
  dev.off()	
}