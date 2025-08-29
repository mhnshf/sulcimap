# Developer: Mahan Shafie

# Set working directory
current_dir <- getwd()
new_dir <- file.path(current_dir)

if (dir.exists(new_dir)) {
  setwd(new_dir)
} else {
  stop("Directory does not exist: ", new_dir)
}

# Add functions
source("functions.R")

# List all needed packages here (add or remove as needed)
required_packages <- c(
  "ggplot2",
  "patchwork",
  "cowplot",
  "grid"
  # add others if needed
)

install_and_load(required_packages)

# Create output directory if it doesn't exist
output_dir <- "output"
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

# List of left lateral and medial sulci
left_lateral_names <- readLines("leftlat_files/leftlatnames.txt")
left_medial_names <- readLines("leftmed_files/leftmednames.txt")
right_lateral_names <- readLines("rightlat_files/rightlatnames.txt")
right_medial_names <- readLines("rightmed_files/rightmednames.txt")

# Set input ################################################################################
args <- commandArgs(trailingOnly = TRUE)

if (length(args) == 0) {
  stop("Please provide the path to the CSV file as an argument.")
}

input_csv <- args[1]

# Read your CSV using the input path
df <- read.csv(input_csv)

#df <- read.csv("input_data_example.csv")

# Opening
df_opening <- subset(df, grepl("\\.opening$", Sulcus))
df_opening$Sulcus <- sub("\\.opening$", "", df_opening$Sulcus)

# Depth
df_depth <- subset(df, grepl("\\.meandepth_native$", Sulcus))
df_depth$Sulcus <- sub("\\.meandepth_native$", "", df_depth$Sulcus)

# Surface
df_surface <- subset(df, grepl("\\.surface_native$", Sulcus))
df_surface$Sulcus <- sub("\\.surface_native$", "", df_surface$Sulcus)

# Length
df_length <- subset(df, grepl("\\.hull_junction_length_native$", Sulcus))
df_length$Sulcus <- sub("\\.hull_junction_length_native$", "", df_length$Sulcus)

# opening ################################################################################
# Rename columns to standard names for consistency
colnames(df_opening) <- c("Sulcus", "Value")

# Filter left lateral and medial sulci
df_opening_left_lateral <- df_opening[df_opening$Sulcus %in% left_lateral_names, ]
df_opening_left_lateral <- df_opening_left_lateral[match(left_lateral_names, df_opening_left_lateral$Sulcus), ]

df_opening_left_medial <- df_opening[df_opening$Sulcus %in% left_medial_names, ]
df_opening_left_medial <- df_opening_left_medial[match(left_medial_names, df_opening_left_medial$Sulcus), ]

# Create named vector
sulcus_opening_values_left_lateral <- setNames(df_opening_left_lateral$Value, df_opening_left_lateral$Sulcus)
sulcus_opening_values_left_medial <- setNames(df_opening_left_medial$Value, df_opening_left_medial$Sulcus)

# Filter right lateral and medial sulci
df_opening_right_lateral <- df_opening[df_opening$Sulcus %in% right_lateral_names, ]
df_opening_right_lateral <- df_opening_right_lateral[match(right_lateral_names, df_opening_right_lateral$Sulcus), ]

df_opening_right_medial <- df_opening[df_opening$Sulcus %in% right_medial_names, ]
df_opening_right_medial <- df_opening_right_medial[match(right_medial_names, df_opening_right_medial$Sulcus), ]

# Create named vector
sulcus_opening_values_right_lateral <- setNames(df_opening_right_lateral$Value, df_opening_right_lateral$Sulcus)
sulcus_opening_values_right_medial <- setNames(df_opening_right_medial$Value, df_opening_right_medial$Sulcus)

# depth ################################################################################
# Rename columns to standard names for consistency
colnames(df_depth) <- c("Sulcus", "Value")

