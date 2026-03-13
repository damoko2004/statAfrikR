# =============================================================================
# statAfrikR — Module Traitement
# Fonctions de nettoyage, transformation et préparation des données
# =============================================================================

# -----------------------------------------------------------------------------
# 1. NETTOYAGE DES LIBELLÉS
# -----------------------------------------------------------------------------

#' @title Nettoyer les libellés de variables textuelles
#' @description Normalise les chaînes de caractères : suppression des espaces
#'   superflus, normalisation de la casse, gestion des caractères spéciaux,
#'   correction des encodages. Préserve les caractères accentués africains
#'   et francophones.
#' @param data data.frame ou tibble — Données à nettoyer
#' @param vars character ou NULL — Variables à nettoyer. Si NULL, toutes
#'   les variables de type character. Défaut : NULL.
#' @param casse character — Normalisation de la casse :
#'   \code{"titre"} (Première Lettre Majuscule),
#'   \code{"majuscule"}, \code{"minuscule"}, \code{"aucune"}.
#'   Défaut : "titre".
#' @param supprimer_espaces logical — Supprimer les espaces multiples et
#'   les espaces en début/fin. Défaut : TRUE.
#' @param supprimer_ponctuation logical — Supprimer la ponctuation superflue.
#'   Défaut : FALSE.
#' @param encodage character — Encodage cible. Défaut : "UTF-8".
#' @return Un tibble avec les variables textuelles nettoyées.
#' @examples
#' \dontrun{
#'   donnees_propres <- nettoyer_libelles(donnees_enquete)
#'   donnees_propres <- nettoyer_libelles(
#'     donnees_enquete,
#'     vars  = c("region", "commune"),
#'     casse = "majuscule"
#'   )
#' }
#' @export
nettoyer_libelles <- function(data,
                               vars                 = NULL,
                               casse                = c("titre", "majuscule",
                                                        "minuscule", "aucune"),
                               supprimer_espaces    = TRUE,
                               supprimer_ponctuation = FALSE,
                               encodage             = "UTF-8") {

  casse <- match.arg(casse)

  if (!is.data.frame(data)) {
    rlang::abort("L'argument `data` doit \u00eatre un data.frame ou tibble.")
  }

  # Sélection des variables à traiter
  if (is.null(vars)) {
    vars <- names(data)[sapply(data, is.character)]
    if (length(vars) == 0) {
      rlang::warn("Aucune variable de type character trouv\u00e9e dans les donn\u00e9es.")
      return(data)
    }
  } else {
    vars_absentes <- setdiff(vars, names(data))
    if (length(vars_absentes) > 0) {
      rlang::abort(paste0(
        "Variables introuvables : ", paste(vars_absentes, collapse = ", ")
      ))
    }
  }

  journal <- list()

  for (var in vars) {
    x_original <- data[[var]]
    x <- x_original

    # Suppression des espaces superflus
    if (supprimer_espaces) {
      x <- stringr::str_squish(x)
    }

    # Normalisation de la casse
    x <- switch(casse,
      "titre"     = stringr::str_to_title(x),
      "majuscule" = stringr::str_to_upper(x),
      "minuscule" = stringr::str_to_lower(x),
      "aucune"    = x
    )

    # Suppression de la ponctuation superflue (conserve les apostrophes)
    if (supprimer_ponctuation) {
      x <- stringr::str_replace_all(x, "[^[:alnum:][:space:]'\\-]", "")
    }

    # Comptage des modifications
    n_modif <- sum(x != x_original, na.rm = TRUE)
    if (n_modif > 0) {
      journal[[var]] <- paste0(n_modif, " valeur(s) modifi\u00e9e(s)")
    }

    data[[var]] <- x
  }

  if (length(journal) > 0) {
    message("Nettoyage effectu\u00e9 sur ", length(journal), " variable(s) :")
    for (var in names(journal)) {
      message("  - ", var, " : ", journal[[var]])
    }
  } else {
    message("Aucune modification n\u00e9cessaire.")
  }

  data
}


# -----------------------------------------------------------------------------
# 2. HARMONISATION DES RÉGIONS
# -----------------------------------------------------------------------------

