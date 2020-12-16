#!/usr/bin/env Rscript

require(rmarkdown)
require(yaml)
require(stringr)

args = commandArgs(trailingOnly=TRUE)

print(args)

rmarkdown::render('spectralCounting.Rmd', 
                  params = list(sdrfInput = args[1],
                                mzTabInput = args[2]))


