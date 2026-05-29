# =============================================================================
# statAfrikR - Module Cartographie
# Cartographie statistique pour les INS africains
# Construit au-dessus de sf (Suggests) et ggplot2 (Imports)
# Objectif : couvrir les 5 usages SIG prioritaires des INS africains
# =============================================================================

# =============================================================================
# 1. IMPORT DE DONNEES GEOGRAPHIQUES
# =============================================================================

#' @title Importer un fichier geographique
#' @description Importe un fichier geographique (shapefile, GeoJSON,
#'   GeoPackage) et retourne un objet \code{sf} normalise avec
#'   validation du CRS et rapport des entites chargees.
#'
#' @param chemin character -- Chemin vers le fichier geographique
#'   (.shp, .geojson, .gpkg, .json)
#' @param crs integer -- Code EPSG du systeme de coordonnees cible.
#'   Defaut : 4326 (WGS 84)
#' @param couche character ou NULL -- Nom de la couche (GeoPackage
#'   multi-couches). Defaut : NULL (premiere couche)
#' @param simplifier logical -- Simplifier la geometrie pour reduire
#'   le temps de rendu (tolerance = 0.001 degres). Defaut : FALSE
#'
#' @return Un objet \code{sf} normalise
#'
#' @examples
#' \dontrun{
#'   regions <- carte_import("data/regions.shp")
#'   communes <- carte_import("data/communes.geojson", crs = 32632)
#' }
#'
#' @export
carte_import <- function(chemin,
                          crs        = 4326L,
                          couche     = NULL,
                          simplifier = FALSE) {

  .verifier_package("sf", "carte_import")

  if (!file.exists(chemin)) {
    rlang::abort(paste0("Fichier introuvable : '", chemin, "'."))
  }

  ext <- tolower(tools::file_ext(chemin))
  exts_supportees <- c("shp", "geojson", "json", "gpkg", "kml")
  if (!ext %in% exts_supportees) {
    rlang::warn(paste0(
      "Extension '.", ext, "' inhabituelle. ",
      "Formats recommandes : ", paste(exts_supportees, collapse = ", ")
    ))
  }

  # Import
  args_read <- list(dsn = chemin, quiet = TRUE)
  if (!is.null(couche)) args_read$layer <- couche

  sf_obj <- tryCatch(
    do.call(sf::st_read, args_read),
    error = function(e) {
      rlang::abort(paste0(
        "Echec du chargement de '", basename(chemin), "' : ",
        conditionMessage(e)
      ))
    }
  )

  n_ent    <- nrow(sf_obj)
  crs_orig <- sf::st_crs(sf_obj)$epsg

  # Reprojection si necessaire
  if (!is.na(crs_orig) && crs_orig != crs) {
    sf_obj <- sf::st_transform(sf_obj, crs = crs)
  } else if (is.na(crs_orig)) {
    rlang::warn(paste0(
      "CRS non detecte dans '", basename(chemin), "'. ",
      "Attribution de EPSG:", crs, " (a verifier)."
    ))
    sf_obj <- sf::st_set_crs(sf_obj, crs)
  }

  # Simplification optionnelle
  if (simplifier) {
    sf_obj <- sf::st_simplify(sf_obj, dTolerance = 0.001,
                               preserveTopology = TRUE)
  }

  # Valider les geometries
  invalides <- sum(!sf::st_is_valid(sf_obj), na.rm = TRUE)
  if (invalides > 0) {
    rlang::warn(paste0(
      invalides, " geometrie(s) invalide(s) detectee(s). ",
      "Correction automatique appliquee."
    ))
    sf_obj <- sf::st_make_valid(sf_obj)
  }

  message("Fichier charge : ", basename(chemin))
  message("  Entites     : ", n_ent)
  message("  CRS         : EPSG:", crs)
  message("  Variables   : ",
          paste(names(sf_obj)[names(sf_obj) != "geometry"],
                collapse = ", "))

  sf_obj
}

# =============================================================================
# 2. JOINTURE STATISTIQUE / GEOGRAPHIQUE
# =============================================================================

