# =============================================================================
# statAfrikR - Module Bien-etre subjectif
# Indicateurs de bien-etre percu, satisfaction, confiance et securite
# Methodologies : Gallup World Poll / Afrobarometer / OCDE / OMS
# =============================================================================

utils::globalVariables(c(
  "indicateur", "valeur", "categorie", "groupe", "score",
  "distribution", "part_pct", "niveau", "institution"
))

# =============================================================================
# 1. SATISFACTION DANS LA VIE
# =============================================================================

#' @title Calculer le score de satisfaction dans la vie
#' @description Calcule le score moyen de satisfaction dans la vie sur
#'   une echelle de 0 a 10 (echelle de Cantril). Indicateur de bien-etre
#'   subjectif global conforme a la methodologie OCDE / Gallup World Poll.
#'
#' @param donnees data.frame -- Donnees individuelles
#' @param var_satisfaction character -- Variable de satisfaction (0-10)
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#'
#' @return Un objet de classe \code{saf_subjectif}
#'
#' @examples
#' set.seed(42)
#' n <- 500
#' individus <- data.frame(
#'   satisfaction = pmin(10, pmax(0, round(rnorm(n, 5.8, 2.1)))),
#'   milieu       = sample(c("urbain","rural"), n, TRUE),
#'   quintile     = sample(paste0("Q", 1:5), n, TRUE),
#'   poids        = runif(n, 0.8, 1.3)
#' )
#' satisfaction_vie(individus, "satisfaction", poids="poids",
#'                  sous_groupes=c("milieu","quintile"))
#'
#' @export
satisfaction_vie <- function(donnees,
                              var_satisfaction,
                              poids        = NULL,
                              sous_groupes = NULL) {

  .calcul_subjectif(
    donnees      = donnees,
    var_cible    = var_satisfaction,
    indicateur   = "Satisfaction dans la vie (echelle Cantril 0-10)",
    code_ref     = "OCDE / Gallup",
    type         = "score",
    borne_min    = 0,
    borne_max    = 10,
    poids        = poids,
    sous_groupes = sous_groupes
  )
}

# =============================================================================
# 2. BONHEUR DECLARE
# =============================================================================

#' @title Calculer la part de population se declarant heureuse
#' @description Proportion d'individus se declarant tres heureux ou heureux.
#'   Variable categorielle recodee en indicateur 0/1.
#'
#' @param donnees data.frame -- Donnees individuelles
#' @param var_bonheur character -- Variable de bonheur.
#'   Valeurs attendues : 1="Tres heureux", 2="Heureux", 3="Pas tres heureux",
#'   4="Pas du tout heureux" OU variable 0/1 deja binaire.
#' @param codes_heureux numeric ou character -- Codes consideres comme
#'   "heureux" (les autres = "pas heureux"). Defaut : c(1, 2)
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#'
#' @return Un objet de classe \code{saf_subjectif}
#'
#' @examples
#' set.seed(42)
#' n <- 500
#' individus <- data.frame(
#'   bonheur  = sample(1:4, n, TRUE, prob=c(0.20,0.45,0.25,0.10)),
#'   milieu   = sample(c("urbain","rural"), n, TRUE),
#'   poids    = runif(n, 0.8, 1.3)
#' )
#' bonheur_declare(individus, "bonheur", codes_heureux=c(1,2),
#'                  poids="poids", sous_groupes="milieu")
#'
#' @export
bonheur_declare <- function(donnees,
                             var_bonheur,
                             codes_heureux = c(1, 2),
                             poids         = NULL,
                             sous_groupes  = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_bonheur %in% names(donnees)) {
    rlang::abort(paste0("Variable '", var_bonheur, "' introuvable."))
  }

  # Recoder en 0/1
  v_orig <- donnees[[var_bonheur]]
  donnees$.bonheur_bin <- as.integer(v_orig %in% codes_heureux)

  res <- .calcul_subjectif(
    donnees      = donnees,
    var_cible    = ".bonheur_bin",
    indicateur   = "Bonheur declare (proportion se declarant heureuse)",
    code_ref     = "Afrobarometer / World Values Survey",
    type         = "proportion",
    borne_min    = 0,
    borne_max    = 1,
    poids        = poids,
    sous_groupes = sous_groupes
  )
  donnees$.bonheur_bin <- NULL
  res
}

