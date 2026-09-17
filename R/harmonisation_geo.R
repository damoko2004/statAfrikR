# =============================================================================
# statAfrikR - Module Harmonisation des referentiels geographiques
# Tables de concordance . Normalisation . Detection d'ecarts
# Gestion des changements de decoupage administratif en Afrique
# =============================================================================

utils::globalVariables(c(
  "nom_local", "code_iso", "code_gadm", "code_ins", "pays",
  "zone_source", "zone_cible", "score_similarite", "suggestion",
  "annee_debut", "annee_fin", "type_changement", "statut",
  "n_apparies", "n_non_apparies", "n_ambigus", "taux_appariement"
))

# =============================================================================
# 1. TABLE DE CONCORDANCE
# =============================================================================

#' @title Creer une table de concordance entre nomenclatures geographiques
#' @description Cree une table de correspondance entre les differentes
#'   nomenclatures geographiques utilisees en Afrique : nomenclature locale
#'   des INS, codes ISO 3166-2, codes GADM, codes EHCVM, et noms officiels.
#'   Essentielle pour harmoniser les donnees entre plusieurs sources.
#'
#' @param donnees data.frame -- Donnees de reference avec les noms/codes
#'   des zones administratives
#' @param var_nom_local character -- Variable nom local (utilise par l'INS).
#'   Defaut : "nom_zone"
#' @param var_code_ins character ou NULL -- Variable code INS.
#'   Defaut : NULL
#' @param var_code_iso character ou NULL -- Variable code ISO 3166-2.
#'   Defaut : NULL
#' @param var_code_gadm character ou NULL -- Variable code GADM.
#'   Defaut : NULL
#' @param var_niveau character ou NULL -- Variable niveau administratif
#'   (1 = region, 2 = departement, etc.). Defaut : NULL
#' @param var_pays character ou NULL -- Variable pays (code ISO 3).
#'   Defaut : NULL
#'
#' @return Un objet de classe \code{saf_concordance}
#'
#' @examples
#' zones_rca <- data.frame(
#'   nom_zone   = c("Bangui","Ombella-M'Poko","Bamingui-Bangoran",
#'                   "Mbomou","Haute-Kotto"),
#'   code_ins   = c("01","02","03","04","05"),
#'   code_iso   = c("CF-BGF","CF-MP","CF-BB","CF-MB","CF-HK"),
#'   code_gadm  = c("GADMa001","GADMa002","GADMa003","GADMa004","GADMa005"),
#'   niveau     = rep(1L, 5),
#'   pays       = rep("CAF", 5),
#'   stringsAsFactors = FALSE
#' )
#' table_concordance(zones_rca, var_nom_local="nom_zone",
#'                    var_code_ins="code_ins", var_code_iso="code_iso",
#'                    var_code_gadm="code_gadm", var_niveau="niveau",
#'                    var_pays="pays")
#'
#' @export
table_concordance <- function(donnees,
                               var_nom_local = "nom_zone",
                               var_code_ins  = NULL,
                               var_code_iso  = NULL,
                               var_code_gadm = NULL,
                               var_niveau    = NULL,
                               var_pays      = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_nom_local %in% names(donnees)) {
    rlang::abort(paste0("Variable '", var_nom_local, "' introuvable."))
  }

  # Verifier les variables optionnelles
  vars_opt <- list(
    code_ins  = var_code_ins,
    code_iso  = var_code_iso,
    code_gadm = var_code_gadm,
    niveau    = var_niveau,
    pays      = var_pays
  )
  vars_presents <- Filter(function(v) !is.null(v) && v %in% names(donnees),
                           vars_opt)

  # Construire la table de concordance
  conc <- tibble::tibble(nom_local = as.character(donnees[[var_nom_local]]))

  for (nm in names(vars_presents)) {
    conc[[nm]] <- as.character(donnees[[vars_presents[[nm]]]])
  }

  # Ajouter nom normalise automatiquement
  conc$nom_normalise <- .normaliser_nom(conc$nom_local)

  # Doublons
  n_doublons <- sum(duplicated(conc$nom_local))
  if (n_doublons > 0) {
    rlang::warn(paste0(
      n_doublons, " nom(s) en doublon detecte(s) dans la table de concordance."
    ))
  }

  message("=== Table de concordance ===")
  message("  Zones : ", nrow(conc))
  message("  Nomenclatures : ", length(vars_presents) + 1,
          " (nom_local + ", paste(names(vars_presents), collapse=", "), ")")
  if (n_doublons > 0) message("  Doublons detectes : ", n_doublons)

  structure(
    list(
      concordance    = conc,
      n_zones        = nrow(conc),
      nomenclatures  = c("nom_local", names(vars_presents)),
      n_doublons     = n_doublons
    ),
    class = "saf_concordance"
  )
}

