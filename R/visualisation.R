# =============================================================================
# statAfrikR — Module Visualisation
# Fonctions de visualisation statistique pour INS africains
# =============================================================================

# -----------------------------------------------------------------------------
# 1. THÈME INS
# -----------------------------------------------------------------------------

#' @title Thème ggplot2 officiel INS
#' @description Applique un thème graphique professionnel adapté aux
#'   publications officielles des Instituts Nationaux de Statistique africains.
#'   Inspiré des chartes graphiques AFRISTAT/PARIS21.
#' @param base_size numeric — Taille de base de la police. Défaut : 11.
#' @param base_family character — Famille de police. Défaut : "sans".
#' @param couleur_fond character — Couleur de fond du panneau. Défaut : "white".
#' @param grille logical — Afficher les lignes de grille. Défaut : TRUE.
#' @param grille_mineure logical — Afficher la grille mineure. Défaut : FALSE.
#' @return Un objet \code{theme} ggplot2.
#' @examples
#' \dontrun{
#'   library(ggplot2)
#'   ggplot(mtcars, aes(wt, mpg)) +
#'     geom_point() +
#'     theme_ins()
#' }
#' @export
theme_ins <- function(base_size     = 11,
                       base_family   = "sans",
                       couleur_fond  = "white",
                       grille        = TRUE,
                       grille_mineure = FALSE) {

  .verifier_package("ggplot2", "theme_ins")

  theme_base <- ggplot2::theme_minimal(
    base_size   = base_size,
    base_family = base_family
  )

  elements <- list(
    # Fond
    ggplot2::theme(
      plot.background    = ggplot2::element_rect(fill = "white", color = NA),
      panel.background   = ggplot2::element_rect(fill = couleur_fond, color = NA),

      # Titre et sous-titre
      plot.title         = ggplot2::element_text(
        size   = base_size * 1.3,
        face   = "bold",
        color  = "#1a1a2e",
        margin = ggplot2::margin(b = 8)
      ),
      plot.subtitle      = ggplot2::element_text(
        size   = base_size * 1.0,
        color  = "#444444",
        margin = ggplot2::margin(b = 12)
      ),
      plot.caption       = ggplot2::element_text(
        size   = base_size * 0.75,
        color  = "#888888",
        hjust  = 0,
        margin = ggplot2::margin(t = 8)
      ),

      # Axes
      axis.title         = ggplot2::element_text(
        size  = base_size * 0.9,
        color = "#333333"
      ),
      axis.text          = ggplot2::element_text(
        size  = base_size * 0.85,
        color = "#444444"
      ),
      axis.ticks         = ggplot2::element_line(color = "#cccccc"),
      axis.line          = ggplot2::element_line(
        color = "#888888",
        linewidth = 0.4
      ),

      # Légende
      legend.title       = ggplot2::element_text(
        size  = base_size * 0.9,
        face  = "bold",
        color = "#333333"
      ),
      legend.text        = ggplot2::element_text(
        size  = base_size * 0.85,
        color = "#444444"
      ),
      legend.background  = ggplot2::element_rect(
        fill  = "white",
        color = "#dddddd",
        linewidth = 0.3
      ),
      legend.key         = ggplot2::element_rect(fill = "white"),
      legend.position    = "bottom",

      # Facettes
      strip.text         = ggplot2::element_text(
        size  = base_size * 0.9,
        face  = "bold",
        color = "#1a1a2e"
      ),
      strip.background   = ggplot2::element_rect(
        fill  = "#f0f4f8",
        color = "#cccccc"
      ),

      # Marges
      plot.margin        = ggplot2::margin(12, 16, 8, 12)
    )
  )

  # Gestion de la grille
  grille_theme <- if (grille) {
    ggplot2::theme(
      panel.grid.major   = ggplot2::element_line(
        color = "#e8e8e8",
        linewidth = 0.4
      ),
      panel.grid.minor   = if (grille_mineure) {
        ggplot2::element_line(color = "#f0f0f0", linewidth = 0.2)
      } else {
        ggplot2::element_blank()
      }
    )
  } else {
    ggplot2::theme(
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank()
    )
  }

  theme_base + elements[[1]] + grille_theme
}