# =============================================================================
# 3. PERCEPTION ECONOMIQUE
# =============================================================================

#' @title Calculer la perception de la situation economique
#' @description Proportion de menages pouvant joindre les deux bouts ou
#'   percevant leur situation economique comme bonne ou tres bonne.
#'
#' @param donnees data.frame -- Donnees menages
#' @param var_perception character -- Variable de perception economique.
#'   0/1 (1=situation positive) OU categorielle avec codes_positifs.
#' @param codes_positifs numeric ou NULL -- Codes positifs si variable
#'   categorielle. Defaut : NULL (variable deja binaire)
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#'
#' @return Un objet de classe \code{saf_subjectif}
#'
#' @examples
#' set.seed(42)
#' n <- 400
#' menages <- data.frame(
#'   econ_ok = rbinom(n, 1, 0.38),
#'   quintile = sample(paste0("Q", 1:5), n, TRUE),
#'   poids   = runif(n, 0.8, 1.3)
#' )
#' perception_economique(menages, "econ_ok", poids="poids",
#'                        sous_groupes="quintile")
#'
#' @export
perception_economique <- function(donnees,
                                   var_perception,
                                   codes_positifs = NULL,
                                   poids          = NULL,
                                   sous_groupes   = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_perception %in% names(donnees)) {
    rlang::abort(paste0("Variable '", var_perception, "' introuvable."))
  }

  if (!is.null(codes_positifs)) {
    v_orig  <- donnees[[var_perception]]
    donnees$.perc_bin <- as.integer(v_orig %in% codes_positifs)
    var_cible <- ".perc_bin"
  } else {
    var_cible <- var_perception
  }

  res <- .calcul_subjectif(
    donnees      = donnees,
    var_cible    = var_cible,
    indicateur   = "Perception positive de la situation economique",
    code_ref     = "Afrobarometer / MICS",
    type         = "proportion",
    borne_min    = 0,
    borne_max    = 1,
    poids        = poids,
    sous_groupes = sous_groupes
  )
  donnees$.perc_bin <- NULL
  res
}

# =============================================================================
# 4. PRIVATIONS RESSENTIES
# =============================================================================

