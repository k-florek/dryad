## Dryad is a pipeline to construct a reference free core-genome or SNP phylogenetic tree for examining prokaryote relatedness in outbreaks.
[![Build Status](https://travis-ci.org/k-florek/dryad.svg?branch=master)](https://travis-ci.org/k-florek/dryad)

Dryad is a pipeline implemented in Nextflow that uses several programs and pipelines to construct trees from either a core set of genes or a set of SNPs from a reference genome. The pipeline uses the workflow manager Nextflow and Docker containers to maintain stability, reproducibility, and portability by keeping the applications and pipelines used by this pipeline in controlled environments. This also reduces issues surrounding the installation of dependencies.

### Table of Contents:
[Usage](#Using-the-pipeline)  
[Core-genome](#Core-Genome-phylogenetic-tree-construction)  
[SNP](#SNP-phylogenetic-tree-construction)                                                                                        
[Quality-Assessment](#Quality-Assessment)                                                                                         
[Output](#Output-files)  
[Dependencies](#Dependencies)

#### Using the pipeline

The pipeline is designed to start from raw Illumina short reads. All reads must be in the same directory. Then start the pipeline using `./dryad` and follow the options for selecting and running the appropriate pipeline.

```
usage: dryad [-h] pipeline ...

A pipeline for constructing SNP based and reference free phylogenies.

optional arguments:
  -h, --help            show this help message and exit

required arguments:
  pipeline
    -cg, --core-genome  reference free core geneome pipeline
    -s, --snp           CFSAN SNP pipeline
```

The pipeline can also be run with AWS batch (https://aws.amazon.com/batch/) using --profile aws.

Both pipelines begin with a quality trimming step to trim the reads of low quality bases at the end of the read using Trimmomatic v0.39 (http://www.usadellab.org/cms/?page=trimmomatic), the removal of PhiX contamination using BBtools v38.76 (https://jgi.doe.gov/data-and-tools/bbtools/), and the assessment of read quality using FastQC v0.11.8 (https://www.bioinformatics.babraham.ac.uk/projects/fastqc/). After processing, the reads are used by each pipeline as needed. *Note: Both pipelines can be run automatically in succession using the -cg and -s parameters simultaneously.*

#### Core Genome phylogenetic tree construction
The core genome pipeline takes the trimmed and cleaned reads and infers a phylogenetic tree that can be used for inferring outbreak relatedness. This pipeline is based loosely off of the pipeline described here by [Oakeson et. al](https://www.ncbi.nlm.nih.gov/pubmed/30158193).

Species and MLST type are predicted from the assemblies generated during the core genome pipeline, and assembly quality is evaluated.

Additionally, the core genome pipeline can be run with -ar to predict antibiotic resistance genes.

Usage:
```
usage: dryad -cg,--core-genome [-h] [optional arguments] path_to_reads

positional arguments:
  path_to_reads path to paired reads to be included in the analysis

optional arguments:
  -h, --help    show this help message and exit
  --output, -o  output directory - defaults to dryad_results/
  -ar           Detect AR mechanisms
  --profile     Specify a custom Nextflow profile
  --sep         Dryad identifies sample names from the name of the read file by splitting the name 
                on the specified separating characters; default "_"
```

The pipeline uses the following applications and pipelines:

Shovill v1.0.4 (https://github.com/tseemann/shovill)
Shovill is a pipeline centered around SPAdes but alters some of the steps to get similar results in less time.

Prokka v1.14.5 (https://github.com/tseemann/prokka)
Prokka is a whole genome annotation tool that is used to annotate the coding regions of the assembly.

Roary v3.12.0 (https://github.com/sanger-pathogens/Roary)
Roary takes the annotated genomes and constructs a core gene alignment.

IQ-Tree v1.6.7 (http://www.iqtree.org/)
IQ-Tree uses the core gene alignment and creates a maximum likelihood phylogenetic tree bootstraped 1000 times.

Mash v2.1 (https://github.com/marbl/Mash)
Mash performs fast genome and metagenome distance estimation using MinHash.

Mlst v2.17.6 (https://github.com/tseemann/mlst)
Mlst scans contig files against PubMLST typing schemes.

QUAST v5.0.2 (http://bioinf.spbau.ru/quast)
QUAST evaluates genome assemblies.

AMRFinderPlus v3.1.1 (https://github.com/ncbi/amr)
AMRFinderPlus identifies acquired antimicrobial resistance genes.

#### SNP phylogenetic tree construction
The SNP pipeline takes the trimmed and cleaned reads and infers a phylogenetic tree that can be used for inferring outbreak relatedness. The pipeline requires the path to the raw reads (mentioned above) and a reference genome in fasta file format.

Usage:
```
usage: dryad -s,--snp [-h] [optional arguments] path_to_reads -r reference_genome

positional arguments:
  path_to_reads     path to paired reads to be included in the analysis
  reference_genome  reference fasta for SNP tree

optional arguments:
-h, --help    show this help message and exit
--output, -o  output directory - defaults to dryad_results/
--profile     Specify a custom Nextflow profile
--sep         Dryad identifies sample names from the name of the read file by splitting the name on the
              specified separating characters; default "_"
```

The pipeline uses the following applications and pipelines:

CFSAN SNP Pipeline v2.0.2 (https://github.com/CFSAN-Biostatistics/snp-pipeline)

IQ-Tree v1.6.7 (http://www.iqtree.org/)
IQ-Tree uses an alignment of the SNP sites to create a maximum likelihood phylogenetic tree bootstrapped 1000 times.

### Quality Assessment
The results of quality checks from each pipeline are summarized using MultiQC v1.8 (https://multiqc.info/)

#### Output files

**core_genome_tree.tree** - the core-genome phylogenetic tree created by the core-genome pipeline                                       
**ar_predictions.tsv** - antibiotic resistance genes                                                                           
**ar_predictions_binary.tsv** - binary presence/absence matrix of antibiotic resistance genes                                       
**{sample}.mash.txt** - species prediction for each sample                                                                                 
**mlst.tsv** - MLST scheme predictions                                                                                                  
**snp_tree.tree** - the SNP tree created by the SNP pipeline                                                                 
**snp_distance_matrix.tsv** - the SNP distances generated by the SNP pipeline                                                    
**multiqc_report.html** - QC report

#### Dependencies
Nextflow (https://www.nextflow.io)  
Docker (https://www.docker.com)