#' @title Palette de couleurs INS
#' @description Retourne une palette de couleurs officielle pour les
#'   graphiques INS, compatible daltonisme.
#' @param n integer — Nombre de couleurs souhaité. Défaut : 6.
#' @param type character — \code{"categoriel"}, \code{"sequentiel"},
#'   \code{"divergent"}. Défaut : "categoriel".
#' @return Vecteur de codes couleurs hexadécimaux.
#' @examples
#' \dontrun{
#'   couleurs <- palette_ins(4)
#' }
#' @export
palette_ins <- function(n = 6, type = c("categoriel", "sequentiel", "divergent")) {
  type <- match.arg(type)

  palettes <- list(
    categoriel = c(
      "#1B6CA8", "#E8872A", "#2EAA6E", "#D94F3D",
      "#7B5EA7", "#C4A000", "#1AADCE", "#E87E9B"
    ),
    sequentiel = c(
      "#EFF7FB", "#C6E2F0", "#8DC4E3", "#4D9FCC",
      "#1B6CA8", "#0D3D6B", "#061E35"
    ),
    divergent = c(
      "#D94F3D", "#F0A58A", "#FAE0D8", "#F5F5F5",
      "#C6E2F0", "#4D9FCC", "#1B6CA8"
    )
  )

  pal <- palettes[[type]]
  if (n > length(pal)) {
    rlang::warn(paste0(
      "Seulement ", length(pal), " couleurs disponibles pour la palette '",
      type, "'. ", n - length(pal), " couleur(s) r\u00e9p\u00e9t\u00e9e(s)."
    ))
    pal <- rep(pal, ceiling(n / length(pal)))[seq_len(n)]
  }

  pal[seq_len(n)]
}


# -----------------------------------------------------------------------------
# 2. PYRAMIDE DES ÂGES
# -----------------------------------------------------------------------------