#' @title Calculer le score de privations ressenties
#' @description Calcule la proportion de menages ayant declare souffrir
#'   de privations subjectives (manque de nourriture, eau, medicaments,
#'   argent) au cours des 12 derniers mois. Complement a l'IPM.
#'
#' @param donnees data.frame -- Donnees menages
#' @param vars_privations named character -- Vecteur nomme : type de
#'   privation -> variable 0/1. Ex : c(Nourriture="manque_nour",
#'   Eau="manque_eau", Medicaments="manque_med")
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#'
#' @return Un tibble avec prevalence par type de privation
#'
#' @examples
#' set.seed(42)
#' n <- 400
#' menages <- data.frame(
#'   manque_nour = rbinom(n, 1, 0.48),
#'   manque_eau  = rbinom(n, 1, 0.35),
#'   manque_med  = rbinom(n, 1, 0.58),
#'   manque_arg  = rbinom(n, 1, 0.62),
#'   milieu      = sample(c("urbain","rural"), n, TRUE),
#'   poids       = runif(n, 0.8, 1.3)
#' )
#' privations_ressenties(menages,
#'   vars_privations = c(Nourriture="manque_nour",
#'                       Eau="manque_eau",
#'                       Medicaments="manque_med",
#'                       Argent="manque_arg"),
#'   poids="poids", sous_groupes="milieu")
#'
#' @export
privations_ressenties <- function(donnees,
                                   vars_privations,
                                   poids        = NULL,
                                   sous_groupes = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (is.null(names(vars_privations)) || length(vars_privations) == 0L) {
    rlang::abort(paste0(
      "`vars_privations` doit etre un vecteur nomme.\n",
      "Exemple : c(Nourriture='manque_nour', Eau='manque_eau')"
    ))
  }

  vars_abs <- vars_privations[!vars_privations %in% names(donnees)]
  if (length(vars_abs) > 0) {
    rlang::abort(paste0(
      "Variables introuvables : ", paste(vars_abs, collapse=", ")
    ))
  }

  w <- if (!is.null(poids) && poids %in% names(donnees)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp)|wp<=0] <- 1; wp
  } else rep(1, nrow(donnees))

  res <- lapply(names(vars_privations), function(nm) {
    v  <- as.integer(donnees[[vars_privations[[nm]]]])
    ok <- !is.na(v)
    tv <- stats::weighted.mean(v[ok], w[ok])
    ic <- .wilson_ic_bs(tv, sum(ok))
    tibble::tibble(
      type_privation = nm,
      prevalence_pct = round(tv * 100, 2),
      ic_bas         = round(ic[1] * 100, 2),
      ic_haut        = round(ic[2] * 100, 2),
      n_obs          = sum(ok)
    )
  })

  res_df <- dplyr::bind_rows(res)

  # Score de privation composite (au moins une)
  mat <- sapply(vars_privations, function(v) {
    x <- as.integer(donnees[[v]]); x[is.na(x)] <- 0L; x
  })
  if (is.null(dim(mat))) mat <- matrix(mat, ncol=1)
  au_moins_une <- as.integer(rowSums(mat) > 0)
  ok_all       <- rowSums(!is.na(mat)) > 0
  t_glob       <- stats::weighted.mean(au_moins_une[ok_all], w[ok_all])
  score_moy    <- stats::weighted.mean(rowMeans(mat, na.rm=TRUE), w)

  res_df <- dplyr::bind_rows(
    res_df,
    tibble::tibble(
      type_privation = "Au moins une privation",
      prevalence_pct = round(t_glob * 100, 2),
      ic_bas         = round(.wilson_ic_bs(t_glob, sum(ok_all))[1]*100, 2),
      ic_haut        = round(.wilson_ic_bs(t_glob, sum(ok_all))[2]*100, 2),
      n_obs          = sum(ok_all)
    )
  )

  message("=== Privations ressenties ===")
  message("  Score composite moyen : ", round(score_moy * 100, 1), "%")
  for (i in seq_len(nrow(res_df))) {
    message("  ", res_df$type_privation[i], " : ",
            res_df$prevalence_pct[i], "%")
  }

  res_df
}

# =============================================================================
# 5. SANTE MENTALE
# =============================================================================

