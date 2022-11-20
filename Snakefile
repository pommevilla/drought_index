rule targets:
    input:
        "data/ghcnd_all.tar.gz",
        "data/ghcnd-inventory.txt",
        "data/ghcnd_all_files.txt",
        "data/ghcnd-stations.txt",
        "data/ghcnd_tidy.tsv.gz",
        "data/ghcnd_regions_years.tsv",
        "figures/world_drought.png",
        "figures/snakemake_dag.png",
        "index.html",
        "docs/index.html",
        "docs/figures/world_drought.png"

rule get_all_archive:
    input:
        script = "code/get_ghcnd_data.bash"
    output:
        "data/ghcnd_all.tar.gz"
    conda:
        "environment.yml"
    params:
        file = "ghcnd_all.tar.gz"
    shell:
        """
        {input.script} {params.file}
        """

rule concatenate_dly_files:
    input:
        bash_script = "code/concatenate_dly.bash",
        r_script = "code/read_split_dly_files.R",
        tarball = "data/ghcnd_all.tar.gz"
    output:
        "data/ghcnd_tidy.tsv.gz"
    conda:
        "environment.yml"
    shell:
        """
        {input.bash_script}
        """

rule get_all_filenames:
    input:
        script = "code/get_ghcnd_all_files.bash",
        archive = "data/ghcnd_all.tar.gz"
    output:
        "data/ghcnd_all_files.txt"
    conda:
        "environment.yml"
    shell:
        """
        {input.script}
        """
rule get_inventory:
    input:
        script = "code/get_ghcnd_data.bash"
    output:
        "data/ghcnd-inventory.txt"
    conda:
        "environment.yml"
    params:
        file = "ghcnd-inventory.txt"
    shell:
        """
        {input.script} {params.file}
        """

rule get_station_data:
    input:
        script = "code/get_ghcnd_data.bash"
    output:
        "data/ghcnd-stations.txt"
    conda:
        "environment.yml"
    params:
        file = "ghcnd-stations.txt"
    shell:
        """
        {input.script} {params.file}
        """

rule get_regions_years:
    input:
        r_script = "code/get_regions_years.R",
        data = "data/ghcnd-inventory.txt"
    output:
        "data/ghcnd_regions_years.tsv"
    conda:
        "environment.yml"
    shell:
        """
        {input.r_script}
        """

rule plot_drought_by_region:
    input:
        r_script = "code/plot_drought_by_region.R",
        prcp_data = "data/ghcnd_tidy.tsv.gz",
        station_data = "data/ghcnd_regions_years.tsv"
    output:
        "figures/world_drought.png"
    conda:
        "environment.yml"
    shell:
        """
        {input.r_script}
        """

rule render_index:
    input:
        rmd = "index.Rmd",
        png = "figures/world_drought.png"
    output:
        "index.html"
    conda:
        "environment.yml"
    shell:
        """
        R -e "library(rmarkdown); render('{input.rmd}')"
        """

rule generate_snakemake_dag:
    input:
        script = "code/make_snakemake_dag.bash"
    output:
        "figures/snakemake_dag.png"
    conda:
        "environment.yml"
    shell:
        """
        {input.script}
        """

rule prepare_for_publishing:
    input:
        script = "prepare_for_publishing.bash"
    output:
        "docs/index.html",
        "docs/figures/world_drought.png"
    shell:
        """
        {input.script}
        """