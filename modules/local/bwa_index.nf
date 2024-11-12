process BWA_INDEX {

    input:
    path(fasta)

    output:
    path(bwa) , emit: index
    
    script:
    """
    mkdir bwa
    bwa \\
        index \\
        -p bwa/\$(basename ${fasta}) \\
        ${fasta}

    """
}
