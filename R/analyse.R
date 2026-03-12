# =============================================================================
# statAfrikR \u2014 Module Analyse
# Fonctions d'analyse statistique, indicateurs et tableaux
# =============================================================================

# -----------------------------------------------------------------------------
# 1. STATISTIQUES DESCRIPTIVES
# -----------------------------------------------------------------------------

#' @title Statistiques descriptives pondérées
#' @description Calcule les statistiques descriptives complètes pour une ou
#'   plusieurs variables numériques, avec prise en compte optionnelle du plan
#'   de sondage complexe. Produit un tableau formaté prêt à publier.
#' @param data data.frame, tibble ou objet \code{svydesign} — Données source
#' @param vars character — Noms des variables à analyser
#' @param groupe character ou NULL — Variable de regroupement. Défaut : NULL.
#' @param ponderee logical — Utiliser les pondérations si data est un
#'   svydesign. Défaut : TRUE.
#' @param ic logical — Calculer les intervalles de confiance à 95%.
#'   Défaut : TRUE.
#' @param format_sortie character — Format : \code{"tibble"} ou
#'   \code{"flextable"}. Défaut : "tibble".
#' @return Tibble ou flextable avec : n, moyenne, médiane, écart-type,
#'   min, max, IC95.
#' @examples
#' \dontrun{
#'   # Sans pondération
#'   stat_descr(donnees, vars = c("age", "revenu"))
#'   # Avec plan de sondage
#'   plan <- appliquer_ponderations(donnees, "poids")
#'   stat_descr(plan, vars = "revenu", groupe = "region")
#' }
#' @export
stat_descr <- function(data,
                        vars,
                        groupe        = NULL,
                        ponderee      = TRUE,
                        ic            = TRUE,
                        format_sortie = c("tibble", "flextable")) {

  format_sortie <- match.arg(format_sortie)
  est_svydesign <- inherits(data, "survey.design")

  # Extraction des donn\u00e9es brutes si svydesign
  data_brute <- if (est_svydesign) data$variables else data

  # V\u00e9rification des variables
  vars_absentes <- setdiff(vars, names(data_brute))
  if (length(vars_absentes) > 0) {
    rlang::abort(paste0(
      "Variables introuvables : ", paste(vars_absentes, collapse = ", ")
    ))
  }

  vars_non_num <- vars[!sapply(data_brute[vars], is.numeric)]
  if (length(vars_non_num) > 0) {
    rlang::warn(paste0(
      "Variables non num\u00e9riques ignor\u00e9es : ",
      paste(vars_non_num, collapse = ", ")
    ))
    vars <- setdiff(vars, vars_non_num)
  }

  if (length(vars) == 0) {
    rlang::abort("Aucune variable num\u00e9rique valide \u00e0 analyser.")
  }

  resultats <- list()

  if (est_svydesign && ponderee) {
    .verifier_package("survey", "stat_descr")

    for (var in vars) {
      formule <- as.formula(paste0("~", var))

      if (!is.null(groupe)) {
        formule_groupe <- as.formula(paste0("~", groupe))
        moy  <- survey::svyby(formule, formule_groupe, data,
                               survey::svymean, na.rm = TRUE)
        tot  <- survey::svyby(formule, formule_groupe, data,
                               survey::svytotal, na.rm = TRUE)

        res <- tibble::tibble(
          variable = var,
          groupe   = moy[[groupe]],
          n        = as.integer(table(data$variables[[groupe]])),
          moyenne  = round(moy[[var]], 2),
          se       = round(moy[[paste0("se.", var)]], 4)
        )
        if (ic) {
          res$ic_bas <- round(res$moyenne - 1.96 * res$se, 2)
          res$ic_haut <- round(res$moyenne + 1.96 * res$se, 2)
        }
      } else {
        moy_val <- survey::svymean(formule, data, na.rm = TRUE)
        var_val <- survey::svyvar(formule, data, na.rm = TRUE)
        qt_val  <- survey::svyquantile(formule, data,
                                        quantiles = c(0.25, 0.5, 0.75),
                                        na.rm = TRUE)

        res <- tibble::tibble(
          variable   = var,
          n          = sum(!is.na(data$variables[[var]])),
          moyenne    = round(as.numeric(moy_val), 2),
          mediane    = round(as.numeric(qt_val[[1]][2]), 2),
          ecart_type = round(sqrt(as.numeric(var_val)), 2),
          q1         = round(as.numeric(qt_val[[1]][1]), 2),
          q3         = round(as.numeric(qt_val[[1]][3]), 2),
          min        = round(min(data$variables[[var]], na.rm = TRUE), 2),
          max        = round(max(data$variables[[var]], na.rm = TRUE), 2)
        )
        if (ic) {
          se_val <- as.numeric(sqrt(attr(moy_val, "var")))
          res$ic_bas  <- round(res$moyenne - 1.96 * se_val, 2)
          res$ic_haut <- round(res$moyenne + 1.96 * se_val, 2)
        }
      }
      resultats[[var]] <- res
    }
  } else {
    # Sans pond\u00e9ration
    for (var in vars) {
      x <- data_brute[[var]]

      if (!is.null(groupe)) {
        grp <- data_brute[[groupe]]
        res <- data_brute |>
          dplyr::group_by(dplyr::across(dplyr::all_of(groupe))) |>
          dplyr::summarise(
            variable   = var,
            n          = sum(!is.na(.data[[var]])),
            moyenne    = round(mean(.data[[var]], na.rm = TRUE), 2),
            mediane    = round(stats::median(.data[[var]], na.rm = TRUE), 2),
            ecart_type = round(stats::sd(.data[[var]], na.rm = TRUE), 2),
            min        = round(min(.data[[var]], na.rm = TRUE), 2),
            max        = round(max(.data[[var]], na.rm = TRUE), 2),
            .groups    = "drop"
          )
      } else {
        res <- tibble::tibble(
          variable   = var,
          n          = sum(!is.na(x)),
          moyenne    = round(mean(x, na.rm = TRUE), 2),
          mediane    = round(stats::median(x, na.rm = TRUE), 2),
          ecart_type = round(stats::sd(x, na.rm = TRUE), 2),
          q1         = round(stats::quantile(x, 0.25, na.rm = TRUE), 2),
          q3         = round(stats::quantile(x, 0.75, na.rm = TRUE), 2),
          min        = round(min(x, na.rm = TRUE), 2),
          max        = round(max(x, na.rm = TRUE), 2)
        )
        if (ic) {
          se_val     <- stats::sd(x, na.rm = TRUE) / sqrt(sum(!is.na(x)))
          res$ic_bas  <- round(res$moyenne - 1.96 * se_val, 2)
          res$ic_haut <- round(res$moyenne + 1.96 * se_val, 2)
        }
      }
      resultats[[var]] <- res
    }
  }

  tableau <- dplyr::bind_rows(resultats)

  if (format_sortie == "flextable") {
    .verifier_package("flextable", "stat_descr (format flextable)")
    return(.formater_flextable(tableau, titre = "Statistiques descriptives"))
  }

  tableau
}