#' @title Calculer les indicateurs de sante mentale
#' @description Prevalence des symptomes de stress, anxiete et isolement
#'   percu. Compatible avec les modules Kessler K6, PHQ-4 et GAD-2
#'   adaptes aux enquetes menages africaines.
#'
#' @param donnees data.frame -- Donnees individuelles
#' @param var_stress character ou NULL -- Variable stress (0/1 ou score).
#'   Defaut : NULL
#' @param var_anxiete character ou NULL -- Variable anxiete (0/1).
#'   Defaut : NULL
#' @param var_isolement character ou NULL -- Variable isolement social
#'   (0/1). Defaut : NULL
#' @param type character -- "binaire" (variables 0/1) ou "score"
#'   (variables continues). Defaut : "binaire"
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#'
#' @return Un tibble avec prevalence par indicateur
#'
#' @examples
#' set.seed(42)
#' n <- 500
#' individus <- data.frame(
#'   stress    = rbinom(n, 1, 0.38),
#'   anxiete   = rbinom(n, 1, 0.28),
#'   isolement = rbinom(n, 1, 0.22),
#'   sexe      = sample(c("H","F"), n, TRUE),
#'   poids     = runif(n, 0.8, 1.3)
#' )
#' sante_mentale(individus, var_stress="stress",
#'               var_anxiete="anxiete", var_isolement="isolement",
#'               poids="poids", sous_groupes="sexe")
#'
#' @export
sante_mentale <- function(donnees,
                           var_stress    = NULL,
                           var_anxiete   = NULL,
                           var_isolement = NULL,
                           type          = c("binaire","score"),
                           poids         = NULL,
                           sous_groupes  = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  type <- match.arg(type)

  vars_sm <- c(
    Stress    = var_stress,
    Anxiete   = var_anxiete,
    Isolement = var_isolement
  )
  vars_sm <- vars_sm[!is.null(vars_sm) & !is.na(vars_sm)]

  if (length(vars_sm) == 0L) {
    rlang::abort(paste0(
      "Au moins un indicateur doit etre fourni.\n",
      "Fournissez var_stress, var_anxiete ou var_isolement."
    ))
  }

  vars_abs <- vars_sm[!vars_sm %in% names(donnees)]
  if (length(vars_abs) > 0) {
    rlang::abort(paste0(
      "Variables introuvables : ", paste(vars_abs, collapse=", ")
    ))
  }

  w <- if (!is.null(poids) && poids %in% names(donnees)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp)|wp<=0] <- 1; wp
  } else rep(1, nrow(donnees))

  res <- lapply(names(vars_sm), function(nm) {
    v  <- as.numeric(donnees[[vars_sm[[nm]]]])
    ok <- !is.na(v)
    if (type == "binaire") {
      tv <- stats::weighted.mean(v[ok], w[ok])
      tibble::tibble(
        indicateur     = nm,
        prevalence_pct = round(tv * 100, 2),
        n_obs          = sum(ok),
        type_mesure    = "Prevalence (%)"
      )
    } else {
      tibble::tibble(
        indicateur     = nm,
        prevalence_pct = round(stats::weighted.mean(v[ok], w[ok]), 3),
        n_obs          = sum(ok),
        type_mesure    = "Score moyen"
      )
    }
  })
  res_df <- dplyr::bind_rows(res)

  message("=== Sante mentale (indicateurs percus) ===")
  for (i in seq_len(nrow(res_df))) {
    message("  ", res_df$indicateur[i], " : ",
            res_df$prevalence_pct[i],
            if (type=="binaire") "%" else " (score)")
  }

  res_df
}

# =============================================================================
# 6. CONFIANCE DANS LES INSTITUTIONS
# =============================================================================

#' @title Calculer la confiance dans les institutions
#' @description Proportion de la population faisant confiance aux
#'   institutions publiques (gouvernement, justice, police, parlement).
#'   Indicateur de gouvernance percu. Methodologie Afrobarometer.
#'
#' @param donnees data.frame -- Donnees individuelles
#' @param vars_institutions named character -- Vecteur nomme : institution
#'   -> variable 0/1 (ou codes_confiance si categorielle).
#'   Ex : c(Gouvernement="conf_gouv", Justice="conf_just")
#' @param codes_confiance numeric ou NULL -- Codes indiquant confiance.
#'   Defaut : NULL (variables deja binaires)
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#'
#' @return Un tibble avec taux de confiance par institution
#'
#' @examples
#' set.seed(42)
#' n <- 500
#' individus <- data.frame(
#'   conf_gouv  = rbinom(n, 1, 0.35),
#'   conf_just  = rbinom(n, 1, 0.42),
#'   conf_pol   = rbinom(n, 1, 0.38),
#'   milieu     = sample(c("urbain","rural"), n, TRUE),
#'   poids      = runif(n, 0.8, 1.3)
#' )
#' confiance_institutions(individus,
#'   vars_institutions = c(Gouvernement="conf_gouv",
#'                          Justice="conf_just",
#'                          Police="conf_pol"),
#'   poids="poids", sous_groupes="milieu")
#'
#' @export
confiance_institutions <- function(donnees,
                                    vars_institutions,
                                    codes_confiance = NULL,
                                    poids           = NULL,
                                    sous_groupes    = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (is.null(names(vars_institutions)) || length(vars_institutions)==0L) {
    rlang::abort(paste0(
      "`vars_institutions` doit etre un vecteur nomme.\n",
      "Exemple : c(Gouvernement='conf_gouv', Justice='conf_just')"
    ))
  }

  vars_abs <- vars_institutions[!vars_institutions %in% names(donnees)]
  if (length(vars_abs) > 0) {
    rlang::abort(paste0(
      "Variables introuvables : ", paste(vars_abs, collapse=", ")
    ))
  }

  w <- if (!is.null(poids) && poids %in% names(donnees)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp)|wp<=0] <- 1; wp
  } else rep(1, nrow(donnees))

  res <- lapply(names(vars_institutions), function(nm) {
    v_raw <- donnees[[vars_institutions[[nm]]]]
    v <- if (!is.null(codes_confiance))
      as.integer(v_raw %in% codes_confiance)
    else
      as.integer(v_raw)
    ok <- !is.na(v)
    tv <- stats::weighted.mean(v[ok], w[ok])
    ic <- .wilson_ic_bs(tv, sum(ok))
    tibble::tibble(
      institution    = nm,
      confiance_pct  = round(tv * 100, 2),
      ic_bas         = round(ic[1] * 100, 2),
      ic_haut        = round(ic[2] * 100, 2),
      n_obs          = sum(ok)
    )
  })
  res_df <- dplyr::bind_rows(res)

  message("=== Confiance dans les institutions (Afrobarometer) ===")
  for (i in seq_len(nrow(res_df))) {
    message("  ", res_df$institution[i], " : ",
            res_df$confiance_pct[i], "%")
  }

  res_df
}

