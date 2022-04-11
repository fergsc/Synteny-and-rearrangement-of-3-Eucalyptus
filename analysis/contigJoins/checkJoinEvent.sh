#!/bin/bash

# Check the type of event that contig joins occur within
# Requires syri.out and contig join location csv (getJoinLocation.sh)
# syri files are named refSpp~qrySpp.out

syriDir=""

for csv in *.csv
do
    ref=$(basename $csv .csv)
    echo $ref
    for out in `ls -1 ${syriDir}/*${ref}*.out`
    do
        echo "  $out"
        grep -w "DUP\|INV\|INVDP\|INVTR\|NOTAL\|SYN\|TRANS" $out > tmp.out # only use primary types
        file=$(basename $out .out)
        spp1=`echo $file | cut -f1 -d'~'`
        spp2=`echo $file | cut -f2 -d'~'`

        # work out which if we are using the ref or qry info in syri.out
        # and use the correct index into syri.out
        if [ $ref == $spp1 ]
        then
            qry=$spp2
            chr=1
            start=2
            end=3
            echo "     ref=1"
        fi
        if [ $ref == $spp2 ]
        then
            qry=$spp1
            chr=6
            start=7
            end=8
            echo "     ref=2"
        fi

        # check if contig join is with 20 bp of synteny/rearrangement breakpoint
        # if it is record the types.
        while read point
        do
            awk -v P=$point -v C=$chr -v S=$start -v E=$end 'function abs(x) {return x < 0 ? -x : x} BEGIN{split(P,p,",")} $C == p[1]{if(abs($S-p[2])<20 || abs($E-p[2])<20){type = type "," $11}}END{print P type}' tmp.out
        done < $csv >> $ref~tmp.csv

        # for all points that are not near a breakpoint work out what event type they are in
        # output contigJoin,inside:TYPE,ID
        while read point
        do
            awk -v P=$point -v C=$chr -v S=$start -v E=$end 'BEGIN{n = split(P,p,",")} {if(n > 2){print P; exit} if($C == p[1]){if($S <= p[2] && $E >= p[2]) {print P ",inside:" $11 "~" $C","$S","$E; exit}}}' tmp.out
        done < $ref~tmp.csv >> $ref~$qry~checked.csv
    done
done
rm tmp.out


# now check if alinged events have contig joins in other genome
for  csv in `ls *~*~checked.csv`
do
    grep 'inside' $csv | cut -f2 -d'~' > regions.csv
    ref=`echo $(basename $csv ~checked.csv) | cut -f1 -d'~'`
    qry=`echo $(basename $csv ~checked.csv) | cut -f2 -d'~'`

    for join in `cat ${ref}.csv`
    do
        awk -v FS="," -v P=${join} 'BEGIN{split(P,p,",")} p[1] == $1 {if($2 <= p[2] && $3 >= p[2]) {print $0, "hasJoin"} else {print $0, "noJoin"}}' regions.csv >> ${ref}~${qry}~joins.csv
    done

    # count up results
    has=`awk '{if($2 == "hasJoin"){has += 1}; if($2 == "noJoin"){no += 1}} END{print has/(has+no)*100}' ${ref}~${qry}~joins.csv`
    echo "${ref}~${qry}: ${has}%"
    

done

echo "TOTAL:"
awk '{if($2 == "hasJoin"){has += 1}; if($2 == "noJoin"){no += 1}} END{print has/(has+no)*100 "% of " has+no " checks"}' *~*~joins.csv

