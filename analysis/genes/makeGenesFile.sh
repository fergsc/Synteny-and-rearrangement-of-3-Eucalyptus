#!/bin/bash


# takes in a gtf file produced by breaker2
# outputs a csv file of gene locations and gene name
# Chrosome,start,stop,geneName

gtf=$1

species=$(basename $gtf .gtf)
echo $species

# AUGUSTUS predictions
awk -v OFS=',' '{if($2 == "AUGUSTUS") {if($3 == "gene"){split($9,a,";"); if($4<$5){print $1, $4, $5, a[1]} else {print $1, $5, $4, a[1]}}}}' $gtf > ${species}.csv

# GeneMark predictions
awk '{if($2 == "GeneMark.hmm"){if($3 == "start_codon") {print $1, $3, $4, $10}; if($3 == "stop_codon"){ print $1, $3, $5, $10}}}' $gtf |sed -e 's/"//g ; s/;//g' | sort -k4 \
    | awk -v OFS=',' '{if($2 == "start_codon"){start = $3};
            if($2 == "stop_codon"){stop = $3};
            if(start != 0 && stop != 0){print $1, start, stop, $4; start = 0; stop = 0}}' >> ${species}.csv

# GeneMark predictions - no stop/start codon
awk '{ if($2 == "GeneMark.hmm") {print $10}}' $gtf | sort | uniq -c | awk '{if($1 == 1) print $2}' > tmp
grep -f tmp < $gtf | awk '{print $1 "," $4 "," $5 "," $10}' | sed -e 's/"//g ; s/;//g' >> ${species}.csv

sort -k1,2h -t',' ${species}.csv > tmp
mv tmp ${species}.csv