# Filter left lateral and medial sulci
df_depth_left_lateral <- df_depth[df_depth$Sulcus %in% left_lateral_names, ]
df_depth_left_lateral <- df_depth_left_lateral[match(left_lateral_names, df_depth_left_lateral$Sulcus), ]

df_depth_left_medial <- df_depth[df_depth$Sulcus %in% left_medial_names, ]
df_depth_left_medial <- df_depth_left_medial[match(left_medial_names, df_depth_left_medial$Sulcus), ]

# Create named vector
sulcus_depth_values_left_lateral <- setNames(df_depth_left_lateral$Value, df_depth_left_lateral$Sulcus)
sulcus_depth_values_left_medial <- setNames(df_depth_left_medial$Value, df_depth_left_medial$Sulcus)

# Filter right lateral and medial sulci
df_depth_right_lateral <- df_depth[df_depth$Sulcus %in% right_lateral_names, ]
df_depth_right_lateral <- df_depth_right_lateral[match(right_lateral_names, df_depth_right_lateral$Sulcus), ]

df_depth_right_medial <- df_depth[df_depth$Sulcus %in% right_medial_names, ]
df_depth_right_medial <- df_depth_right_medial[match(right_medial_names, df_depth_right_medial$Sulcus), ]

# Create named vector
sulcus_depth_values_right_lateral <- setNames(df_depth_right_lateral$Value, df_depth_right_lateral$Sulcus)
sulcus_depth_values_right_medial <- setNames(df_depth_right_medial$Value, df_depth_right_medial$Sulcus)

# surface ################################################################################
# Rename columns to standard names for consistency
colnames(df_surface) <- c("Sulcus", "Value")

# Filter left lateral and medial sulci
df_surface_left_lateral <- df_surface[df_surface$Sulcus %in% left_lateral_names, ]
df_surface_left_lateral <- df_surface_left_lateral[match(left_lateral_names, df_surface_left_lateral$Sulcus), ]

df_surface_left_medial <- df_surface[df_surface$Sulcus %in% left_medial_names, ]
df_surface_left_medial <- df_surface_left_medial[match(left_medial_names, df_surface_left_medial$Sulcus), ]

# Create named vector
sulcus_surface_values_left_lateral <- setNames(df_surface_left_lateral$Value, df_surface_left_lateral$Sulcus)
sulcus_surface_values_left_medial <- setNames(df_surface_left_medial$Value, df_surface_left_medial$Sulcus)

# Filter right lateral and medial sulci
df_surface_right_lateral <- df_surface[df_surface$Sulcus %in% right_lateral_names, ]
df_surface_right_lateral <- df_surface_right_lateral[match(right_lateral_names, df_surface_right_lateral$Sulcus), ]

df_surface_right_medial <- df_surface[df_surface$Sulcus %in% right_medial_names, ]
df_surface_right_medial <- df_surface_right_medial[match(right_medial_names, df_surface_right_medial$Sulcus), ]

# Create named vector
sulcus_surface_values_right_lateral <- setNames(df_surface_right_lateral$Value, df_surface_right_lateral$Sulcus)
sulcus_surface_values_right_medial <- setNames(df_surface_right_medial$Value, df_surface_right_medial$Sulcus)

# length ################################################################################
# Rename columns to standard names for consistency
colnames(df_length) <- c("Sulcus", "Value")

# Filter left lateral and medial sulci
df_length_left_lateral <- df_length[df_length$Sulcus %in% left_lateral_names, ]
df_length_left_lateral <- df_length_left_lateral[match(left_lateral_names, df_length_left_lateral$Sulcus), ]

df_length_left_medial <- df_length[df_length$Sulcus %in% left_medial_names, ]
df_length_left_medial <- df_length_left_medial[match(left_medial_names, df_length_left_medial$Sulcus), ]

# Create named vector
sulcus_length_values_left_lateral <- setNames(df_length_left_lateral$Value, df_length_left_lateral$Sulcus)
sulcus_length_values_left_medial <- setNames(df_length_left_medial$Value, df_length_left_medial$Sulcus)

