#!/usr/bin/env Rscript
#; -*- mode: R;-*-
# =========================================================
#
# This is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License.
# If not, see <http://www.gnu.org/licenses/>.
#
#
# =========================================================

###############################################################
suppressPackageStartupMessages(library("optparse"))

IRAP.DIR <- Sys.getenv(c("IRAP_DIR"))
if ( IRAP.DIR == "" ) {
  cat("ERROR: environment variable IRAP_DIR is not set\n")
  q(status=1)
}
#
# specify our desired options in a list
#
source(paste(IRAP.DIR,"aux/R","irap_utils.R",sep="/"))
pdebug.enabled <- TRUE
#######################
usage <- "irap_single_lib_gen_tpm.R -l irap_lengths.Rdata --dir counts_dir [options]"

filenames <- c("dir","lengths_file")

option_list <- list(
  make_option(c("-d", "--dir"), type="character", dest="dir", default=NULL,help="Directory with the quantification files generated by irap_single_lib"),
  make_option(c("-l", "--lengths"), type="character", dest="lengths_file", default=NULL,help="File with the gene and transcript lengths generated by iRAP"),
  make_option(c("-f","--force"),action="store_true",dest="force",default=FALSE,help="Force the generation of the files when they already exist"),
  make_option(c("--debug"),action="store_true",dest="debug",default=FALSE,help="Debug mode")
)
mandatory <- c("dir","lengths_file")
#pinfo("saved")
opt <- myParseArgs(usage = usage, option_list=option_list,filenames.exist=filenames,mandatory=mandatory)

pdebug.enabled <- opt$debug

# Look for the gene level quantification file
#opt$dir="/tmp"
files.found <- system(paste("ls --color=never ",opt$dir,"/*genes.raw.*.tsv",sep=""),intern=TRUE)
force.gen <- opt$force
#print(force.gen)

cat("Gene level quantification: found ",length(files.found),"\n")
for ( f in as.vector(files.found) ) {
  cat("--->",f,"\n")
  tpm.file <- gsub(".raw.",".tpm.",f)
  tpm.file <- gsub(".tsv",".irap.tsv",tpm.file)
  if ( file.exists(tpm.file) && ! force.gen ) {
    cat("File ",tpm.file," already exists...skipping generation.\n")
  } else {
    cmd <- paste("irap_raw2metric --lengths ",opt$lengths," --tsv ",f," -f gene -m tpm -o ",tpm.file,sep="")
    if ( opt$debug ) { cat(cmd,"\n") }
    system(cmd,intern=TRUE)
    if ( file.exists(tpm.file) ) {
      cat("Generated ",tpm.file,"\n")
    } else
      stop("ERROR generating tpm.file\n")
  }
}
q(status=0)