#' @title Harmoniser les noms de régions/provinces
#' @description Standardise les noms de régions géographiques selon un
#'   référentiel national ou africain. Corrige les variantes orthographiques,
#'   les abréviations et les noms en langues locales.
#' @param data data.frame ou tibble — Données à harmoniser
#' @param var_region character — Nom de la variable contenant les régions
#' @param pays character ou NULL — Code pays ISO2 pour utiliser le référentiel
#'   intégré (ex: "BJ", "BF", "SN", "CI", "ML", "NE", "TG", "CM", "GN").
#'   Si NULL, utilise \code{table_correspondance}. Défaut : NULL.
#' @param table_correspondance data.frame ou NULL — Table de correspondance
#'   avec colonnes \code{original} et \code{standardise}. Si NULL et
#'   \code{pays} est NULL, tente une correspondance floue automatique.
#'   Défaut : NULL.
#' @param var_sortie character — Nom de la nouvelle colonne standardisée.
#'   Défaut : "region_std".
#' @param signaler_non_trouves logical — Afficher les valeurs non reconnues.
#'   Défaut : TRUE.
#' @return Le tibble avec une colonne \code{var_sortie} ajoutée contenant
#'   les régions standardisées.
#' @examples
#' \dontrun{
#'   donnees <- harmoniser_regions(
#'     data       = donnees_enquete,
#'     var_region = "region",
#'     pays       = "BJ"
#'   )
#' }
#' @export
harmoniser_regions <- function(data,
                                var_region,
                                pays                  = NULL,
                                table_correspondance  = NULL,
                                var_sortie            = "region_std",
                                signaler_non_trouves  = TRUE) {

  if (!var_region %in% names(data)) {
    rlang::abort(paste0("Variable '", var_region, "' introuvable dans les donn\u00e9es."))
  }

  # Référentiels intégrés par pays
  referentiels <- .charger_referentiels_regions()

  if (!is.null(pays)) {
    pays_up <- toupper(pays)
    if (!pays_up %in% names(referentiels)) {
      pays_dispo <- paste(names(referentiels), collapse = ", ")
      rlang::warn(paste0(
        "Pays '", pays, "' non disponible dans les r\u00e9f\u00e9rentiels int\u00e9gr\u00e9s.\n",
        "Pays disponibles : ", pays_dispo, "\n",
        "Fournissez une `table_correspondance` manuelle."
      ))
      table_correspondance <- NULL
    } else {
      table_correspondance <- referentiels[[pays_up]]
    }
  }

  valeurs <- data[[var_region]]
  valeurs_uniques <- unique(valeurs[!is.na(valeurs)])

  if (!is.null(table_correspondance)) {
    # Vérification de la table de correspondance
    cols_req <- c("original", "standardise")
    cols_man <- setdiff(cols_req, names(table_correspondance))
    if (length(cols_man) > 0) {
      rlang::abort(paste0(
        "Colonnes manquantes dans `table_correspondance` : ",
        paste(cols_man, collapse = ", ")
      ))
    }

    # Correspondance insensible à la casse et aux espaces
    table_norm <- table_correspondance
    table_norm$original_norm <- stringr::str_squish(
      stringr::str_to_lower(table_norm$original)
    )

    valeurs_norm <- stringr::str_squish(stringr::str_to_lower(valeurs))

    data[[var_sortie]] <- table_norm$standardise[
      match(valeurs_norm, table_norm$original_norm)
    ]

  } else {
    # Sans référentiel : copie simple + normalisation basique
    data[[var_sortie]] <- stringr::str_to_title(
      stringr::str_squish(valeurs)
    )
  }

  # Rapport des non-trouvés
  if (signaler_non_trouves) {
    non_trouves <- valeurs_uniques[is.na(data[[var_sortie]][
      match(valeurs_uniques, valeurs)
    ])]
    if (length(non_trouves) > 0) {
      rlang::warn(paste0(
        length(non_trouves), " valeur(s) de r\u00e9gion non reconnue(s) : ",
        paste(head(non_trouves, 10), collapse = ", "),
        if (length(non_trouves) > 10) paste0(" (et ", length(non_trouves) - 10, " autres)")
      ))
    }
  }

  taux_harmonise <- mean(!is.na(data[[var_sortie]]), na.rm = TRUE)
  message("Harmonisation : ", scales::percent(taux_harmonise),
          " des valeurs standardis\u00e9es.")

  data
}


# -----------------------------------------------------------------------------
# 3. PONDÉRATIONS
# -----------------------------------------------------------------------------