# Filter right lateral and medial sulci
df_length_right_lateral <- df_length[df_length$Sulcus %in% right_lateral_names, ]
df_length_right_lateral <- df_length_right_lateral[match(right_lateral_names, df_length_right_lateral$Sulcus), ]

df_length_right_medial <- df_length[df_length$Sulcus %in% right_medial_names, ]
df_length_right_medial <- df_length_right_medial[match(right_medial_names, df_length_right_medial$Sulcus), ]

# Create named vector
sulcus_length_values_right_lateral <- setNames(df_length_right_lateral$Value, df_length_right_lateral$Sulcus)
sulcus_length_values_right_medial <- setNames(df_length_right_medial$Value, df_length_right_medial$Sulcus)

# global range ################################################################################
# Combine all values
all_values <- c(sulcus_opening_values_left_lateral,
                sulcus_opening_values_left_medial,
                sulcus_opening_values_right_lateral,
                sulcus_opening_values_right_medial,
                sulcus_depth_values_left_lateral,
                sulcus_depth_values_left_medial,
                sulcus_depth_values_right_lateral,
                sulcus_depth_values_right_medial,
                sulcus_surface_values_left_lateral,
                sulcus_surface_values_left_medial,
                sulcus_surface_values_right_lateral,
                sulcus_surface_values_right_medial,
                sulcus_length_values_left_lateral,
                sulcus_length_values_left_medial,
                sulcus_length_values_right_lateral,
                sulcus_length_values_right_medial)

# Compute the global min/max range for consistent scaling
global_range <- range(all_values, na.rm = TRUE)
global_range[1] # should be normally 0
global_range[2] <- ceiling(global_range[2] * 2) / 2

################################################################################
# Plots ################################################################################
################################################################################
# Define paths
sulcus_dir_left_lateral <- "leftlat"
background_path_left_lateral <- "leftlat/brain_leftlat.png"

sulcus_dir_left_medial <- "leftmed"
background_path_left_medial <- "leftmed/brain_leftmed.png"

# Define paths
sulcus_dir_right_lateral <- "rightlat"
background_path_right_lateral <- "rightlat/brain_rightlat.png"

sulcus_dir_right_medial <- "rightmed"
background_path_right_medial <- "rightmed/brain_rightmed.png"

# opening ################################################################################
############ left
# Plot
figure_opening_left_lateral <- plot_sulci(
  sulcus_values = sulcus_opening_values_left_lateral,
  sulcus_dir = sulcus_dir_left_lateral,
  background_path = background_path_left_lateral,
  palette = "gyr",
  scale_width = "1000x",
  value_range = global_range)

figure_opening_left_medial <- plot_sulci(
  sulcus_values = sulcus_opening_values_left_medial,
  sulcus_dir = sulcus_dir_left_medial,
  background_path = background_path_left_medial,
  palette = "gyr",
  scale_width = "1000x",
  value_range = global_range
)

# Show with ggplot2
plot_opening_left_lateral <- ggplot() +
  annotation_custom(rasterGrob(figure_opening_left_lateral)) +
  theme_void()

plot_opening_left_medial <- ggplot() +
  annotation_custom(rasterGrob(figure_opening_left_medial)) +
  theme_void()

############ right
# Plot
figure_opening_right_lateral <- plot_sulci(
  sulcus_values = sulcus_opening_values_right_lateral,
  sulcus_dir = sulcus_dir_right_lateral,
  background_path = background_path_right_lateral,
  palette = "gyr",
  scale_width = "1000x",
  value_range = global_range)

figure_opening_right_medial <- plot_sulci(
  sulcus_values = sulcus_opening_values_right_medial,
  sulcus_dir = sulcus_dir_right_medial,
  background_path = background_path_right_medial,
  palette = "gyr",
  scale_width = "1000x",
  value_range = global_range
)

