# ---- install missing packages ----
req_pkgs <- c("magick", "scales", "viridisLite", "ggplot2", "grid", "patchwork", "cowplot")
to_install <- req_pkgs[!vapply(req_pkgs, requireNamespace, quietly = TRUE, FUN.VALUE = logical(1))]
if (length(to_install)) {
  install.packages(to_install)
}

# ---- function ----
plot_sulci <- function(
    sulcus_values,
    palette = "gyr",
    value_range = NULL,
    base_dir = NULL,
    caption = expression(-log[10](p)),
    scale_width = "1000x",
    measure = c("all","opening","depth","surface","length"),
    show_colorbar = TRUE,
    save_dir = NULL,
    file_prefix = "sulci",
    width_in = 14,
    height_in = 8,
    dpi = 300
) {
  # ---- packages (lazy-load via ::) ----
  req_pkgs <- c("magick", "scales", "viridisLite", "ggplot2", "grid", "patchwork", "cowplot")
  missing <- req_pkgs[!vapply(req_pkgs, requireNamespace, quietly = TRUE, FUN.VALUE = logical(1))]
  if (length(missing)) stop(sprintf("Missing packages: %s", paste(missing, collapse = ", ")))  
  
  # ---- locate assets root from the script folder ----
  if (is.null(base_dir)) {
    base_dir <- if (!is.null(sys.frame(1)$ofile)) dirname(sys.frame(1)$ofile) else getwd()
  }
  
  # ---- helpers ----
  recolor_sulcus <- function(sulcus_image, color) {
    sulcus_image <- magick::image_convert(sulcus_image, format = "png")
    sulcus_mask   <- magick::image_transparent(sulcus_image, 'black')
    colored_layer <- magick::image_colorize(sulcus_image, opacity = 100, color = color)
    magick::image_composite(colored_layer, sulcus_mask, operator = "atop")
  }
  plot_sulci <- function(sulcus_values, sulcus_dir, background_path, palette = "viridis", scale_width = "1000x", value_range = NULL) {
    sulcus_names <- names(sulcus_values)
    background_img <- magick::image_read(background_path)
    bg_info <- magick::image_info(background_img)
    if (is.null(value_range)) value_range <- range(sulcus_values, na.rm = TRUE)
    remapped_values <- round(scales::rescale(sulcus_values, to = c(1, 1000), from = value_range))
    palette_map <- switch(palette,
                          viridis = viridisLite::viridis(1000),
                          magma   = viridisLite::magma(1000),
                          plasma  = viridisLite::plasma(1000),
                          inferno = viridisLite::inferno(1000),
                          cividis = viridisLite::cividis(1000),
                          heat    = grDevices::heat.colors(1000),
                          gyr     = grDevices::colorRampPalette(c("grey90", "yellow", "gold", "orange", "darkorange", "orangered", "red", "firebrick", "darkred"))(1000),
                          viridisLite::viridis(1000)
    )
    sulcus_colors <- palette_map[remapped_values]
    composite_img <- background_img
    for (i in seq_along(sulcus_names)) {
      sulcus_file <- file.path(sulcus_dir, paste0(sulcus_names[i], ".png"))
      if (file.exists(sulcus_file)) {
        sulcus_img <- magick::image_read(sulcus_file)
        sulcus_img <- magick::image_resize(
          sulcus_img,
          magick::geometry_size_pixels(width = bg_info$width, height = bg_info$height, preserve_aspect = FALSE)
        )
        recolored <- recolor_sulcus(sulcus_img, sulcus_colors[i])
        composite_img <- magick::image_composite(composite_img, recolored)
      } else {
        warning(sprintf("Missing PNG for: %s", sulcus_names[i]))
      }
    }
    magick::image_scale(magick::image_trim(magick::image_transparent(composite_img, "white")), scale_width)
  }
  plot_colorbar <- function(my_palette, min_val, max_val, caption = NULL, n_colors = 1000) {
    pal <- grDevices::colorRampPalette(my_palette)(n_colors)
    df  <- data.frame(x = seq(0, 1, length.out = n_colors), y = 1)
    ggplot2::ggplot(df, ggplot2::aes(x = x, y = y, fill = x)) +
      ggplot2::geom_tile(height = 0.3) +
      ggplot2::scale_fill_gradientn(colours = pal) +
      ggplot2::coord_cartesian(xlim = c(-0.1, 1.1), ylim = c(0.5, 1.5), clip = "off") +
      ggplot2::theme_void() +
      ggplot2::theme(legend.position = "none", plot.margin = ggplot2::margin(t = 10, r = 40, b = 20, l = 40)) +
      ggplot2::annotate("text", x = -0.02, y = 1, label = min_val, hjust = 1, vjust = 0.5, size = 10) +
      ggplot2::annotate("text", x = 1.02,  y = 1, label = max_val, hjust = 0, vjust = 0.5, size = 10) +
      {if (!is.null(caption)) ggplot2::annotate("text", x = 0.5, y = 0.85, label = caption, hjust = 0.5, vjust = 1, size = 10)}
  }
  
  # ---- assets & inputs ----
  name_files <- list(
    left_lateral  = file.path(base_dir, "leftlat_files",  "leftlatnames.txt"),
    left_medial   = file.path(base_dir, "leftmed_files",  "leftmednames.txt"),
    right_lateral = file.path(base_dir, "rightlat_files", "rightlatnames.txt"),
    right_medial  = file.path(base_dir, "rightmed_files","rightmednames.txt")
  )
  stopifnot(all(file.exists(unlist(name_files))))
  left_lateral_names  <- readLines(name_files$left_lateral)
  left_medial_names   <- readLines(name_files$left_medial)
  right_lateral_names <- readLines(name_files$right_lateral)
  right_medial_names  <- readLines(name_files$right_medial)
  
  sulcus_dirs <- list(
    left_lateral  = file.path(base_dir, "leftlat"),
    left_medial   = file.path(base_dir, "leftmed"),
    right_lateral = file.path(base_dir, "rightlat"),
    right_medial  = file.path(base_dir, "rightmed")
  )
  bgs <- list(
    left_lateral  = file.path(sulcus_dirs$left_lateral,  "brain_leftlat.png"),
    left_medial   = file.path(sulcus_dirs$left_medial,   "brain_leftmed.png"),
    right_lateral = file.path(sulcus_dirs$right_lateral, "brain_rightlat.png"),
    right_medial  = file.path(sulcus_dirs$right_medial,  "brain_rightmed.png")
  )
  stopifnot(all(file.exists(unlist(bgs))))
  
  # ---- split metrics ----
  df <- sulcus_values
  stopifnot(all(c("Sulcus", "Value") %in% names(df)))
  df_opening <- subset(df, grepl("\\.opening$", Sulcus));                     df_opening$Sulcus <- sub("\\.opening$", "", df_opening$Sulcus)
  df_depth   <- subset(df, grepl("\\.meandepth_native$", Sulcus));             df_depth$Sulcus   <- sub("\\.meandepth_native$", "", df_depth$Sulcus)
  df_surface <- subset(df, grepl("\\.surface_native$", Sulcus));               df_surface$Sulcus <- sub("\\.surface_native$", "", df_surface$Sulcus)
  df_length  <- subset(df, grepl("\\.hull_junction_length_native$", Sulcus));  df_length$Sulcus  <- sub("\\.hull_junction_length_native$", "", df_length$Sulcus)
  names(df_opening) <- names(df_depth) <- names(df_surface) <- names(df_length) <- c("Sulcus", "Value")
  
  nv <- function(x, order_names) {
    x_in <- x[x$Sulcus %in% order_names, ]
    x_in <- x_in[match(order_names, x_in$Sulcus), ]
    stats::setNames(x_in$Value, x_in$Sulcus)
  }
  
  sulc_vals <- list(
    opening = list(
      left_lateral  = nv(df_opening, left_lateral_names),
      left_medial   = nv(df_opening, left_medial_names),
      right_lateral = nv(df_opening, right_lateral_names),
      right_medial  = nv(df_opening, right_medial_names)
    ),
    depth = list(
      left_lateral  = nv(df_depth, left_lateral_names),
      left_medial   = nv(df_depth, left_medial_names),
      right_lateral = nv(df_depth, right_lateral_names),
      right_medial  = nv(df_depth, right_medial_names)
    ),
    surface = list(
      left_lateral  = nv(df_surface, left_lateral_names),
      left_medial   = nv(df_surface, left_medial_names),
      right_lateral = nv(df_surface, right_lateral_names),
      right_medial  = nv(df_surface, right_medial_names)
    ),
    length = list(
      left_lateral  = nv(df_length, left_lateral_names),
      left_medial   = nv(df_length, left_medial_names),
      right_lateral = nv(df_length, right_lateral_names),
      right_medial  = nv(df_length, right_medial_names)
    )
  )
  
  # ---- global range ----
  if (is.null(value_range)) {
    all_values <- unlist(sulc_vals, use.names = FALSE)
    rng <- range(all_values, na.rm = TRUE)
    rng[2] <- ceiling(rng[2] * 2) / 2
  } else {
    rng <- value_range
  }
  
  # ---- per-view builder ----
  make_view_plot <- function(vals, side) {
    fig <- plot_sulci(
      sulcus_values = vals[[side]],
      sulcus_dir = sulcus_dirs[[side]],
      background_path = bgs[[side]],
      palette = palette,
      scale_width = scale_width,
      value_range = rng
    )
    ggplot2::ggplot() + ggplot2::annotation_custom(grid::rasterGrob(fig)) + ggplot2::theme_void()
  }
  
  # ---- color scale used in bottoms (created only if needed) ----
  if (isTRUE(show_colorbar)) {
    my_palette <- switch(palette,
                         gyr     = c("grey90", "yellow", "gold", "orange", "darkorange", "orangered", "red", "firebrick", "darkred"),
                         viridis = viridisLite::viridis(9),
                         magma   = viridisLite::magma(9),
                         plasma  = viridisLite::plasma(9),
                         inferno = viridisLite::inferno(9),
                         cividis = viridisLite::cividis(9),
                         heat    = grDevices::heat.colors(9),
                         c("grey90", "yellow", "gold", "orange", "darkorange", "orangered", "red", "firebrick", "darkred")
    )
    colorbar <- plot_colorbar(my_palette, min_val = rng[1], max_val = rng[2], caption = caption)
    bottom_row <- (patchwork::plot_spacer() + colorbar + patchwork::plot_spacer()) +
      patchwork::plot_layout(ncol = 3, widths = c(0.3, 0.3, 0.3))
  }
  
  # ---- build each metric grid ----
  build_metric_grid <- function(metric) {
    mvals <- sulc_vals[[metric]]
    ( make_view_plot(mvals, "left_lateral") | make_view_plot(mvals, "left_medial")
      | make_view_plot(mvals, "right_lateral") | make_view_plot(mvals, "right_medial") )
  }
  
  # titles
  title_plot <- function(txt) cowplot::ggdraw() + cowplot::draw_label(txt, size = 30, fontface = "bold")
  metric_title <- function(metric) switch(metric,
                                          opening = "Width",
                                          depth   = "Depth",
                                          surface = "Surface Area",
                                          length  = "Length"
  )
  
  # =========================
  # BRANCH 1: all-in-one (when measure == "all")
  # =========================
  title_font_size <- 22
  if (match.arg(measure) == "all") {
    label_width   <- patchwork::wrap_elements(full = grid::textGrob("Width",        gp = grid::gpar(fontsize = title_font_size), just = "center"))
    label_depth   <- patchwork::wrap_elements(full = grid::textGrob("Depth",        gp = grid::gpar(fontsize = title_font_size), just = "center"))
    label_surface <- patchwork::wrap_elements(full = grid::textGrob("Surface Area", gp = grid::gpar(fontsize = title_font_size), just = "center"))
    label_length  <- patchwork::wrap_elements(full = grid::textGrob("Length",       gp = grid::gpar(fontsize = title_font_size), just = "center"))
    label_left  <- cowplot::ggdraw() + cowplot::draw_label("Left",  size = title_font_size)
    label_right <- cowplot::ggdraw() + cowplot::draw_label("Right", size = title_font_size)
    empty_label <- patchwork::plot_spacer()
    
    top_row <- empty_label + label_left + label_right + patchwork::plot_layout(widths = c(0.15, 0.5, 0.5))
    
    combined_opening_brain <- build_metric_grid("opening")
    combined_depth_brain   <- build_metric_grid("depth")
    combined_surface_brain <- build_metric_grid("surface")
    combined_length_brain  <- build_metric_grid("length")
    
    row1 <- label_width   + combined_opening_brain + patchwork::plot_layout(widths = c(0.15, 1))
    row2 <- label_depth   + combined_depth_brain   + patchwork::plot_layout(widths = c(0.15, 1))
    row3 <- label_surface + combined_surface_brain + patchwork::plot_layout(widths = c(0.15, 1))
    row4 <- label_length  + combined_length_brain  + patchwork::plot_layout(widths = c(0.15, 1))
    
    final_plot <- top_row / row1 / row2 / row3 / row4 + patchwork::plot_layout(heights = c(0.1, 1, 1, 1, 1))
    
    if (isTRUE(show_colorbar)) {
      combined_all <- (final_plot / (patchwork::plot_spacer() + colorbar + patchwork::plot_spacer())) +
        patchwork::plot_layout(heights = c(0.3, 1, 1, 1, 1, 0.3))
    } else {
      combined_all <- final_plot
    }
    
    # save if requested
    if (!is.null(save_dir)) {
      if (!dir.exists(save_dir)) dir.create(save_dir, recursive = TRUE, showWarnings = FALSE)
      ggplot2::ggsave(
        filename = file.path(save_dir, sprintf("%s_all.png", file_prefix)),
        plot = combined_all, width = width_in, height = height_in, dpi = dpi
      )
    }
    
    return(combined_all)
  }
  
  # =========================
  # BRANCH 2: single measure figure
  # =========================
  measure <- match.arg(measure)
  grid_plot <- build_metric_grid(measure)
  
  if (isTRUE(show_colorbar)) {
    out_plot <- title_plot(metric_title(measure)) / grid_plot / bottom_row +
      patchwork::plot_layout(heights = c(0.15, 1, 0.25))
  } else {
    out_plot <- title_plot(metric_title(measure)) / grid_plot +
      patchwork::plot_layout(heights = c(0.15, 1))
  }
  
  if (!is.null(save_dir)) {
    if (!dir.exists(save_dir)) dir.create(save_dir, recursive = TRUE, showWarnings = FALSE)
    ggplot2::ggsave(
      filename = file.path(save_dir, sprintf("%s_%s.png", file_prefix, measure)),
      plot = out_plot, width = width_in, height = height_in, dpi = dpi
    )
  }
  
  return(out_plot)
}
