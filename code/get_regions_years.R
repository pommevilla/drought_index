#!/usr/bin/env Rscript

# https://www.ncei.noaa.gov/pub/data/ghcn/daily/readme.txt
# ------------------------------
# Variable   Columns   Type
# ------------------------------
# ID            1-11   Character
# LATITUDE     13-20   Real
# LONGITUDE    22-30   Real
# ELEVATION    32-37   Real
# STATE        39-40   Character
# NAME         42-71   Character
# GSN FLAG     73-75   Character
# HCN/CRN FLAG 77-79   Character
# WMO ID       81-85   Character
# ------------------------------
library(tidyverse)

read_fwf("data/ghcnd-inventory.txt",
    col_positions = fwf_cols(
        id = c(1, 11),
        latitude = c(13, 20),
        longitude = c(22, 30),
        element = c(32, 35),
        first_year = c(37, 40),
        last_year = c(42, 45)
    )
) %>%
    filter(element == "PRCP") %>%
    mutate(
        latitude = round(latitude, 0),
        longitude = round(longitude, 0)
    ) %>%
    group_by(longitude, latitude) %>%
    mutate(region = cur_group_id()) %>%
    select(-element) %>%
    write_tsv("data/ghcnd_regions_years.tsv")