# Show with ggplot2
plot_opening_right_lateral <- ggplot() +
  annotation_custom(rasterGrob(figure_opening_right_lateral)) +
  theme_void()

plot_opening_right_medial <- ggplot() +
  annotation_custom(rasterGrob(figure_opening_right_medial)) +
  theme_void()

# depth ################################################################################
############ left
# Plot
figure_depth_left_lateral <- plot_sulci(
  sulcus_values = sulcus_depth_values_left_lateral,
  sulcus_dir = sulcus_dir_left_lateral,
  background_path = background_path_left_lateral,
  palette = "gyr",
  scale_width = "1000x",
  value_range = global_range)

figure_depth_left_medial <- plot_sulci(
  sulcus_values = sulcus_depth_values_left_medial,
  sulcus_dir = sulcus_dir_left_medial,
  background_path = background_path_left_medial,
  palette = "gyr",
  scale_width = "1000x",
  value_range = global_range
)

# Show with ggplot2
plot_depth_left_lateral <- ggplot() +
  annotation_custom(rasterGrob(figure_depth_left_lateral)) +
  theme_void()

plot_depth_left_medial <- ggplot() +
  annotation_custom(rasterGrob(figure_depth_left_medial)) +
  theme_void()

############ right
# Plot
figure_depth_right_lateral <- plot_sulci(
  sulcus_values = sulcus_depth_values_right_lateral,
  sulcus_dir = sulcus_dir_right_lateral,
  background_path = background_path_right_lateral,
  palette = "gyr",
  scale_width = "1000x",
  value_range = global_range)

figure_depth_right_medial <- plot_sulci(
  sulcus_values = sulcus_depth_values_right_medial,
  sulcus_dir = sulcus_dir_right_medial,
  background_path = background_path_right_medial,
  palette = "gyr",
  scale_width = "1000x",
  value_range = global_range
)

# Show with ggplot2
plot_depth_right_lateral <- ggplot() +
  annotation_custom(rasterGrob(figure_depth_right_lateral)) +
  theme_void()

plot_depth_right_medial <- ggplot() +
  annotation_custom(rasterGrob(figure_depth_right_medial)) +
  theme_void()

# surface ################################################################################
############ left
# Plot
figure_surface_left_lateral <- plot_sulci(
  sulcus_values = sulcus_surface_values_left_lateral,
  sulcus_dir = sulcus_dir_left_lateral,
  background_path = background_path_left_lateral,
  palette = "gyr",
  scale_width = "1000x",
  value_range = global_range)

figure_surface_left_medial <- plot_sulci(
  sulcus_values = sulcus_surface_values_left_medial,
  sulcus_dir = sulcus_dir_left_medial,
  background_path = background_path_left_medial,
  palette = "gyr",
  scale_width = "1000x",
  value_range = global_range
)

# Show with ggplot2
plot_surface_left_lateral <- ggplot() +
  annotation_custom(rasterGrob(figure_surface_left_lateral)) +
  theme_void()

plot_surface_left_medial <- ggplot() +
  annotation_custom(rasterGrob(figure_surface_left_medial)) +
  theme_void()

############ right
# Plot
figure_surface_right_lateral <- plot_sulci(
  sulcus_values = sulcus_surface_values_right_lateral,
  sulcus_dir = sulcus_dir_right_lateral,
  background_path = background_path_right_lateral,
  palette = "gyr",
  scale_width = "1000x",
  value_range = global_range)

figure_surface_right_medial <- plot_sulci(
  sulcus_values = sulcus_surface_values_right_medial,
  sulcus_dir = sulcus_dir_right_medial,
  background_path = background_path_right_medial,
  palette = "gyr",
  scale_width = "1000x",
  value_range = global_range
)

# Show with ggplot2
plot_surface_right_lateral <- ggplot() +
  annotation_custom(rasterGrob(figure_surface_right_lateral)) +
  theme_void()

plot_surface_right_medial <- ggplot() +
  annotation_custom(rasterGrob(figure_surface_right_medial)) +
  theme_void()