#' @title Pyramide des âges
#' @description Génère une pyramide des âges pondérée à partir de données
#'   individuelles ou agrégées. Adapté aux recensements et enquêtes démographiques.
#' @param data data.frame ou tibble — Données individuelles
#' @param var_age character — Variable d'âge
#' @param var_sexe character — Variable de sexe/genre
#' @param var_poids character ou NULL — Variable de pondération. Défaut : NULL.
#' @param modalite_homme character — Modalité masculine. Défaut : "Masculin".
#' @param modalite_femme character — Modalité féminine. Défaut : "Féminin".
#' @param largeur_classe integer — Largeur des classes d'âge en années.
#'   Défaut : 5.
#' @param age_max integer — Âge maximum affiché. Défaut : 80.
#' @param titre character ou NULL — Titre du graphique. Défaut : NULL.
#' @param pourcentage logical — Afficher en pourcentage (TRUE) ou effectifs
#'   (FALSE). Défaut : TRUE.
#' @param couleur_homme character — Couleur hommes. Défaut : "#1B6CA8".
#' @param couleur_femme character — Couleur femmes. Défaut : "#E8872A".
#' @return Un objet \code{ggplot}.
#' @examples
#' \dontrun{
#'   pyramide_ages(
#'     donnees_rgph,
#'     var_age   = "age",
#'     var_sexe  = "sexe",
#'     var_poids = "poids",
#'     titre     = "Pyramide des âges — RGPH 2023"
#'   )
#' }
#' @export
pyramide_ages <- function(data,
                           var_age,
                           var_sexe,
                           var_poids       = NULL,
                           modalite_homme  = "Masculin",
                           modalite_femme  = "F\u00e9minin",
                           largeur_classe  = 5L,
                           age_max         = 80L,
                           titre           = NULL,
                           pourcentage     = TRUE,
                           couleur_homme   = "#1B6CA8",
                           couleur_femme   = "#E8872A") {

  .verifier_package("ggplot2", "pyramide_ages")

  vars_req <- c(var_age, var_sexe)
  vars_abs <- setdiff(vars_req, names(data))
  if (length(vars_abs) > 0) {
    rlang::abort(paste0("Variables introuvables : ", paste(vars_abs, collapse = ", ")))
  }

  # Pondération
  if (!is.null(var_poids) && var_poids %in% names(data)) {
    poids <- data[[var_poids]]
  } else {
    poids <- rep(1, nrow(data))
  }

  # Construction des classes d'âge
  breaks <- seq(0, age_max + largeur_classe, by = largeur_classe)
  labels <- paste0(
    seq(0, age_max, by = largeur_classe), "-",
    seq(largeur_classe - 1, age_max + largeur_classe - 1, by = largeur_classe)
  )
  labels[length(labels)] <- paste0(age_max, "+")

  data_calc <- data
  data_calc$.poids <- poids
  data_calc$.classe_age <- cut(
    pmin(data[[var_age]], age_max + 1),
    breaks  = breaks,
    labels  = labels,
    right   = FALSE,
    include.lowest = TRUE
  )

  # Agrégation
  data_agg <- data_calc |>
    dplyr::filter(
      !is.na(.data[[var_sexe]]),
      !is.na(.data$.classe_age)
    ) |>
    dplyr::group_by(
      classe_age = .data$.classe_age,
      sexe       = .data[[var_sexe]]
    ) |>
    dplyr::summarise(
      effectif = sum(.data$.poids, na.rm = TRUE),
      .groups  = "drop"
    )

  total <- sum(data_agg$effectif)

  if (pourcentage) {
    data_agg <- data_agg |>
      dplyr::mutate(valeur = round(effectif / total * 100, 2))
    label_x <- "Population (%)"
  } else {
    data_agg <- data_agg |>
      dplyr::mutate(valeur = effectif)
    label_x <- "Effectif"
  }

  # Hommes à gauche (négatif)
  data_agg <- data_agg |>
    dplyr::mutate(
      valeur_plot = dplyr::case_when(
        sexe == modalite_homme ~ -valeur,
        TRUE                   ~ valeur
      )
    )

  # Graphique
  p <- ggplot2::ggplot(
    data_agg,
    ggplot2::aes(
      x    = valeur_plot,
      y    = classe_age,
      fill = sexe
    )
  ) +
    ggplot2::geom_col(width = 0.85, alpha = 0.9) +
    ggplot2::scale_fill_manual(
      values = stats::setNames(
        c(couleur_homme, couleur_femme),
        c(modalite_homme, modalite_femme)
      )
    ) +
    ggplot2::scale_x_continuous(
      labels = function(x) paste0(abs(x), if (pourcentage) "%" else "")
    ) +
    ggplot2::geom_vline(xintercept = 0, color = "#333333", linewidth = 0.6) +
    ggplot2::labs(
      title    = titre,
      x        = label_x,
      y        = "Groupe d'\u00e2ge",
      fill     = NULL,
      caption  = paste0(
        "Source : statAfrikR | N = ",
        formatC(round(total), big.mark = " ", format = "d")
      )
    ) +
    theme_ins() +
    ggplot2::theme(
      legend.position = "top",
      panel.grid.major.y = ggplot2::element_blank()
    )

  p
}


# -----------------------------------------------------------------------------
# 3. GRAPHIQUE EN BARRES
# -----------------------------------------------------------------------------

