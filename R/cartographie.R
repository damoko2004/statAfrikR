# =============================================================================
# statAfrikR - Module Cartographie v2
# Fonds de cartes africains embarques - aucune dependance externe requise
# sf en Imports - ggplot2 en Imports - zero package supplementaire
# =============================================================================

# Variables globales
utils::globalVariables(c(
  ".classe", ".cat_pauvrete", ".lon", ".lat",
  "pays", "pays_fr", "iso3", "prefecture"
))

# Zones regionales disponibles dans statAfrikR
.ZONES_DISPONIBLES <- c(
  "afrique"      = "saf_pays_afrique",
  "cemac"        = "saf_cemac",
  "cedeao"       = "saf_cedeao",
  "eau"          = "saf_eau",
  "sadc"         = "saf_sadc",
  "rca"          = "saf_rca_prefectures",
  "subdivisions" = "saf_subdivisions_afrique"
)

# =============================================================================
# 1. ACCES AUX FONDS DE CARTES EMBARQUES
# =============================================================================

#' @title Charger un fond de carte africain integre
#' @description Charge un fond de carte geographique directement integre
#'   dans statAfrikR. Aucun package supplementaire requis.
#'
#' @param zone character -- Zone geographique :
#'   \code{"afrique"} (54 pays), \code{"cemac"} (6 pays),
#'   \code{"cedeao"} (15 pays), \code{"eau"} (Afrique de l'Est),
#'   \code{"sadc"} (Afrique Australe),
#'   \code{"rca"} (17 prefectures RCA).
#'   Defaut : "afrique"
#' @param pays character ou NULL -- Filtrer par noms de pays (colonne
#'   \code{pays}) ou codes ISO3 (colonne \code{iso3}). Defaut : NULL
#'
#' @return Un objet \code{sf} pret a l'emploi
#'
#' @examples
#' # Tous les pays africains
#' afrique <- carte_zones("afrique")
#'
#' # Zone CEMAC uniquement
#' cemac <- carte_zones("cemac")
#'
#' # Prefectures de la RCA
#' rca <- carte_zones("rca")
#'
#' # Filtrer : Cameroun + Centrafrique uniquement
#' sous_zone <- carte_zones("afrique", pays = c("CMR", "CAF"))
#'
#' @export
carte_zones <- function(zone = c("afrique", "cemac", "cedeao", "eau", "sadc", "rca", "subdivisions"),
                         pays = NULL) {

  zone <- match.arg(zone)

  # Charger le dataset embarque
  nom_data <- .ZONES_DISPONIBLES[[zone]]
  sf_obj   <- tryCatch(
    get(nom_data, envir = asNamespace("statAfrikR")),
    error = function(e) {
      rlang::abort(paste0(
        "Fond de carte '", zone, "' introuvable.\n",
        "Reinstallez statAfrikR : install.packages('statAfrikR')"
      ))
    }
  )

  # Filtre optionnel par pays ou ISO3
  if (!is.null(pays)) {
    if ("iso3" %in% names(sf_obj)) {
      idx <- sf_obj$iso3 %in% pays | sf_obj$pays %in% pays
    } else {
      idx <- sf_obj$prefecture %in% pays
    }
    if (!any(idx)) {
      rlang::warn(paste0(
        "Aucune zone ne correspond au filtre : ",
        paste(pays, collapse = ", "), ".\n",
        "Valeurs disponibles : ",
        paste(head(
          if ("iso3" %in% names(sf_obj)) sf_obj$iso3
          else sf_obj$prefecture, 10
        ), collapse = ", ")
      ))
    }
    sf_obj <- sf_obj[idx, ]
  }

  sf_obj
}

# =============================================================================
# 2. IMPORT DE FICHIERS GEOGRAPHIQUES EXTERNES
# =============================================================================

