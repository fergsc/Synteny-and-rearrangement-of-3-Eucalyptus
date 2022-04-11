#!/bin/bash

# Use OrthoFinder results to get a list of genes that are in an OG
# and to get a list of OG that the all species have a gene in.
# 


numSpecies=3
countsFile="./TPS-OrthoFinder/Orthogroups/Orthogroups.GeneCount.tsv"
orthogroupsFile="./TPS-OrthoFinder/Orthogroups/Orthogroups.tsv"

for((i=2; i<=$(($numSpecies +1)); ++i))
do
    spp=`head -n 1 $countsFile| cut -f$i`
    awk -v R=$i -v N=$numSpecies 'NR > 1 {if($R == 0){next} if($R != $(N+2)){print $1}}' $countsFile > $spp~OG.lst

    grep -wf $spp~OG.lst $orthogroupsFile \
        | cut -f$i \
        | sed -e 's/ //g ; s/,/\n/g' > $spp~genes.lst
done
