#!/bin/bash

# run after getEvents.sh

# get summary stats for events for each genome.
# inverted transpositions and inverted duplications are treated as non-inverted and combined
# output: reference,query,type,mean,sd,count,total,pc

genomeDir=""
speciesList="spp1 spp2 spp3"


echo "reference,query,type,mean,sd,count,total,pc" > all.csv
for csv in *~sizes_primary.csv
do
    host=$(basename $csv ~sizes_primary.csv)
    hostSize=`bioawk -c fastx '{total += length($seq)} END{print total}' ${genomeDir}/${host}.fasta`
    for spp in $speciesList
    do
        SR=$hostSize
        [ $host == $spp ] && continue
        grep -w $spp $csv > tmp
        for type in `DUP INV NOTAL SYN TRANS`
        do
            grep -w $type tmp | cut -f2 -d',' >lens
            mean=`awk '{x+=$0}END{print x/NR}' lens`
            sd=`awk '{x+=$0;y+=$0^2}END{print sqrt(y/NR-(x/NR)^2)}' lens`
            wc=`cat lens | wc -l`
            total=`paste -s -d+ lens | bc`
            pc=`echo "$total $hostSize" | awk '{print $1/$2}'`
            echo "${host},${spp},${type},${mean},${sd},${wc},${total},${pc}" >> all.csv

            [ $type == "NOTAL" ] && SR=$(($SR - $total))
            [ $type == "SYN" ] && SR=$(($SR - $total))
        done
        pc=`echo "" | awk -v S=$SR -v A=$hostSize '{print S/A}'`
        echo "${host},${spp},SR,,,,${SR},${pc}" >> all.csv
    done
done
rm lens tmp