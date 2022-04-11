#!/bin/bash


#
# splits syri.out files into SR-type.out
# types : SYN INV NOTAL DUP INVDP INVTR TRANS
#



chrs=`cat chromosomes.lst`

for SyRI in `find data -maxdepth 2 -name "syri.out"`
do
    tmp=$(dirname $SyRI)
    dir=$(basename $tmp)

    #### SYN
    grep -w "SYN" $SyRI > ${dir}/SYN.out
    for chr in $chrs
    do
        grep -w ${chr} ${dir}/SYN.out > ${dir}/SYN_${chr}.out
    done
    

    ### NOTAL
    grep -w "NOTAL" $SyRI > ${dir}/NOTAL.out
    for chr in $chrs
    do
        awk -v C=$chr '{if($1 == C && $6 == "-") print $0}' ${dir}/NOTAL.out > ${dir}/NOTAL_ref_${chr}.out
        awk -v C=$chr '{if($1 == "-" && $6 == C) print $0}' ${dir}/NOTAL.out > ${dir}/NOTAL_qry_${chr}.out
    done
done

