# calculate the proportion of bases within a window that are of syriType (eg. SYN, NOTAL)
# RUN: python3 syriWindow.py type windowSize Spp1 Spp2
#     eg. python3 syriWindow.py SYN 1000 E_albens E_sideroxylon
# OUTPUT: chromosome,start,end,count,pc .csv


import sys
import csv
import math
import ntpath

SYRI_DIR = "/scratch/xe2/sf3809/mell-alb-sider/syri/SyRI"
GENOME_DIR = "/scratch/xe2/sf3809/mell-alb-sider/genomes"

def incrementList(list, x = 1):
    '''
    Add a score, default 1
    to the pased in list.
    '''
    xxx = []
    for n in list:
        if n + x <0:
            xxx.append(0)
        else:
            xxx.append(n + x)
    return xxx

def getGenomeSize(chromosomes, chr):
    '''
    Takes in the genome file and returns the
    chromosome size of the requested chromosome
    '''
    for x in chromosomes:
        if (x[0] == chr):
            return int(x[1])


##########
### START
###

# read in file names & parameters
syriType = sys.argv[1]
window = int(sys.argv[2])
sp1 = sys.argv[3]
sp2 = sys.argv[4]
print("{}-{}: {} ~ {}".format(syriType, window, sp1, sp2))

# setup chromosomes
chroms = ["Chr01", "Chr02", "Chr03", "Chr04", "Chr05", "Chr06", "Chr07", "Chr08", "Chr09", "Chr10", "Chr11"]

##########
### read in genome file
### set up score matrix
with open("{}/{}.genome".format(GENOME_DIR, sp1)) as f:
    genome1 = f.read().splitlines()
genome1 = [(x.split("\t")) for x in genome1]

with open("{}/{}.genome".format(GENOME_DIR, sp2)) as f:
    genome2 = f.read().splitlines()
genome2 = [(x.split("\t")) for x in genome2]


##########
### initalise save file.
### clear if it exists and write out header
with open("{}~{}~{}~{}.csv".format(sp1, sp2, syriType, window), "w") as outfile:
    outfile.write("chromosome,start,end,count,pc\n")

with open("{}~{}~{}~{}.csv".format(sp2, sp1, syriType, window), "w") as outfile:
    outfile.write("chromosome,start,end,count,pc\n")

##########
### loop over chromosomes and score each one
for index, currChrom in enumerate(chroms):
    #print("Chrom:{}".format(currChrom))
    # get chromosome size & build score list
    gSize1 = getGenomeSize(genome1, currChrom)
    gSize2 = getGenomeSize(genome2, currChrom)

    score1 = [0] * gSize1
    score2 = [0] * gSize2


    tsvFile = open("{}/{}~{}/{}_{}.out".format(SYRI_DIR, sp1, sp2, syriType, currChrom), "r")
    syriEvents = csv.reader(tsvFile, delimiter="\t")

    for event in syriEvents:
        # first do sp1
        start = int(event[1])
        end = int(event[2])
        if start > end:
            start , end = end, start
        score1[start:end] = [1] * (end-start) #incrementList(score1[start:end])

        # now do sp1
        start = int(event[6])
        end = int(event[7])
        if start > end:
            start , end = end, start
        score2[start:end] = [1] * (end-start )#incrementList(score2[start:end])
    tsvFile.close()


    ##########
    ### save results

    with open("{}~{}~{}~{}.csv".format(sp1, sp2, syriType, window), "a+") as outfile:
        for i in range(0, gSize1, window):
            outfile.write("{},{},{},{},{}\n".format(currChrom, i, i+window, sum(score2[i:i+window]),sum(score1[i:i+window])/window))

    with open("{}~{}~{}~{}.csv".format(sp2, sp1, syriType, window), "a+") as outfile:
        for i in range(0, gSize2, window):
            outfile.write("{},{},{},{},{}\n".format(currChrom, i, i+window, sum(score2[i:i+window]), sum(score2[i:i+window])/window))

