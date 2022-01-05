# Script recovered from
# https://github.com/kpj/rna-seq-star-deseq2/blob/master/workflow/scripts/plot-pca.R


log <- file(snakemake@log[[1]], open="wt")
sink(log)
sink(log, type="message")

library("rio")
library("tidyverse")
library("tidyr")
library("viridis")


# load deseq2 data
d <- rio::import(snakemake@input[["penguins_data"]])

# obtain normalized counts
# counts <- rlog(dds, blind=FALSE)
# svg(snakemake@output[[1]])
# plotPCA(counts, intgroup=snakemake@params[["pca_labels"]])

mytitle <- snakemake@params[["title_label"]]
my_x1_label <- snakemake@params[["x1_label"]]

p1 <- d %>% 
  ggplot(aes(bill_length_mm, bill_depth_mm, colour = species)) +
  geom_point() +
  scale_fill_viridis(discrete = TRUE, option = "viridis") +
  labs(
    title = mytitle,
    x = my_x1_label
    )

ggsave(snakemake@output[["fig1"]], width=8, height = 5)

my_x2_label <- snakemake@params[["x2_label"]]
p2 <- d %>% 
  ggplot(aes(flipper_length_mm, body_mass_g, colour = species)) +
  geom_point() +
  scale_fill_viridis(discrete = TRUE, option = "viridis") +
  labs(
    title = mytitle,
    x = my_x2_label
  )

ggsave(snakemake@output[["fig2"]], width=8, height = 5)

d1 <- d %>% 
  dplyr::select(
    flipper_length_mm, body_mass_g
  )

saveRDS(
  d1, snakemake@output[["data_subset"]]
)

# dev.off()

# Check this out:
# https://snakemake.readthedocs.io/en/stable/snakefiles/rules.html#non-file-parameters-for-rules