# =============================================================================
# 7. SENTIMENT DE SECURITE
# =============================================================================

#' @title Calculer le sentiment de securite
#' @description Proportion de la population se sentant en securite
#'   (le soir dans le quartier, au travail, dans les transports).
#'   Methodologie Afrobarometer / Gallup.
#'
#' @param donnees data.frame -- Donnees individuelles
#' @param var_securite character -- Variable de securite percue (0/1 ou
#'   codes_securise)
#' @param codes_securise numeric ou NULL -- Codes indiquant "securise".
#'   Defaut : NULL (variable deja binaire)
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#'
#' @return Un objet de classe \code{saf_subjectif}
#'
#' @examples
#' set.seed(42)
#' n <- 400
#' individus <- data.frame(
#'   securise = rbinom(n, 1, 0.52),
#'   sexe     = sample(c("H","F"), n, TRUE),
#'   milieu   = sample(c("urbain","rural"), n, TRUE),
#'   poids    = runif(n, 0.8, 1.3)
#' )
#' sentiment_securite(individus, "securise", poids="poids",
#'                     sous_groupes=c("sexe","milieu"))
#'
#' @export
sentiment_securite <- function(donnees,
                                var_securite,
                                codes_securise = NULL,
                                poids          = NULL,
                                sous_groupes   = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_securite %in% names(donnees)) {
    rlang::abort(paste0("Variable '", var_securite, "' introuvable."))
  }

  if (!is.null(codes_securise)) {
    donnees$.sec_bin <- as.integer(donnees[[var_securite]] %in% codes_securise)
    var_cible <- ".sec_bin"
  } else {
    var_cible <- var_securite
  }

  res <- .calcul_subjectif(
    donnees      = donnees,
    var_cible    = var_cible,
    indicateur   = "Sentiment de securite percue",
    code_ref     = "Afrobarometer / Gallup",
    type         = "proportion",
    borne_min    = 0,
    borne_max    = 1,
    poids        = poids,
    sous_groupes = sous_groupes
  )
  donnees$.sec_bin <- NULL
  res
}

# =============================================================================
# 8. TABLEAU DE BORD BIEN-ETRE SUBJECTIF
# =============================================================================

