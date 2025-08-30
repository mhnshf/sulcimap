setwd("~/bv_stat_figures")

source("functions.R")

df <- read.csv("input_data_example.csv")

plot_out <- plot_sulci(
  sulcus_values = df,                              # input dataframe with Sulcus and Value
  palette       = "gyr",                           # color palette
  value_range   = NULL,                            # value range (NULL = auto, c(m,M) = fixed scale)
  save_dir      = "output",                        # directory to save plots
  measure       = "opening",                       # "all" to plot all four measures or choose one: "opening", "depth", "surface", "length"
  show_colorbar = TRUE,                            # color bar show/hide
  caption       = expression(-log[10](p))          # colorbar caption
)