# -----------------------------------------------------------------------------
# 2. TABLEAU CROIS\u00c9
# -----------------------------------------------------------------------------

#' @title Tableau croisé pondéré avec intervalles de confiance
#' @description Produit un tableau croisé (ou tableau de fréquences simple)
#'   avec prise en compte optionnelle de la pondération et du plan de sondage
#'   complexe. Résultat formaté pour publication directe.
#' @param data data.frame, tibble ou objet \code{svydesign} — Données source
#' @param var_ligne character — Variable en ligne
#' @param var_col character ou NULL — Variable en colonne. Si NULL, tableau
#'   de fréquences simple. Défaut : NULL.
#' @param var_poids character ou NULL — Variable de pondération (ignorée si
#'   data est un svydesign). Défaut : NULL.
#' @param ic logical — Calculer les IC à 95%. Défaut : TRUE.
#' @param pourcentage character — Type : \code{"colonne"}, \code{"ligne"},
#'   \code{"total"}. Défaut : "colonne".
#' @param format_sortie character — \code{"tibble"} ou \code{"flextable"}.
#'   Défaut : "flextable".
#' @return Tibble ou flextable du tableau croisé.
#' @examples
#' \dontrun{
#'   # Tableau simple
#'   tab_croisee(donnees, "region", "sexe")
#'   # Avec plan de sondage
#'   tab_croisee(plan_sondage, "quintile", "region")
#' }
#' @export
tab_croisee <- function(data,
                         var_ligne,
                         var_col       = NULL,
                         var_poids     = NULL,
                         ic            = TRUE,
                         pourcentage   = c("colonne", "ligne", "total"),
                         format_sortie = c("flextable", "tibble")) {

  pourcentage   <- match.arg(pourcentage)
  format_sortie <- match.arg(format_sortie)
  est_svydesign <- inherits(data, "survey.design")

  data_brute <- if (est_svydesign) data$variables else data

  # V\u00e9rifications
  if (!var_ligne %in% names(data_brute)) {
    rlang::abort(paste0("Variable en ligne introuvable : '", var_ligne, "'."))
  }
  if (!is.null(var_col) && !var_col %in% names(data_brute)) {
    rlang::abort(paste0("Variable en colonne introuvable : '", var_col, "'."))
  }

  if (est_svydesign) {
    .verifier_package("survey", "tab_croisee")

    if (is.null(var_col)) {
      formule <- as.formula(paste0("~", var_ligne))
      res_raw <- survey::svytable(formule, data)
      res_prop <- prop.table(res_raw)

      tableau <- tibble::tibble(
        modalite   = names(res_raw),
        effectif   = as.integer(res_raw),
        proportion = round(as.numeric(res_prop), 4),
        pourcentage = round(as.numeric(res_prop) * 100, 1)
      )
    } else {
      formule <- as.formula(paste0("~", var_ligne, "+", var_col))
      res_raw  <- survey::svytable(formule, data)
      res_prop <- switch(pourcentage,
        "colonne" = prop.table(res_raw, margin = 2),
        "ligne"   = prop.table(res_raw, margin = 1),
        "total"   = prop.table(res_raw)
      )

      tableau <- as.data.frame(res_prop) |>
        tibble::as_tibble() |>
        dplyr::rename(
          !!var_ligne := 1,
          !!var_col   := 2,
          proportion  = Freq
        ) |>
        dplyr::mutate(pourcentage = round(proportion * 100, 1))

      effectifs <- as.data.frame(res_raw) |>
        tibble::as_tibble() |>
        dplyr::rename(
          !!var_ligne := 1,
          !!var_col   := 2,
          effectif    = Freq
        )

      tableau <- dplyr::left_join(tableau, effectifs,
                                   by = c(var_ligne, var_col))
    }
  } else {
    # Sans plan de sondage
    if (!is.null(var_poids) && var_poids %in% names(data_brute)) {
      poids <- data_brute[[var_poids]]
    } else {
      poids <- rep(1, nrow(data_brute))
    }

    if (is.null(var_col)) {
      tableau <- data_brute |>
        dplyr::group_by(dplyr::across(dplyr::all_of(var_ligne))) |>
        dplyr::summarise(
          effectif    = dplyr::n(),
          .groups     = "drop"
        ) |>
        dplyr::mutate(
          proportion  = round(effectif / sum(effectif), 4),
          pourcentage = round(proportion * 100, 1)
        )
    } else {
      tableau <- data_brute |>
        dplyr::filter(!is.na(.data[[var_ligne]]),
                      !is.na(.data[[var_col]])) |>
        dplyr::group_by(dplyr::across(dplyr::all_of(c(var_ligne, var_col)))) |>
        dplyr::summarise(effectif = dplyr::n(), .groups = "drop")

      tableau <- tableau |>
        dplyr::group_by(dplyr::across(dplyr::all_of(
          switch(pourcentage,
            "colonne" = var_col,
            "ligne"   = var_ligne,
            "total"   = NULL
          )
        ))) |>
        dplyr::mutate(
          total_groupe = sum(effectif),
          proportion   = round(effectif / total_groupe, 4),
          pourcentage  = round(proportion * 100, 1)
        ) |>
        dplyr::ungroup() |>
        dplyr::select(-total_groupe)
    }
  }

  if (format_sortie == "flextable") {
    .verifier_package("flextable", "tab_croisee (format flextable)")
    return(.formater_flextable(tableau,
                                titre = paste0("Tableau crois\u00e9 : ",
                                               var_ligne,
                                               if (!is.null(var_col))
                                                 paste0(" \u00d7 ", var_col))))
  }

  tableau
}


