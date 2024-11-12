// Check mandatory parameters
if (params.input) { csv_file = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }
if (params.reference == null) error "Please specify a reference genome fasta file with --reference"

def reference =  file(params.reference)

log.info """\
    =======================================================================
    B U I L D   W I T H   R E S U M E   P I P E L I N E
    ======================================================================
    samplesheet: ${params.input}
    reference: ${params.reference}
    ======================================================================
    """
    .stripIndent()

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT LOCAL MODULES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { FASTP } from './modules/local/fastp'
include { SAMTOOLS_FAIDX } from './modules/local/samtools_faidx'
include { BWA_INDEX } from './modules/local/bwa_index'
include { BWA_MEM } from './modules/local/bwa_mem'
include { BCFTOOLS_CALL } from './modules/local/bcftools_call'

workflow {

	// Read in samplesheet and convert into input sample channel
    Channel.fromPath(params.input) \
        | splitCsv(header:true) \
        | map { row-> tuple(row.sample_id, file(row.fastq_1), file(row.fastq_2)) } \
        | set {input_reads}

	//input_reads.view()
	
	// QC preprocessing of reads
	FASTP(input_reads)
	FASTP.out.reads.view()

	// Create reference index for BWA
	BWA_INDEX(reference)

	// Map reads to reference
	BWA_MEM(FASTP.out.reads, BWA_INDEX.out.index)
	BWA_MEM.out.bam.view()

	// Create reference index for bcftools
	SAMTOOLS_FAIDX(reference)
	

	//BWA_MEM.out.bam.map { tuple -> tuple[1] }.collect().view()
	// Call variants
	BCFTOOLS_CALL(BWA_MEM.out.bam.map { tuple -> tuple[1] }.collect(), BWA_MEM.out.bai.map { tuple -> tuple[1] }.collect(), reference, SAMTOOLS_FAIDX.out.fai)

}