#' @title Joindre des donnees statistiques a un objet sf
#' @description Effectue la jointure entre un objet sf et un data.frame
#'   statistique sur une cle administrative commune. Signale les zones
#'   non appariees et propose un diagnostic de correspondance.
#'
#' @param sf_obj sf -- Objet geographique (resultat de \code{carte_import()}
#'   ou tout objet sf valide)
#' @param data data.frame ou tibble -- Donnees statistiques a joindre
#' @param cle_geo character -- Nom de la variable cle dans \code{sf_obj}
#' @param cle_data character -- Nom de la variable cle dans \code{data}.
#'   Si NULL, utilise \code{cle_geo}. Defaut : NULL
#' @param type character -- Type de jointure : \code{"gauche"} (toutes
#'   les zones geo conservees) ou \code{"interne"} (seulement les zones
#'   appariees). Defaut : "gauche"
#' @param normaliser logical -- Normaliser les cles (majuscules, suppression
#'   accents et espaces) avant jointure. Defaut : TRUE
#'
#' @return Un objet \code{sf} enrichi avec les donnees statistiques
#'
#' @examples
#' \dontrun{
#'   regions_sf <- carte_import("data/regions.shp")
#'   stats      <- data.frame(region = c("Nord", "Sud"), taux = c(0.42, 0.31))
#'   enrichi    <- carte_joindre(regions_sf, stats,
#'                               cle_geo = "NOM_REGION", cle_data = "region")
#' }
#'
#' @export
carte_joindre <- function(sf_obj,
                           data,
                           cle_geo,
                           cle_data   = NULL,
                           type       = c("gauche", "interne"),
                           normaliser = TRUE) {

  .verifier_package("sf", "carte_joindre")

  if (!inherits(sf_obj, "sf")) {
    rlang::abort("`sf_obj` doit etre un objet sf.")
  }
  if (!is.data.frame(data)) {
    rlang::abort("`data` doit etre un data.frame ou tibble.")
  }
  if (!cle_geo %in% names(sf_obj)) {
    rlang::abort(paste0(
      "Cle '", cle_geo, "' absente de l'objet sf.\n",
      "Colonnes disponibles : ",
      paste(names(sf_obj)[names(sf_obj) != "geometry"], collapse = ", ")
    ))
  }

  if (is.null(cle_data)) cle_data <- cle_geo

  if (!cle_data %in% names(data)) {
    rlang::abort(paste0(
      "Cle '", cle_data, "' absente des donnees.\n",
      "Colonnes disponibles : ", paste(names(data), collapse = ", ")
    ))
  }

  type <- match.arg(type)

  # Normalisation des cles
  .norm <- function(x) {
    x <- toupper(trimws(as.character(x)))
    x <- gsub("[^A-Z0-9]", "_", x)
    x
  }

  sf_cles   <- if (normaliser) .norm(sf_obj[[cle_geo]])   else as.character(sf_obj[[cle_geo]])
  data_cles <- if (normaliser) .norm(data[[cle_data]])    else as.character(data[[cle_data]])

  # Diagnostic d'appariement
  non_app_geo  <- setdiff(sf_cles, data_cles)
  non_app_data <- setdiff(data_cles, sf_cles)

  if (length(non_app_geo) > 0) {
    rlang::warn(paste0(
      length(non_app_geo), " zone(s) geo sans correspondance dans les donnees : ",
      paste(head(non_app_geo, 5), collapse = ", "),
      if (length(non_app_geo) > 5) paste0(" ... (", length(non_app_geo) - 5, " de plus)")
    ))
  }

  if (length(non_app_data) > 0) {
    rlang::warn(paste0(
      length(non_app_data), " valeur(s) dans les donnees sans zone geo : ",
      paste(head(non_app_data, 5), collapse = ", ")
    ))
  }

  # Jointure
  sf_tmp   <- sf_obj
  dat_tmp  <- data
  sf_tmp$.cle_norm   <- sf_cles
  dat_tmp$.cle_norm  <- data_cles

  if (type == "gauche") {
    result <- merge(sf_tmp, dat_tmp, by = ".cle_norm", all.x = TRUE)
  } else {
    result <- merge(sf_tmp, dat_tmp, by = ".cle_norm", all = FALSE)
  }

  result$.cle_norm <- NULL

  # Dupliquer la col cle_data si elle porte un nom different de cle_geo
  if (paste0(cle_data, ".y") %in% names(result)) {
    result[[paste0(cle_data, ".y")]] <- NULL
  }
  if (paste0(cle_data, ".x") %in% names(result)) {
    names(result)[names(result) == paste0(cle_data, ".x")] <- cle_data
  }

  n_app <- sum(!is.na(result[[cle_geo]]))
  message("Jointure effectuee : ", n_app, "/", nrow(sf_obj),
          " zones appariees (", round(n_app / nrow(sf_obj) * 100, 1), "%)")

  result
}