# -----------------------------------------------------------------------------
# 3. R\u00c9GRESSION
# -----------------------------------------------------------------------------

#' @title Analyse de régression
#' @description Ajuste un modèle de régression linéaire, logistique ou de
#'   Poisson avec prise en compte optionnelle du plan de sondage complexe.
#'   Produit un tableau de résultats formaté avec OR/RR si approprié.
#' @param formule formula — Formule du modèle (ex: \code{revenu ~ age + sexe})
#' @param data data.frame, tibble ou objet \code{svydesign} — Données
#' @param type character — Type de modèle : \code{"lineaire"},
#'   \code{"logistique"}, \code{"poisson"}. Défaut : "lineaire".
#' @param niveau_confiance numeric — Niveau de confiance pour les IC.
#'   Défaut : 0.95.
#' @param format_sortie character — \code{"liste"}, \code{"tibble"} ou
#'   \code{"flextable"}. Défaut : "tibble".
#' @return Selon format_sortie : liste complète, tibble ou flextable des
#'   coefficients avec IC et p-valeurs.
#' @examples
#' \dontrun{
#'   # Régression linéaire simple
#'   analyse_regression(revenu ~ age + sexe, donnees)
#'   # Régression logistique avec plan de sondage
#'   analyse_regression(pauvre ~ age + region + sexe, plan,
#'                      type = "logistique")
#' }
#' @export
analyse_regression <- function(formule,
                                data,
                                type             = c("lineaire", "logistique",
                                                     "poisson"),
                                niveau_confiance = 0.95,
                                format_sortie    = c("tibble", "liste",
                                                     "flextable")) {

  type          <- match.arg(type)
  format_sortie <- match.arg(format_sortie)
  est_svydesign <- inherits(data, "survey.design")

  if (est_svydesign) {
    .verifier_package("survey", "analyse_regression")

    modele <- switch(type,
      "lineaire"   = survey::svyglm(formule, design = data,
                                    family = stats::gaussian()),,
      "logistique" = survey::svyglm(formule, design = data,
                                     family = stats::quasibinomial()),
      "poisson"    = survey::svyglm(formule, design = data,
                                     family = stats::quasipoisson())
    )
  } else {
    data_brute <- if (is.data.frame(data)) data else data$variables
    modele <- switch(type,
      "lineaire"   = stats::lm(formule, data = data_brute),
      "logistique" = stats::glm(formule, data = data_brute,
                                 family = stats::binomial()),
      "poisson"    = stats::glm(formule, data = data_brute,
                                 family = stats::poisson())
    )
  }

  # Construction du tableau de r\u00e9sultats
  coefs   <- stats::coef(modele)
  ic_vals <- tryCatch(
    stats::confint(modele, level = niveau_confiance),
    error = function(e) {
      se <- sqrt(diag(stats::vcov(modele)))
      z  <- stats::qnorm((1 + niveau_confiance) / 2)
      cbind(coefs - z * se, coefs + z * se)
    }
  )

  p_vals <- tryCatch(
    summary(modele)$coefficients[, 4],
    error = function(e) rep(NA_real_, length(coefs))
  )

  tableau <- tibble::tibble(
    terme      = names(coefs),
    estimateur = round(coefs, 4),
    ic_bas     = round(ic_vals[, 1], 4),
    ic_haut    = round(ic_vals[, 2], 4),
    p_valeur   = round(p_vals, 4),
    significatif = dplyr::case_when(
      p_vals < 0.001 ~ "***",
      p_vals < 0.01  ~ "**",
      p_vals < 0.05  ~ "*",
      p_vals < 0.1   ~ ".",
      TRUE           ~ ""
    )
  )

  # Ajout OR/RR pour mod\u00e8les log-lin\u00e9aires
  if (type %in% c("logistique", "poisson")) {
    tableau$odds_ratio <- round(exp(tableau$estimateur), 3)
    tableau$or_ic_bas  <- round(exp(tableau$ic_bas), 3)
    tableau$or_ic_haut <- round(exp(tableau$ic_haut), 3)
  }

  # Statistiques globales du mod\u00e8le
  if (type == "lineaire") {
    r2 <- tryCatch(summary(modele)$r.squared, error = function(e) NA)
    if (!is.null(r2) && is.numeric(r2)) {
      message("R\u00b2 = ", round(r2, 4))
    }
  }

  if (format_sortie == "liste") {
    return(list(
      modele   = modele,
      tableau  = tableau,
      type     = type,
      formule  = formule
    ))
  }

  if (format_sortie == "flextable") {
    .verifier_package("flextable", "analyse_regression")
    return(.formater_flextable(tableau, titre = paste0("R\u00e9gression ",
                                                        type)))
  }

  tableau
}


