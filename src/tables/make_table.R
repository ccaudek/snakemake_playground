
log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")

library("here")
library("tidyverse")
library("tidyr")
library("rio")


# load data
# d <- readRDS(here::here("out", "data", "processed", "penguin_subset.rds"))
d <- readRDS(snakemake@input[["penguins_subset"]])

fm <- lm(flipper_length_mm ~ body_mass_g, data = d)
out_tab <- summary(fm)
foo <- summary(fm)

# Save output in a .txt file
# sink(here::here("out", "table", "tab_1.txt"))
sink(snakemake@output[["tab1"]])
print(summary(fm))
sink()  # returns output to the console


# dput(
#   out_tab,
#   file = snakemake@output[["tab1"]],
#   control = "all"
# )

# To re-import the summary object:
# res <- dget(
#   here::here("out", "table","tab_1.txt")
# )
# res