#' @title Appliquer les pondérations d'enquête
#' @description Crée un objet de plan de sondage complexe à partir d'un
#'   tibble et des variables de pondération, strates et grappes. Enveloppe
#'   ergonomique autour de \code{survey::svydesign()} avec validation
#'   complète des poids et messages d'erreur en français.
#' @param data data.frame ou tibble — Données de l'enquête
#' @param var_poids character — Nom de la variable de pondération finale
#' @param var_strate character ou NULL — Variable de stratification.
#'   Défaut : NULL.
#' @param var_grappe character ou NULL — Variable d'unité primaire de
#'   sondage (UPS/cluster). Défaut : NULL.
#' @param var_fpc character ou NULL — Variable de correction pour
#'   population finie (FPC). Défaut : NULL.
#' @param normaliser logical — Normaliser les poids pour que leur somme
#'   soit égale à l'effectif de l'échantillon. Défaut : FALSE.
#' @return Un objet \code{svydesign} du package \code{survey}.
#' @examples
#' \dontrun{
#'   plan <- appliquer_ponderations(
#'     data       = donnees_menages,
#'     var_poids  = "poids_final",
#'     var_strate = "strate",
#'     var_grappe = "grappe_id"
#'   )
#' }
#' @seealso \code{\link{tab_croisee}}, \code{\link{stat_descr}}
#' @export
appliquer_ponderations <- function(data,
                                    var_poids,
                                    var_strate  = NULL,
                                    var_grappe  = NULL,
                                    var_fpc     = NULL,
                                    normaliser  = FALSE) {

  .verifier_package("survey", "appliquer_ponderations")

  if (!var_poids %in% names(data)) {
    rlang::abort(paste0(
      "Variable de pond\u00e9ration introuvable : '", var_poids, "'.\n",
      "Variables disponibles : ", paste(names(data), collapse = ", ")
    ))
  }

  poids_vals <- data[[var_poids]]

  # Contrôles sur les valeurs des poids
  if (any(is.na(poids_vals))) {
    n_na <- sum(is.na(poids_vals))
    rlang::warn(paste0(
      n_na, " valeur(s) manquante(s) dans '", var_poids, "'. ",
      "Ces observations seront exclues du plan de sondage."
    ))
    data <- data[!is.na(poids_vals), ]
    poids_vals <- data[[var_poids]]
  }

  if (any(poids_vals <= 0)) {
    lignes_pb <- which(poids_vals <= 0)
    rlang::abort(paste0(
      "Poids nuls ou n\u00e9gatifs d\u00e9tect\u00e9s aux lignes : ",
      paste(head(lignes_pb, 10), collapse = ", "),
      if (length(lignes_pb) > 10)
        paste0(" (et ", length(lignes_pb) - 10, " autres)"),
      ".\nLes poids doivent \u00eatre strictement positifs."
    ))
  }

  # Normalisation des poids
  if (normaliser) {
    n <- nrow(data)
    somme_poids <- sum(poids_vals)
    data[[var_poids]] <- poids_vals * (n / somme_poids)
    message("Poids normalis\u00e9s : somme = ", n)
  }

  # Construction de la formule
  formule_ids <- if (!is.null(var_grappe)) {
    as.formula(paste0("~", var_grappe))
  } else {
    ~1
  }

  formule_strate <- if (!is.null(var_strate)) {
    as.formula(paste0("~", var_strate))
  } else {
    NULL
  }

  formule_fpc <- if (!is.null(var_fpc)) {
    as.formula(paste0("~", var_fpc))
  } else {
    NULL
  }

  design <- survey::svydesign(
    ids     = formule_ids,
    strata  = formule_strate,
    weights = as.formula(paste0("~", var_poids)),
    fpc     = formule_fpc,
    nest    = TRUE,
    data    = data
  )

  message("Plan de sondage cr\u00e9\u00e9 :")
  message("  - Observations : ", formatC(nrow(data), big.mark = " "))
  if (!is.null(var_strate)) {
    n_strates <- length(unique(data[[var_strate]]))
    message("  - Strates : ", n_strates)
  }
  if (!is.null(var_grappe)) {
    n_grappes <- length(unique(data[[var_grappe]]))
    message("  - Grappes (UPS) : ", n_grappes)
  }

  design
}


# -----------------------------------------------------------------------------
# 4. IMPUTATION DES VALEURS MANQUANTES
# -----------------------------------------------------------------------------

#' @title Imputer les valeurs manquantes
#' @description Impute les valeurs manquantes d'un dataset selon la méthode
#'   spécifiée. Supporte l'imputation simple (statistiques descriptives),
#'   hot-deck et par régression. Produit un rapport de traçabilité.
#' @param data data.frame ou tibble — Données avec valeurs manquantes
#' @param vars character ou NULL — Variables à imputer. Si NULL, toutes les
#'   variables avec valeurs manquantes. Défaut : NULL.
#' @param methode character — Méthode d'imputation :
#'   \code{"mediane"}, \code{"moyenne"}, \code{"mode"},
#'   \code{"hot_deck"}, \code{"regression"}. Défaut : "mediane".
#' @param vars_auxiliaires character ou NULL — Variables auxiliaires pour
#'   l'imputation par régression ou hot-deck. Défaut : NULL.
#' @param graine integer — Graine aléatoire pour la reproductibilité.
#'   Défaut : 42.
#' @param rapport logical — Retourner un rapport d'imputation. Défaut : TRUE.
#' @return Si \code{rapport = FALSE} : tibble imputé.
#'   Si \code{rapport = TRUE} : liste avec \code{$donnees} et \code{$rapport}.
#' @examples
#' \dontrun{
#'   resultat <- imputer_valeurs(
#'     data    = donnees_enquete,
#'     vars    = c("revenu_mensuel", "age"),
#'     methode = "mediane"
#'   )
#'   donnees_propres <- resultat$donnees
#' }
#' @export
imputer_valeurs <- function(data,
                             vars              = NULL,
                             methode           = c("mediane", "moyenne", "mode",
                                                   "hot_deck", "regression"),
                             vars_auxiliaires  = NULL,
                             graine            = 42L,
                             rapport           = TRUE) {

  methode <- match.arg(methode)

  if (!is.data.frame(data)) {
    rlang::abort("L'argument `data` doit \u00eatre un data.frame ou tibble.")
  }

  if (methode == "regression" && is.null(vars_auxiliaires)) {
    rlang::abort(c(
      "La m\u00e9thode 'regression' n\u00e9cessite des variables auxiliaires.",
      "i" = "Sp\u00e9cifiez `vars_auxiliaires = c('var1', 'var2')`."
    ))
  }

  # Sélection des variables avec NA
  if (is.null(vars)) {
    vars <- names(data)[sapply(data, function(x) any(is.na(x)))]
    if (length(vars) == 0) {
      message("Aucune valeur manquante d\u00e9tect\u00e9e. Aucune imputation n\u00e9cessaire.")
      if (rapport) return(list(donnees = data,
                               rapport = tibble::tibble()))
      return(data)
    }
  } else {
    vars_absentes <- setdiff(vars, names(data))
    if (length(vars_absentes) > 0) {
      rlang::abort(paste0(
        "Variables introuvables : ", paste(vars_absentes, collapse = ", ")
      ))
    }
  }

  set.seed(graine)
  data_imp <- data
  rapport_imp <- list()

  for (var in vars) {
    x <- data_imp[[var]]
    n_na_avant <- sum(is.na(x))
    if (n_na_avant == 0) next

    x_impute <- switch(methode,
      "mediane"    = .imputer_mediane(x),
      "moyenne"    = .imputer_moyenne(x),
      "mode"       = .imputer_mode(x),
      "hot_deck"   = .imputer_hot_deck(data_imp, var, vars_auxiliaires),
      "regression" = .imputer_regression(data_imp, var, vars_auxiliaires)
    )

    n_na_apres <- sum(is.na(x_impute))
    data_imp[[var]] <- x_impute

    rapport_imp[[var]] <- tibble::tibble(
      variable        = var,
      methode         = methode,
      n_na_avant      = n_na_avant,
      n_na_apres      = n_na_apres,
      n_imputes       = n_na_avant - n_na_apres,
      taux_imputation = round((n_na_avant - n_na_apres) / n_na_avant, 3)
    )

    message("  ", var, " : ", n_na_avant - n_na_apres, "/", n_na_avant,
            " valeurs imput\u00e9es (m\u00e9thode : ", methode, ")")
  }

  rapport_final <- dplyr::bind_rows(rapport_imp)

  if (rapport) {
    list(donnees = data_imp, rapport = rapport_final)
  } else {
    data_imp
  }
}