#' @title Graphique en barres pondéré
#' @description Génère un graphique en barres avec intervalles de confiance
#'   optionnels, adapté aux résultats d'enquêtes pondérées.
#' @param data data.frame, tibble ou résultat de \code{tab_croisee()} —
#'   Données source
#' @param var_x character — Variable en abscisse (catégories)
#' @param var_y character — Variable en ordonnée (valeurs)
#' @param var_groupe character ou NULL — Variable de regroupement (barres
#'   groupées). Défaut : NULL.
#' @param var_ic_bas character ou NULL — Variable borne inférieure IC.
#'   Défaut : NULL.
#' @param var_ic_haut character ou NULL — Variable borne supérieure IC.
#'   Défaut : NULL.
#' @param position character — \code{"dodge"} (groupé) ou \code{"stack"}
#'   (empilé). Défaut : "dodge".
#' @param titre character ou NULL — Titre. Défaut : NULL.
#' @param label_x character ou NULL — Label axe X. Défaut : NULL.
#' @param label_y character ou NULL — Label axe Y. Défaut : NULL.
#' @param pourcentage logical — Formater l'axe Y en pourcentage. Défaut : FALSE.
#' @param trier logical — Trier les barres par valeur décroissante. Défaut : FALSE.
#' @return Un objet \code{ggplot}.
#' @examples
#' \dontrun{
#'   resultats <- tab_croisee(donnees, "region", format_sortie = "tibble")
#'   graphique_barres(
#'     resultats,
#'     var_x   = "region",
#'     var_y   = "pourcentage",
#'     titre   = "Répartition par région"
#'   )
#' }
#' @export
graphique_barres <- function(data,
                              var_x,
                              var_y,
                              var_groupe  = NULL,
                              var_ic_bas  = NULL,
                              var_ic_haut = NULL,
                              position    = c("dodge", "stack"),
                              titre       = NULL,
                              label_x     = NULL,
                              label_y     = NULL,
                              pourcentage = FALSE,
                              trier       = FALSE) {

  .verifier_package("ggplot2", "graphique_barres")
  position <- match.arg(position)

  vars_req <- c(var_x, var_y)
  if (!is.null(var_groupe)) vars_req <- c(vars_req, var_groupe)
  vars_abs <- setdiff(vars_req, names(data))
  if (length(vars_abs) > 0) {
    rlang::abort(paste0("Variables introuvables : ", paste(vars_abs, collapse = ", ")))
  }

  # Tri optionnel
  if (trier && is.null(var_groupe)) {
    data <- data |>
      dplyr::mutate(
        !!var_x := forcats::fct_reorder(.data[[var_x]], .data[[var_y]])
      )
  }

  # Mapping esthétique
  aes_base <- if (!is.null(var_groupe)) {
    ggplot2::aes(
      x    = .data[[var_x]],
      y    = .data[[var_y]],
      fill = .data[[var_groupe]]
    )
  } else {
    ggplot2::aes(
      x    = .data[[var_x]],
      y    = .data[[var_y]],
      fill = .data[[var_x]]
    )
  }

  n_couleurs <- if (!is.null(var_groupe)) {
    length(unique(data[[var_groupe]]))
  } else {
    length(unique(data[[var_x]]))
  }

  p <- ggplot2::ggplot(data, aes_base) +
    ggplot2::geom_col(
      position = position,
      alpha    = 0.9,
      width    = 0.7
    ) +
    ggplot2::scale_fill_manual(values = palette_ins(n_couleurs))

  # Intervalles de confiance
  if (!is.null(var_ic_bas) && !is.null(var_ic_haut) &&
      var_ic_bas %in% names(data) && var_ic_haut %in% names(data)) {
    p <- p + ggplot2::geom_errorbar(
      ggplot2::aes(
        ymin = .data[[var_ic_bas]],
        ymax = .data[[var_ic_haut]]
      ),
      width    = 0.25,
      color    = "#333333",
      linewidth = 0.6,
      position = if (position == "dodge")
        ggplot2::position_dodge(0.7) else "identity"
    )
  }

  # Formatage axe Y
  if (pourcentage) {
    p <- p + ggplot2::scale_y_continuous(
      labels = function(x) paste0(x, "%")
    )
  }

  p <- p + ggplot2::labs(
    title = titre,
    x     = label_x %||% var_x,
    y     = label_y %||% var_y,
    fill  = var_groupe
  ) + theme_ins()

  p
}


# -----------------------------------------------------------------------------
# 4. GRAPHIQUE DE TENDANCE
# -----------------------------------------------------------------------------

