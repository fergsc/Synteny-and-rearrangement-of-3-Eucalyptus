#!/bin/bash

# Find syri events that contain a TPS gene.
# Convert gene names to OG name so that we can match gene homologues
# Find syri events with the same gene homologue



sppList="E_albens~E_sideroxylon E_albens~E_melliodora E_sideroxylon~E_melliodora"
syriDir=""          # location where syri.out are stored. Files will be named ref~qry.out
syriTypesNotUsed="CPG\|CPL\|DEL\|DUPAL\|HDR\|INS\|INVAL\|INVDPAL\|INVTRAL\|SNP\|SYNAL\|TDM\|TRANSAL"
genesInSyri=""      # this results from syri-genes/syri-genes.py

mkdir syriTPS
cd syriTPS


# get genes list and clean up
for lst in ../*~genes.lst
do
    ref=$(basename $lst ~genes.lst)
    echo $ref
    cut -f1 -d'.' $lst | cut -f1 -d'~' | sed -e 's/_t/_g/g' > $(basename $lst)
done

# get syrigenes
# only save lines with TPS genes
# & work out which events are shared from the reduced gene set of syrigenes
for spp in $sppList
do
    echo $spp
    for sg in `find $genesInSyri -maxdepth 1 -name "$spp~*.syrigenes"`
    do
        sp3=`echo $(basename $sg .syrigenes) | cut -f3 -d'~'`
        grep -wf $sp3~genes.lst < $sg > $(basename $sg)
        [ -f id1 ] &&  cut -f1 -d',' $(basename $sg) | sort | uniq > id2 || cut -f1 -d',' $(basename $sg) | sort | uniq > id1
    done

    sort id1 id2 | uniq -c | awk '$1==2{print $2}' > use
    for sg in `find . -maxdepth 1 -name "$spp~*.syrigenes"`
    do
        grep -wf use < $sg > $(basename $sg).final
    done
    rm id1 id2 use
    mv $(basename $sg).final $(basename $sg)
done

# convert gene name to OG
for sg in `ls -1 *.syrigenes`
do
    sp3=`echo $(basename $sg .syrigenes) | cut -f3 -d'~'`
    echo $sg
    echo "  $sp3"
    while read line
    do 
        og=`echo $line | cut -f1 -d','`
        gene=`echo $line | cut -f2 -d','`

        sed -i "s/$gene/$og/g" $sg
    done < ../../all-OG/$sp3.csv
done

# Lastly,
# find any OG + syriID that match between syri run pairs.
for spp in $sppList
do
    sg1=`ls -1 $spp~*.syrigenes | head -n 1`
    sg2=`ls -1 $spp~*.syrigenes | tail -n 1`

    sp1=`echo $(basename $sg1 .syrigenes) | cut -f3 -d'~'`
    sp2=`echo $(basename $sg2 .syrigenes) | cut -f3 -d'~'`

    echo "type,syri,OG" > $sp1~$sp2.csv
    while read line
    do
        id=`echo $line | cut -f1 -d','`
        type=`echo $line | cut -f2 -d','`
        og=`echo $line | cut -f3 -d','`
        grep -w $id $sg2| grep -w $og >tmp
        [[ $(cat tmp | wc -l) == 1 ]] && echo "$type,$id,$og">> $sp1~$sp2.csv
    done < $sg1
done
rm tmp

for csv in *.csv
do
    echo $(basename $csv .csv)
    tail -n +2 $csv | cut -f1 -d',' | sort | uniq -c | awk '{print $2","$1}' | sort -k2,2h -t','
done
