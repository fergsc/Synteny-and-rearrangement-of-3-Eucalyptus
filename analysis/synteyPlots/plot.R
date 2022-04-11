library(karyoploteR)
library(data.table)

setwd("/path to data/data")
genomeDir = "data/genomes" # tsv per species containing sequence name & length. 
syriDirSYN = "data/SYN"
syriDirNOTAL = "data/NOTAL"
genes = "data/TPS/all~gene.csv"

chromosomes = c("Chr01", "Chr02", "Chr03", "Chr04", "Chr05", "Chr06", "Chr07", "Chr08", "Chr09", "Chr10", "Chr11")
syriFiles = c("E_albens~E_melliodora",
              "E_sideroxylon~E_melliodora",
              "E_albens~E_sideroxylon")
plotOrder = c("E_albens",
              "E_melliodora",
              "E_sideroxylon",
              "E_albens")
saveLocation = "plots/loop~TPS"
dir.create(saveLocation)

##########
### Get TPS gene locations
genesDF = fread(genes, header = TRUE)


##########
### get chromosome sizes
# use: genomes[, "ssp"] to get all sizes for species ssp
# use genomes["Chr01", ] to get chromosome sizes
genomes = matrix(ncol = length(plotOrder), nrow = 11, dimnames = list(chromosomes, plotOrder))
for(species in plotOrder)
{
  genomes[, species] = unlist(fread(sprintf("%s/%s.genome", genomeDir, species))[,2])
}


##########
### create index so that  outpout can be combined
indexRegion = toGRanges(plotOrder[1], start = 1, end = 2) # used to get links to line up not display karyotypes

syntRegions = c()
for(chr in chromosomes)
{
  ### setup
  currGenome = toGRanges(data.frame(chr=colnames(genomes), start=rep(1, length(plotOrder)), 
                                    end=genomes[chr,]))
  ### print a blank karyotype
  png(sprintf("%s/%s~blank.png", saveLocation, chr), width = 2048, height = 1536)
  kp = plotKaryotype(genome = currGenome)
  dev.off()
  
  ### gene locations
  currGenes = genesDF[genesDF$chromosome == chr,]
  currGenes = rbind(currGenes, data.frame(chromosome=chr, start=1, stop=2, species="E_albens")) # index, remove me from plots!!!!
  geneRegions = toGRanges(data.frame(chr=currGenes$species, start=currGenes$start, 
                                     end=currGenes$stop, gieStain = "acen"))
  png(sprintf("%s/%s~TPS.png", saveLocation, chr), width = 2048, height = 1536)
  kp = plotKaryotype(genome = currGenome, cytobands = geneRegions)
  dev.off()
  
  firstRun = TRUE
  for(currSyri in syriFiles)
  {
    print(currSyri)
    currSyn = fread(sprintf("%s/%s/SYN_%s.out", syriDirSYN, currSyri, chr))
    synRef = data.frame(unlist(strsplit(currSyri, "~"))[1], currSyn$V2, currSyn$V3, currSyn$V9, "stalk")
    synQuery = data.frame(unlist(strsplit(currSyri, "~"))[2], currSyn$V7, currSyn$V8, currSyn$V9, "stalk")
    colnames(synRef) = c("chr", "start", "end", "name", "gieStain")
    colnames(synQuery) = c("chr", "start", "end", "name", "gieStain")
    if(firstRun)
    {
      a = synRef
      b = synQuery
      firstRun = FALSE
    }
    else
    {
      a = rbind(a, synRef)
      b = rbind(b, synQuery)
    } 
  }
  synBands = toGRanges(rbind(a,b))
  inv1 = toGRanges(a)
  inv2 = toGRanges(b)
  
  png(sprintf("%s/%s~links.png", saveLocation, chr), width = 2048, height = 1272)#1536
  kp = plotKaryotype(genome = currGenome, plot.type = 1, main = chr, cytobands = indexRegion)
  kp = kpPlotLinks(kp, data=inv1, data2=inv2, col = "#647FA4", ymin=0.17, arch.height = 0.3)#, ymax=1 )
  dev.off()
}

##########
### notal- produce 3 plots, will need to manually join
syntRegions = c()
for(chr in chromosomes)
{
  ### setup
  currGenome = toGRanges(data.frame(chr=colnames(genomes), start=rep(1, length(plotOrder)), 
                                    end=genomes[chr,]))
  
  for(currSyri in syriFiles)
  {
    refNOTAL = fread(sprintf("%s/%s/NOTAL_ref_%s.out", syriDirNOTAL, currSyri, chr), select = c(2,3))
    qryNOTAL = fread(sprintf("%s/%s/NOTAL_qry_%s.out", syriDirNOTAL, currSyri, chr), select = c(7,8))
    
    refNOTALBands = toGRanges(unlist(strsplit(currSyri, "~"))[1], start = refNOTAL$V2, end = refNOTAL$V3, gieStain = "gpos100")
    qryNOTALBands = toGRanges(unlist(strsplit(currSyri, "~"))[2], start = qryNOTAL$V7, end = qryNOTAL$V8, gieStain = "gpos100")
    png(sprintf("%s/%s~%s~%s~notal.png", saveLocation, chr, unlist(strsplit(currSyri, "~"))[1], unlist(strsplit(currSyri, "~"))[2]), width = 2048, height = 765)#1536
    #kp = plotKaryotype(genome = currGenome, plot.type = 1, main = chr, cytobands = indexRegion)
    kp = plotKaryotype(genome = currGenome, plot.type = 1, main = chr, cytobands = c(refNOTALBands, qryNOTALBands))
    kpPlotRegions(kp, data=indexRegion, r0=0, r1=0.45)
    dev.off()
    
  }
}