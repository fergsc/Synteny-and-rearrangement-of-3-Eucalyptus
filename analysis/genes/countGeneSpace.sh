#!/bin/bash


# count the number of BP that genes occupy in a gtf file produced from breaker2

awk -v S=$(basename $1 .gtf) '{
	if($2 == "AUGUSTUS" && $3 == "gene")
    {
        count = count +$5 - $4
    }
    if($2 == "GeneMark.hmm")
    {
        if($3 == "start_codon")
        {
            count = count - $4
        };
        if($3 == "stop_codon")
        {
            count = count + $5
        }
    }
} END{print S, count}' $1
