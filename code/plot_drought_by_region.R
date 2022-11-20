#!/usr/bin/env Rscript

library(tidyverse)
library(lubridate)
library(glue)
library(showtext)

font_add_google("Roboto slab", family = "roboto-slab")
font_add_google("Rubik", family = "rubik")
showtext_auto()

prcp_data <- read_tsv("data/ghcnd_tidy.tsv.gz")

station_data <- read_tsv("data/ghcnd_regions_years.tsv")

lat_long_prcp <- inner_join(prcp_data, station_data, by = "id") %>%
    filter((year != first_year & year != last_year) | year == 2022) %>%
    group_by(latitude, longitude, year) %>%
    summarize(mean_prcp = mean(prcp), .groups = "drop")

end <- format(today(), "%B %d")
start <- format(today() - 30, "%B %d")

lat_long_prcp %>%
    group_by(latitude, longitude) %>%
    mutate(
        z_score = (mean_prcp - mean(mean_prcp)) / sd(mean_prcp),
        n = n()
    ) %>%
    ungroup() %>%
    filter(n >= 50 & year == 2022) %>%
    select(-c(n, mean_prcp, year)) %>%
    mutate(z_score = case_when(
        z_score > 2 ~ 2,
        z_score < -2 ~ -2,
        TRUE ~ z_score
    )) %>%
    ggplot(aes(longitude, latitude, fill = z_score)) +
    geom_tile() +
    coord_fixed() +
    scale_fill_gradient2(
        low = "#d8b365", mid = "#f5f5f5", high = "#5ab4ac", midpoint = 0,
        breaks = c(-2, -1, 0, 1, 2),
        labels = c("<-2,", "-1", "0", "1", ">2"),
        name = NULL
    ) +
    theme(
        plot.background = element_rect(fill = "black", color = "black"),
        panel.background = element_rect(fill = "black"),
        panel.grid = element_blank(),
        legend.background = element_blank(),
        legend.text = element_text(color = "#f5f5f5", family = "rubik"),
        legend.position = c(0.15, 0.0),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        legend.key.height = unit(0.25, "cm"),
        legend.direction = "horizontal",
        plot.title = element_text(color = "#f5f5f5", size = 20, family = "roboto-slab"),
        plot.caption = element_text(color = "#f5f5f5", family = "rubik"),
        plot.subtitle = element_text(color = "#f5f5f5", family = "rubik")
    ) +
    labs(
        title = glue("Amount of precipitation for {start} to {end}"),
        subtitle = "Standardized z-scores for at least hte past 50 years",
        caption = "Precipitation data collected from GHCN daily data at NOAA"
    )

ggsave("figures/world_drought.png", width = 8, height = 4)