#' @title Graphique de tendance temporelle
#' @description Génère un graphique de tendance pour un ou plusieurs
#'   indicateurs sur une période temporelle. Adapté au suivi des indicateurs
#'   ODD et des indicateurs macroéconomiques.
#' @param data data.frame ou tibble — Données en format long ou large
#' @param var_temps character — Variable temporelle (année, trimestre...)
#' @param var_valeur character — Variable de valeur (format long) ou NULL
#'   si format large. Défaut : NULL.
#' @param var_indicateur character ou NULL — Variable d'indicateur (format
#'   long). Défaut : NULL.
#' @param vars_indicateurs character ou NULL — Vecteur de colonnes à tracer
#'   (format large). Défaut : NULL.
#' @param titre character ou NULL — Titre. Défaut : NULL.
#' @param label_y character — Label axe Y. Défaut : "Valeur".
#' @param afficher_points logical — Afficher les points. Défaut : TRUE.
#' @param afficher_valeurs logical — Annoter les valeurs. Défaut : FALSE.
#' @param lisser logical — Ajouter une courbe lissée (loess). Défaut : FALSE.
#' @return Un objet \code{ggplot}.
#' @examples
#' \dontrun{
#'   graphique_tendance(
#'     data            = evolution_pib,
#'     var_temps       = "annee",
#'     vars_indicateurs = c("pib_reel", "pib_nominal"),
#'     titre           = "Évolution du PIB 2000-2023"
#'   )
#' }
#' @export
graphique_tendance <- function(data,
                                var_temps,
                                var_valeur       = NULL,
                                var_indicateur   = NULL,
                                vars_indicateurs = NULL,
                                titre            = NULL,
                                label_y          = "Valeur",
                                afficher_points  = TRUE,
                                afficher_valeurs = FALSE,
                                lisser           = FALSE) {

  .verifier_package("ggplot2", "graphique_tendance")

  if (!var_temps %in% names(data)) {
    rlang::abort(paste0("Variable temporelle introuvable : '", var_temps, "'."))
  }

  # Conversion format large → long si nécessaire
  if (!is.null(vars_indicateurs)) {
    vars_abs <- setdiff(vars_indicateurs, names(data))
    if (length(vars_abs) > 0) {
      rlang::abort(paste0("Variables introuvables : ", paste(vars_abs, collapse = ", ")))
    }
    data_long <- data |>
      tidyr::pivot_longer(
        cols      = dplyr::all_of(vars_indicateurs),
        names_to  = "indicateur",
        values_to = "valeur"
      )
    var_valeur     <- "valeur"
    var_indicateur <- "indicateur"
  } else if (!is.null(var_valeur) && !is.null(var_indicateur)) {
    data_long <- data
  } else {
    rlang::abort(paste0(
      "Sp\u00e9cifiez soit `vars_indicateurs` (format large) soit ",
      "`var_valeur` + `var_indicateur` (format long)."
    ))
  }

  n_indicateurs <- length(unique(data_long[[var_indicateur]]))

  p <- ggplot2::ggplot(
    data_long,
    ggplot2::aes(
      x     = .data[[var_temps]],
      y     = .data[[var_valeur]],
      color = .data[[var_indicateur]],
      group = .data[[var_indicateur]]
    )
  ) +
    ggplot2::geom_line(linewidth = 1.1, alpha = 0.9)

  if (afficher_points) {
    p <- p + ggplot2::geom_point(size = 2.5, alpha = 0.9)
  }

  if (lisser) {
    p <- p + ggplot2::geom_smooth(
      method  = "loess",
      se      = FALSE,
      linetype = "dashed",
      linewidth = 0.7,
      alpha   = 0.7
    )
  }

  if (afficher_valeurs) {
    p <- p + ggplot2::geom_text(
      ggplot2::aes(label = round(.data[[var_valeur]], 1)),
      vjust    = -0.8,
      size     = 3,
      fontface = "bold"
    )
  }

  p <- p +
    ggplot2::scale_color_manual(values = palette_ins(n_indicateurs)) +
    ggplot2::labs(
      title = titre,
      x     = var_temps,
      y     = label_y,
      color = NULL
    ) +
    theme_ins()

  p
}


# -----------------------------------------------------------------------------
# 5. CARTE THÉMATIQUE
# -----------------------------------------------------------------------------