#' @export
print.saf_concordance <- function(x, ...) {
  cat("\n=== Table de concordance geographique ===\n")
  cat("  Zones         :", x$n_zones, "\n")
  cat("  Nomenclatures :", paste(x$nomenclatures, collapse=" | "), "\n")
  cat("  Doublons      :", x$n_doublons, "\n")
  print(utils::head(x$concordance, 6))
  if (nrow(x$concordance) > 6) {
    cat("  ... et", nrow(x$concordance) - 6, "autres zones\n")
  }
  invisible(x)
}

# =============================================================================
# 2. HARMONISER LES NOMS DE ZONES
# =============================================================================

#' @title Harmoniser les noms de zones geographiques
#' @description Normalise automatiquement les noms de zones : suppression
#'   des accents, standardisation de la casse, suppression des caracteres
#'   speciaux. Permet de faire des jointures geographiques robustes meme
#'   quand les orthographes different entre sources.
#'
#' @param donnees data.frame -- Donnees a harmoniser
#' @param var_zone character -- Variable contenant les noms de zones
#' @param reference saf_concordance ou data.frame -- Table de reference.
#'   Si NULL, harmonise seulement les noms (sans correspondance).
#'   Defaut : NULL
#' @param var_ref character -- Variable de la reference correspondant.
#'   Defaut : "nom_local"
#' @param seuil_similarite numeric -- Seuil de score Jaro-Winkler pour
#'   l'appariement automatique (0-1). Defaut : 0.85
#'
#' @return Un data.frame avec colonne supplementaire de nom harmonise
#'
#' @examples
#' donnees_enquete <- data.frame(
#'   region    = c("Bangui","BANGUI","Ombella Mpoko","Bamingui Bangoran"),
#'   valeur    = c(120, 85, 200, 150),
#'   stringsAsFactors = FALSE
#' )
#' harmoniser_zones(donnees_enquete, "region")
#'
#' @export
harmoniser_zones <- function(donnees,
                              var_zone,
                              reference          = NULL,
                              var_ref            = "nom_local",
                              seuil_similarite   = 0.85) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_zone %in% names(donnees)) {
    rlang::abort(paste0("Variable '", var_zone, "' introuvable."))
  }

  zones    <- as.character(donnees[[var_zone]])
  zones_n  <- .normaliser_nom(zones)

  df_res <- donnees
  df_res[[paste0(var_zone, "_normalise")]] <- zones_n

  # Si reference fournie : appariement
  if (!is.null(reference)) {
    ref_df <- if (inherits(reference, "saf_concordance"))
      reference$concordance else reference

    if (!var_ref %in% names(ref_df)) {
      rlang::abort(paste0(
        "Variable '", var_ref, "' introuvable dans la reference."
      ))
    }

    ref_noms <- as.character(ref_df[[var_ref]])
    ref_n    <- .normaliser_nom(ref_noms)

    # Appariement exact d'abord, puis approche par similarite
    matches <- sapply(zones_n, function(z) {
      # Exact
      idx_exact <- which(ref_n == z)
      if (length(idx_exact) > 0) return(ref_noms[idx_exact[1]])
      # Similarite Jaro-Winkler (approximation)
      scores <- .jaro_winkler_approx(z, ref_n)
      best   <- which.max(scores)
      if (scores[best] >= seuil_similarite) return(ref_noms[best])
      return(NA_character_)
    })

    df_res[[paste0(var_zone, "_ref")]] <- matches
    n_mod <- sum(zones != matches | is.na(matches), na.rm=TRUE)
    n_na  <- sum(is.na(matches))

    message("Harmonisation : ",
            sum(!is.na(matches)), "/", length(zones),
            " zones appariees | ", n_na, " non appariee(s)")
  } else {
    # Simple normalisation
    n_mod <- sum(zones != zones_n, na.rm=TRUE)
    message("Nettoyage effectue sur 1 variable(s) :")
    if (n_mod > 0) {
      message("  ", var_zone, " : ", n_mod, " valeur(s) modifiee(s)")
    } else {
      message("Harmonisation : 100% des valeurs standardisees.")
    }
  }

  df_res
}

