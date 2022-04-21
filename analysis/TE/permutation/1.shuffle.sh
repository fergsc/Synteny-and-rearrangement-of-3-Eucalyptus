#!/bin/bash


#permutations
start=1
end=3000
checkExtension=10 # how many bp to extend TE regions
distBetweenBreaks=200

teDir="/path to TE bed files"
genomeDir="/path to genome fasta"

spp=E_albens
#spp=E_melliodora
#spp=E_sideroxylon

mkdir ${spp}
mkdir ${spp}/working
cd ${spp}/working

cp ${teDir}/${spp}.bed .
bioawk -c fastx '{print $name, length($seq)}' ${genomeDir}/${spp}.fasta > ${spp}.genome
cut -f1 -d',' ../${spp}.csv  | sort | uniq -c | awk '{print $2, $1}' > numPoints.tsv

for ((i=${start};i <= ${end}; ++i))
do
    for chr in Chr01 Chr02 Chr03 Chr04 Chr05 Chr06 Chr07 Chr08 Chr09 Chr10 Chr11
    do
        points=`grep "^${chr}" numPoints.tsv | awk '{print $2}'`
        size=`grep "^${chr}" ${spp}.genome | awk '{print $2 - 300}'`
        python3 randPoints.py $distBetweenBreaks $size $points tmp
        awk -v C=${chr} -v OFS="," '{print C, $1}' tmp >> ${spp}~${i}.csv
    done
    python3 ../checkRegions.py ${spp}.bed ${spp}~${i}.csv $checkExtension
done
rm tmp ${spp}.bed ${spp}.genome 
cd ..

# do stats - work out the proportion of breakpoints inside TE
for checked in `ls -1 working/*~checked.csv`
do
    inside=`grep 'inside' $checked|wc -l`
    outside=`grep 'outside' $checked|wc -l`
    echo "$inside $outside" | awk '{print $1/($1+$2)}' >> ${spp}~${end}.results
done
cd ..
