library(tidyverse)
library(glue)

quadruplet <- function(x) {
    c(glue("VALUE{x}"), glue("MFLAG{x}"), glue("QFLAG{x}"), glue("SFLAG{x}"))
}

widths <- c(11, 4, 2, 4, rep(c(5, 1, 1, 1), 31))
headers <- c("ID", "YEAR", "MONTH", "ELEMENT", unlist(map(1:31, quadruplet)))

dly_files <- list.files("data/ghcnd_all", full.names = TRUE)

read_fwf(
    dly_files,
    fwf_widths(widths, headers),
    na = c("NA", "-9999", ""),
    col_select = c(ID, YEAR, MONTH, ELEMENT, starts_with("VALUE"))
) %>%
    rename_all(tolower) %>%
    filter(element == "PRCP") %>%
    select(-element) %>%
    pivot_longer(
        cols = starts_with("value"),
        names_to = "day",
        values_to = "prcp"
    )