# =============================================================================
# 3. DETECTER LES ECARTS GEOGRAPHIQUES
# =============================================================================

#' @title Detecter les zones non appariees entre deux sources
#' @description Identifie les zones presentes dans les donnees mais absentes
#'   de la reference geographique. Propose des suggestions d'appariement
#'   par score de similarite (Jaro-Winkler). Essentiel avant toute jointure
#'   cartographique.
#'
#' @param donnees data.frame -- Donnees avec zones a verifier
#' @param var_zone character -- Variable zone dans les donnees
#' @param reference data.frame ou saf_concordance -- Reference geographique
#' @param var_ref character -- Variable zone dans la reference.
#'   Defaut : "nom_local"
#' @param n_suggestions integer -- Nombre de suggestions par zone.
#'   Defaut : 3L
#'
#' @return Un tibble avec zones non appariees et suggestions
#'
#' @examples
#' donnees <- data.frame(
#'   region = c("Bangui","Ombella-Mpoko","Kemo","Zone inconnue"),
#'   valeur = c(100, 200, 150, 80),
#'   stringsAsFactors = FALSE
#' )
#' reference <- data.frame(
#'   nom_local = c("Bangui","Ombella-M'Poko","Kemo",
#'                  "Bamingui-Bangoran","Mbomou"),
#'   stringsAsFactors = FALSE
#' )
#' detecter_ecarts_geo(donnees, "region", reference, "nom_local")
#'
#' @export
detecter_ecarts_geo <- function(donnees,
                                 var_zone,
                                 reference,
                                 var_ref       = "nom_local",
                                 n_suggestions = 3L) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_zone %in% names(donnees)) {
    rlang::abort(paste0("Variable '", var_zone, "' introuvable."))
  }

  ref_df <- if (inherits(reference, "saf_concordance"))
    reference$concordance else reference

  if (!var_ref %in% names(ref_df)) {
    rlang::abort(paste0("Variable '", var_ref, "' introuvable dans la reference."))
  }

  zones_data  <- unique(as.character(donnees[[var_zone]]))
  zones_data  <- zones_data[!is.na(zones_data)]
  zones_ref   <- as.character(ref_df[[var_ref]])

  zones_n_d   <- .normaliser_nom(zones_data)
  zones_n_r   <- .normaliser_nom(zones_ref)

  # Appariement exact
  apparies    <- zones_data[zones_n_d %in% zones_n_r]
  non_app     <- zones_data[!zones_n_d %in% zones_n_r]

  # Suggestions pour les non-appariees
  if (length(non_app) > 0) {
    suggestions <- lapply(non_app, function(z) {
      z_n    <- .normaliser_nom(z)
      scores <- .jaro_winkler_approx(z_n, zones_n_r)
      idx_top <- order(scores, decreasing=TRUE)[
        seq_len(min(n_suggestions, length(scores)))]
      tibble::tibble(
        zone_source       = z,
        suggestion_1      = zones_ref[idx_top[1]],
        score_1           = round(scores[idx_top[1]], 3),
        suggestion_2      = if (length(idx_top) >= 2) zones_ref[idx_top[2]] else NA_character_,
        score_2           = if (length(idx_top) >= 2) round(scores[idx_top[2]], 3) else NA_real_,
        suggestion_3      = if (length(idx_top) >= 3) zones_ref[idx_top[3]] else NA_character_,
        score_3           = if (length(idx_top) >= 3) round(scores[idx_top[3]], 3) else NA_real_
      )
    })
    res_non_app <- dplyr::bind_rows(suggestions)
  } else {
    res_non_app <- tibble::tibble(
      zone_source  = character(0),
      suggestion_1 = character(0),
      score_1      = numeric(0)
    )
  }

  taux_app <- round(length(apparies) / length(zones_data) * 100, 1)

  message("=== Detection des ecarts geographiques ===")
  message("  Zones dans les donnees    : ", length(zones_data))
  message("  Zones appariees           : ", length(apparies),
          " (", taux_app, "%)")
  message("  Zones non appariees       : ", length(non_app))

  if (length(non_app) > 0) {
    message("  Zones non appariees :")
    for (z in non_app) {
      message("    - ", z)
    }
  }

  list(
    appariees      = apparies,
    non_appariees  = non_app,
    suggestions    = res_non_app,
    taux_appariement = taux_app
  )
}