#' @title Importer un fichier geographique
#' @description Importe un fichier geographique externe (shapefile, GeoJSON,
#'   GeoPackage) fourni par l'utilisateur ou l'INS.
#'
#' @param chemin character -- Chemin vers le fichier (.shp, .geojson, .gpkg)
#' @param crs integer -- Code EPSG cible. Defaut : 4326 (WGS 84)
#' @param couche character ou NULL -- Couche GeoPackage. Defaut : NULL
#' @param simplifier logical -- Simplifier la geometrie. Defaut : FALSE
#'
#' @return Un objet \code{sf}
#'
#' @examples
#' \dontrun{
#'   regions <- carte_import("data/regions_enquete.shp")
#' }
#'
#' @export
carte_import <- function(chemin,
                          crs        = 4326L,
                          couche     = NULL,
                          simplifier = FALSE) {

  if (!file.exists(chemin)) {
    rlang::abort(paste0(
      "Fichier introuvable : '", chemin, "'.\n",
      "Verifiez le chemin ou utilisez carte_zones() pour les ",
      "fonds de cartes integres dans statAfrikR."
    ))
  }

  args_read <- list(dsn = chemin, quiet = TRUE)
  if (!is.null(couche)) args_read$layer <- couche

  sf_obj <- tryCatch(
    do.call(sf::st_read, args_read),
    error = function(e) {
      rlang::abort(paste0(
        "Impossible de lire '", basename(chemin), "'.\n",
        "Formats supportes : .shp, .geojson, .gpkg, .kml\n",
        "Detail : ", conditionMessage(e)
      ))
    }
  )

  crs_orig <- sf::st_crs(sf_obj)$epsg

  if (!is.na(crs_orig) && crs_orig != crs) {
    sf_obj <- sf::st_transform(sf_obj, crs = crs)
  } else if (is.na(crs_orig)) {
    rlang::warn(paste0(
      "CRS non detecte dans '", basename(chemin), "'. ",
      "Attribution de EPSG:", crs, "."
    ))
    sf_obj <- sf::st_set_crs(sf_obj, crs)
  }

  invalides <- sum(!sf::st_is_valid(sf_obj), na.rm = TRUE)
  if (invalides > 0) sf_obj <- sf::st_make_valid(sf_obj)

  if (simplifier) {
    sf_obj <- sf::st_simplify(sf_obj, dTolerance = 0.01,
                               preserveTopology = TRUE)
  }

  message("Fichier charge : ", nrow(sf_obj), " entites | EPSG:", crs)
  sf_obj
}

# =============================================================================
# 3. JOINTURE STATISTIQUE / GEOGRAPHIQUE
# =============================================================================