# -----------------------------------------------------------------------------
# 4. ANALYSE SPATIALE
# -----------------------------------------------------------------------------

#' @title Analyse spatiale — jointure et indicateurs par zone
#' @description Joint un jeu de données statistiques avec un shapefile
#'   géographique et calcule des indicateurs par aire géographique.
#'   Produit un objet sf enrichi prêt pour la cartographie.
#' @param data data.frame ou tibble — Données avec variable géographique
#' @param shapefile sf ou character — Objet sf ou chemin vers un fichier
#'   shapefile (.shp, .gpkg, .geojson)
#' @param var_geo_data character — Variable géographique dans \code{data}
#' @param var_geo_shape character — Variable géographique dans le shapefile
#' @param indicateurs character ou NULL — Variables à agréger par zone.
#'   Si NULL, toutes les variables numériques. Défaut : NULL.
#' @param fonctions list — Fonctions d'agrégation nommées.
#'   Défaut : \code{list(moyenne = mean, n = length)}.
#' @return Un objet \code{sf} avec les indicateurs calculés par zone.
#' @examples
#' \dontrun{
#'   carte <- analyse_spatiale(
#'     data          = donnees_enquete,
#'     shapefile     = "data/shapefiles/regions.shp",
#'     var_geo_data  = "region",
#'     var_geo_shape = "NOM_REGION",
#'     indicateurs   = c("taux_pauvrete", "revenu_moyen")
#'   )
#' }
#' @export
analyse_spatiale <- function(data,
                              shapefile,
                              var_geo_data,
                              var_geo_shape,
                              indicateurs = NULL,
                              fonctions   = list(
                                moyenne = function(x) mean(x, na.rm = TRUE),
                                n       = function(x) sum(!is.na(x))
                              )) {

  .verifier_package("sf", "analyse_spatiale")

  if (!var_geo_data %in% names(data)) {
    rlang::abort(paste0("Variable g\u00e9ographique introuvable dans data : '",
                        var_geo_data, "'."))
  }

  # Chargement du shapefile si chemin fourni
  if (is.character(shapefile)) {
    if (!file.exists(shapefile)) {
      rlang::abort(paste0("Shapefile introuvable : '", shapefile, "'."))
    }
    shapefile <- sf::st_read(shapefile, quiet = TRUE)
    message("Shapefile charg\u00e9 : ", nrow(shapefile), " entit\u00e9s g\u00e9ographiques.")
  }

  if (!inherits(shapefile, "sf")) {
    rlang::abort("`shapefile` doit \u00eatre un objet sf ou un chemin vers un fichier spatial.")
  }

  if (!var_geo_shape %in% names(shapefile)) {
    rlang::abort(paste0(
      "Variable g\u00e9ographique introuvable dans le shapefile : '",
      var_geo_shape, "'.\n",
      "Variables disponibles : ",
      paste(names(shapefile)[names(shapefile) != "geometry"],
            collapse = ", ")
    ))
  }

  # S\u00e9lection des indicateurs
  if (is.null(indicateurs)) {
    indicateurs <- names(data)[sapply(data, is.numeric)]
    indicateurs <- setdiff(indicateurs, var_geo_data)
  }

  # Agr\u00e9gation par zone g\u00e9ographique
  data_agregee <- data |>
    dplyr::group_by(dplyr::across(dplyr::all_of(var_geo_data))) |>
    dplyr::summarise(
      dplyr::across(
        dplyr::all_of(indicateurs),
        .fns    = fonctions,
        .names  = "{.col}_{.fn}"
      ),
      .groups = "drop"
    )

  # Jointure avec le shapefile
  shapefile_enrichi <- shapefile |>
    dplyr::left_join(
      data_agregee,
      by = stats::setNames(var_geo_data, var_geo_shape)
    )

  # Rapport des non-appari\u00e9s
  zones_data  <- unique(data[[var_geo_data]])
  zones_shape <- unique(shapefile[[var_geo_shape]])
  non_apparies <- setdiff(zones_data, zones_shape)

  if (length(non_apparies) > 0) {
    rlang::warn(paste0(
      length(non_apparies), " zone(s) de data non appari\u00e9e(s) : ",
      paste(head(non_apparies, 5), collapse = ", ")
    ))
  }

  message("Jointure spatiale : ", sum(!is.na(shapefile_enrichi[[
    paste0(indicateurs[1], "_moyenne")]])),
    "/", nrow(shapefile_enrichi), " zones enrichies.")

  shapefile_enrichi
}


# -----------------------------------------------------------------------------
# 5. CALCUL DE L'IDH
# -----------------------------------------------------------------------------

