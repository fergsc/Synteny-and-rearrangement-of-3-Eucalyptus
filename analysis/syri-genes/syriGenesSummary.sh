#!/bin/bash


# summarise results from syri-genes.
# want to count up the number of events with and without genes
# for each event type fro each species pairing

#!/bin/bash

[ -f syriGeneSummary.csv ] || echo "reference~query,type,inOut,count" > syriGeneSummary.csv

file=$(basename $1 .syrigenes)
sp1=`echo $file | cut -f1 -d'~'`
sp2=`echo $file | cut -f2 -d'~'`
ref=`echo $file | cut -f3 -d'~'`

[ $ref == $sp1 ] && qry=$sp2 || qry=$sp1

cut -f2,4 -d',' $1 \
    | sed -e 's/,inside/,gene/g; s/,outside/,gene/g; s/,start/,gene/g; s/,end/,gene/g; s/,-/,noGene/g' \
    | sort \
    | uniq -c \
    | grep -v 'geneLocation' \
    | awk -v R=${ref} -v Q=${qry} -v OFS=',' '{print R"~"Q, $2, $1}' >> syriGeneSummary.csv