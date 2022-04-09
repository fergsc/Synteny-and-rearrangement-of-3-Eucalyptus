#!/bin/bash
[ $# != 2 ] && echo "Must specify: fasta + number of seq per file" && exit 0

fna=$1
bits=$2
pwd=`pwd`
fnaFile=$(basename $fna)
spp=${fnaFile%.*}
absoluteFna=$( readlink -e $fna )

echo "Splitting $fna into $bits"

grep '^>' $absoluteFna | cut -f1 -d' ' | sed -e 's/>//g' | shuf > contigs.all
total=`cat contigs.all | wc -l`
div=$((total/bits))

out=1
for i in $( seq $bits $bits $total )
do
    head -n $bits contigs.all > current.lst
    sed -i "1,${bits}d" contigs.all

    seqtk subseq $absoluteFna current.lst > bit_$out.fasta
    out=$((out+1))
done
rm current.lst contigs.all