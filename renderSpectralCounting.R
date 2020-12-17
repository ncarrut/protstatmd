#!/usr/bin/env Rscript

require(rmarkdown)
require(yaml)
require(stringr)

args = commandArgs(trailingOnly=TRUE)

message("renderscript output:")
message(paste0(args[1], "\n"))
message(paste0(args[2], "\n"))
message(paste0(args[3], "\n"))
message(paste0(getwd(), "\n"))
message(paste0(list.files(), "\n"))

temp_sdrf <- read.delim(args[1], stringsAsFactors = FALSE)

rmarkdown::render('spectralCounting.Rmd')