# =============================================================================
# 4. MIGRER UNE NOMENCLATURE
# =============================================================================

#' @title Migrer d'une nomenclature geographique vers une autre
#' @description Convertit les codes ou noms d'une nomenclature vers une
#'   autre en utilisant une table de concordance. Gere les fusions et
#'   scissions de zones administratives dans le temps.
#'
#' @param donnees data.frame -- Donnees a convertir
#' @param var_zone_source character -- Variable zone source
#' @param concordance saf_concordance ou data.frame -- Table de concordance
#' @param var_source character -- Variable source dans la concordance.
#'   Defaut : "nom_local"
#' @param var_cible character -- Variable cible dans la concordance.
#'   Defaut : "code_iso"
#' @param var_resultat character -- Nom de la nouvelle variable.
#'   Defaut : "zone_harmonisee"
#' @param conserver_non_apparies logical -- Conserver les zones non
#'   appariees (NA dans var_cible). Defaut : TRUE
#'
#' @return Un data.frame avec la nouvelle variable de zone
#'
#' @examples
#' concordance_df <- data.frame(
#'   nom_local  = c("Bangui","Ombella-M'Poko","Bamingui-Bangoran"),
#'   code_iso   = c("CF-BGF","CF-MP","CF-BB"),
#'   code_ins   = c("01","02","03"),
#'   stringsAsFactors = FALSE
#' )
#' concordance <- table_concordance(concordance_df, "nom_local",
#'                                   var_code_iso="code_iso",
#'                                   var_code_ins="code_ins")
#' donnees_enquete <- data.frame(
#'   zone   = c("Bangui","Ombella-M'Poko","Zone inconnue"),
#'   valeur = c(100, 200, 150),
#'   stringsAsFactors = FALSE
#' )
#' migrer_nomenclature(donnees_enquete, "zone", concordance,
#'                      var_source="nom_local", var_cible="code_iso")
#'
#' @export
migrer_nomenclature <- function(donnees,
                                 var_zone_source,
                                 concordance,
                                 var_source          = "nom_local",
                                 var_cible           = "code_iso",
                                 var_resultat        = "zone_harmonisee",
                                 conserver_non_apparies = TRUE) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_zone_source %in% names(donnees)) {
    rlang::abort(paste0("Variable '", var_zone_source, "' introuvable."))
  }

  conc_df <- if (inherits(concordance, "saf_concordance"))
    concordance$concordance else concordance

  for (v in c(var_source, var_cible)) {
    if (!v %in% names(conc_df)) {
      rlang::abort(paste0("Variable '", v, "' introuvable dans la concordance."))
    }
  }

  zones   <- as.character(donnees[[var_zone_source]])
  zones_n <- .normaliser_nom(zones)
  src_n   <- .normaliser_nom(as.character(conc_df[[var_source]]))
  cible   <- as.character(conc_df[[var_cible]])

  # Appariement
  result <- sapply(zones_n, function(z) {
    idx <- which(src_n == z)
    if (length(idx) > 0) cible[idx[1]] else NA_character_
  })

  n_apparies <- sum(!is.na(result))
  n_na       <- sum(is.na(result))

  message("Migration : ", n_apparies, "/", length(zones),
          " zones converties | ", n_na, " non appariee(s)")

  df_res <- donnees
  df_res[[var_resultat]] <- result

  if (!conserver_non_apparies) {
    df_res <- df_res[!is.na(result), ]
    message("  ", n_na, " ligne(s) supprimee(s) (zones non appariees).")
  }

  df_res
}

# =============================================================================
# 5. VALIDER LA COHERENCE GEOGRAPHIQUE
# =============================================================================