#' @title Carte thématique choroplèthe
#' @description Génère une carte choroplèthe à partir d'un objet sf enrichi
#'   ou de la jointure d'un shapefile avec des données statistiques.
#' @param data_sf sf ou NULL — Objet sf avec données. Si NULL, utilise
#'   \code{shapefile} + \code{data}. Défaut : NULL.
#' @param shapefile sf ou character ou NULL — Shapefile si \code{data_sf}
#'   est NULL. Défaut : NULL.
#' @param data data.frame ou NULL — Données à joindre si \code{data_sf}
#'   est NULL. Défaut : NULL.
#' @param var_geo_shape character ou NULL — Variable clé dans le shapefile.
#'   Défaut : NULL.
#' @param var_geo_data character ou NULL — Variable clé dans les données.
#'   Défaut : NULL.
#' @param var_couleur character — Variable à représenter par la couleur
#' @param titre character ou NULL — Titre de la carte. Défaut : NULL.
#' @param sous_titre character ou NULL — Sous-titre. Défaut : NULL.
#' @param source character ou NULL — Source des données. Défaut : NULL.
#' @param palette character — Palette de couleurs : \code{"sequentiel"},
#'   \code{"divergent"}. Défaut : "sequentiel".
#' @param n_classes integer — Nombre de classes. Défaut : 5.
#' @param na_couleur character — Couleur pour les NA. Défaut : "#cccccc".
#' @return Un objet \code{ggplot}.
#' @examples
#' \dontrun{
#'   carte_thematique(
#'     data_sf      = regions_sf_enrichi,
#'     var_couleur  = "taux_pauvrete_moyenne",
#'     titre        = "Taux de pauvreté par région"
#'   )
#' }
#' @export
carte_thematique <- function(data_sf        = NULL,
                              shapefile      = NULL,
                              data           = NULL,
                              var_geo_shape  = NULL,
                              var_geo_data   = NULL,
                              var_couleur,
                              titre          = NULL,
                              sous_titre     = NULL,
                              source         = NULL,
                              palette        = c("sequentiel", "divergent"),
                              n_classes      = 5L,
                              na_couleur     = "#cccccc") {

  .verifier_package("ggplot2", "carte_thematique")
  .verifier_package("sf", "carte_thematique")

  palette <- match.arg(palette)

  # Préparation de l'objet sf
  if (is.null(data_sf)) {
    if (is.null(shapefile) || is.null(data)) {
      rlang::abort(
        "Fournissez soit `data_sf`, soit `shapefile` + `data` + cl\u00e9s de jointure."
      )
    }
    if (is.character(shapefile)) {
      shapefile <- sf::st_read(shapefile, quiet = TRUE)
    }
    data_sf <- shapefile |>
      dplyr::left_join(data,
                        by = stats::setNames(var_geo_data, var_geo_shape))
  }

  if (!inherits(data_sf, "sf")) {
    rlang::abort("`data_sf` doit \u00eatre un objet sf.")
  }

  if (!var_couleur %in% names(data_sf)) {
    rlang::abort(paste0(
      "Variable de couleur introuvable : '", var_couleur, "'.\n",
      "Variables disponibles : ",
      paste(names(data_sf)[names(data_sf) != "geometry"], collapse = ", ")
    ))
  }

  # Couleurs de la palette
  couleurs_pal <- palette_ins(n_classes, type = palette)

  p <- ggplot2::ggplot(data_sf) +
    ggplot2::geom_sf(
      ggplot2::aes(fill = .data[[var_couleur]]),
      color     = "white",
      linewidth = 0.3
    ) +
    ggplot2::scale_fill_gradientn(
      colors   = couleurs_pal,
      na.value = na_couleur,
      name     = var_couleur
    ) +
    ggplot2::labs(
      title    = titre,
      subtitle = sous_titre,
      caption  = if (!is.null(source)) paste0("Source : ", source) else NULL
    ) +
    ggplot2::theme_void() +
    ggplot2::theme(
      plot.title    = ggplot2::element_text(
        size  = 13, face = "bold", color = "#1a1a2e",
        margin = ggplot2::margin(b = 6)
      ),
      plot.subtitle = ggplot2::element_text(
        size = 10, color = "#444444",
        margin = ggplot2::margin(b = 10)
      ),
      plot.caption  = ggplot2::element_text(
        size = 8, color = "#888888", hjust = 0
      ),
      legend.position = "right",
      legend.title  = ggplot2::element_text(size = 9, face = "bold"),
      plot.background = ggplot2::element_rect(fill = "white", color = NA),
      plot.margin   = ggplot2::margin(12, 12, 8, 12)
    )

  p
}