# =============================================================================
# 3. CARTE CHOROPLETHE
# =============================================================================

#' @title Carte choroplethe institutionnelle
#' @description Produit une carte choroplethe a partir d'un objet sf,
#'   avec choix de la methode de discretisation et de la palette.
#'   Retourne un objet ggplot2 pret a l'emploi.
#'
#' @param sf_obj sf -- Objet geographique enrichi (resultat de
#'   \code{carte_joindre()} ou tout objet sf avec attributs statistiques)
#' @param var character -- Nom de la variable numerique a cartographier
#' @param titre character ou NULL -- Titre de la carte. Defaut : NULL
#' @param sous_titre character ou NULL -- Sous-titre. Defaut : NULL
#' @param legende character ou NULL -- Titre de la legende. Defaut : NULL
#' @param palette character -- Palette de couleur ColorBrewer :
#'   \code{"Blues"}, \code{"Reds"}, \code{"YlOrRd"}, \code{"YlGnBu"},
#'   \code{"RdYlGn"} (divergente). Defaut : "Blues"
#' @param n_classes integer -- Nombre de classes (3 a 9).
#'   Defaut : 5L
#' @param methode character -- Methode de discretisation :
#'   \code{"quantile"}, \code{"jenks"}, \code{"egal"}, \code{"sd"}.
#'   Defaut : "quantile"
#' @param inverser logical -- Inverser la palette. Defaut : FALSE
#' @param fond character -- Couleur de fond de la carte.
#'   Defaut : \code{"#EEF4F8"}
#' @param na_couleur character -- Couleur des zones sans donnees.
#'   Defaut : \code{"#D9E4EC"}
#' @param source character ou NULL -- Note de source. Defaut : NULL
#'
#' @return Un objet \code{ggplot2}
#'
#' @examples
#' \dontrun{
#'   sf_enrichi <- carte_joindre(regions_sf, stats_pauvrete,
#'                               cle_geo = "NOM_REGION",
#'                               cle_data = "region")
#'   carte_choroplethe(sf_enrichi, var = "taux_pauvrete",
#'                     titre = "Taux de pauvrete par region",
#'                     methode = "quantile")
#' }
#'
#' @export
carte_choroplethe <- function(sf_obj,
                               var,
                               titre      = NULL,
                               sous_titre = NULL,
                               legende    = NULL,
                               palette    = "Blues",
                               n_classes  = 5L,
                               methode    = c("quantile", "jenks",
                                              "egal", "sd"),
                               inverser   = FALSE,
                               fond       = "#EEF4F8",
                               na_couleur = "#D9E4EC",
                               source     = NULL) {

  .verifier_package("sf", "carte_choroplethe")

  if (!inherits(sf_obj, "sf")) {
    rlang::abort("`sf_obj` doit etre un objet sf.")
  }
  if (!var %in% names(sf_obj)) {
    rlang::abort(paste0(
      "Variable '", var, "' absente de l'objet sf.\n",
      "Variables disponibles : ",
      paste(names(sf_obj)[names(sf_obj) != "geometry"], collapse = ", ")
    ))
  }
  if (!is.numeric(sf_obj[[var]])) {
    rlang::abort(paste0("'", var, "' doit etre numerique."))
  }

  n_classes <- as.integer(n_classes)
  if (n_classes < 2L || n_classes > 9L) {
    rlang::abort("`n_classes` doit etre entre 2 et 9.")
  }

  methode <- match.arg(methode)

  valeurs <- sf_obj[[var]]
  valeurs_ok <- valeurs[!is.na(valeurs)]

  if (length(valeurs_ok) == 0) {
    rlang::abort(paste0("Aucune valeur non-NA dans '", var, "'."))
  }

  # Discretisation
  bornes <- switch(methode,
    "quantile" = stats::quantile(valeurs_ok,
                                  probs = seq(0, 1, length.out = n_classes + 1),
                                  na.rm = TRUE),
    "egal"     = seq(min(valeurs_ok), max(valeurs_ok),
                     length.out = n_classes + 1),
    "sd"       = {
      m  <- mean(valeurs_ok)
      s  <- stats::sd(valeurs_ok)
      c(min(valeurs_ok),
        m - 2*s, m - s, m, m + s, m + 2*s,
        max(valeurs_ok))
    },
    "jenks"    = .jenks_breaks(valeurs_ok, n_classes)
  )

  bornes <- unique(sort(bornes))
  if (length(bornes) < 3) {
    rlang::warn("Trop peu de valeurs distinctes \u2014 passage en methode 'egal'.")
    bornes <- seq(min(valeurs_ok), max(valeurs_ok),
                  length.out = n_classes + 1)
    bornes <- unique(sort(bornes))
  }

  sf_obj$.classe <- cut(valeurs, breaks = bornes, include.lowest = TRUE,
                         right = TRUE)

  # Palette
  palettes_dispo <- c("Blues", "Reds", "Greens", "Oranges", "Purples",
                       "YlOrRd", "YlGnBu", "RdYlGn", "BrBG", "PuOr")
  if (!palette %in% palettes_dispo) {
    rlang::warn(paste0(
      "Palette '", palette, "' inconnue. Utilisation de 'Blues'."
    ))
    palette <- "Blues"
  }

  n_classes_eff <- length(levels(sf_obj$.classe))
  couleurs <- grDevices::colorRampPalette(
    if (palette == "Blues")   c("#EFF6FF", "#1D4ED8")
    else if (palette == "Reds") c("#FEF2F2", "#DC2626")
    else if (palette == "YlOrRd") c("#FFFFCC", "#BD0026")
    else if (palette == "YlGnBu") c("#FFFFD9", "#253494")
    else if (palette == "RdYlGn") c("#D73027", "#FFFFBF", "#1A9850")
    else c("#EFF6FF", "#1D4ED8")
  )(n_classes_eff)

  if (inverser) couleurs <- rev(couleurs)

  # Graphique
  g <- ggplot2::ggplot(sf_obj) +
    ggplot2::geom_sf(
      ggplot2::aes(fill = .data$.classe),
      color = "white", linewidth = 0.3
    ) +
    ggplot2::scale_fill_manual(
      values   = couleurs,
      na.value = na_couleur,
      name     = if (!is.null(legende)) legende else var,
      drop     = FALSE
    ) +
    ggplot2::coord_sf() +
    ggplot2::theme_void(base_size = 11) +
    ggplot2::theme(
      plot.background  = ggplot2::element_rect(fill = fond, color = NA),
      plot.title       = ggplot2::element_text(
        face = "bold", color = "#0F2742", size = 13, hjust = 0
      ),
      plot.subtitle    = ggplot2::element_text(
        color = "#475569", size = 10, hjust = 0
      ),
      plot.caption     = ggplot2::element_text(
        color = "#64748B", size = 8, hjust = 1
      ),
      legend.position  = "right",
      legend.title     = ggplot2::element_text(
        face = "bold", color = "#1E293B", size = 9
      ),
      legend.text      = ggplot2::element_text(color = "#475569", size = 8),
      plot.margin      = ggplot2::margin(10, 10, 10, 10)
    ) +
    ggplot2::labs(
      title    = titre,
      subtitle = sous_titre,
      caption  = if (!is.null(source)) paste0("Source : ", source)
                 else "statAfrikR"
    )

  g
}

