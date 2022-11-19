#!/usr/bin/env Rscript

library(tidyverse)
library(glue)
library(lubridate)

tday_julian <- yday(today())
window <- 30

quadruplet <- function(x) {
    c(glue("VALUE{x}"), glue("MFLAG{x}"), glue("QFLAG{x}"), glue("SFLAG{x}"))
}

widths <- c(11, 4, 2, 4, rep(c(5, 1, 1, 1), 31))
headers <- c("ID", "YEAR", "MONTH", "ELEMENT", unlist(map(1:31, quadruplet)))

process_xfiles <- function(x) {
    print(x)
    read_fwf(x,
        fwf_widths(widths, headers),
        na = c("NA", "-9999", ""),
        col_types = cols(.default = col_character()),
        col_select = c(ID, YEAR, MONTH, starts_with("VALUE"))
    ) %>%
        rename_all(tolower) %>%
        pivot_longer(
            cols = starts_with("value"),
            names_to = "day",
            values_to = "prcp"
        ) %>%
        # drop_na() %>%
        # filter(prcp != 0) %>%
        mutate(
            day = str_replace(day, "value", ""),
            date = ymd(glue("{year}-{month}-{day}"), quiet = TRUE),
            prcp = replace_na(prcp, "0"),
            prcp = as.numeric(prcp) / 100 # prcp now in cm
        ) %>%
        drop_na(date) %>%
        select(id, date, prcp) %>%
        mutate(
            julian_day = yday(date),
            diff = tday_julian - julian_day,
            is_in_window = case_when(
                diff < window & diff > 0 ~ TRUE,
                diff > window ~ FALSE,
                tday_julian < window & diff + 365 < window ~ TRUE,
                diff < 0 ~ FALSE
            ),
            year = year(date),
            year = if_else(diff < 0, year + 1, year)
        ) %>%
        filter(is_in_window) %>%
        group_by(id, year) %>%
        summarize(prcp = sum(prcp), .groups = "drop")
}

xfiles <- list.files("data/temp", full.names = TRUE)

map_dfr(xfiles, process_xfiles) %>%
    group_by(id, year) %>%
    summarize(prcp = sum(prcp), .groups = "drop") %>%
    write_tsv("data/ghcnd_tidy.tsv.gz")
