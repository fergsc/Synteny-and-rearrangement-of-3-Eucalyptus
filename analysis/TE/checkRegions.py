#!/usr/bin/env python3

# checks if a give list of points occur within genome regions.
# points are formatted as: seqName,loci
# regions can be a csv or bed: seqName,start,end
# regionExtension is used to extend regions, eg. +-10bp


# RUN: python3 checkRegions.py regions.bed/csv points.csv/bed regionExtension

import csv
import ntpath
import os
import sys
from intervaltree import Interval, IntervalTree


def SyRIIntervalTree(openFile):
    treeDict = {}
    with open(openFile, "r") as file:
        if openFile.split(".")[1] == "csv":
            regions = csv.reader(file, delimiter=",")
        elif openFile.split(".")[1] == "bed":
           regions = csv.reader(file, delimiter="\t")
        else:
           sys.exit("unknown file extension: {}".format(openFile))

        for region in regions:
            chrom = region[0]
            if chrom == "-":
                continue
            start = int(region[1])
            end = int(region[2])
            if start > end:
                start, end = end, start
            start = start - fuzz
            end = end + fuzz
            if start < 0:
                start = 0
            if chrom not in treeDict:
                treeDict[chrom] = IntervalTree()
            treeDict[chrom].add(Interval(start, end))
    for key in treeDict:
        treeDict[key].merge_overlaps()
    return treeDict

if (len(sys.argv)) < 3:
    sys.exit("required: regions.csv/bed checkRegions.csv/bed, [fuzz = 0]")
regionsFile = sys.argv[1]
checkFile = sys.argv[2]
if (len(sys.argv)) == 4:
    fuzz = int(sys.argv[3])
else:
    fuzz = 0
print("checking with {} fuzz".format(fuzz))

saveName = os.path.splitext(os.path.basename(checkFile))[0]

regions = SyRIIntervalTree(regionsFile)
with open(checkFile, "r") as inFile, open("{}~checked.csv".format(saveName), "w") as outFile:
    if checkFile.split(".")[1] == "csv":
        checks = csv.reader(inFile, delimiter=",")
    elif checkFile.split(".")[1] == "bed":
       checks = csv.reader(inFile, delimiter="\t")
    else:
       sys.exit("unknown file extension: {}".format(checkFile))
#    next(checks) # skip header.
    for check in checks:
        outString = ""
        checkStart = int(check[1])
        checkEnd = int(-1)
        if check[0] not in regions:
            continue
        if len(check) == 2: # have chr,point
            intervals = sorted(regions[check[0]][checkStart])
        else: # have chr,start,end
            checkEnd = int(check[2])
            intervals = sorted(regions[check[0]][checkStart:checkEnd])

        for interval in intervals:
            startIn = checkStart >= interval[0] and checkStart <= interval[1]
            if checkEnd != -1:
                endIn = checkEnd >= interval[0] and checkEnd <= interval[1]
            else:
                endIn = False
            startOut = checkStart < interval[0]
            endOut = checkEnd > interval[1]

            if startIn and endIn:
                outFile.write("{},{},{},inside\n".format(check[0], check[1], check[2]))
                continue
            if startIn and checkEnd == -1:
                outFile.write("{},{},inside\n".format(check[0], check[1]))
                continue
        if len(intervals) == 0:
            if checkEnd == -1:
                outFile.write("{},{},outside\n".format(check[0], check[1]))
            else:
                outFile.write("{},{},{},outside\n".format(check[0], check[1], check[2]))
