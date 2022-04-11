#!/bin/bash

# script to count the number of genes that are core, dispensible, and private for each genome.
# makes use of OrthoFinder output

numSpecies=3
species="E_albens E_sideroxylon E_melliodora"
gene_counts="/path to OrthoFinder results/Orthogroups/Orthogroups.GeneCount.tsv"
OG_file="/path to OrthoFinder results/Orthogroups/Orthogroups.tsv"
spp_v_spp="/path to OrthoFinder results/Orthologues/Orthologues"

# get all genes that exist within the panGenome
for((i=2;i<= $((numSpecies+1)); ++i))
do
    spp=`head -n 1 $OG_file | cut -f$i | sed 's/\r//g'`
    cut -f$i $OG_file | tail -n +2 | sed -e 's/, /\n/g' |sort | uniq | awk 'NF >0' > ${spp}~all.lst
done


# get all genes that exist within 1 other species in panGenome
for sp1 in $species
do
    for tsv in `ls -1 ${spp_v_spp}_${sp1}/*.tsv`
    do
        sp2=`echo $(basename $tsv .tsv) | awk -v FS='__' '{print $NF}'`
        [ $sp1 == $sp2 ] && continue
        cut -f2 $tsv | tr ',' '\n' | sed -e 's/ //g' |sort |uniq | awk 'NF == 1' > ${sp1}~${sp2}.lst
    done
done


#get all genes for each species that are in all 3.
sed -e 's/ //g' $OG_file | awk -F'\t' -v OFS='~' 'BEGIN{RS="\r\n"}
    {zeros = 0; for(i=2;i<=NF;++i){n=split($i,a,",");if(n == 0){zeros = 1}}if(zeros == 0){print $1,$2,$3,$4}}' > all.lst

for((i=2;i <= $(($numSpecies +1));++i))
do
    spp=`head -n 1 all.lst | cut -f$i -d'~'`
    echo $spp
    tail -n +2 all.lst | cut -f${i} -d'~' | sed -e 's/,/\n/g' > ${spp}~3.lst
done


cat E_albens~E_sideroxylon.lst E_albens~E_melliodora.lst | sort | uniq > E_albens~2.lst
cat E_sideroxylon~E_albens.lst E_sideroxylon~E_melliodora.lst | sort | uniq > E_sideroxylon~2.lst
cat E_melliodora~E_albens.lst E_melliodora~E_sideroxylon.lst | sort | uniq > E_melliodora~2.lst



# summary
awk -v OFS="," 'NR != 1 {species=0; for(i=2;i<NF;++i){if($i != 0){++species}}print $1, species}' $gene_counts > OG_speciesCounts.csv



for((i=2;i<=$(($numSpecies));++i))
do

    sp1=`head -n 1 $gene_counts| cut -f${i}`
    sp2=`head -n 1 $gene_counts| cut -f$(($i + 1))`

    count=`cut -f${i},$(($i + 1)) $gene_counts | grep -vw '0' | cut -f1 | tail -n +2 | paste -s -d+ | bc`
    echo "$sp1 $sp2 = $count"

    count=`cut -f${i},$(($i + 1)) $gene_counts | grep -vw '0' | cut -f2 | tail -n +2 | paste -s -d+ | bc`
    echo "$sp2 $sp1 = $count"
done

sp1=`head -n 1 $gene_counts| cut -f2`
sp2=`head -n 1 $gene_counts| cut -f$(($numSpecies + 1))`

count=`cut -f2,$(($numSpecies + 1)) $gene_counts | grep -vw '0' | cut -f1 | tail -n +2 | paste -s -d+ | bc`
echo "$sp1 $sp2 = $count"

count=`cut -f2,$(($numSpecies + 1)) $gene_counts | grep -vw '0' | cut -f2 | tail -n +2 | paste -s -d+ | bc`
echo "$sp2 $sp1 = $count"
