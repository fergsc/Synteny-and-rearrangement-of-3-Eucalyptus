#!/bin/bash

# runner script for finding all unique breakpoints and
# calculating the proportion that occur with a TE.

teDir="/path to TE bed files"
checkExtension=20 # how many bp to extend TE regions

bash breaks.sh /path to syri output/E_albens~E_melliodora.out
bash breaks.sh /path to syri output/E_albens~E_sideroxylon.out
bash breaks.sh /path to syri output/E_sideroxylon~E_melliodora.out

for csv in `ls -1 *.csv`
do
    spp=$(basename $csv .csv)
    python3 checkRegions.py  ${teDir}/${spp}.bed $csv $checkExtension
done

for checked in `ls -1 *~checked.csv`
do
    inside=`grep 'inside' $checked|wc -l`
    outside=`grep 'outside' $checked|wc -l`
    echo $(basename $checked ~checked.csv)
    echo "$inside $outside" | awk '{print $1/($1+$2)}'
done
