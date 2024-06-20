// Alignment_based subworkflow

include { PARSNP           } from '../../modules/local/parsnp'
include { IQTREE           } from '../../modules/nf-core/iqtree'
include { SNPDISTS         } from '../../modules/nf-core/snpdists'

workflow ALIGNMENT_BASED {

    take:
    reads       // channel: [ path[ reads ] ]
    fasta       // channel: /path/to/genome.fasta
    outdir      // output directory
    partition   // tells parsnp if it's important to partition

    main:
    ch_versions = Channel.empty()       // Creating empty version channel to get versions.yml

//
// PARSNP
//
    PARSNP (
        reads,
        fasta,
        partition
        )
    ch_versions = ch_versions.mix(PARSNP.out.versions) 

//
// IQTREE
//
    IQTREE (
        PARSNP.out.mblocks
    )
    ch_versions = ch_versions.mix(IQTREE.out.versions)

//
// SNPDISTS
//
    SNPDISTS (
        PARSNP.out.mblocks
    )
    ch_versions = ch_versions.mix(SNPDISTS.out.versions)

    emit:
    phylogeny    =      IQTREE.out.phylogeny
    tsv          =      SNPDISTS.out.tsv
    versions     =      ch_versions
}