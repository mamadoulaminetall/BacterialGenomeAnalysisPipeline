# Snakefile

# Paramètres
reads = "data/*.fastq.gz"
output_dir = "results"

# Règle pour le contrôle qualité avec FastQC
rule fastqc:
    input:
        reads
    output:
        "{output_dir}/fastqc_reports/{reads}.html"
    conda:
        "envs/fastqc.yml"
    shell:
        """
        fastqc -o {output_dir}/fastqc_reports {input}
        """

# Règle pour l'assemblage du génome avec SPAdes
rule assemble_genome:
    input:
        reads
    output:
        "{output_dir}/assembly/genome.fasta"
    conda:
        "envs/spades.yml"
    shell:
        """
        spades.py -s {input} -o {output_dir}/assembly
        """

# Règle pour l'alignement avec BWA
rule align_sequences:
    input:
        genome = "{output_dir}/assembly/genome.fasta",
        reference = "data/reference.fasta"
    output:
        "{output_dir}/alignment/aligned.sam"
    conda:
        "envs/bwa.yml"
    shell:
        """
        bwa mem {input.reference} {input.genome} > {output}
        """

# Règle pour l'annotation du génome avec Prokka
rule annotate_genome:
    input:
        genome = "{output_dir}/assembly/genome.fasta"
    output:
        "{output_dir}/annotation/annotation.gff"
    conda:
        "envs/prokka.yml"
    shell:
        """
        prokka --outdir {output_dir}/annotation --prefix genome {input.genome}
        """

# Règle pour l'analyse de la résistance aux antibiotiques avec ResFinder
rule resistance_analysis:
    input:
        genome = "{output_dir}/assembly/genome.fasta"
    output:
        "{output_dir}/resistance/resfinder_output.txt"
    conda:
        "envs/resfinder.yml"
    shell:
        """
        resfinder -i {input.genome} -o {output}
        """

# Règle pour l'analyse de la diversité génétique avec Roary
rule diversity_analysis:
    input:
        genomes = "{output_dir}/assembly/genomes/*.fasta"
    output:
        "{output_dir}/diversity/roary_output"
    conda:
        "envs/roary.yml"
    shell:
        """
        roary -i 90 -p 8 -o {output_dir}/diversity/ {input.genomes}
        """
