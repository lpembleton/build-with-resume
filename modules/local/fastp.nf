process FASTP {

    input:
    tuple val(sample), path(read1), path(read2)
	
    output:
    tuple val(sample), path('*_1.fastp.fastq.gz'), path('*_2.fastp.fastq.gz') , emit: reads

    script:   
	"""
	fastp \\
		--in1 ${read1} \
		--in2 ${read2} \
		--out1 ${sample}_1.fastp.fastq.gz \\
		--out2 ${sample}_2.fastp.fastq.gz \\
		--json ${sample}.fastp.json \\
		--html ${sample}.fastp.html \\
		2> ${sample}.fastp.log

	"""
}