#' @title Calculer l'Indice de Développement Humain (IDH)
#' @description Calcule l'IDH et ses trois dimensions (santé, éducation,
#'   revenu) selon la méthodologie officielle PNUD post-2010. Applicable
#'   au niveau national ou infranational.
#' @param esperance_vie numeric — Espérance de vie à la naissance (années)
#' @param annees_scol_moy numeric — Durée moyenne de scolarisation (années)
#' @param annees_scol_att numeric — Durée attendue de scolarisation (années)
#' @param rnb_habitant numeric — RNB par habitant en PPA (USD constants 2017)
#' @param niveau character — \code{"national"} ou \code{"infranational"}.
#'   Défaut : "national".
#' @param annee integer ou NULL — Année de référence. Défaut : NULL.
#' @return Une liste avec : \code{idh}, \code{indice_sante},
#'   \code{indice_education}, \code{indice_revenu}, \code{categorie}.
#' @references
#' PNUD (2023). Technical Notes: Calculating the Human Development Indices.
#' @examples
#' \dontrun{
#'   idh <- calcul_idh(
#'     esperance_vie   = 61.2,
#'     annees_scol_moy = 5.4,
#'     annees_scol_att = 9.8,
#'     rnb_habitant    = 2350,
#'     annee           = 2023
#'   )
#'   cat("IDH :", idh$idh, "—", idh$categorie)
#' }
#' @export
calcul_idh <- function(esperance_vie,
                        annees_scol_moy,
                        annees_scol_att,
                        rnb_habitant,
                        niveau = c("national", "infranational"),
                        annee  = NULL) {

  niveau <- match.arg(niveau)

  # Bornes officielles PNUD
  bornes <- list(
    ev_min        = 20,   ev_max        = 85,
    scol_moy_min  = 0,    scol_moy_max  = 15,
    scol_att_min  = 0,    scol_att_max  = 18,
    rnb_min       = 100,  rnb_max       = 75000
  )

  # Validation
  .valider_borne(esperance_vie,  bornes$ev_min,       bornes$ev_max,
                 "Esp\u00e9rance de vie", "ans")
  .valider_borne(annees_scol_moy, bornes$scol_moy_min, bornes$scol_moy_max,
                 "Dur\u00e9e moyenne de scolarisation", "ans")
  .valider_borne(annees_scol_att, bornes$scol_att_min, bornes$scol_att_max,
                 "Dur\u00e9e attendue de scolarisation", "ans")
  .valider_borne(rnb_habitant,   bornes$rnb_min,      bornes$rnb_max,
                 "RNB par habitant", "USD")

  # Calcul des indices composantes
  indice_sante <- (esperance_vie - bornes$ev_min) /
    (bornes$ev_max - bornes$ev_min)

  indice_education <- (
    (annees_scol_moy  - bornes$scol_moy_min) /
      (bornes$scol_moy_max - bornes$scol_moy_min) +
      (annees_scol_att - bornes$scol_att_min) /
      (bornes$scol_att_max - bornes$scol_att_min)
  ) / 2

  indice_revenu <- (log(rnb_habitant) - log(bornes$rnb_min)) /
    (log(bornes$rnb_max) - log(bornes$rnb_min))

  # \u00c9cr\u00eatage entre 0 et 1
  indice_sante      <- max(0, min(1, indice_sante))
  indice_education  <- max(0, min(1, indice_education))
  indice_revenu     <- max(0, min(1, indice_revenu))

  # IDH = moyenne g\u00e9om\u00e9trique des 3 indices
  idh <- (indice_sante * indice_education * indice_revenu) ^ (1/3)
  idh <- round(idh, 3)

  # Cat\u00e9gorie PNUD
  categorie <- dplyr::case_when(
    idh >= 0.800 ~ "Tr\u00e8s \u00e9lev\u00e9",
    idh >= 0.700 ~ "\u00c9lev\u00e9",
    idh >= 0.550 ~ "Moyen",
    TRUE         ~ "Faible"
  )

  if (!is.null(annee)) message("IDH ", annee, " : ", idh, " (", categorie, ")")

  list(
    idh               = idh,
    indice_sante      = round(indice_sante, 4),
    indice_education  = round(indice_education, 4),
    indice_revenu     = round(indice_revenu, 4),
    categorie         = categorie,
    annee             = annee,
    inputs = list(
      esperance_vie   = esperance_vie,
      annees_scol_moy = annees_scol_moy,
      annees_scol_att = annees_scol_att,
      rnb_habitant    = rnb_habitant
    )
  )
}


# -----------------------------------------------------------------------------
# 6. CALCUL DE L'IPM
# -----------------------------------------------------------------------------

