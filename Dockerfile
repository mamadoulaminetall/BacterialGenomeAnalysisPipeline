FROM continuumio/miniconda3

# Installer les dépendances de base
RUN apt-get update && apt-get install -y \
    git \
    wget \
    fastqc \
    bwa \
    spades \
    prokka \
    && apt-get clean

# Installer Snakemake
RUN conda install -c bioconda snakemake

# Copier le contenu du projet
COPY . /workspace
WORKDIR /workspace

# Installer les environnements Conda pour chaque étape
RUN conda env create -f envs/fastqc.yml
RUN conda env create -f envs/spades.yml
RUN conda env create -f envs/bwa.yml
RUN conda env create -f envs/prokka.yml
RUN conda env create -f envs/resfinder.yml
RUN conda env create -f envs/roary.yml

# Exécuter Snakemake
ENTRYPOINT ["snakemake", "--use-conda"]
CMD ["--cores", "1"]