#' @title Joindre des donnees statistiques a un fond de carte
#' @description Joint un objet sf avec un data.frame statistique.
#'   Normalise automatiquement les cles pour eviter les erreurs de
#'   correspondance dues aux accents, casses et espaces.
#'
#' @param sf_obj sf -- Objet geographique (depuis \code{carte_zones()} ou
#'   \code{carte_import()})
#' @param data data.frame -- Donnees statistiques
#' @param cle_geo character -- Variable cle dans \code{sf_obj}
#' @param cle_data character -- Variable cle dans \code{data}.
#'   Si NULL, utilise \code{cle_geo}. Defaut : NULL
#' @param type character -- \code{"gauche"} (toutes zones conservees) ou
#'   \code{"interne"} (zones appariees uniquement). Defaut : "gauche"
#' @param normaliser logical -- Normaliser les cles (recommande).
#'   Defaut : TRUE
#'
#' @return Un objet \code{sf} enrichi
#'
#' @examples
#' # Avec les fonds de cartes integres
#' rca <- carte_zones("rca")
#' stats <- data.frame(
#'   prefecture    = rca$prefecture,
#'   taux_pauvrete = c(74.2, 71.8, 68.5, 65.3, 72.1,
#'                     55.4, 48.7, 51.2, 62.3, 58.9,
#'                     28.4, 42.1, 52.8, 63.7, 59.4,
#'                     44.6, 70.5)[seq_len(nrow(rca))]
#' )
#' sf_enrichi <- carte_joindre(rca, stats,
#'                              cle_geo  = "prefecture",
#'                              cle_data = "prefecture")
#'
#' @export
carte_joindre <- function(sf_obj,
                           data,
                           cle_geo,
                           cle_data   = NULL,
                           type       = c("gauche", "interne"),
                           normaliser = TRUE) {

  if (!inherits(sf_obj, "sf")) {
    rlang::abort(paste0(
      "`sf_obj` doit etre un objet sf.\n",
      "Utilisez carte_zones() ou carte_import() pour creer un objet sf."
    ))
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

  # Normalisation : majuscules + alphanum seulement
  .norm <- function(x) gsub("[^A-Z0-9]", "_", toupper(trimws(x)))

  sf_tmp  <- sf_obj
  dat_tmp <- data
  sf_tmp$.cle  <- if (normaliser) .norm(sf_obj[[cle_geo]])   else as.character(sf_obj[[cle_geo]])
  dat_tmp$.cle <- if (normaliser) .norm(data[[cle_data]])    else as.character(data[[cle_data]])

  non_app_geo  <- setdiff(sf_tmp$.cle, dat_tmp$.cle)
  non_app_data <- setdiff(dat_tmp$.cle, sf_tmp$.cle)

  if (length(non_app_geo) > 0) {
    rlang::warn(paste0(
      length(non_app_geo), " zone(s) sans donnees : ",
      paste(head(non_app_geo, 3), collapse = ", "),
      if (length(non_app_geo) > 3)
        paste0(" ... +", length(non_app_geo)-3),
      "\nCes zones apparaitront en gris sur la carte."
    ))
  }

  result <- if (type == "gauche") {
    merge(sf_tmp, dat_tmp, by = ".cle", all.x = TRUE)
  } else {
    merge(sf_tmp, dat_tmp, by = ".cle", all = FALSE)
  }

  result$.cle <- NULL
  result <- sf::st_as_sf(result)

  n_app <- nrow(result) - length(non_app_geo)
  message("Jointure : ", n_app, "/", nrow(sf_obj), " zones appariees (",
          round(n_app/nrow(sf_obj)*100, 0), "%)")

  result
}

# =============================================================================
# 4. CARTE CHOROPLETHE INSTITUTIONNELLE
# =============================================================================

#' @title Carte choroplethe statistique institutionnelle
#' @description Produit une carte choroplethe professionnelle. Utilise
#'   uniquement ggplot2 (deja installe avec statAfrikR) et sf.
#'   Gestion automatique des labels pour les petits pays.
#'
#' @param sf_obj sf -- Objet sf enrichi (depuis \code{carte_joindre()})
#' @param var character -- Variable numerique a cartographier
#' @param titre character ou NULL -- Titre. Defaut : NULL
#' @param sous_titre character ou NULL -- Sous-titre. Defaut : NULL
#' @param legende character ou NULL -- Titre de la legende. Defaut : NULL
#' @param palette character -- Palette : \code{"pauvrete"} (jaune-rouge),
#'   \code{"developpement"} (rouge-vert), \code{"eau"} (bleu clair-fonce),
#'   \code{"neutre"} (gris-bleu). Defaut : "pauvrete"
#' @param n_classes integer -- Nombre de classes (2-9). Defaut : 5L
#' @param methode character -- Discretisation : \code{"quantile"},
#'   \code{"jenks"}, \code{"egal"}, \code{"sd"}. Defaut : "quantile"
#' @param col_label character ou NULL -- Variable a afficher comme label
#'   sur chaque zone. Defaut : NULL
#' @param inverser logical -- Inverser la palette. Defaut : FALSE
#' @param source character ou NULL -- Note de source. Defaut : NULL
#'
#' @return Un objet \code{ggplot2}
#'
#' @examples
#' rca <- carte_zones("rca")
#' n <- nrow(rca)
#' stats <- data.frame(
#'   prefecture    = rca$prefecture,
#'   taux_pauvrete = c(74.2, 71.8, 68.5, 65.3, 72.1,
#'                     55.4, 48.7, 51.2, 62.3, 58.9,
#'                     28.4, 42.1, 52.8, 63.7, 59.4,
#'                     44.6, 70.5)[seq_len(n)]
#' )
#' sf_enr <- carte_joindre(rca, stats, "prefecture", "prefecture")
#' carte_choroplethe(sf_enr, "taux_pauvrete",
#'                   titre = "Pauvrete en RCA",
#'                   source = "Donnees simulees")
#'
#' @export
carte_choroplethe <- function(sf_obj,
                               var,
                               titre      = NULL,
                               sous_titre = NULL,
                               legende    = NULL,
                               palette    = c("pauvrete", "developpement",
                                              "eau", "neutre"),
                               n_classes  = 5L,
                               methode    = c("quantile", "jenks",
                                              "egal", "sd"),
                               col_label  = NULL,
                               inverser   = FALSE,
                               source     = NULL) {

  if (!inherits(sf_obj, "sf")) {
    rlang::abort(paste0(
      "`sf_obj` doit etre un objet sf.\n",
      "Utilisez carte_joindre() pour enrichir un fond de carte."
    ))
  }
  if (!var %in% names(sf_obj)) {
    rlang::abort(paste0(
      "Variable '", var, "' absente.\n",
      "Variables disponibles : ",
      paste(names(sf_obj)[names(sf_obj) != "geometry"], collapse = ", ")
    ))
  }
  if (!is.numeric(sf_obj[[var]])) {
    rlang::abort(paste0(
      "'", var, "' doit etre numerique.\n",
      "Convertissez avec : sf_obj$", var, " <- as.numeric(sf_obj$", var, ")"
    ))
  }

  palette <- match.arg(palette)
  methode <- match.arg(methode)
  n_classes <- as.integer(n_classes)
  if (n_classes < 2L || n_classes > 9L) {
    rlang::abort("`n_classes` doit etre entre 2 et 9.")
  }

  valeurs <- sf_obj[[var]]
  v_ok    <- valeurs[!is.na(valeurs)]

  if (length(v_ok) == 0) {
    rlang::abort(paste0(
      "Aucune valeur non-manquante dans '", var, "'.\n",
      "Verifiez la jointure avec carte_joindre()."
    ))
  }

  # Palettes statAfrikR
  pal_couleurs <- switch(palette,
    "pauvrete"      = c("#FFF7BC","#FEE391","#FEC44F",
                         "#FE9929","#EC7014","#CC4C02","#8C2D04"),
    "developpement" = c("#BD0026","#F03B20","#FD8D3C",
                         "#FECC5C","#FFFFB2","#C7E9B4","#1D9A60"),
    "eau"           = c("#EFF8FB","#C6E2F0","#86C5DA",
                         "#43A2CA","#0868AC","#084081"),
    "neutre"        = c("#F7FAFC","#DCE8F0","#B3CFE0",
                         "#7EAFC5","#4D8FAC","#1B4965")
  )
  if (inverser) pal_couleurs <- rev(pal_couleurs)

  # Echelle adaptee aux donnees reelles
  vmin <- floor(min(v_ok)  / max(1, diff(range(v_ok)) / 20)) *
    max(1, diff(range(v_ok)) / 20)
  vmax <- ceiling(max(v_ok) / max(1, diff(range(v_ok)) / 20)) *
    max(1, diff(range(v_ok)) / 20)

  couleurs_interp <- grDevices::colorRampPalette(pal_couleurs)(256)
  breaks_legende  <- pretty(c(vmin, vmax), n = 5)

  # Graphique de base
  g <- ggplot2::ggplot(sf_obj) +
    ggplot2::geom_sf(
      ggplot2::aes(fill = .data[[var]]),
      color     = "white",
      linewidth = 0.35
    ) +
    ggplot2::scale_fill_gradientn(
      colors   = couleurs_interp,
      limits   = c(vmin, vmax),
      breaks   = breaks_legende,
      labels   = function(x) format(x, big.mark = " ", scientific = FALSE),
      na.value = "#D9E4EC",
      name     = if (!is.null(legende)) legende else var,
      guide    = ggplot2::guide_colorbar(
        barheight      = ggplot2::unit(6, "cm"),
        barwidth       = ggplot2::unit(0.45, "cm"),
        title.position = "top",
        title.hjust    = 0.5
      )
    ) +
    ggplot2::coord_sf() +
    ggplot2::theme_void(base_size = 11) +
    ggplot2::theme(
      plot.background  = ggplot2::element_rect(fill = "#F0F7FF",
                                                color = NA),
      plot.title       = ggplot2::element_text(
        size = 13, face = "bold", color = "#0F2742",
        margin = ggplot2::margin(b = 4)
      ),
      plot.subtitle    = ggplot2::element_text(
        size = 9, color = "#475569",
        margin = ggplot2::margin(b = 8)
      ),
      plot.caption     = ggplot2::element_text(
        size = 7.5, color = "#94A3B8", hjust = 1,
        margin = ggplot2::margin(t = 8)
      ),
      legend.position  = "right",
      legend.title     = ggplot2::element_text(
        face = "bold", size = 9, color = "#1E293B"
      ),
      legend.text      = ggplot2::element_text(
        size = 8, color = "#475569"
      ),
      plot.margin      = ggplot2::margin(10, 15, 10, 10)
    ) +
    ggplot2::labs(
      title    = titre,
      subtitle = sous_titre,
      caption  = if (!is.null(source))
        paste0("Source : ", source, " | statAfrikR")
      else "statAfrikR Foundation"
    )

  # Labels internes (ggplot2 natif \u2014 sans ggrepel)
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

    # Grands polygones : label centr\u00e9
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
  }

  g
}