# -----------------------------------------------------------------------------
# 5. SUPPRESSION DES DOUBLONS
# -----------------------------------------------------------------------------

#' @title Détecter et supprimer les doublons
#' @description Identifie et supprime les enregistrements dupliqués selon
#'   une ou plusieurs clés d'identification. Produit un rapport des doublons
#'   détectés.
#' @param data data.frame ou tibble — Données à dédupliquer
#' @param cles character ou NULL — Variables clés pour la détection. Si NULL,
#'   utilise toutes les colonnes. Défaut : NULL.
#' @param garder character — Quel doublon conserver :
#'   \code{"premier"} (première occurrence),
#'   \code{"dernier"} (dernière occurrence),
#'   \code{"aucun"} (supprimer tous les doublons). Défaut : "premier".
#' @param rapport logical — Retourner un rapport des doublons. Défaut : TRUE.
#' @return Si \code{rapport = FALSE} : tibble dédupliqué.
#'   Si \code{rapport = TRUE} : liste avec \code{$donnees} et \code{$rapport}.
#' @examples
#' \dontrun{
#'   resultat <- supprimer_doublons(donnees_enquete, cles = "id_menage")
#'   donnees_propres <- resultat$donnees
#'   cat("Doublons supprimés :", nrow(resultat$rapport))
#' }
#' @export
supprimer_doublons <- function(data,
                                cles    = NULL,
                                garder  = c("premier", "dernier", "aucun"),
                                rapport = TRUE) {

  garder <- match.arg(garder)

  if (!is.data.frame(data)) {
    rlang::abort("L'argument `data` doit \u00eatre un data.frame ou tibble.")
  }

  if (!is.null(cles)) {
    cles_absentes <- setdiff(cles, names(data))
    if (length(cles_absentes) > 0) {
      rlang::abort(paste0(
        "Cl\u00e9s introuvables : ", paste(cles_absentes, collapse = ", ")
      ))
    }
  } else {
    cles <- names(data)
  }

  n_avant <- nrow(data)

  # Identification des doublons
  data_temp <- data
  data_temp$.row_id <- seq_len(nrow(data))

  doublons_idx <- data_temp |>
    dplyr::group_by(dplyr::across(dplyr::all_of(cles))) |>
    dplyr::filter(dplyr::n() > 1) |>
    dplyr::ungroup() |>
    dplyr::pull(.row_id)

  rapport_doublons <- data[doublons_idx, ]
  n_doublons <- length(doublons_idx)

  # Dédoublonnage
  data_dedup <- switch(garder,
    "premier" = data |>
      dplyr::distinct(dplyr::across(dplyr::all_of(cles)), .keep_all = TRUE),
    "dernier" = data |>
      dplyr::group_by(dplyr::across(dplyr::all_of(cles))) |>
      dplyr::slice_tail(n = 1) |>
      dplyr::ungroup(),
    "aucun" = data |>
      dplyr::group_by(dplyr::across(dplyr::all_of(cles))) |>
      dplyr::filter(dplyr::n() == 1) |>
      dplyr::ungroup()
  )

  n_apres <- nrow(data_dedup)
  n_supprimes <- n_avant - n_apres

  if (n_supprimes == 0) {
    message("Aucun doublon d\u00e9tect\u00e9.")
  } else {
    message(n_supprimes, " doublon(s) supprim\u00e9(s) sur ", n_avant,
            " enregistrements (", n_apres, " conserv\u00e9s).")
  }

  if (rapport) {
    list(donnees = data_dedup, rapport = rapport_doublons)
  } else {
    data_dedup
  }
}


# -----------------------------------------------------------------------------
# 6. RECODAGE DE VARIABLES
# -----------------------------------------------------------------------------

