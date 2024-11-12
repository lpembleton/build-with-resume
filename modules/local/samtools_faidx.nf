process SAMTOOLS_FAIDX {

    input:
    path(fasta)

    output:
    path ("*.fai")          , emit: fai

    script:
    """
    samtools \\
        faidx \\
        $fasta

    """

}
