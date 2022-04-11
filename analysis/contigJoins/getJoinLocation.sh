#!/bin/bash


# uses RaGOO output logs to calculate the loaction of contig joins for each
# chromosome of each species.

for chr in Chr01 Chr02 Chr03 Chr04 Chr05 Chr06 Chr07 Chr08 Chr09 Chr10 Chr11
do

    cut -f1 /path to RaGOO/E_melliodora/orderings/${chr}_orderings.txt  >E_melliodora.lst
    cut -f1 /path to RaGOO/E_albens/orderings/${chr}_orderings.txt > E_albens.lst
    cut -f1 /path to RaGOO/E_sideroxylon/orderings/${chr}_orderings.txt > E_sideroxylon.lst

    for l in *.lst
    do
        tmp=$(basename $l .lst)
        spp=`echo $tmp | cut -f1 -d'.'`

        for c in `cat $l`
        do
            bioawk -v C=$c -c fastx '$name == C {print length($seq)}' /path to genomes/${spp}.fasta >> tmp
        done
        awk '{count = count + $2; print count}' tmp > ${spp}.${chr}.cumsum
        rm tmp
    done
done

rm *.lst