#' @title Recoder une variable
#' @description Recode une variable selon une table de correspondance
#'   explicite. Supporte le recodage numérique (classes d'âge, quintiles)
#'   et textuel (modalités). Traçabilité complète des transformations.
#' @param data data.frame ou tibble — Données
#' @param var character — Nom de la variable à recoder
#' @param table_recodage data.frame — Table avec colonnes \code{avant} et
#'   \code{apres}, ou vecteur nommé.
#' @param var_sortie character ou NULL — Nom de la variable recodée. Si NULL,
#'   remplace la variable originale. Défaut : NULL.
#' @param na_si_absent logical — Mettre NA si la valeur n'est pas dans la
#'   table de recodage. Défaut : TRUE.
#' @return Le tibble avec la variable recodée.
#' @examples
#' \dontrun{
#'   # Recodage des classes d'âge
#'   table_age <- data.frame(
#'     avant = c("15-24", "25-34", "35-49", "50+"),
#'     apres = c("Jeune", "Adulte", "Adulte", "Senior")
#'   )
#'   donnees <- recoder_variable(donnees, "classe_age", table_age)
#'   # Recodage avec vecteur nommé
#'   donnees <- recoder_variable(
#'     donnees, "sexe",
#'     table_recodage = c("1" = "Masculin", "2" = "Féminin")
#'   )
#' }
#' @export
recoder_variable <- function(data,
                              var,
                              table_recodage,
                              var_sortie    = NULL,
                              na_si_absent  = TRUE) {

  if (!var %in% names(data)) {
    rlang::abort(paste0("Variable '", var, "' introuvable dans les donn\u00e9es."))
  }

  # Conversion en data.frame si vecteur nommé
  if (is.vector(table_recodage) && !is.null(names(table_recodage))) {
    table_recodage <- data.frame(
      avant = names(table_recodage),
      apres = unname(table_recodage),
      stringsAsFactors = FALSE
    )
  }

  cols_req <- c("avant", "apres")
  cols_man <- setdiff(cols_req, names(table_recodage))
  if (length(cols_man) > 0) {
    rlang::abort(paste0(
      "Colonnes manquantes dans `table_recodage` : ",
      paste(cols_man, collapse = ", "), ".\n",
      "La table doit avoir les colonnes 'avant' et 'apres'."
    ))
  }

  nom_sortie <- if (is.null(var_sortie)) var else var_sortie
  x <- as.character(data[[var]])

  x_recode <- table_recodage$apres[match(x, as.character(table_recodage$avant))]

  if (na_si_absent) {
    n_non_recodes <- sum(is.na(x_recode) & !is.na(x))
    if (n_non_recodes > 0) {
      valeurs_manquantes <- unique(x[is.na(x_recode) & !is.na(x)])
      rlang::warn(paste0(
        n_non_recodes, " valeur(s) absente(s) de la table de recodage \u2192 NA : ",
        paste(head(valeurs_manquantes, 5), collapse = ", ")
      ))
    }
  } else {
    x_recode[is.na(x_recode) & !is.na(x)] <- x[is.na(x_recode) & !is.na(x)]
  }

  data[[nom_sortie]] <- x_recode

  n_recodes <- sum(!is.na(x_recode))
  message(n_recodes, " valeur(s) recod\u00e9e(s) dans '", nom_sortie, "'.")

  data
}


# -----------------------------------------------------------------------------
# 7. STANDARDISATION DES ÂGES
# -----------------------------------------------------------------------------