#' @title Valider la coherence de la couverture geographique
#' @description Verifie que les donnees couvrent l'ensemble des zones du
#'   referentiel officiel. Identifie les zones manquantes, les doublons
#'   et les zones surnumeraires (non dans le referentiel).
#'
#' @param donnees data.frame -- Donnees a verifier
#' @param var_zone character -- Variable zone dans les donnees
#' @param referentiel data.frame ou saf_concordance -- Referentiel officiel
#' @param var_ref character -- Variable zone dans le referentiel.
#'   Defaut : "nom_local"
#'
#' @return Un tibble de rapport de coherence
#'
#' @examples
#' donnees <- data.frame(
#'   region = c("Bangui","Ombella-M'Poko","Bangui"),
#'   valeur = c(100, 200, 50),
#'   stringsAsFactors = FALSE
#' )
#' ref <- data.frame(
#'   nom_local = c("Bangui","Ombella-M'Poko","Kemo","Mbomou"),
#'   stringsAsFactors = FALSE
#' )
#' valider_coherence_geo(donnees, "region", ref, "nom_local")
#'
#' @export
valider_coherence_geo <- function(donnees,
                                   var_zone,
                                   referentiel,
                                   var_ref = "nom_local") {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_zone %in% names(donnees)) {
    rlang::abort(paste0("Variable '", var_zone, "' introuvable."))
  }

  ref_df <- if (inherits(referentiel, "saf_concordance"))
    referentiel$concordance else referentiel
  if (!var_ref %in% names(ref_df)) {
    rlang::abort(paste0("Variable '", var_ref, "' introuvable dans le referentiel."))
  }

  zones_d <- as.character(donnees[[var_zone]])
  zones_n_d <- .normaliser_nom(zones_d)
  zones_r   <- as.character(ref_df[[var_ref]])
  zones_n_r <- .normaliser_nom(zones_r)

  # Zones manquantes dans les donnees
  manquantes <- zones_r[!zones_n_r %in% zones_n_d]

  # Zones en surplus (dans donnees mais pas dans ref)
  surplus    <- unique(zones_d[!zones_n_d %in% zones_n_r])

  # Doublons dans les donnees
  doublons   <- zones_d[duplicated(zones_n_d) & !is.na(zones_d)]

  n_app <- length(zones_r) - length(manquantes)
  taux  <- round(n_app / length(zones_r) * 100, 1)

  res <- tibble::tibble(
    critere        = c(
      "Zones du referentiel couvertes",
      "Zones manquantes dans les donnees",
      "Zones surnumeraires (hors referentiel)",
      "Doublons dans les donnees",
      "Taux de couverture (%)"
    ),
    valeur = c(
      n_app,
      length(manquantes),
      length(surplus),
      length(doublons),
      taux
    ),
    statut = c(
      if (n_app == length(zones_r)) "OK" else "Incomplet",
      if (length(manquantes) == 0) "OK" else "Alerte",
      if (length(surplus)    == 0) "OK" else "Attention",
      if (length(doublons)   == 0) "OK" else "Attention",
      if (taux >= 100) "OK" else if (taux >= 90) "Acceptable" else "Alerte"
    )
  )

  message("=== Coherence geographique ===")
  message("  Couverture : ", n_app, "/", length(zones_r),
          " zones (", taux, "%)")
  if (length(manquantes) > 0) {
    message("  Manquantes : ", paste(manquantes[1:min(5,length(manquantes))],
                                     collapse=", "),
            if (length(manquantes) > 5) "..." else "")
  }
  if (length(surplus) > 0) {
    message("  Surplus    : ", paste(surplus[1:min(3,length(surplus))],
                                     collapse=", "))
  }

  res
}

# =============================================================================
# 6. RAPPORT D'HARMONISATION
# =============================================================================