# =============================================================================
# 5. CARTE PAUVRETE SPECIALISEE
# =============================================================================

#' @title Carte thematique de la pauvrete (FGT0)
#' @description Specialisation de \code{carte_choroplethe()} pour les
#'   indices de pauvrete. Symbologie standardisee AFRISTAT/Banque mondiale
#'   avec seuil d'alerte.
#'
#' @param sf_obj sf -- Objet sf avec taux de pauvrete
#' @param var_fgt0 character -- Variable de taux de pauvrete
#' @param seuil_alerte numeric -- Seuil d'alerte. Defaut : 0.5
#' @param col_label character ou NULL -- Variable de label. Defaut : NULL
#' @param titre character ou NULL -- Titre. Defaut : titre automatique
#' @param source character ou NULL -- Source. Defaut : NULL
#'
#' @return Un objet \code{ggplot2}
#'
#' @examples
#' rca <- carte_zones("rca")
#' n <- nrow(rca)
#' stats <- data.frame(
#'   prefecture    = rca$prefecture,
#'   taux_pauvrete = c(74.2, 71.8, 68.5, 65.3, 72.1,
#'                     55.4, 48.7, 51.2, 62.3, 58.9,
#'                     28.4, 42.1, 52.8, 63.7, 59.4,
#'                     44.6, 70.5)[seq_len(n)]
#' )
#' sf_enr <- carte_joindre(rca, stats, "prefecture", "prefecture")
#' sf_enr$taux_prop <- sf_enr$taux_pauvrete / 100
#' carte_pauvrete(sf_enr, var_fgt0 = "taux_prop",
#'                source = "Donnees simulees")
#'
#' @export
carte_pauvrete <- function(sf_obj,
                            var_fgt0,
                            seuil_alerte = 0.5,
                            col_label    = NULL,
                            titre        = NULL,
                            source       = NULL) {

  if (!inherits(sf_obj, "sf")) {
    rlang::abort("`sf_obj` doit etre un objet sf.")
  }
  if (!var_fgt0 %in% names(sf_obj)) {
    rlang::abort(paste0("Variable '", var_fgt0, "' absente de l'objet sf."))
  }

  val <- sf_obj[[var_fgt0]]
  if (max(val, na.rm = TRUE) > 1.5) {
    sf_obj[[var_fgt0]] <- val / 100
    rlang::inform(paste0(
      "'", var_fgt0, "' convertie de % en proportion (division par 100)."
    ))
  }

  if (is.null(titre)) {
    titre <- paste0("Incidence de la pauvrete (FGT0) \u2014 seuil alerte ",
                    round(seuil_alerte * 100), "%")
  }

  carte_choroplethe(
    sf_obj    = sf_obj,
    var       = var_fgt0,
    titre     = titre,
    legende   = "Taux de pauvrete",
    palette   = "pauvrete",
    methode   = "quantile",
    col_label = col_label,
    source    = source
  ) +
    ggplot2::geom_sf(
      data      = sf_obj[!is.na(sf_obj[[var_fgt0]]) &
                           sf_obj[[var_fgt0]] >= seuil_alerte, ],
      fill      = NA,
      color     = "#DC2626",
      linewidth = 1.2
    ) +
    ggplot2::annotate(
      "text",
      x = -Inf, y = Inf,
      label    = paste0("Zone d'alerte : taux >= ",
                        round(seuil_alerte * 100), "%"),
      color    = "#DC2626",
      size     = 2.8,
      hjust    = -0.05,
      vjust    = 1.5,
      fontface = "italic"
    )
}

