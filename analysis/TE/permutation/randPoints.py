#!/usr/bin/env python3

# python script to generate random points on a sequence
# points will be not occur within pointDist bp of each other
# not checking is performed to ensure that all points of pointDist will fit within sequence.

import random
import sys

if len(sys.argv) < 5:
    print("You need to specifiy:")
    print("    gap between rand points")
    print("    sequence size. Rand points will be from 1 to seqSize")
    print("    number of random points to generate")
    print("    filename to save random points to")
    exit()

pointDist   = int(sys.argv[1])    # gap between rand points
seqSize     = int(sys.argv[2])    # sequence size. Rand points will be from 1 to seqSize
numPoints   = int(sys.argv[3])    # number of random points to generate
saveFile    = sys.argv[4]    # filename to save random points to

randPoints = []
excluded = set()

i = 0
while i<numPoints:
    x = random.randrange(seqSize)
    if x in excluded:
        continue
    randPoints.append(x)
    excluded.update((x+dx) for dx in range(-pointDist,pointDist))
    i += 1

with open(saveFile, 'w') as output_file:
    for value in randPoints:
        output_file.write("{}\n".format(value))

