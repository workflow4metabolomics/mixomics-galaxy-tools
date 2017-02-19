# mixomics-galaxy-tools

This repository contains the Galaxy tool wrappers for the functions from the [mixOmics](https://cran.r-project.org/web/packages/mixOmics/index.html) R package. 
This fork is intented to be the base for integration of mixOmics tools in workflow4metabolomics.org

## Known issues and to-do
* First mixOmics function integartion into W4M with withinVariation as proof of concept
*issue when using warppers on W4M Virtual Machine..to be solved
* The wrappers are for mixOmics version 4.X and an older version of Galaxy.
* Updates to wrappers for newer versions or R > 3.3.1 and mixOmics 6.1.1
* Upload to Galaxy toolshed


## mixOmics auto installation & tests

[![install with bioconda](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg?style=flat-square)](http://bioconda.github.io/recipes/r-mixomics/README.html) [![Build Status](https://travis-ci.org/workflow4metabolomics/mixomics-galaxy-tools.svg?branch=master)](https://travis-ci.org/workflow4metabolomics/mixomics-galaxy-tools)

Our project
-----------
The [Workflow4Metabolomics](http://workflow4metabolomics.org), W4M in short, is a French infrastructure offering software tool processing, analyzing and annotating metabolomics data. It is based on the Galaxy platform.

Galaxy
------
Galaxy is an open, web-based platform for data intensive biomedical research. Whether on the free public server or your own instance, you can perform, reproduce, and share complete analyses. 

Homepage: [https://galaxyproject.org/](https://galaxyproject.org/)

Dependencies using Conda
------------------------
[![install with bioconda](https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg?style=flat)](http://bioconda.github.io/recipes/r-mixomics/README.html) 

[Conda](http://conda.pydata.org/) is package manager that among many other things can be used to manage Python packages.


```
#To install miniconda2
#http://conda.pydata.org/miniconda.html
#To install the mixOmics R library using conda:
conda install r-mixomics r-batch
#To set an environment:
conda create -n r-mixomics r-mixomics r-batch
#To activate the environment:
. activate r-mixomics
```

Travis
------
[![Build Status](https://travis-ci.org/workflow4metabolomics/mixomics-galaxy-tools.svg?branch=master)](https://travis-ci.org/workflow4metabolomics/mixomics-galaxy-tools))

Test and Deploy with Confidence. Easily sync your GitHub projects with Travis CI and you'll be testing your code in minutes!

Historic contributors
---------------------
 - mixOmics mainteners www.mixomics.org
 
 - Gildas Le Corguillé @lecorguille - [ABiMS](http://abims.sb-roscoff.fr/) / [IFB](http://www.france-bioinformatique.fr/) - [UPMC](www.upmc.fr)/[CNRS](www.cnrs.fr) - [Station Biologique de Roscoff](http://www.sb-roscoff.fr/) - France
 - Yann Guitton @yguitton - [LABERCA - Laboratory of Food Contaminants and Residue Analysis](http://www.laberca.org/) - Ecole Nationale Vétérinaire, Agroalimentaire et de l'Alimentation Nantes-Atlantique - France
 