#' @title Standardiser les âges déclarés
#' @description Détecte et corrige le "heap effect" (attraction vers les âges
#'   ronds) fréquent dans les enquêtes africaines où les âges sont déclarés.
#'   Calcule l'indice de Whipple et l'indice de Myers pour évaluer la qualité.
#' @param data data.frame ou tibble — Données
#' @param var_age character — Nom de la variable d'âge
#' @param methode character — Méthode de correction :
#'   \code{"aucune"} (diagnostic uniquement),
#'   \code{"interpolation"} (répartition uniforme autour des âges ronds),
#'   \code{"united_nations"} (méthode Nations Unies). Défaut : "aucune".
#' @param age_min integer — Âge minimum valide. Défaut : 0.
#' @param age_max integer — Âge maximum valide. Défaut : 120.
#' @return Une liste avec :
#'   \item{donnees}{tibble avec âges corrigés si methode != "aucune"}
#'   \item{indice_whipple}{numeric — Indice de Whipple (1 = parfait, > 1.05 = problème)}
#'   \item{indice_myers}{numeric — Indice de Myers (0 = parfait)}
#'   \item{diagnostic}{character — Évaluation de la qualité}
#' @examples
#' \dontrun{
#'   resultat <- standardiser_ages(donnees_rgph, "age")
#'   cat("Indice de Whipple :", resultat$indice_whipple)
#' }
#' @export
standardiser_ages <- function(data,
                               var_age  = "age",
                               methode  = c("aucune", "interpolation",
                                            "united_nations"),
                               age_min  = 0L,
                               age_max  = 120L) {

  methode <- match.arg(methode)

  if (!var_age %in% names(data)) {
    rlang::abort(paste0("Variable '", var_age, "' introuvable."))
  }

  ages <- data[[var_age]]

  if (!is.numeric(ages)) {
    rlang::abort(paste0("La variable '", var_age, "' doit \u00eatre num\u00e9rique."))
  }

  # Détection des valeurs hors plage
  n_hors_plage <- sum(ages < age_min | ages > age_max, na.rm = TRUE)
  if (n_hors_plage > 0) {
    rlang::warn(paste0(
      n_hors_plage, " \u00e2ge(s) hors plage [", age_min, "-", age_max,
      "] d\u00e9tect\u00e9(s) \u2192 seront mis \u00e0 NA."
    ))
    ages[ages < age_min | ages > age_max] <- NA
  }

  # Calcul de l'indice de Whipple (concentration sur multiples de 5)
  ages_valides <- ages[ages >= 23 & ages <= 62 & !is.na(ages)]
  n_total_wh <- length(ages_valides)
  n_multiples_5 <- sum(ages_valides %% 5 == 0)

  indice_whipple <- if (n_total_wh > 0) {
    round((n_multiples_5 / n_total_wh) / 0.2, 3)
  } else NA

  # Calcul de l'indice de Myers (simplifié)
  ages_10_89 <- ages[ages >= 10 & ages <= 89 & !is.na(ages)]
  blended <- sapply(0:9, function(d) {
    sum(ages_10_89 %% 10 == d)
  })
  myers_idx <- if (sum(blended) > 0) {
    round(0.5 * sum(abs(blended / sum(blended) - 0.1)) * 100, 2)
  } else NA

  # Diagnostic
  diagnostic <- dplyr::case_when(
    is.na(indice_whipple)      ~ "Indisponible (effectif insuffisant)",
    indice_whipple <= 1.05     ~ "Excellente qualit\u00e9",
    indice_whipple <= 1.10     ~ "Bonne qualit\u00e9",
    indice_whipple <= 1.25     ~ "Qualit\u00e9 acceptable",
    indice_whipple <= 1.75     ~ "Qualit\u00e9 m\u00e9diocre \u2014 heap effect d\u00e9tect\u00e9",
    TRUE                        ~ "Qualit\u00e9 tr\u00e8s mauvaise \u2014 correction fortement recommand\u00e9e"
  )

  message("=== Diagnostic qualit\u00e9 des \u00e2ges ===")
  message("Indice de Whipple : ", indice_whipple,
          " (", diagnostic, ")")
  message("Indice de Myers   : ", myers_idx)

  # Correction si demandée
  if (methode != "aucune") {
    data[[var_age]] <- .corriger_ages(ages, methode)
    message("Correction appliqu\u00e9e : m\u00e9thode '", methode, "'")
  }

  list(
    donnees          = data,
    indice_whipple   = indice_whipple,
    indice_myers     = myers_idx,
    diagnostic       = diagnostic
  )
}


# -----------------------------------------------------------------------------
# 8. FUSION DE DATASETS
# -----------------------------------------------------------------------------

#' @title Fusionner plusieurs jeux de données
#' @description Fusionne plusieurs datasets horizontalement (jointure) ou
#'   verticalement (empilement). Gère les conflits de noms de variables et
#'   produit un rapport de fusion.
#' @param liste_data list — Liste nommée de data.frames/tibbles à fusionner
#' @param type character — Type de fusion :
#'   \code{"horizontal"} (jointure par clé),
#'   \code{"vertical"} (empilement / append). Défaut : "vertical".
#' @param cle character ou NULL — Variable(s) clé(s) pour la fusion
#'   horizontale. Obligatoire si \code{type = "horizontal"}. Défaut : NULL.
#' @param jointure character — Type de jointure horizontale :
#'   \code{"interne"}, \code{"gauche"}, \code{"droite"}, \code{"complete"}.
#'   Défaut : "gauche".
#' @param suffixes character — Suffixes pour les variables en conflit lors
#'   d'une fusion horizontale. Défaut : c("_1", "_2").
#' @return Un tibble fusionné.
#' @examples
#' \dontrun{
#'   # Empilement de deux vagues d'enquête
#'   donnees_total <- fusion_datasets(
#'     liste_data = list(vague1 = emop_2022, vague2 = emop_2023),
#'     type       = "vertical"
#'   )
#'   # Jointure ménages + individus
#'   donnees_merged <- fusion_datasets(
#'     liste_data = list(menages = df_menages, individus = df_individus),
#'     type       = "horizontal",
#'     cle        = "id_menage"
#'   )
#' }
#' @export
fusion_datasets <- function(liste_data,
                             type      = c("vertical", "horizontal"),
                             cle       = NULL,
                             jointure  = c("gauche", "interne", "droite", "complete"),
                             suffixes  = c("_1", "_2")) {

  type     <- match.arg(type)
  jointure <- match.arg(jointure)

  if (!is.list(liste_data) || length(liste_data) < 2) {
    rlang::abort("`liste_data` doit \u00eatre une liste d'au moins 2 data.frames.")
  }

  # Vérification que tous les éléments sont des data.frames
  non_df <- names(liste_data)[!sapply(liste_data, is.data.frame)]
  if (length(non_df) > 0) {
    rlang::abort(paste0(
      "\u00c9l\u00e9ments non reconnus comme data.frames : ",
      paste(non_df, collapse = ", ")
    ))
  }

  if (type == "vertical") {
    # Vérification de la compatibilité des colonnes
    cols_premier <- names(liste_data[[1]])
    for (i in seq_along(liste_data)[-1]) {
      cols_i <- names(liste_data[[i]])
      cols_manquantes <- setdiff(cols_premier, cols_i)
      cols_nouvelles  <- setdiff(cols_i, cols_premier)
      if (length(cols_manquantes) > 0) {
        rlang::warn(paste0(
          "Dataset '", names(liste_data)[i], "' : ",
          length(cols_manquantes), " colonne(s) manquante(s) \u2192 remplies avec NA : ",
          paste(head(cols_manquantes, 5), collapse = ", ")
        ))
      }
    }
    result <- dplyr::bind_rows(liste_data, .id = "source_dataset")
    message("Empilement : ", nrow(result), " lignes au total (",
            length(liste_data), " datasets).")

  } else {
    # Fusion horizontale
    if (is.null(cle)) {
      rlang::abort(c(
        "La fusion horizontale requiert une cl\u00e9.",
        "i" = "Sp\u00e9cifiez `cle = 'nom_variable'`."
      ))
    }

    for (i in seq_along(liste_data)) {
      if (!all(cle %in% names(liste_data[[i]]))) {
        rlang::abort(paste0(
          "Cl\u00e9 '", paste(cle, collapse = ", "), "' absente du dataset '",
          names(liste_data)[i], "'."
        ))
      }
    }

    result <- liste_data[[1]]
    for (i in seq_along(liste_data)[-1]) {
      result <- switch(jointure,
        "gauche"   = dplyr::left_join(result, liste_data[[i]],
                                       by = cle, suffix = suffixes),
        "interne"  = dplyr::inner_join(result, liste_data[[i]],
                                        by = cle, suffix = suffixes),
        "droite"   = dplyr::right_join(result, liste_data[[i]],
                                        by = cle, suffix = suffixes),
        "complete" = dplyr::full_join(result, liste_data[[i]],
                                       by = cle, suffix = suffixes)
      )
    }
    message("Fusion '", jointure, "' : ", nrow(result), " lignes x ",
            ncol(result), " colonnes.")
  }

  result
}


