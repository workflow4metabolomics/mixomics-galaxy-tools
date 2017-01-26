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
import shutil;
import subprocess;

def main(argv):
   print("###\n\n");
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
   dataDir = '/opt/galaxy-central/database/files/000/';

   parser = argparse.ArgumentParser(description="mixOmics tool wrapper for PCA function");
   parser.add_argument('-t', dest='title',
                        required='True',
                        help='title for this run');
   parser.add_argument('-M', dest='methodology',
                        required='True',
                        help='methodology class');
   parser.add_argument('-m', dest='method',
                        choices = ['pca','pls'],
                        required='True',
                        help='mixOmics function');
   parser.add_argument('-n', dest='ncomp',
                        required='True',
                        help='number of components');
   parser.add_argument('-w', dest='workingDir',
                        required='True',
                        help='working directory where mixomics.r script is located');
   parser.add_argument('-z', dest='zipFile',
                        help='location of output zip file (galaxy specific)');
   parser.add_argument('-o', dest='pdfFile',
                        help='location of output pdf file (galaxy specific)');
   
   #parser.print_help();

   args = parser.parse_args(argv);
   #print("\nARGUMENTS PARSED:\n");
   #print(args);

   script = '%s/mixomics2.r' % args.workingDir;
   cmd = ['/usr/local/bin/Rscript', script, 
      args.title, 
      args.methodology, 
      args.method, 
      args.ncomp, 
      str(xlabelVar), 
      str(xlabelIndiv), 
      str(cytoscape), 
      str(gct), 
      str(cls), 
      str(ihop), 
      ihop_id, 
      ihop_focus, 
      str(center), 
      str(scaled), 
      dataDir]

   try:
      child = subprocess.Popen(cmd, 
                              stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE);
   except Exception, err:
      sys.stderr.write("\n!!! Error invoking command: \n%s\n\n%s\n" % (cmd, err));
      sys.exit(1);

   stdout, stderr = child.communicate();
   exitcode = child.returncode;
   sys.stdout.write(stdout);
   if exitcode:
      sys.stderr.write(stderr);
   else:
      sys.stdout.write(stderr);

      #cp output to expected location
      zipFile = '%s/%s.zip' % (dataDir, args.title);
      pdfFile = '%s/Rplots.pdf' % dataDir;
   
      if args.zipFile and os.path.exists(zipFile):
         print "\nZIP FILE FOUND\n";
         shutil.move(zipFile,args.zipFile);
     
      if args.pdfFile and os.path.exists(pdfFile):
         print "\nPDF FILE FILE\n";
         shutil.move(pdfFile,args.pdfFile);

if __name__ == "__main__":
   main(sys.argv[1:]);
