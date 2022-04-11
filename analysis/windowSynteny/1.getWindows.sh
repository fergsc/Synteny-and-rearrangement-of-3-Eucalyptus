#!/bin/bash 

# calculate the proportion of syntenic bases within windows.
# 
# output: chromosome,start,end,count,pc
# will be an entry for each window within a genome
#


type="SYN"
for window in 5000 10000 100000 500000 1000000 1500000 2000000 2500000 5000000 10000000
do
    python3 syriWindows.py $type $window E_albens E_sideroxylon
    python3 syriWindows.py $type $window E_albens E_melliodora
    python3 syriWindows.py $type $window E_sideroxylon E_melliodora
    mkdir $window
    mv *~${window}.csv $window
done