#' @title Calculer l'Indice de Pauvreté Multidimensionnelle (IPM)
#' @description Calcule l'IPM selon la méthodologie OPHI/PNUD (Alkire-Foster).
#'   Supporte les dimensions standard (santé, éducation, niveau de vie) et
#'   des dimensions personnalisées.
#' @param data data.frame ou tibble — Données individuelles ou ménages
#' @param indicateurs list — Liste nommée des indicateurs par dimension.
#'   Chaque élément est un vecteur de noms de variables (0/1 : 1 = privation).
#'   Ex: \code{list(sante = c("malnutrition", "mortalite_enfant"), ...)}
#' @param poids_dimensions numeric ou NULL — Poids de chaque dimension
#'   (doit sommer à 1). Si NULL, poids égaux. Défaut : NULL.
#' @param seuil_pauvrete numeric — Seuil de privation pour être considéré
#'   multidimensionnellement pauvre (entre 0 et 1). Défaut : 1/3.
#' @param var_poids character ou NULL — Variable de pondération.
#'   Défaut : NULL.
#' @return Une liste avec : \code{ipm}, \code{H} (incidence),
#'   \code{A} (intensité), \code{contributions} par dimension,
#'   \code{donnees_enrichies}.
#' @references
#' Alkire, S. & Foster, J. (2011). Counting and multidimensional poverty
#' measurement. Journal of Public Economics, 95(7-8), 476-487.
#' @examples
#' \dontrun{
#'   indicateurs_ipm <- list(
#'     sante     = c("malnutrition", "mortalite_enfant"),
#'     education = c("annees_scolarisation", "enfants_scolarises"),
#'     niveau_vie = c("electricite", "eau_potable", "assainissement",
#'                    "combustible", "actifs", "logement")
#'   )
#'   resultat <- calcul_ipm(donnees_menages, indicateurs_ipm)
#'   cat("IPM :", resultat$ipm)
#' }
#' @export
calcul_ipm <- function(data,
                        indicateurs,
                        poids_dimensions = NULL,
                        seuil_pauvrete   = 1/3,
                        var_poids        = NULL) {

  if (!is.list(indicateurs) || length(indicateurs) == 0) {
    rlang::abort("`indicateurs` doit \u00eatre une liste nomm\u00e9e non vide.")
  }

  if (seuil_pauvrete <= 0 || seuil_pauvrete >= 1) {
    rlang::abort("`seuil_pauvrete` doit \u00eatre entre 0 et 1 (exclu).")
  }

  n_dimensions <- length(indicateurs)
  noms_dim     <- names(indicateurs)

  # Poids par d\u00e9faut : \u00e9gaux
  if (is.null(poids_dimensions)) {
    poids_dimensions <- rep(1 / n_dimensions, n_dimensions)
  } else {
    if (length(poids_dimensions) != n_dimensions) {
      rlang::abort(paste0(
        "Le vecteur `poids_dimensions` doit avoir ", n_dimensions,
        " \u00e9l\u00e9ments (un par dimension)."
      ))
    }
    if (abs(sum(poids_dimensions) - 1) > 1e-6) {
      rlang::warn(paste0(
        "La somme des poids (", round(sum(poids_dimensions), 4),
        ") \u2260 1. Normalisation automatique."
      ))
      poids_dimensions <- poids_dimensions / sum(poids_dimensions)
    }
  }

  # V\u00e9rification des indicateurs
  tous_indicateurs <- unlist(indicateurs)
  indicateurs_absents <- setdiff(tous_indicateurs, names(data))
  if (length(indicateurs_absents) > 0) {
    rlang::abort(paste0(
      "Indicateurs introuvables dans les donn\u00e9es : ",
      paste(indicateurs_absents, collapse = ", ")
    ))
  }

  # Poids par indicateur (pond\u00e9ration \u00e9quitable au sein de chaque dimension)
  poids_indicateurs <- numeric(length(tous_indicateurs))
  names(poids_indicateurs) <- tous_indicateurs

  for (i in seq_along(indicateurs)) {
    n_ind_dim <- length(indicateurs[[i]])
    for (ind in indicateurs[[i]]) {
      poids_indicateurs[ind] <- poids_dimensions[i] / n_ind_dim
    }
  }

  # Score de privation pond\u00e9r\u00e9 par individu
  data_priv <- data[, tous_indicateurs, drop = FALSE]

  # Conversion en num\u00e9rique si n\u00e9cessaire
  data_priv <- data.frame(lapply(data_priv, function(x) {
    if (is.logical(x)) as.integer(x) else as.numeric(x)
  }))

  # V\u00e9rification valeurs 0/1
  vals_invalides <- sapply(data_priv, function(x) {
    any(!x %in% c(0, 1, NA))
  })
  if (any(vals_invalides)) {
    rlang::warn(paste0(
      "Certains indicateurs ont des valeurs autres que 0/1 : ",
      paste(names(vals_invalides)[vals_invalides], collapse = ", "),
      ". Ils seront trait\u00e9s comme : \u2265 0.5 = privation."
    ))
    data_priv <- data.frame(lapply(data_priv, function(x) {
      as.integer(x >= 0.5)
    }))
  }

  # Score de privation pond\u00e9r\u00e9
  score_prive <- as.matrix(data_priv) %*% poids_indicateurs

  # Identification des pauvres multidimensionnels
  est_pauvre <- score_prive >= seuil_pauvrete

  # Calcul des indicateurs IPM
  poids_pop <- if (!is.null(var_poids) && var_poids %in% names(data)) {
    data[[var_poids]] / sum(data[[var_poids]], na.rm = TRUE)
  } else {
    rep(1 / nrow(data), nrow(data))
  }

  H <- sum(est_pauvre * poids_pop, na.rm = TRUE)  # Incidence
  A <- if (H > 0) {
    sum(score_prive[est_pauvre] * poids_pop[est_pauvre], na.rm = TRUE) / H
  } else 0  # Intensit\u00e9
  ipm <- H * A  # IPM = H \u00d7 A

  # Contributions par dimension
  contributions <- sapply(seq_along(indicateurs), function(i) {
    vars_dim   <- indicateurs[[i]]
    score_dim  <- rowSums(as.matrix(data_priv[, vars_dim, drop = FALSE]) *
                            poids_indicateurs[vars_dim])
    contrib_censuree <- sum(score_dim[est_pauvre] * poids_pop[est_pauvre],
                             na.rm = TRUE)
    round(contrib_censuree / max(ipm, 1e-10) * 100, 2)
  })
  names(contributions) <- noms_dim

  # Enrichissement des donn\u00e9es
  data_enrichie <- data
  data_enrichie$.score_privation  <- round(as.numeric(score_prive), 4)
  data_enrichie$.est_pauvre_multi <- as.logical(est_pauvre)

  message("=== R\u00e9sultats IPM ===")
  message("IPM   : ", round(ipm, 4))
  message("H (incidence) : ", scales::percent(H, accuracy = 0.1))
  message("A (intensit\u00e9) : ", scales::percent(A, accuracy = 0.1))
  message("Contributions par dimension :")
  for (dim in noms_dim) {
    message("  ", dim, " : ", contributions[dim], "%")
  }

  list(
    ipm              = round(ipm, 4),
    H                = round(H, 4),
    A                = round(A, 4),
    contributions    = contributions,
    seuil_pauvrete   = seuil_pauvrete,
    n_pauvres        = sum(est_pauvre, na.rm = TRUE),
    n_total          = nrow(data),
    donnees_enrichies = data_enrichie
  )
}