#' @title Tableau de bord du bien-etre subjectif
#' @description Synthetise tous les indicateurs de bien-etre subjectif
#'   en un tableau institutionnel unique. Format adapte aux rapports
#'   nationaux sur le bien-etre et la qualite de vie.
#'
#' @param indicateurs list -- Liste nommee d'objets saf_subjectif ou tibbles
#' @param pays character -- Nom du pays. Defaut : "Pays"
#' @param annee integer -- Annee. Defaut : annee courante
#' @param source character ou NULL -- Source. Defaut : NULL
#'
#' @return Un tibble institutionnel
#'
#' @examples
#' set.seed(42)
#' n <- 400
#' individus <- data.frame(
#'   satisf   = pmin(10,pmax(0,round(rnorm(n,5.8,2.1)))),
#'   bonheur  = rbinom(n,1,0.62),
#'   securise = rbinom(n,1,0.52),
#'   poids    = runif(n,0.8,1.3)
#' )
#' r1 <- suppressMessages(
#'   satisfaction_vie(individus,"satisf",poids="poids"))
#' r2 <- suppressMessages(
#'   sentiment_securite(individus,"securise",poids="poids"))
#' tableau_bien_etre_subjectif(list(satisfaction=r1, securite=r2),
#'                              pays="RCA", annee=2026L)
#'
#' @export
tableau_bien_etre_subjectif <- function(indicateurs,
                                         pays   = "Pays",
                                         annee  = as.integer(
                                           format(Sys.Date(),"%Y")),
                                         source = NULL) {

  if (!is.list(indicateurs) || length(indicateurs) == 0L) {
    rlang::abort("`indicateurs` doit etre une liste non vide.")
  }

  rows <- lapply(names(indicateurs), function(nm) {
    ind <- indicateurs[[nm]]
    if (inherits(ind, "saf_subjectif")) {
      tibble::tibble(
        indicateur = ind$indicateur,
        code_ref   = ind$code_ref,
        valeur     = if (!is.null(ind$score_moy)) ind$score_moy
                     else ind$taux_pct,
        unite      = if (!is.null(ind$score_moy)) "/10" else "%",
        n_obs      = ind$n_obs,
        pays       = pays,
        annee      = annee
      )
    } else if (is.data.frame(ind)) {
      # Pour privations_ressenties, confiance_institutions, sante_mentale
      dernier <- ind[nrow(ind), ]
      tibble::tibble(
        indicateur = nm,
        code_ref   = "Bien-etre subjectif",
        valeur     = if ("prevalence_pct" %in% names(dernier))
          dernier$prevalence_pct[[1]]
        else if ("confiance_pct" %in% names(dernier))
          dernier$confiance_pct[[1]]
        else NA_real_,
        unite  = "%",
        n_obs  = if ("n_obs" %in% names(dernier))
          dernier$n_obs[[1]] else NA_integer_,
        pays   = pays,
        annee  = annee
      )
    } else NULL
  })

  res <- dplyr::bind_rows(rows)
  message("Tableau bien-etre subjectif : ", pays, " - ", annee,
          " (", nrow(res), " indicateurs)")
  res
}

# =============================================================================
# FONCTIONS INTERNES
# =============================================================================

