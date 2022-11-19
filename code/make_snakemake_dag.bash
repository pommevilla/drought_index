#!/usr/bin/env bash

snakemake --dag | dot -Tpng > figures/snakemake_dag.png