# -----------------------------------------------------------------------------
# 7. MESURES D'IN\u00c9GALIT\u00c9
# -----------------------------------------------------------------------------

#' @title Décomposer les inégalités
#' @description Calcule les mesures d'inégalité (Gini, Theil, Atkinson) et
#'   leur décomposition inter/intra-groupe pour une variable de revenu ou
#'   de dépense.
#' @param data data.frame ou tibble — Données
#' @param var_revenu character — Variable de revenu/dépense (strictement
#'   positive)
#' @param var_groupe character ou NULL — Variable de groupe pour la
#'   décomposition. Défaut : NULL.
#' @param var_poids character ou NULL — Variable de pondération.
#'   Défaut : NULL.
#' @param mesures character — Mesures à calculer :
#'   \code{"gini"}, \code{"theil"}, \code{"atkinson"}, \code{"all"}.
#'   Défaut : "all".
#' @return Une liste avec les mesures d'inégalité et leur décomposition.
#' @examples
#' \dontrun{
#'   inegalites <- decomposer_inegalite(
#'     donnees_menages,
#'     var_revenu = "depense_totale",
#'     var_groupe = "milieu"
#'   )
#' }
#' @export
decomposer_inegalite <- function(data,
                                  var_revenu,
                                  var_groupe = NULL,
                                  var_poids  = NULL,
                                  mesures    = c("all", "gini", "theil",
                                                 "atkinson")) {

  mesures <- match.arg(mesures)

  if (!var_revenu %in% names(data)) {
    rlang::abort(paste0("Variable '", var_revenu, "' introuvable."))
  }

  x <- data[[var_revenu]]

  if (!is.numeric(x)) {
    rlang::abort(paste0("La variable '", var_revenu, "' doit \u00eatre num\u00e9rique."))
  }

  if (any(x <= 0, na.rm = TRUE)) {
    n_negatif <- sum(x <= 0, na.rm = TRUE)
    rlang::warn(paste0(
      n_negatif, " valeur(s) \u2264 0 dans '", var_revenu,
      "' \u2192 exclues du calcul."
    ))
    idx_valide <- !is.na(x) & x > 0
    x <- x[idx_valide]
    data <- data[idx_valide, ]
  }

  poids <- if (!is.null(var_poids) && var_poids %in% names(data)) {
    data[[var_poids]]
  } else {
    rep(1, length(x))
  }

  # Indice de Gini pond\u00e9r\u00e9
  gini_val <- .calcul_gini(x, poids)

  # Indice de Theil T
  theil_val <- .calcul_theil(x, poids)

  # Indice d'Atkinson (epsilon = 1)
  atkinson_val <- .calcul_atkinson(x, poids, epsilon = 1)

  resultats <- list(
    gini     = round(gini_val, 4),
    theil    = round(theil_val, 4),
    atkinson = round(atkinson_val, 4)
  )

  # D\u00e9composition par groupe
  if (!is.null(var_groupe) && var_groupe %in% names(data)) {
    groupes <- unique(data[[var_groupe]])
    decomp <- lapply(groupes, function(g) {
      idx <- data[[var_groupe]] == g & !is.na(data[[var_groupe]])
      x_g <- x[idx]
      p_g <- poids[idx]
      tibble::tibble(
        groupe       = g,
        n            = length(x_g),
        moyenne      = round(weighted.mean(x_g, p_g, na.rm = TRUE), 2),
        gini_interne = round(.calcul_gini(x_g, p_g), 4),
        part_pop     = round(sum(p_g) / sum(poids), 4),
        part_revenu  = round(sum(x_g * p_g) / sum(x * poids), 4)
      )
    })
    resultats$decomposition <- dplyr::bind_rows(decomp)
  }

  message("=== Mesures d'in\u00e9galit\u00e9 ===")
  message("Gini     : ", resultats$gini)
  message("Theil T  : ", resultats$theil)
  message("Atkinson : ", resultats$atkinson)

  resultats
}


# -----------------------------------------------------------------------------
# 8. SCORE DE QUALIT\u00c9 DES DONN\u00c9ES
# -----------------------------------------------------------------------------