# length ################################################################################
############ left
# Plot
figure_length_left_lateral <- plot_sulci(
  sulcus_values = sulcus_length_values_left_lateral,
  sulcus_dir = sulcus_dir_left_lateral,
  background_path = background_path_left_lateral,
  palette = "gyr",
  scale_width = "1000x",
  value_range = global_range)

figure_length_left_medial <- plot_sulci(
  sulcus_values = sulcus_length_values_left_medial,
  sulcus_dir = sulcus_dir_left_medial,
  background_path = background_path_left_medial,
  palette = "gyr",
  scale_width = "1000x",
  value_range = global_range
)

# Show with ggplot2
plot_length_left_lateral <- ggplot() +
  annotation_custom(rasterGrob(figure_length_left_lateral)) +
  theme_void()

plot_length_left_medial <- ggplot() +
  annotation_custom(rasterGrob(figure_length_left_medial)) +
  theme_void()

############ right
# Plot
figure_length_right_lateral <- plot_sulci(
  sulcus_values = sulcus_length_values_right_lateral,
  sulcus_dir = sulcus_dir_right_lateral,
  background_path = background_path_right_lateral,
  palette = "gyr",
  scale_width = "1000x",
  value_range = global_range)

figure_length_right_medial <- plot_sulci(
  sulcus_values = sulcus_length_values_right_medial,
  sulcus_dir = sulcus_dir_right_medial,
  background_path = background_path_right_medial,
  palette = "gyr",
  scale_width = "1000x",
  value_range = global_range
)

# Show with ggplot2
plot_length_right_lateral <- ggplot() +
  annotation_custom(rasterGrob(figure_length_right_lateral)) +
  theme_void()

plot_length_right_medial <- ggplot() +
  annotation_custom(rasterGrob(figure_length_right_medial)) +
  theme_void()

# combined plots ################################################################################

# # color bar ################################################################################
my_palette <- c("grey90", "yellow", "gold", "orange", 
                 "darkorange", "orangered", "red", 
                 "firebrick", "darkred")
 
colorbar <- plot_colorbar(my_palette, min_val = global_range[1], max_val = global_range[2], caption = expression(-log[10](p)))

combined_opening_brain <- (
  wrap_elements(plot_opening_left_lateral) |
    wrap_elements(plot_opening_left_medial) |
    wrap_elements(plot_opening_right_lateral) |
    wrap_elements(plot_opening_right_medial)
) + plot_annotation(title = "Opening (Width)")

print(combined_opening_brain)

save_combined_plot(
  plot = combined_opening_brain,
  filename = "combined_width_brain.png"
)


combined_depth_brain <- (
  wrap_elements(plot_depth_left_lateral) |
    wrap_elements(plot_depth_left_medial) |
    wrap_elements(plot_depth_right_lateral) |
    wrap_elements(plot_depth_right_medial)
) + plot_annotation(title = "Mean Depth")

print(combined_depth_brain)

save_combined_plot(
  plot = combined_depth_brain,
  filename = "combined_depth_brain.png"
)

combined_surface_brain <- (
  wrap_elements(plot_surface_left_lateral) |
    wrap_elements(plot_surface_left_medial) |
    wrap_elements(plot_surface_right_lateral) |
    wrap_elements(plot_surface_right_medial)
) + plot_annotation(title = "Surface Area")

print(combined_surface_brain)

save_combined_plot(
  plot = combined_surface_brain,
  filename = "combined_surface_brain.png"
)

combined_length_brain <- (
  wrap_elements(plot_length_left_lateral) |
    wrap_elements(plot_length_left_medial) |
    wrap_elements(plot_length_right_lateral) |
    wrap_elements(plot_length_right_medial)
) + plot_annotation(title = "Length")

print(combined_length_brain)

save_combined_plot(
  plot = combined_length_brain,
  filename = "combined_length_brain.png"
)
