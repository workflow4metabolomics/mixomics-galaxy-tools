#!/usr/bin/env python

"""
mixOmics PCA wrapper

created: 2012.09.19
wrapper-author: xinyi.chua@qfab.org (support@qfab.org)

Purpose:
   wrapper to call mixOmics PCA function

Parameters

"""

import sys;
import argparse;
import os;

def usage():
   print "\nUsage: mixomics_pca.py -t <name> -g <methodology> -m <method> -n <ncomp>"


def main(argv):
   name = 'default_name';
   methodology = 'pca';
   method = 'pca';
   ncomp = 3;
   xlabelVar = False;
   xlabelIndiv = False;
   cytoscape = False;
   gct = False;
   cls = False;
   ihop = False;
   ihop_id = 'none';
   ihop_focus = 'none';
   center = True;
   scaled = False;

   try:
      opts, args = getopt.getopt(argv, "ht:g:m:n:", ["help", "title", "methodology", "method", "ncomp"]);
   except getopt.GetoptError:
      print usage();
      sys.exit(2);

   for opt, arg in opts:
      if opt in ("-h", "--help"):
         print usage();
         sys.exit();
      elif opt in ("-t", "--title"):
         name = arg;
      elif opt in ("-g", "--methodology"):
         methodology = arg;
      elif opt in ("-m", "--method"):
         method = arg;
      elif opt in ("-n", "--ncomp"):
         ncomp = arg;
   
   wd = os.getcwd();
   print "working dir: ", wd;
   print [(wd + '/mixomics.r')];
   cmd = ["/opt/galaxy-central/tools/mixOmics/mixomics.r", name, methodology, method, ncomp, xlabelVar, xlabelIndiv, cytoscape, gct, cls, ihop, ihop_id, ihop_focus, center, scaled]
   cml = ' '.join(str(x) for x in cmd);
   print cml;

   os.system(cml);

if __name__ == "__main__":
   main(sys.argv[1:]);