#' @title Valider la qualité globale d'un jeu de données
#' @description Calcule un score de qualité composite (0-100) en évaluant
#'   la complétude, la cohérence, l'unicité et la plausibilité des données.
#' @param data data.frame ou tibble — Données à évaluer
#' @param seuil_na numeric — Seuil acceptable de valeurs manquantes.
#'   Défaut : 0.1.
#' @param vars_cles character ou NULL — Variables clés pour le test d'unicité.
#'   Défaut : NULL.
#' @return Une liste avec \code{score_global} et le détail par dimension.
#' @examples
#' \dontrun{
#'   qualite <- valider_qualite_donnees(donnees_enquete, vars_cles = "id_menage")
#'   cat("Score de qualité :", qualite$score_global, "/100")
#' }
#' @export
valider_qualite_donnees <- function(data,
                                     seuil_na  = 0.1,
                                     vars_cles = NULL) {

  if (!is.data.frame(data)) {
    rlang::abort("L'argument `data` doit \u00eatre un data.frame ou tibble.")
  }

  scores <- list()

  # 1. Compl\u00e9tude
  taux_na_global <- mean(is.na(data))
  scores$completude <- round(max(0, (1 - taux_na_global / seuil_na) * 25), 1)
  scores$completude <- min(25, scores$completude)

  # 2. Unicit\u00e9
  if (!is.null(vars_cles)) {
    vars_cles_dispo <- intersect(vars_cles, names(data))
    if (length(vars_cles_dispo) > 0) {
      n_uniques <- nrow(dplyr::distinct(data[, vars_cles_dispo, drop = FALSE]))
      taux_unicite <- n_uniques / nrow(data)
      scores$unicite <- round(taux_unicite * 25, 1)
    } else {
      scores$unicite <- 25
    }
  } else {
    n_uniques <- nrow(dplyr::distinct(data))
    scores$unicite <- round(n_uniques / nrow(data) * 25, 1)
  }

  # 3. Coh\u00e9rence des types
  n_vars <- ncol(data)
  n_coherents <- sum(sapply(data, function(x) {
    if (is.character(x)) {
      vals_sans_na <- x[!is.na(x)]
      if (length(vals_sans_na) == 0) return(TRUE)
      mean(suppressWarnings(!is.na(as.numeric(vals_sans_na)))) < 0.9
    } else TRUE
  }))
  scores$coherence <- round(n_coherents / n_vars * 25, 1)

  # 4. Plausibilit\u00e9 (valeurs hors plage)
  vars_num <- names(data)[sapply(data, is.numeric)]
  if (length(vars_num) > 0) {
    n_plausibles <- sum(sapply(data[vars_num], function(x) {
      vals <- x[!is.na(x)]
      if (length(vals) == 0) return(TRUE)
      q1 <- stats::quantile(vals, 0.01)
      q99 <- stats::quantile(vals, 0.99)
      mean(vals >= q1 & vals <= q99) >= 0.95
    }))
    scores$plausibilite <- round(n_plausibles / length(vars_num) * 25, 1)
  } else {
    scores$plausibilite <- 25
  }

  score_global <- sum(unlist(scores))

  message("=== Score de qualit\u00e9 des donn\u00e9es ===")
  message("Compl\u00e9tude   : ", scores$completude, "/25")
  message("Unicit\u00e9      : ", scores$unicite, "/25")
  message("Coh\u00e9rence    : ", scores$coherence, "/25")
  message("Plausibilit\u00e9 : ", scores$plausibilite, "/25")
  message("SCORE GLOBAL : ", score_global, "/100")

  list(
    score_global = score_global,
    completude   = scores$completude,
    unicite      = scores$unicite,
    coherence    = scores$coherence,
    plausibilite = scores$plausibilite,
    n_lignes     = nrow(data),
    n_colonnes   = ncol(data),
    taux_na      = round(taux_na_global, 4)
  )
}


# =============================================================================
# FONCTIONS INTERNES
# =============================================================================

#' @keywords internal
.valider_borne <- function(valeur, min_val, max_val, nom, unite = "") {
  if (is.na(valeur) || !is.numeric(valeur)) {
    rlang::abort(paste0(nom, " doit \u00eatre un nombre."))
  }
  if (valeur < min_val || valeur > max_val) {
    rlang::warn(paste0(
      nom, " hors plage PNUD [", min_val, "-", max_val, "] ",
      unite, " : ", valeur, ". R\u00e9sultat \u00e9cr\u00eat\u00e9."
    ))
  }
}

#' @keywords internal
.calcul_gini <- function(x, poids = NULL) {
  if (is.null(poids)) poids <- rep(1, length(x))
  idx   <- order(x)
  x     <- x[idx]
  poids <- poids[idx]
  n     <- length(x)
  poids_norm <- poids / sum(poids)
  cum_poids  <- cumsum(poids_norm)
  cum_rev    <- cumsum(x * poids_norm) / sum(x * poids_norm)
  # M\u00e9thode trap\u00e8ze
  gini <- 1 - 2 * sum(cum_rev * poids_norm) +
    sum(x * poids_norm) / sum(x * poids_norm)
  # Formule simplifi\u00e9e
  gini <- 1 - sum((cum_rev[-n] + cum_rev[-1]) *
                    diff(cum_poids))
  max(0, min(1, gini))
}

#' @keywords internal
.calcul_theil <- function(x, poids = NULL) {
  if (is.null(poids)) poids <- rep(1, length(x))
  poids_norm <- poids / sum(poids)
  mu <- sum(x * poids_norm)
  if (mu <= 0) return(NA_real_)
  sum(poids_norm * (x / mu) * log(x / mu + 1e-10), na.rm = TRUE)
}

#' @keywords internal
.calcul_atkinson <- function(x, poids = NULL, epsilon = 1) {
  if (is.null(poids)) poids <- rep(1, length(x))
  poids_norm <- poids / sum(poids)
  mu <- sum(x * poids_norm)
  if (mu <= 0) return(NA_real_)
  if (epsilon == 1) {
    ede <- exp(sum(poids_norm * log(x + 1e-10), na.rm = TRUE))
  } else {
    ede <- sum(poids_norm * (x / mu)^(1 - epsilon), na.rm = TRUE)^(1 / (1 - epsilon)) * mu
  }
  max(0, 1 - ede / mu)
}

#' @keywords internal
.formater_flextable <- function(data, titre = NULL) {
  .verifier_package("flextable", ".formater_flextable")
  ft <- flextable::flextable(data) |>
    flextable::theme_vanilla() |>
    flextable::autofit()
  if (!is.null(titre)) {
    ft <- flextable::set_caption(ft, caption = titre)
  }
  ft
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