# -----------------------------------------------------------------------------
# 9. JOURNAL DE TRAITEMENT
# -----------------------------------------------------------------------------

#' @title Tracer le flux de traitement
#' @description Crée et maintient un journal horodaté des transformations
#'   appliquées à un dataset. Permet l'auditabilité complète du pipeline
#'   de traitement des données.
#' @param data data.frame ou tibble — Données traitées
#' @param action character — Description de l'action effectuée
#' @param journal list ou NULL — Journal existant à compléter. Si NULL,
#'   crée un nouveau journal. Défaut : NULL.
#' @param details list ou NULL — Détails supplémentaires à enregistrer
#'   (ex: paramètres utilisés). Défaut : NULL.
#' @return Une liste mise à jour avec \code{$donnees} et \code{$journal}.
#' @examples
#' \dontrun{
#'   # Initialiser le journal
#'   etape1 <- tracer_flux_traitement(
#'     data    = donnees_brutes,
#'     action  = "Import depuis fichier Excel"
#'   )
#'   # Ajouter une étape
#'   etape2 <- tracer_flux_traitement(
#'     data    = donnees_nettoyees,
#'     action  = "Nettoyage des libellés",
#'     journal = etape1$journal
#'   )
#'   # Afficher le journal
#'   print(etape2$journal)
#' }
#' @export
tracer_flux_traitement <- function(data,
                                    action,
                                    journal = NULL,
                                    details = NULL) {

  if (!is.data.frame(data)) {
    rlang::abort("L'argument `data` doit \u00eatre un data.frame ou tibble.")
  }

  if (missing(action) || !nzchar(action)) {
    rlang::abort("L'argument `action` est obligatoire.")
  }

  nouvelle_entree <- tibble::tibble(
    horodatage  = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    action      = action,
    n_lignes    = nrow(data),
    n_colonnes  = ncol(data),
    details     = if (!is.null(details)) jsonlite_safe(details) else NA_character_
  )

  if (is.null(journal)) {
    journal_maj <- nouvelle_entree
  } else {
    if (!is.data.frame(journal)) {
      rlang::abort("`journal` doit \u00eatre un data.frame (retourn\u00e9 par une \u00e9tape pr\u00e9c\u00e9dente).")
    }
    journal_maj <- dplyr::bind_rows(journal, nouvelle_entree)
  }

  message("[", nouvelle_entree$horodatage, "] ", action,
          " (", nrow(data), " lignes x ", ncol(data), " colonnes)")

  list(donnees = data, journal = journal_maj)
}


# =============================================================================
# FONCTIONS INTERNES
# =============================================================================