# -----------------------------------------------------------------------------
# 6. EXPORTER UN GRAPHIQUE
# -----------------------------------------------------------------------------

#' @title Exporter un graphique en haute résolution
#' @description Exporte un objet ggplot en PNG, PDF ou SVG avec les
#'   paramètres optimaux pour publication officielle.
#' @param graphique ggplot — Objet graphique à exporter
#' @param chemin character — Chemin de sortie avec extension
#'   (.png, .pdf, .svg)
#' @param largeur numeric — Largeur en cm. Défaut : 20.
#' @param hauteur numeric — Hauteur en cm. Défaut : 14.
#' @param dpi integer — Résolution pour PNG (ignoré pour PDF/SVG).
#'   Défaut : 300.
#' @param fond character — Couleur de fond. Défaut : "white".
#' @return Chemin du fichier exporté (invisible).
#' @examples
#' \dontrun{
#'   p <- pyramide_ages(donnees_rgph, "age", "sexe")
#'   exporter_graphique(p, "outputs/pyramide_ages_2023.png")
#' }
#' @export
exporter_graphique <- function(graphique,
                                chemin,
                                largeur = 20,
                                hauteur = 14,
                                dpi     = 300L,
                                fond    = "white") {

  .verifier_package("ggplot2", "exporter_graphique")

  if (!inherits(graphique, "gg")) {
    rlang::abort("`graphique` doit \u00eatre un objet ggplot.")
  }

  if (missing(chemin) || !nzchar(chemin)) {
    rlang::abort("`chemin` est obligatoire.")
  }

  ext <- tolower(tools::file_ext(chemin))
  formats_valides <- c("png", "pdf", "svg", "eps", "tiff")

  if (!ext %in% formats_valides) {
    rlang::abort(paste0(
      "Format non support\u00e9 : '.", ext, "'.\n",
      "Formats valides : ", paste(formats_valides, collapse = ", ")
    ))
  }

  # Création du répertoire si nécessaire
  dir_sortie <- dirname(chemin)
  if (!dir.exists(dir_sortie) && dir_sortie != ".") {
    dir.create(dir_sortie, recursive = TRUE)
    message("R\u00e9pertoire cr\u00e9\u00e9 : ", dir_sortie)
  }

  ggplot2::ggsave(
    filename   = chemin,
    plot       = graphique,
    width      = largeur,
    height     = hauteur,
    units      = "cm",
    dpi        = dpi,
    bg         = fond
  )

  taille <- file.size(chemin)
  taille_fmt <- dplyr::case_when(
    taille > 1e6 ~ paste0(round(taille / 1e6, 1), " Mo"),
    taille > 1e3 ~ paste0(round(taille / 1e3, 1), " Ko"),
    TRUE         ~ paste0(taille, " octets")
  )

  message("Graphique export\u00e9 : ", chemin, " (", taille_fmt, ")")
  invisible(chemin)
}


# =============================================================================
# FONCTIONS INTERNES
# =============================================================================

#' @keywords internal
.verifier_package <- function(pkg, contexte = NULL) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    ctx <- if (!is.null(contexte)) paste0(" (requis pour ", contexte, ")") else ""
    rlang::abort(paste0(
      "Package '", pkg, "' requis", ctx, " mais non install\u00e9.\n",
      "Installez-le avec : install.packages('", pkg, "')"
    ))
  }
}

#' @keywords internal
`%||%` <- function(a, b) if (!is.null(a)) a else b
