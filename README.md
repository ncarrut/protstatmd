# protstatmd

This is a container for analysis of proteomic data that have already been matched to a database.  It's designed to be appended to the [proteomicslfq](https://nf-co.re/proteomicslfq) nextflow workflow but can also be run independently.  Key features of this container are (1) RMarkdown funcionality to produce interactive html documents and (2) common proteomics analyses R packages installed.  It takes an experimental design file and a mzTab file, conducts edgeR analysis of spectral counts and returns an html report and table of statistical results.  Test data are provided for [PXD016772](https://www.ebi.ac.uk/pride/archive/projects/PXD016772).  

## Installation

## Usage with built-in test data
```
sudo docker run --name protstat -t -d ncarrut/protstatmd:2.0
sudo docker exec -d protstat gzip -d out.mzTab.gz # gzip was required to keep under github file size limit
sudo docker exec -d protstat Rscript renderSpectralCounting.R test/out.csv test/out.mzTab
sudo docker cp protstat:/usr/local/src/myscripts/spectralCounting.html .
sudo docker cp protstat:/usr/local/src/myscripts/edgeR_output.csv .
sudo docker stop protstat
sudo docker rm protstat
```

## Usage with own data
```
sudo docker run --name protstat -t -d ncarrut/protstatmd:1.21

```

## To do:
Better output logging
define usage
MA plots


## References