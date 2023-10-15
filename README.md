# Synteny and rearrangement of 3 Eucalyptus

All genomes were assembled and annoated using https://www.protocols.io/view/plant-assemble-plant-de-novo-genome-assembly-scaff-81wgb6zk3lpk/v1

Genomes were then aligned with nucmer (MUMmer), annotated for syntenic regions and rearrangements with SyRI.
Genomes, genes, transposons, and alignments were processed with the script in this repository.

All work is for the publication: 
Ferguson S, Jones A, Murray K, Schwessinger B, & Borevitz J (2023). Interspecies genome divergence is predominantly due to frequent small scale rearrangements in Eucalyptus. Molecular Ecology, 32, 1271–1287. https://doi.org/10.1111/mec.16608


## Tools/programs
* bioawk
* seqtk
* MUMmer
* SyRI
* GNU paraller
* OrthoFinder
* breaker2

## Sections:

### Alignement
Run nucmer and syri

### Analysis
* contigJoins - for each chromosome of each genome calculatye location of contig joins.
* genes - All gene related scripts.
* synteyPlots - Get data and create synteny karyotype plots.
* syri - Create summary information of syri alignmnents.
* syri-genes - Find what genes are in which syri events.
* TPS - Identify TPS genes and what syri events they are in, and perfrom oftho grouping.
* windowSynteny - Windowed synteny calculatyions and plotting.
