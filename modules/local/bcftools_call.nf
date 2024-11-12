process BCFTOOLS_CALL {

    publishDir "./results/variants", pattern: '*.vcf.gz', mode: 'copy'

    input:
    path(bam)
    path(bai)
    path fasta
    path fai

    output:
    path("*.vcf.gz") , emit: vcf
    
    script:
    """
    bcftools mpileup \\
        --output-type u \\
        --fasta-ref ${fasta} \\
        --max-depth 4000 \\
        --annotate AD,DP \\
        ${bam} | bcftools call \\
            --variants-only \\
            --multiallelic-caller \\
            --output-type z \\
            --group-samples - \\
            --skip-variants indels \\
            --output variants.vcf.gz

    """
}