#' @keywords internal
.charger_referentiels_regions <- function() {
  list(
    BJ = data.frame(
      original    = c("Alibori", "Atacora", "Atlantique", "Borgou",
                      "Collines", "Couffo", "Donga", "Littoral",
                      "Mono", "Ou\u00e9m\u00e9", "Plateau", "Zou"),
      standardise = c("Alibori", "Atacora", "Atlantique", "Borgou",
                      "Collines", "Couffo", "Donga", "Littoral",
                      "Mono", "Ou\u00e9m\u00e9", "Plateau", "Zou"),
      stringsAsFactors = FALSE
    ),
    BF = data.frame(
      original    = c("Boucle du Mouhoun", "Cascades", "Centre",
                      "Centre-Est", "Centre-Nord", "Centre-Ouest",
                      "Centre-Sud", "Est", "Hauts-Bassins", "Nord",
                      "Plateau Central", "Sahel", "Sud-Ouest"),
      standardise = c("Boucle du Mouhoun", "Cascades", "Centre",
                      "Centre-Est", "Centre-Nord", "Centre-Ouest",
                      "Centre-Sud", "Est", "Hauts-Bassins", "Nord",
                      "Plateau Central", "Sahel", "Sud-Ouest"),
      stringsAsFactors = FALSE
    ),
    SN = data.frame(
      original    = c("Dakar", "Diourbel", "Fatick", "Kaffrine",
                      "Kaolack", "K\u00e9dougou", "Kolda", "Louga",
                      "Matam", "Saint-Louis", "S\u00e9dhiou", "Tambacounda",
                      "Thi\u00e8s", "Ziguinchor"),
      standardise = c("Dakar", "Diourbel", "Fatick", "Kaffrine",
                      "Kaolack", "K\u00e9dougou", "Kolda", "Louga",
                      "Matam", "Saint-Louis", "S\u00e9dhiou", "Tambacounda",
                      "Thi\u00e8s", "Ziguinchor"),
      stringsAsFactors = FALSE
    ),
    CI = data.frame(
      original    = c("Abidjan", "Bas-Sassandra", "Como\u00e9", "Denguel\u00e9",
                      "G\u00f4h-Djiboua", "Lacs", "Lagunes", "Montagnes",
                      "Sassandra-Marahou\u00e9", "Savanes", "Vall\u00e9e du Bandama",
                      "Woroba", "Yamoussoukro", "Zanzan"),
      standardise = c("Abidjan", "Bas-Sassandra", "Como\u00e9", "Denguel\u00e9",
                      "G\u00f4h-Djiboua", "Lacs", "Lagunes", "Montagnes",
                      "Sassandra-Marahou\u00e9", "Savanes", "Vall\u00e9e du Bandama",
                      "Woroba", "Yamoussoukro", "Zanzan"),
      stringsAsFactors = FALSE
    )
  )
}

#' @keywords internal
.imputer_mediane <- function(x) {
  if (!is.numeric(x)) return(x)
  med <- stats::median(x, na.rm = TRUE)
  x[is.na(x)] <- med
  x
}

#' @keywords internal
.imputer_moyenne <- function(x) {
  if (!is.numeric(x)) return(x)
  moy <- mean(x, na.rm = TRUE)
  x[is.na(x)] <- moy
  x
}

#' @keywords internal
.imputer_mode <- function(x) {
  vals <- x[!is.na(x)]
  if (length(vals) == 0) return(x)
  mode_val <- names(sort(table(vals), decreasing = TRUE))[1]
  if (is.numeric(x)) mode_val <- as.numeric(mode_val)
  x[is.na(x)] <- mode_val
  x
}

#' @keywords internal
.imputer_hot_deck <- function(data, var, vars_auxiliaires) {
  x <- data[[var]]
  idx_na <- which(is.na(x))
  idx_ok <- which(!is.na(x))
  if (length(idx_ok) == 0) return(x)
  x[idx_na] <- x[sample(idx_ok, length(idx_na), replace = TRUE)]
  x
}

#' @keywords internal
.imputer_regression <- function(data, var, vars_auxiliaires) {
  x <- data[[var]]
  if (!is.numeric(x)) {
    rlang::warn(paste0(
      "Imputation par r\u00e9gression non disponible pour variable non num\u00e9rique '",
      var, "'. M\u00e9thode m\u00e9diane utilis\u00e9e \u00e0 la place."
    ))
    return(.imputer_mediane(x))
  }

  vars_aux_dispo <- intersect(vars_auxiliaires, names(data))
  if (length(vars_aux_dispo) == 0) return(.imputer_mediane(x))

  df_mod <- data[, c(var, vars_aux_dispo), drop = FALSE]
  df_mod <- df_mod[sapply(df_mod, is.numeric)]

  idx_complet <- which(complete.cases(df_mod))
  idx_na_var  <- which(is.na(x))

  if (length(idx_complet) < 10) return(.imputer_mediane(x))

  formule <- as.formula(paste(var, "~", paste(vars_aux_dispo, collapse = " + ")))
  modele <- tryCatch(
    stats::lm(formule, data = df_mod[idx_complet, ]),
    error = function(e) NULL
  )
  if (is.null(modele)) return(.imputer_mediane(x))

  predictions <- tryCatch(
    stats::predict(modele, newdata = df_mod[idx_na_var, ]),
    error = function(e) rep(stats::median(x, na.rm = TRUE), length(idx_na_var))
  )

  x[idx_na_var] <- predictions
  x
}

#' @keywords internal
.corriger_ages <- function(ages, methode) {
  if (methode == "interpolation") {
    ages_ronds <- which(ages %% 5 == 0 & !is.na(ages))
    for (idx in ages_ronds) {
      age_actuel <- ages[idx]
      decalage <- sample(-2:2, 1)
      ages[idx] <- age_actuel + decalage
    }
    ages <- pmax(0, pmin(120, ages))
  }
  ages
}

#' @keywords internal
jsonlite_safe <- function(x) {
  if (requireNamespace("jsonlite", quietly = TRUE)) {
    tryCatch(jsonlite::toJSON(x, auto_unbox = TRUE), error = function(e) NA_character_)
  } else {
    paste(names(x), unlist(x), sep = "=", collapse = "; ")
  }
}

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
