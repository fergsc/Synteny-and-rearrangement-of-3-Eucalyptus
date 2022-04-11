# script to take gene locations (genes/makeGenesFile.sh) and a syri file and return a csv file containing
# syriID,type,geneId,geneLocation,dupType
# if no gene is inside a SyRI annotation geneId,geneLocation,dupType = -,-,-
# dupTyype = loss or gain
#           This is for duplications that are lost in refernec, or gained in reference.

# RUN: python3 syri-genes.py E_albens~E_sideroxylon.out
# syri.out and geneRegions.csv should all be in the running directory


# Need to edit this so that chromosomes are not hard coded.

import ntpath
import os
import sys
import csv

def loadGenes(filename):
    tsv_file = open(filename, "r")
    geneFile = csv.reader(tsv_file, delimiter=",")
    chr01=[]
    chr02=[]
    chr03=[]
    chr04=[]
    chr05=[]
    chr06=[]
    chr07=[]
    chr08=[]
    chr09=[]
    chr10=[]
    chr11=[]
    for gene in geneFile:
        chrom = gene[0]
        start = gene[1]
        end = gene[2]
        geneId = gene[3]
        if chrom == "Chr01":
            chr01.append([geneId, int(start), int(end)])
        if chrom == "Chr02":
            chr02.append([geneId, int(start), int(end)])
        if chrom == "Chr03":
            chr03.append([geneId, int(start), int(end)])
        if chrom == "Chr04":
            chr04.append([geneId, int(start), int(end)])
        if chrom == "Chr05":
            chr05.append([geneId, int(start), int(end)])
        if chrom == "Chr06":
            chr06.append([geneId, int(start), int(end)])
        if chrom == "Chr07":
            chr07.append([geneId, int(start), int(end)])
        if chrom == "Chr08":
            chr08.append([geneId, int(start), int(end)])
        if chrom == "Chr09":
            chr09.append([geneId, int(start), int(end)])
        if chrom == "Chr10":
            chr10.append([geneId, int(start), int(end)])
        if chrom == "Chr11":
            chr11.append([geneId, int(start), int(end)])
    return [chr01, chr02, chr03, chr04, chr05, chr06, chr07, chr08, chr09, chr10, chr11]

def inRegion(x, region):
    if region[0] < region[1]:
        return x > region[0] and x < region[1]
    elif region[0] > region[1]:
        return x > region[1] and x < region[0]
    else:
        return False

syriFile = sys.argv[1]
refSpecies = ntpath.basename(syriFile).split("~")[0]
qrySpecies = ntpath.basename(syriFile).split("~")[1]
qrySpecies = qrySpecies.split(".")[0]

if os.path.isfile(syriFile) == False:
    print ("{} doesn't not exist".format(syriFile))
    exit()

if os.path.isfile("{}.csv".format(refSpecies)) == False:
    print ("{}.csv doesn't not exist".format(refSpecies))
    print("awk -v OFS='\\t' '{if($3 == \"gene\"){split($9,a,\";\"); if($4<$5){print $1,$4,$5,a[1]} else {print $1,$5,$4,a[1]}}}' XXX.gtf > XXX.csv")
    exit()

if os.path.isfile("{}.csv".format(qrySpecies)) == False:
    print ("{}.csv doesn't not exist".format(qrySpecies))
    print("awk -v OFS='\\t' '{if($3 == \"gene\"){split($9,a,\";\"); if($4<$5){print $1,$4,$5,a[1]} else {print $1,$5,$4,a[1]}}}' XXX.gtf > XXX.csv")
    exit()

print("ref:{}\nqry:{}".format(refSpecies, qrySpecies))

#
#open files
tsv_file = open(syriFile, "r")
syriFile = csv.reader(tsv_file, delimiter="\t")

refGenes = loadGenes("{}.csv".format(refSpecies))
qryGenes = loadGenes("{}.csv".format(qrySpecies))

#syriGenes = []
refOutput = open("{}~{}~{}.syrigenes".format(refSpecies, qrySpecies, refSpecies),"w")
qryOutput = open("{}~{}~{}.syrigenes".format(refSpecies, qrySpecies, qrySpecies),"w")

refOutput.write("syriID,type,geneId,geneLocation,dupType\n")
qryOutput.write("syriID,type,geneId,geneLocation,dupType\n")