# =============================================================================
# 4. CARTE PAUVRETE
# =============================================================================

#' @title Carte thematique de la pauvrete
#' @description Surcouche de \code{carte_choroplethe()} specialisee pour
#'   la cartographie des indices de pauvrete (FGT0, FGT1, FGT2).
#'   Utilise une symbologie standardisee AFRISTAT/Banque mondiale.
#'
#' @param sf_obj sf -- Objet geographique enrichi avec les taux de pauvrete
#' @param var_fgt0 character -- Variable du taux de pauvrete (FGT0, en
#'   proportion ou pourcentage)
#' @param seuil_alerte numeric -- Seuil d'alerte (zones en rouge).
#'   Defaut : 0.5 (50%)
#' @param titre character ou NULL -- Titre. Defaut : titre automatique
#' @param source character ou NULL -- Note source. Defaut : NULL
#' @param afficher_valeurs logical -- Afficher les valeurs sur la carte.
#'   Defaut : FALSE
#' @param var_label character ou NULL -- Variable a utiliser comme etiquette
#'   (nom de la zone). Defaut : NULL
#'
#' @return Un objet \code{ggplot2}
#'
#' @examples
#' \dontrun{
#'   carte_pauvrete(regions_enrichi,
#'                  var_fgt0 = "taux_pauvrete",
#'                  seuil_alerte = 0.5,
#'                  titre = "Incidence de la pauvrete par region 2026")
#' }
#'
#' @export
carte_pauvrete <- function(sf_obj,
                            var_fgt0,
                            seuil_alerte   = 0.5,
                            titre          = NULL,
                            source         = NULL,
                            afficher_valeurs = FALSE,
                            var_label      = NULL) {

  .verifier_package("sf", "carte_pauvrete")

  if (!inherits(sf_obj, "sf")) {
    rlang::abort("`sf_obj` doit etre un objet sf.")
  }
  if (!var_fgt0 %in% names(sf_obj)) {
    rlang::abort(paste0("Variable '", var_fgt0, "' absente de l'objet sf."))
  }

  val <- sf_obj[[var_fgt0]]

  # Normaliser en proportion si en pourcentage
  if (max(val, na.rm = TRUE) > 1.5) {
    sf_obj[[var_fgt0]] <- val / 100
    val <- sf_obj[[var_fgt0]]
    rlang::warn(paste0(
      "'", var_fgt0, "' semble en pourcentage (max > 1.5). ",
      "Division par 100 appliquee."
    ))
  }

  # Categorisation avec seuil d'alerte
  sf_obj$.cat_pauvrete <- cut(
    val,
    breaks         = c(-Inf, 0.2, 0.35, seuil_alerte, 0.65, Inf),
    labels         = c("< 20%", "20-35%",
                       paste0("35-", round(seuil_alerte * 100), "%"),
                       paste0(round(seuil_alerte * 100), "-65%"),
                       "> 65%"),
    include.lowest = TRUE
  )

  couleurs_pauv <- c(
    "< 20%"  = "#2166AC",
    "20-35%" = "#67A9CF",
    "35-50%" = "#FDDBC7",
    "50-65%" = "#EF8A62",
    "> 65%"  = "#B2182B"
  )
  # Adapter les noms des couleurs aux labels effectifs
  labels_eff   <- levels(sf_obj$.cat_pauvrete)
  couleurs_eff <- setNames(
    grDevices::colorRampPalette(
      c("#2166AC", "#67A9CF", "#FDDBC7", "#EF8A62", "#B2182B")
    )(length(labels_eff)),
    labels_eff
  )

  if (is.null(titre)) {
    titre <- paste0("Incidence de la pauvrete (FGT0) -- seuil alerte ",
                    round(seuil_alerte * 100), "%")
  }

  g <- ggplot2::ggplot(sf_obj) +
    ggplot2::geom_sf(
      ggplot2::aes(fill = .data$.cat_pauvrete),
      color = "white", linewidth = 0.4
    ) +
    ggplot2::scale_fill_manual(
      values   = couleurs_eff,
      na.value = "#D9E4EC",
      name     = "Taux de pauvrete",
      drop     = FALSE
    ) +
    ggplot2::coord_sf() +
    ggplot2::theme_void(base_size = 11) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = "#EEF4F8", color = NA),
      plot.title      = ggplot2::element_text(
        face = "bold", color = "#0F2742", size = 13, hjust = 0
      ),
      plot.caption    = ggplot2::element_text(
        color = "#64748B", size = 8, hjust = 1
      ),
      legend.position = "right",
      legend.title    = ggplot2::element_text(
        face = "bold", color = "#1E293B", size = 9
      ),
      plot.margin     = ggplot2::margin(10, 10, 10, 10)
    ) +
    ggplot2::labs(
      title   = titre,
      caption = if (!is.null(source)) paste0("Source : ", source)
                else "statAfrikR | FGT Foster, Greer & Thorbecke (1984)"
    )

  # Etiquettes optionnelles
  if (afficher_valeurs && !is.null(var_label) &&
      var_label %in% names(sf_obj)) {
    centroides <- suppressWarnings(sf::st_centroid(sf_obj))
    coords     <- sf::st_coordinates(centroides)
    sf_obj$.lon <- coords[, 1]
    sf_obj$.lat <- coords[, 2]

    g <- g + ggplot2::geom_text(
      data = as.data.frame(sf_obj),
      ggplot2::aes(x = .data$.lon, y = .data$.lat,
                   label = .data[[var_label]]),
      size = 2.5, color = "#1E293B", fontface = "bold"
    )
  }

  g
}

