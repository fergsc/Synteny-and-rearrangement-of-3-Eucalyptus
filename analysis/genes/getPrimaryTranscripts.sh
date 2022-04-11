#!/bin/bash


# takes in a genome.fasta and break.gtf
# extracts transcripts for all genes within gtf
# transcripts are then filtered for primary transcripts
# primary = longest transcript for genes with multiple.

genome=""
gtf="braker.gtf"

breakerDir=""

label=$(basename $genome .aa)

${breakerDir}/bin/getAnnoFastaFromJoingenes.py -g $genome -f $gtf -o $label

bioawk -c fastx '{print $name, length($seq)}' ${label}.aa \
    | sort -k1,1h \
    | awk '{if(NR == 1){prevTrans = $1; prevLen = $2}; split(prevTrans,p,"."); split($1,c,"."); if(p[1] == c[1] && $2 > prevLen){prevTrans = $1; prevLen = $2}; if(p[1] != c[1]){print prevTrans; prevTrans = $1; prevLen = $2}}' \
    > ${label}~primary.lst

seqtk subseq $${label}.aa ${label}~primary.lst > ${label}~primary.aa
