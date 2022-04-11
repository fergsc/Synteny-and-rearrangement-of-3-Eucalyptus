#!/bin/bash

# identify all TPS genes within transcripts
# 1. Create a blast DB
# 2. blast all XXX.faa to TPS DB
# 3. Filter low score blast hits and extract TPS genes
# 4. run OrthoFinder on TPS genes found in all species.

orthoFinderDir=""
blastDir=""

# create blast DB from conserved TPS sequences
makeblastdb -in TPS-sequences.faa -out TPS -dbtype prot


# blast all gene transcripts to TPS blast DB
mkdir blastResults
for faa in E_albens.faa E_melliodora.faa E_sideroxylon.faa
do
    ${blastDir}/blastp -query $(basename $fasta) -db TPS -out blastResults/$(basename $faa .fasta).out -outfmt 6
done


# filter blast results and get a list of TPS genes for each species
for out in blastResults/*.out
do
    awk '$11< 1e-8{print $1}' $out |sort |uniq > $(basename $out .out).lst
done


# extract TPS genes from gene transcripts
mkdir TPS
for lst in `ls -1 *.lst`
do
    seqtk subseq $(basename $lst .lst).faa $lst > TPS/$(basename $lst .lst).faa
done

# run OrthoFinder on TPS genes
${orthoFinderDir}/orthofinder -a $((threads/2)) -t $threads -f TPS

# Summary stastics are from
#    Comparative_Genomics_Statistics/Statistics_Overall.tsv
#    Comparative_Genomics_Statistics/Statistics_PerSpecies.tsv
#    Orthogroups/Orthogroups.GeneCount.tsv