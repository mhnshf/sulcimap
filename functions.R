# Required libraries
library(magick)
library(scales)
library(viridisLite)
library(ggplot2)
library(grid)

install_and_load <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  if(length(new_packages)) {
    install.packages(new_packages, dependencies = TRUE)
  }
  invisible(lapply(packages, library, character.only = TRUE))
}

# Function to recolor sulcus shapes (black → desired color)
recolor_sulcus <- function(sulcus_image, color) {
  sulcus_image <- image_convert(sulcus_image, format = "png")
  
  # Create a version with transparent black
  sulcus_mask <- image_transparent(sulcus_image, 'black')
  
  # Create a solid color layer
  colored_layer <- image_colorize(sulcus_image, opacity = 100, color = color)
  
  # Overlay the color where the sulcus was
  result <- image_composite(colored_layer, sulcus_mask, operator = "atop")
  return(result)
}

# Main function to color and combine sulci
plot_sulci <- function(sulcus_values, sulcus_dir, background_path, palette = "viridis", scale_width = "1000x", value_range = NULL) {
  sulcus_names <- names(sulcus_values)
  background_img <- image_read(background_path)
  
  # Get background size
  bg_info <- image_info(background_img)
  
  if (is.null(value_range)) {
    value_range <- range(sulcus_values, na.rm = TRUE)
  }
  
  # Rescale metric values
  remapped_values <- round(scales::rescale(sulcus_values, 
                                           to = c(1, 1000),
                                           from = value_range))
  
  # Get colormap (here you can add any color palette similar to "gyr")
  palette_map <- switch(palette,
                        viridis = viridis(1000),
                        magma = magma(1000),
                        plasma = plasma(1000),
                        inferno = inferno(1000),
                        cividis = cividis(1000),
                        viridis(1000),
                        heat = heat(1000),
                        gyr = colorRampPalette(c("grey90", "yellow", "gold", "orange", "darkorange", "orangered", "red", "firebrick", "darkred"))(1000))  # fallback
  sulcus_colors <- palette_map[remapped_values]
  
  # Composite sulci onto background
  composite_img <- background_img
  for (i in seq_along(sulcus_names)) {
    sulcus_file <- file.path(sulcus_dir, paste0(sulcus_names[i], ".png"))
    
    if (file.exists(sulcus_file)) {
      sulcus_img <- image_read(sulcus_file)
      
      # Resize sulcus image to match background if needed
      sulcus_img <- image_resize(sulcus_img, geometry_size_pixels(
        width = bg_info$width,
        height = bg_info$height,
        preserve_aspect = FALSE
      ))
      
      # Recolor and overlay
      recolored <- recolor_sulcus(sulcus_img, sulcus_colors[i])
      composite_img <- image_composite(composite_img, recolored)
    } else {
      warning(paste("Missing PNG for:", sulcus_names[i]))
    }
  }
  
  # Return the final scaled image
  return(image_scale(image_trim(image_transparent(composite_img, "white")), scale_width))
}

# color bar function ################################################################################
library(ggplot2)

plot_colorbar <- function(my_palette, min_val, max_val, caption = NULL, n_colors = 1000) {
  # Generate color gradient
  pal <- colorRampPalette(my_palette)(n_colors)
  
  # Create data for the color bar
  df <- data.frame(x = seq(0, 1, length.out = n_colors), y = 1)
  
  # Base plot
  p <- ggplot(df, aes(x = x, y = y, fill = x)) +
    geom_tile(height = 0.3) +
    scale_fill_gradientn(colours = pal) +
    coord_cartesian(xlim = c(-0.1, 1.1), ylim = c(0.5, 1.5), clip = "off") +
    theme_void() +
    theme(
      legend.position = "none",
      plot.margin = margin(t = 10, r = 40, b = 20, l = 40)  # extra bottom margin for caption
    ) +
    annotate("text", x = -0.02, y = 1, label = min_val, hjust = 1, vjust = 0.5, size = 10) +
    annotate("text", x = 1.02,  y = 1, label = max_val, hjust = 0, vjust = 0.5, size = 10)
  
  # Add caption if provided
  if (!is.null(caption)) {
    p <- p + annotate("text", x = 0.5, y = 0.85, label = caption, hjust = 0.5, vjust = 1, size = 10)
  }
  
  return(p)
}

save_combined_plot <- function(plot, filename, output_dir = "output", width = 12, height = 4, dpi = 300) {
  # Create output directory if it doesn't exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # Construct the full file path
  output_path <- file.path(output_dir, filename)
  
  # Save the plot
  ggplot2::ggsave(
    filename = output_path,
    plot = plot,
    width = width,
    height = height,
    dpi = dpi
  )
  
  message("Plot saved to: ", normalizePath(output_path))
}


