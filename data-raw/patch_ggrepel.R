# =============================================================================
# Patch : integration de ggrepel dans carte_choroplethe()
# Remplace le code manuel de labels par ggrepel::geom_label_repel()
# =============================================================================

lines <- readLines("R/cartographie.R")
txt   <- paste(lines, collapse = "\n")

# Remplacer le bloc de labels dans carte_choroplethe()
# (le bloc commence apres "Labels internes" et finit avant le "g" final)

ancien <- '  # Labels internes (ggplot2 natif -- sans ggrepel)
  if (!is.null(col_label) && col_label %in% names(sf_obj)) {
    centroides  <- suppressWarnings(sf::st_centroid(sf_obj))
    coords      <- sf::st_coordinates(centroides)
    aire        <- as.numeric(sf::st_area(sf_obj))
    seuil_petit <- stats::quantile(aire, probs = 0.25)

    df_labels <- data.frame(
      X      = coords[, 1],
      Y      = coords[, 2],
      label  = as.character(sf_obj[[col_label]]),
      petit  = aire < seuil_petit
    )

    # Grands polygones : label centre
    g <- g + ggplot2::geom_text(
      data = df_labels[!df_labels$petit, ],
      ggplot2::aes(x = .data$X, y = .data$Y, label = .data$label),
      size = 2.5, color = "#1E293B", fontface = "bold",
      check_overlap = TRUE
    )

    # Petits polygones : label offset + segment
    if (any(df_labels$petit)) {
      df_petits <- df_labels[df_labels$petit, ]
      df_petits$Xend <- df_petits$X + (df_petits$X - mean(df_labels$X)) * 0.5
      df_petits$Yend <- df_petits$Y + (df_petits$Y - mean(df_labels$Y)) * 0.5

      g <- g +
        ggplot2::geom_segment(
          data = df_petits,
          ggplot2::aes(x = .data$X, y = .data$Y,
                       xend = .data$Xend, yend = .data$Yend),
          color = "#64748B", linewidth = 0.35
        ) +
        ggplot2::geom_label(
          data = df_petits,
          ggplot2::aes(x = .data$Xend, y = .data$Yend,
                       label = .data$label),
          size = 2.2, fill = "white", alpha = 0.85,
          label.size = 0.1,
          label.padding = ggplot2::unit(0.1, "lines"),
          color = "#1E293B", fontface = "bold"
        )
    }
  }'

nouveau <- '  # Labels avec ggrepel -- repositionnement automatique
  if (!is.null(col_label) && col_label %in% names(sf_obj)) {
    centroides <- suppressWarnings(sf::st_centroid(sf_obj))
    coords     <- sf::st_coordinates(centroides)

    df_labels <- data.frame(
      X     = coords[, 1],
      Y     = coords[, 2],
      label = as.character(sf_obj[[col_label]])
    )

    g <- g + ggrepel::geom_label_repel(
      data              = df_labels,
      ggplot2::aes(x = .data$X, y = .data$Y, label = .data$label),
      size              = 2.5,
      fill              = "white",
      alpha             = 0.88,
      color             = "#1E293B",
      fontface          = "bold",
      label.size        = 0.12,
      label.padding     = ggplot2::unit(0.15, "lines"),
      box.padding       = ggplot2::unit(0.3,  "lines"),
      min.segment.length = 0,
      segment.color     = "#94A3B8",
      segment.size      = 0.35,
      segment.curvature = -0.1,
      max.overlaps      = Inf
    )
  }'

if (grepl(ancien, txt, fixed = TRUE)) {
  txt <- gsub(ancien, nouveau, txt, fixed = TRUE)
  writeLines(strsplit(txt, "\n")[[1]], "R/cartographie.R")
  message("Patch applique avec succes.")
} else {
  message("Pattern non trouve — verifiez que cartographie.R est la bonne version.")
  # Chercher les lignes du bloc a remplacer manuellement
  idx <- grep("Labels internes.*ggrepel|geom_label_repel|check_overlap", lines)
  cat("Lignes candidates :", idx, "\n")
}