# =============================================================================
# 5. EXPORT DE CARTE
# =============================================================================

#' @title Exporter une carte
#' @description Exporte un objet ggplot2 (carte) en PNG, PDF ou SVG
#'   avec resolution et dimensions optimisees pour les rapports INS.
#'
#' @param carte ggplot2 -- Objet ggplot a exporter
#' @param chemin character -- Chemin du fichier de sortie (extension
#'   determinant le format : .png, .pdf, .svg)
#' @param largeur numeric -- Largeur en cm. Defaut : 20
#' @param hauteur numeric -- Hauteur en cm. Defaut : 15
#' @param resolution integer -- Resolution en DPI (PNG uniquement).
#'   Defaut : 300L
#'
#' @return Chemin du fichier cree (invisible)
#'
#' @examples
#' \dontrun{
#'   g <- carte_choroplethe(sf_enrichi, var = "taux_pauvrete")
#'   carte_exporter(g, file.path(tempdir(), "carte_pauvrete.png"))
#' }
#'
#' @export
carte_exporter <- function(carte,
                            chemin,
                            largeur    = 20,
                            hauteur    = 15,
                            resolution = 300L) {

  if (!inherits(carte, "ggplot")) {
    rlang::abort("`carte` doit etre un objet ggplot2.")
  }
  if (!is.character(chemin) || nchar(chemin) == 0) {
    rlang::abort("`chemin` doit etre un chemin valide.")
  }
  if (!dir.exists(dirname(chemin))) {
    rlang::abort(paste0("Repertoire inexistant : ", dirname(chemin)))
  }

  ext <- tolower(tools::file_ext(chemin))
  if (!ext %in% c("png", "pdf", "svg")) {
    rlang::abort("Format non supporte. Utilisez .png, .pdf ou .svg.")
  }

  ggplot2::ggsave(
    filename = chemin,
    plot     = carte,
    width    = largeur,
    height   = hauteur,
    units    = "cm",
    dpi      = if (ext == "png") resolution else 72L
  )

  message("Carte exportee : ", chemin,
          " (", largeur, "x", hauteur, " cm)")
  invisible(chemin)
}

# =============================================================================
# FONCTIONS INTERNES
# =============================================================================

#' @keywords internal
.jenks_breaks <- function(x, n) {
  # Implementation simplifiee de Jenks Natural Breaks
  # Pour une implementation complete, utiliser classInt::classIntervals()
  x_sort <- sort(x[!is.na(x)])
  n_vals  <- length(x_sort)

  if (n_vals <= n) {
    return(unique(c(min(x_sort) - 1e-10, x_sort)))
  }

  # Algorithme Jenks simplifie (Fisher-Jenks)
  idx <- round(seq(1, n_vals, length.out = n + 1))
  idx <- unique(pmax(1L, pmin(n_vals, as.integer(idx))))
  bornes <- unique(c(x_sort[1] - 1e-10, x_sort[idx]))

  if (length(bornes) < 3) {
    bornes <- seq(min(x_sort), max(x_sort), length.out = n + 1)
    bornes[1] <- bornes[1] - 1e-10
  }

  bornes
}
