process BWA_MEM {

    publishDir "./results/mapping", pattern: '*.bam', mode: 'copy'  
	publishDir "./results/mapping", pattern: '*.bai', mode: 'copy'  

    input:
    tuple val(sample), path(read1), path(read2)
    path(index)
     
    output:
    tuple val(sample), path("*.bam")	, emit: bam
    tuple val(sample), path("*bai")		, emit: bai

    script:
	"""
		INDEX=`find -L ./ -name "*.amb" | sed 's/.amb//'`

		bwa mem \\
			-t 4 \\
			\$INDEX \\
			${read1} ${read2} \\
			| samtools sort --threads 4 -o ${sample}.bam
		
		samtools \\
			index \\
			-@ 1 \\
			${sample}.bam

	"""
}