# =============================================================================
# 6. EXPORT
# =============================================================================

#' @title Exporter une carte en fichier image
#' @description Exporte un objet ggplot2 en PNG, PDF ou SVG.
#'
#' @param carte ggplot -- Objet ggplot2
#' @param chemin character -- Chemin de sortie (.png, .pdf, .svg)
#' @param largeur numeric -- Largeur en cm. Defaut : 20
#' @param hauteur numeric -- Hauteur en cm. Defaut : 15
#' @param resolution integer -- Resolution DPI (PNG). Defaut : 300L
#'
#' @return Chemin du fichier (invisible)
#'
#' @examples
#' \dontrun{
#'   g <- carte_choroplethe(sf_enrichi, "taux_pauvrete")
#'   carte_exporter(g, file.path(tempdir(), "carte.png"))
#' }
#'
#' @export
carte_exporter <- function(carte,
                            chemin,
                            largeur    = 20,
                            hauteur    = 15,
                            resolution = 300L) {

  if (!inherits(carte, "ggplot")) {
    rlang::abort(paste0(
      "`carte` doit etre un objet ggplot2.\n",
      "Utilisez carte_choroplethe() ou carte_pauvrete() pour creer une carte."
    ))
  }
  if (!dir.exists(dirname(chemin))) {
    rlang::abort(paste0(
      "Repertoire inexistant : ", dirname(chemin), "\n",
      "Creez-le avec : dir.create('", dirname(chemin), "', recursive=TRUE)"
    ))
  }

  ext <- tolower(tools::file_ext(chemin))
  if (!ext %in% c("png", "pdf", "svg")) {
    rlang::abort(paste0(
      "Format '.", ext, "' non supporte.\n",
      "Utilisez : .png (rapports), .pdf (impression), .svg (web)"
    ))
  }

  ggplot2::ggsave(
    filename = chemin,
    plot     = carte,
    width    = largeur,
    height   = hauteur,
    units    = "cm",
    dpi      = if (ext == "png") resolution else 72L
  )

  message("Carte exportee : ", chemin)
  invisible(chemin)
}

# =============================================================================
# FONCTIONS INTERNES
# =============================================================================

#' @keywords internal
.jenks_breaks <- function(x, n) {
  x_sort <- sort(x[!is.na(x)])
  n_vals <- length(x_sort)
  if (n_vals <= n) return(unique(c(min(x_sort) - 1e-10, x_sort)))
  idx    <- round(seq(1, n_vals, length.out = n + 1))
  idx    <- unique(pmax(1L, pmin(n_vals, as.integer(idx))))
  bornes <- unique(c(x_sort[1] - 1e-10, x_sort[idx]))
  if (length(bornes) < 3)
    bornes <- seq(min(x_sort) - 1e-10, max(x_sort), length.out = n + 1)
  bornes
}
