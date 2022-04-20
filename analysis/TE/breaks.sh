#!/bin/bash

# Takes in a syri.out file named refSpp~qrySpp.out
# and generates a list of unique breakpoints for all events
# listed in useTypes.
# Output appends to both ref and qry csv files.

useTypes="DUP\|INV\|INVDP\|INVTR\|NOTAL\|SYN\|TRANS"

tmp=$(basename $1)
syri=${tmp%.*}
spp1=`echo $syri | cut -f1 -d'~'`
spp2=`echo $syri | cut -f2 -d'~'`
echo $spp1 $spp2

grep -wf $useTypes $1 | awk 'BEGIN{FS="\t"; OFS=","} {if($1 != "-" && $10 == "-") print $1, $2}' > tmp
grep -wf $useTypes $1 | awk 'BEGIN{FS="\t"; OFS=","} {if($1 != "-" && $10 == "-") print $1, $3}' >> tmp
sort -k1,2V tmp | uniq >> ${spp1}.csv

grep -wf $useTypes $1 | awk 'BEGIN{FS="\t"; OFS=","} {if($6 != "-" && $10 == "-") print $6, $7}' > tmp
grep -wf $useTypes $1 | awk 'BEGIN{FS="\t"; OFS=","} {if($6 != "-" && $10 == "-") print $6, $8}' >> tmp
sort -k1,2V tmp | uniq >> ${spp2}.csv

rm tmp