#' @keywords internal
.calcul_subjectif <- function(donnees, var_cible, indicateur, code_ref,
                               type, borne_min, borne_max, poids,
                               sous_groupes) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_cible %in% names(donnees)) {
    rlang::abort(paste0("Variable '", var_cible, "' introuvable."))
  }
  if (!is.null(poids) && !poids %in% names(donnees)) {
    rlang::abort(paste0("Variable de poids '", poids, "' introuvable."))
  }

  v <- as.numeric(donnees[[var_cible]])
  v[v < borne_min | v > borne_max] <- NA
  w <- if (!is.null(poids)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp)|wp<=0] <- 1; wp
  } else rep(1, nrow(donnees))

  ok    <- !is.na(v)
  n_obs <- sum(ok)

  if (type == "score") {
    score_val <- stats::weighted.mean(v[ok], w[ok])
    taux_val  <- NULL
  } else {
    score_val <- NULL
    taux_val  <- stats::weighted.mean(v[ok], w[ok])
  }

  # Distribution
  distrib <- NULL
  if (type == "score") {
    cuts <- cut(v[ok],
                breaks = c(-Inf, 3.9, 5.9, 7.9, Inf),
                labels = c("Bas (0-3)", "Moyen (4-5)",
                           "Eleve (6-7)", "Tres eleve (8-10)"))
    t_distrib <- table(cuts)
    distrib   <- tibble::tibble(
      categorie = names(t_distrib),
      part_pct  = round(as.numeric(t_distrib) / n_obs * 100, 1)
    )
  }

  # Desagregation
  decomp <- NULL
  if (!is.null(sous_groupes)) {
    decomp <- lapply(sous_groupes, function(sg) {
      if (!sg %in% names(donnees)) {
        rlang::warn(paste0("Variable '", sg, "' introuvable."))
        return(NULL)
      }
      g <- as.character(donnees[[sg]])
      dplyr::bind_rows(lapply(sort(unique(g[!is.na(g)])), function(gr) {
        idx  <- which(g == gr)
        ok_g <- ok[idx]
        if (sum(ok_g) < 5L) return(NULL)
        val_g <- if (type == "score")
          round(stats::weighted.mean(v[idx][ok_g], w[idx][ok_g]), 3)
        else
          round(stats::weighted.mean(v[idx][ok_g], w[idx][ok_g]) * 100, 2)
        tibble::tibble(variable=sg, groupe=gr, valeur=val_g, n=sum(ok_g))
      }))
    })
    decomp <- dplyr::bind_rows(decomp)
  }

  if (type == "score") {
    message("=== ", indicateur, " ===")
    message("  Score moyen : ", round(score_val, 2), " / ", borne_max)
  } else {
    message("=== ", indicateur, " ===")
    message("  Taux : ", round(taux_val * 100, 1), "%")
  }

  structure(
    list(
      indicateur    = indicateur,
      code_ref      = code_ref,
      score_moy     = if (!is.null(score_val)) round(score_val, 4) else NULL,
      taux_pct      = if (!is.null(taux_val)) round(taux_val * 100, 2) else NULL,
      ic_bas        = if (!is.null(taux_val))
        round(.wilson_ic_bs(taux_val, n_obs)[1] * 100, 2) else NULL,
      ic_haut       = if (!is.null(taux_val))
        round(.wilson_ic_bs(taux_val, n_obs)[2] * 100, 2) else NULL,
      n_obs         = n_obs,
      distribution  = distrib,
      decomposition = decomp
    ),
    class = "saf_subjectif"
  )
}

#' @export
print.saf_subjectif <- function(x, ...) {
  cat("\n===", x$indicateur, "(", x$code_ref, ") ===\n")
  if (!is.null(x$score_moy)) {
    cat(sprintf("  Score moyen : %.2f\n", x$score_moy))
  }
  if (!is.null(x$taux_pct)) {
    cat(sprintf("  Taux : %.1f%%", x$taux_pct))
    if (!is.null(x$ic_bas)) {
      cat(sprintf("  [IC 95%% : %.1f%% - %.1f%%]", x$ic_bas, x$ic_haut))
    }
    cat("\n")
  }
  cat(sprintf("  N obs : %s\n", format(x$n_obs, big.mark=" ")))
  if (!is.null(x$distribution)) {
    cat("\nDistribution :\n")
    for (i in seq_len(nrow(x$distribution))) {
      cat(sprintf("  %-20s : %s%%\n",
                  x$distribution$categorie[i],
                  x$distribution$part_pct[i]))
    }
  }
  if (!is.null(x$decomposition) && nrow(x$decomposition) > 0) {
    cat("\nDesagregation :\n")
    for (i in seq_len(nrow(x$decomposition))) {
      cat(sprintf("  %-20s : %s  (n=%d)\n",
                  x$decomposition$groupe[i],
                  x$decomposition$valeur[i],
                  x$decomposition$n[i]))
    }
  }
  invisible(x)
}

#' @keywords internal
.wilson_ic_bs <- function(p, n, alpha = 0.05) {
  if (n == 0) return(c(0, 0))
  z      <- stats::qnorm(1 - alpha/2)
  denom  <- 1 + z^2/n
  centre <- (p + z^2/(2*n)) / denom
  marge  <- z * sqrt(p*(1-p)/n + z^2/(4*n^2)) / denom
  c(max(0, centre - marge), min(1, centre + marge))
}
