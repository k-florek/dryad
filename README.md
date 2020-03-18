## Dryad is a pipeline to construct a reference free core-genome or SNP phylogenetic tree for examining prokaryote relatedness in outbreaks.
[![Build Status](https://travis-ci.org/k-florek/dryad.svg?branch=master)](https://travis-ci.org/k-florek/dryad)

Dryad is a pipeline that uses several programs and pipelines to construct trees from either a core set of genes or a set of SNPs from a reference genome. The pipeline uses multiprocessing to evenly distribute sample data across cores to maximize the speed of the pipeline. The pipeline uses Docker containers to maintain the stability, reproducibility, and portability by keeping the applications and pipelines used by this pipeline in controlled environments. This also reduces issues surrounding the installation of dependencies.

### Table of Contents:
[Usage](#Using-the-pipeline)  
[Core-genome](#Core-Genome-phylogenetic-tree-construction)  
[SNP](#SNP-phylogenetic-tree-construction)  
[Output](#Output-files)  
[Dependencies](#Dependencies)  

#### Using the pipeline

The pipeline is designed to start from raw Illumina short reads. The core-genome pipeline only requires a text file that contains the paths to the raw reads used in the analysis. This can simply be generated using the following command `find {read_path} -name "*.fastq.gz" > read_file.txt` and just replacing `{read_path}` with the path to the folder containing the reads. Then start the pipeline using `./dryad` and follow the options for selecting and running the appropriate pipeline.

Note: Sample names that have an _ will not work with this pipeline. It is suggested to remove the _ from the fastq names before running. E.g. `sample_1_R1_L001.fastq.gz` should be `sample-1_R1_L001.fastq.gz`.

```
usage: dryad [-h] pipeline ...

A pipeline for constructing SNP based and reference free phylogenies.

optional arguments:
  -h, --help  show this help message and exit

required arguments:
  pipeline
    cg        reference free core geneome pipeline
    snp       CFSAN SNP pipeline
    all       all pipelines
```

Both pipelines begin with a quality trimming step to trim the reads of low quality bases at the end of the read using Trimmomatic v0.39 (http://www.usadellab.org/cms/?page=trimmomatic). After the trimming process the read information is then used by each pipeline as needed. *Note: Both pipelines can be run automatically in succession using the `all` parameter.*

#### Core Genome phylogenetic tree construction
The core-genome pipeline takes the trimmed reads and generates a phylogenetic tree that can be used for inferring outbreak relatedness. The pipeline only requires the text file containing the read paths mentioned above. This pipeline is based loosely off of the pipeline described here by [Oakeson et. al](https://www.ncbi.nlm.nih.gov/pubmed/30158193).

Usage:
```
usage: dryad cg [-h] [-o output] [-t threads] reads

positional arguments:
  reads       text file listing the location of paired reads to be included in
              the analysis

optional arguments:
  -h, --help  show this help message and exit
  -o output   output directory - defaults to working directory
  -t threads  number of cpus to use for pipeline - default of 4
```

The pipeline uses the following applications and pipelines:

Shovill v1.0.4 (https://github.com/tseemann/shovill)
Shovill is a pipeline centered around SPAdes but alters some of the steps to get similar results in less time.

Prokka v1.14.0 (https://github.com/tseemann/prokka)
Prokka is a whole genome annotation tool that is used to annotate the coding regions of the assembly.

Roary v3.6.0 (https://github.com/sanger-pathogens/Roary)
Roary takes the annotated genomes and constructs a core gene alignment.

IQ-Tree v1.6.7 (http://www.iqtree.org/)
IQ-Tree uses the core gene alignment and creates a maximum likelihood phylogenetic tree bootstraped 1000 times.

#### SNP phylogenetic tree construction
The SNP pipeline takes the trimmed reads and generates a phylogenetic tree that can be used for inferring outbreak relatedness. The pipeline requires the text file containing the read paths mentioned above and a reference genome in a fasta file format.

Usage:
```
usage: dryad snp [-h] [-o output] [-t threads] reads reference_sequence

positional arguments:
  reads               text file listing the location of paired reads to be
                      included in the analysis
  reference_sequence  reference fasta for SNP tree

optional arguments:
  -h, --help          show this help message and exit
  -o output           output directory - defaults to working directory
  -t threads          number of cpus to use for pipeline - default of 4
```

CFSAN SNP Pipeline v2.0.2 (https://github.com/CFSAN-Biostatistics/snp-pipeline)

IQ-Tree v1.6.7 (http://www.iqtree.org/)
IQ-Tree uses an alignment of the SNP sites to create a maximum likelihood phylogenetic tree bootstraped 1000 times.


#### Output files
The dryad pipeline creates a folder named `dryad-XXXXXXXXXX` when it is initially run. The x values are replaced with datetime information. In the dryad folder you will find the intermediate and result files. The following files are the key output files generated by the pipeline.

**core_genome_tree.tree** - the core-genome phylogenetic tree created by the core-genome pipeline  
**snp_tree.tree** - the SNP tree created by the SNP pipeline  
**snp_distance_matrix.tsv** - the SNP distances generated by the SNP pipeline  

#### Dependencies
Python 3 (https://www.python.org)  
Docker (https://www.docker.com)  
python Docker library (https://github.com/docker/docker-py)  
Process and System utilities (https://pypi.org/project/psutil/)  

To install the python dependencies use pip `pip install -r requirements.txt`
