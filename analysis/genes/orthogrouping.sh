#!/bin/bash

# Run orthofinder
# make a directory containing a faa file for each genome
# faa files contain all primary transcripts.
# results will be sace to faa directory
 
geneDir="" # this Dir will contain a XXX.faa file for each genome, containing amino transcript sequences
threads=

orthofinderDir=


mkdir ${PBS_JOBFS}/faa terpene
cp ${genes}/*.faa ${PBS_JOBFS}/faa
cd ${PBS_JOBFS}

${orthofinderDir}/orthofinder -a $((threads/2)) -t $threads -f $geneDir