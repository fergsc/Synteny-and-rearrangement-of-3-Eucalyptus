#!/bin/bash

# after running syriWindows.py
# run this to combine data from different window sizes and get summary for joy plots.

for spp in E_albens~E_sideroxylon E_albens~E_melliodora E_sideroxylon~E_albens E_sideroxylon~E_melliodora E_melliodora~E_albens E_melliodora~E_sideroxylon
do
    echo $spp
    echo "size,pc" > ${spp}.summary
    for size in 5000 10000 100000 500000 1000000 1500000 2000000 2500000 5000000 10000000
    do
        echo "  $size"
        cut -f5 -d',' ${size}/${spp}~SYN~${size}.csv |awk -v S=${size} 'NR > 1 {print S","$1}' >> ${spp}.summary
    done
done