#' @title Produire un rapport d'harmonisation geographique
#' @description Genere un rapport complet sur l'harmonisation geographique :
#'   zones appariees, non appariees, ambigues. Format institutionnel
#'   conforme aux standards IHSN/PARIS21.
#'
#' @param donnees data.frame -- Donnees source
#' @param var_zone character -- Variable zone
#' @param reference data.frame ou saf_concordance -- Reference geographique
#' @param var_ref character -- Variable zone de reference.
#'   Defaut : "nom_local"
#' @param pays character -- Nom du pays. Defaut : "Pays"
#' @param annee integer -- Annee. Defaut : annee courante
#'
#' @return Un tibble de rapport d'harmonisation
#'
#' @examples
#' donnees <- data.frame(
#'   region = c("Bangui","Ombella-Mpoko","Kemo","Zone inconnue"),
#'   stringsAsFactors = FALSE
#' )
#' ref <- data.frame(
#'   nom_local = c("Bangui","Ombella-M'Poko","Kemo","Bamingui-Bangoran"),
#'   stringsAsFactors = FALSE
#' )
#' rapport_harmonisation(donnees, "region", ref, pays="RCA", annee=2026L)
#'
#' @export
rapport_harmonisation <- function(donnees,
                                   var_zone,
                                   reference,
                                   var_ref = "nom_local",
                                   pays    = "Pays",
                                   annee   = as.integer(
                                     format(Sys.Date(),"%Y"))) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_zone %in% names(donnees)) {
    rlang::abort(paste0("Variable '", var_zone, "' introuvable."))
  }

  # Appariement
  ecarts <- suppressMessages(
    detecter_ecarts_geo(donnees, var_zone, reference, var_ref))

  # Coherence
  coherence <- suppressMessages(
    valider_coherence_geo(donnees, var_zone, reference, var_ref))

  rapport <- tibble::tibble(
    indicateur = c(
      "Zones uniques dans les donnees",
      "Zones appariees avec le referentiel",
      "Zones non appariees",
      "Taux d'appariement (%)"
    ),
    valeur = c(
      length(unique(donnees[[var_zone]])),
      length(ecarts$appariees),
      length(ecarts$non_appariees),
      ecarts$taux_appariement
    ),
    statut = c(
      "Info",
      "OK",
      if (length(ecarts$non_appariees) == 0) "OK" else "Alerte",
      if (ecarts$taux_appariement >= 95) "Excellent"
      else if (ecarts$taux_appariement >= 80) "Acceptable"
      else "Alerte"
    ),
    pays  = pays,
    annee = annee
  )

  # Ajouter suggestions si des zones non appariees existent
  if (length(ecarts$non_appariees) > 0 && nrow(ecarts$suggestions) > 0) {
    attr(rapport, "suggestions") <- ecarts$suggestions
    message("Suggestions d'appariement disponibles dans attr(res,'suggestions')")
  }

  message("Rapport harmonisation : ", pays, " - ", annee)
  message("  Appariement : ", ecarts$taux_appariement, "%")

  rapport
}

# =============================================================================
# FONCTIONS INTERNES
# =============================================================================

#' @keywords internal
.normaliser_nom <- function(x) {
  # Supprimer accents (approximation ASCII)
  x <- as.character(x)
  x <- tolower(x)
  x <- gsub("[\u00e0\u00e2\u00e4]", "a", x)
  x <- gsub("[\u00e9\u00e8\u00ea\u00eb]", "e", x)
  x <- gsub("[\u00ef\u00ee\u00ec]", "i", x)
  x <- gsub("[\u00f4\u00f6\u00f2]", "o", x)
  x <- gsub("[\u00fb\u00fc\u00f9]", "u", x)
  x <- gsub("\u00e7", "c", x)
  x <- gsub("[\u00e3\u00e5]", "a", x)
  x <- gsub("[\u00f1]", "n", x)
  # Supprimer caracteres speciaux et ponctuation (sauf tiret et espace)
  x <- gsub("[^a-z0-9 -]", "", x)
  # Normaliser espaces et tirets
  x <- gsub("[-]+", "-", x)
  x <- gsub("\\s+", " ", x)
  x <- trimws(x)
  x
}

#' @keywords internal
.jaro_winkler_approx <- function(s1, s2_vec) {
  # Approximation simple de la similarite de chaines
  # Basee sur le nombre de caracteres communs
  sapply(s2_vec, function(s2) {
    if (is.na(s1) || is.na(s2)) return(0)
    if (s1 == s2) return(1)
    n1 <- nchar(s1); n2 <- nchar(s2)
    if (n1 == 0 || n2 == 0) return(0)

    # Caracteres communs (simplifie)
    chars1 <- strsplit(s1, "")[[1]]
    chars2 <- strsplit(s2, "")[[1]]
    communs <- length(intersect(chars1, chars2))

    # Score de similarite simplifie
    sim <- 2 * communs / (n1 + n2)

    # Bonus debut commun (Winkler)
    prefix_len <- 0
    for (i in seq_len(min(4L, n1, n2))) {
      if (substr(s1,i,i) == substr(s2,i,i)) prefix_len <- prefix_len + 1
      else break
    }
    sim + prefix_len * 0.1 * (1 - sim)
  })
}