for syriEvent in syriFile:
    # refChr = syriEvent[0]
    # refStart = int(syriEvent[1])
    # refEnd = int(syriEvent[2])
    # qryChr = syriEvent[5]
    # qryStart = int(syriEvent[6])
    # qryEnd = int(syriEvent[7])
    # uID = syriEvent[8]
    # directionB = syriEvent[9]
    # type = syriEvent[10]
    # DUP Copy status = syriEvent[11]
    if syriEvent[10] in ["DUP", "INV", "INVDP", "INVTR", "SYN", "TRANS", "NOTAL"]:
        if syriEvent[0] != "-":
            if syriEvent[0] == "Chr01":
                useChrA = 0
            elif syriEvent[0] == "Chr02":
                useChrA = 1
            elif syriEvent[0] == "Chr03":
                useChrA = 2
            elif syriEvent[0] == "Chr04":
                useChrA = 3
            elif syriEvent[0] == "Chr05":
                useChrA = 4
            elif syriEvent[0] == "Chr06":
                useChrA = 5
            elif syriEvent[0] == "Chr07":
                useChrA = 6
            elif syriEvent[0] == "Chr08":
                useChrA = 7
            elif syriEvent[0] == "Chr09":
                useChrA = 8
            elif syriEvent[0] == "Chr10":
                useChrA = 9
            elif syriEvent[0] == "Chr11":
                useChrA = 10
            if syriEvent[11] == "copygain":
                dupFlag = "loss"
            elif syriEvent[11] == "copyloss":
                dupFlag = "gain"
            else:
                dupFlag = "-"
            geneA = False
            for gene in refGenes[useChrA]:
                startIn =  inRegion(gene[1], [int(syriEvent[1]), int(syriEvent[2])])
                endIn = inRegion(gene[2], [int(syriEvent[1]), int(syriEvent[2])])

                if(startIn and endIn):
                    refOutput.write("{},{},{},inside,{}\n".format(syriEvent[8], syriEvent[10], gene[0], dupFlag))
                    geneA = True

                if(startIn and not endIn):
                    refOutput.write("{},{},{},start,{}\n".format(syriEvent[8], syriEvent[10], gene[0], dupFlag))
                    geneA = True

                if(endIn and not startIn):
                    refOutput.write("{},{},{},end,{}\n".format(syriEvent[8], syriEvent[10], gene[0], dupFlag))
                    geneA = True

                if(gene[1] < int(syriEvent[1]) and gene[1] < int(syriEvent[2])):
                    if(gene[2] > int(syriEvent[1]) and gene[2] > int(syriEvent[2])):
                        refOutput.write("{},{},{},outside,{}\n".format(syriEvent[8], syriEvent[10], gene[0], dupFlag))
                        geneA = True
            if geneA == False:
                refOutput.write("{},{},-,-,-\n".format(syriEvent[8], syriEvent[10]))

        if syriEvent[5] != "-":
            if syriEvent[5] == "Chr01":
                useChrB = 0
            elif syriEvent[5] == "Chr02":
                useChrB = 1
            elif syriEvent[5] == "Chr03":
                useChrB = 2
            elif syriEvent[5] == "Chr04":
                useChrB = 3
            elif syriEvent[5] == "Chr05":
                useChrB = 4
            elif syriEvent[5] == "Chr06":
                useChrB = 5
            elif syriEvent[5] == "Chr07":
                useChrB = 6
            elif syriEvent[5] == "Chr08":
                useChrB = 7
            elif syriEvent[5] == "Chr09":
                useChrB = 8
            elif syriEvent[5] == "Chr10":
                useChrB = 9
            elif syriEvent[5] == "Chr11":
                useChrB= 10
            if syriEvent[11] == "copygain":
                dupFlag = "gain"
            elif syriEvent[11] == "copyloss":
                dupFlag = "loss"
            else:
                dupFlag = "-"
            geneB = False
            for gene in qryGenes[useChrB]:
                startIn =  inRegion(gene[1], [int(syriEvent[6]), int(syriEvent[7])])
                endIn = inRegion(gene[2], [int(syriEvent[6]), int(syriEvent[7])])

                if(startIn and endIn):
                    qryOutput.write("{},{},{},inside,{}\n".format(syriEvent[8], syriEvent[10], gene[0], dupFlag))
                    geneB = True

                if(startIn and not endIn):
                    qryOutput.write("{},{},{},start,{}\n".format(syriEvent[8], syriEvent[10], gene[0], dupFlag))
                    geneB = True

                if(endIn and not startIn):
                    qryOutput.write("{},{},{},end,{}\n".format(syriEvent[8], syriEvent[10], gene[0], dupFlag))
                    geneB = True

                if(gene[1] < int(syriEvent[6]) and gene[1] < int(syriEvent[7])):
                    if(gene[2] > int(syriEvent[6]) and gene[2] > int(syriEvent[7])):
                        qryOutput.write("{},{},{},outside,{}\n".format(syriEvent[8], syriEvent[10], gene[0], dupFlag))
                        geneB = True
            if geneB == False:
                qryOutput.write("{},{},-,-,-\n".format(syriEvent[8], syriEvent[10]))

