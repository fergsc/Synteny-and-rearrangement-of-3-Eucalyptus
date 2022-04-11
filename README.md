# Synteny and rearrangement of 3 Eucalyptus

All genomes were assembled and annoated using https://www.protocols.io/view/plant-assemble-plant-de-novo-genome-assembly-scaff-81wgb6zk3lpk/v1

Genomes were then aligned with nucmer (MUMmer), annotated for syntenic regions and rearrangements with SyRI.
Genomes, genes, transposons, and alignments were processed with the script in this repository.

All work is for the publication: Long-read genome assemblies uncover extensive loss of micro-syntenty and conservation of macro-synteny among three woodland Eucalyptus species.
https://www.authorea.com/users/459343/articles/555631-long-read-genome-assemblies-uncover-extensive-loss-of-micro-syntenty-and-conservation-of-macro-synteny-among-three-woodland-eucalyptus-species


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

### Analysis/
* contigJoins - for each chromosome of each genome calculatye location of contig joins.
* genes - All gene related scripts.
* synteyPlots - Get data and create synteny karyotype plots.
* syri - Create summary information of syri alignmnents.
* syri-genes - Find what genes are in which syri events.
* TPS - Identify TPS genes and what syri events they are in, and perfrom oftho grouping.
* windowSynteny - Windowed synteny calculatyions and plotting.
