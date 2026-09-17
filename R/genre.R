# =============================================================================
# statAfrikR - Module Genre & Inclusion
# Indicateurs ODD 5 \u00b7 DHS/MICS \u00b7 UNHCR \u00b7 standards ONU
# =============================================================================

utils::globalVariables(c(
  "indicateur", "valeur", "seuil", "ecart_parite", "statut",
  "dimension", "score", "groupe", "taux", "part"
))

# =============================================================================
# 1. AUTONOMISATION DES FEMMES
# =============================================================================

#' @title Calculer l'indice d'autonomisation des femmes
#' @description Calcule un indice composite d'autonomisation des femmes
#'   base sur trois dimensions : prises de decision, acces aux ressources
#'   et mobilite. Conforme a la methodologie DHS/MICS.
#'
#' @param donnees data.frame -- Donnees femmes
#' @param vars_decision character ou NULL -- Variables 0/1 de prise de
#'   decision (ex: decisions achat menage, sante, visites). Defaut : NULL
#' @param vars_ressources character ou NULL -- Variables 0/1 d'acces aux
#'   ressources (ex: compte bancaire, revenu propre, terre). Defaut : NULL
#' @param vars_mobilite character ou NULL -- Variables 0/1 de mobilite
#'   (ex: libre de se deplacer seule, rendre visite, marche). Defaut : NULL
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#'
#' @return Un objet de classe \code{saf_genre}
#'
#' @examples
#' set.seed(42)
#' n <- 400
#' femmes <- data.frame(
#'   dec_achat   = rbinom(n, 1, 0.55),
#'   dec_sante   = rbinom(n, 1, 0.48),
#'   compte_ban  = rbinom(n, 1, 0.32),
#'   rev_propre  = rbinom(n, 1, 0.41),
#'   libre_dep   = rbinom(n, 1, 0.62),
#'   milieu      = sample(c("urbain","rural"), n, TRUE),
#'   poids       = runif(n, 0.8, 1.3)
#' )
#' autonomisation_femmes(femmes,
#'   vars_decision   = c("dec_achat","dec_sante"),
#'   vars_ressources = c("compte_ban","rev_propre"),
#'   vars_mobilite   = c("libre_dep"),
#'   poids = "poids", sous_groupes = "milieu")
#'
#' @export
autonomisation_femmes <- function(donnees,
                                   vars_decision   = NULL,
                                   vars_ressources = NULL,
                                   vars_mobilite   = NULL,
                                   poids           = NULL,
                                   sous_groupes    = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }

  dims <- list(
    Decision   = vars_decision,
    Ressources = vars_ressources,
    Mobilite   = vars_mobilite
  )
  dims_actives <- Filter(function(x) !is.null(x) && length(x) > 0, dims)

  if (length(dims_actives) == 0L) {
    rlang::abort(paste0(
      "Au moins une dimension doit etre fournie.\n",
      "Fournissez vars_decision, vars_ressources ou vars_mobilite."
    ))
  }

  # Verifier toutes les variables
  toutes_vars <- unlist(dims_actives)
  vars_abs    <- toutes_vars[!toutes_vars %in% names(donnees)]
  if (length(vars_abs) > 0) {
    rlang::abort(paste0(
      "Variables introuvables : ", paste(vars_abs, collapse=", "), "\n",
      "Colonnes disponibles : ", paste(names(donnees), collapse=", ")
    ))
  }
  if (!is.null(poids) && !poids %in% names(donnees)) {
    rlang::abort(paste0("Variable de poids '", poids, "' introuvable."))
  }

  w <- if (!is.null(poids)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp) | wp <= 0] <- 1; wp
  } else rep(1, nrow(donnees))

  # Score par dimension
  scores_dim <- lapply(names(dims_actives), function(dim_nm) {
    vars  <- dims_actives[[dim_nm]]
    mat   <- sapply(vars, function(v) {
      x <- as.numeric(donnees[[v]]); x[is.na(x)] <- 0; pmax(0, pmin(1, x))
    })
    if (is.null(dim(mat))) mat <- matrix(mat, ncol=1)
    score_d <- rowMeans(mat, na.rm=TRUE)
    list(
      dimension = dim_nm,
      score_moy = round(stats::weighted.mean(score_d, w, na.rm=TRUE), 4),
      n_vars    = length(vars)
    )
  })

  # Indice global (moyenne des dimensions)
  scores_vals <- sapply(scores_dim, `[[`, "score_moy")
  indice_global <- round(mean(scores_vals), 4)

  # Desagregation
  decomp <- NULL
  if (!is.null(sous_groupes)) {
    decomp <- lapply(sous_groupes, function(sg) {
      if (!sg %in% names(donnees)) return(NULL)
      g <- as.character(donnees[[sg]])
      dplyr::bind_rows(lapply(sort(unique(g[!is.na(g)])), function(gr) {
        idx <- which(g == gr)
        df_g <- donnees[idx, ]
        wg   <- w[idx]
        toutes <- unlist(dims_actives)
        ok <- !is.na(toutes) & toutes %in% names(df_g)
        if (sum(ok) == 0) return(NULL)
        scores_g <- sapply(names(dims_actives), function(dn) {
          vv <- dims_actives[[dn]]
          m  <- sapply(vv, function(v) {
            x <- as.numeric(df_g[[v]]); x[is.na(x)] <- 0; x
          })
          if (is.null(dim(m))) m <- matrix(m, ncol=1)
          stats::weighted.mean(rowMeans(m, na.rm=TRUE), wg, na.rm=TRUE)
        })
        tibble::tibble(
          variable = sg, groupe = gr,
          indice   = round(mean(scores_g), 4),
          n        = nrow(df_g)
        )
      }))
    })
    decomp <- dplyr::bind_rows(decomp)
  }

  scores_df <- dplyr::bind_rows(lapply(scores_dim, function(x) {
    tibble::tibble(dimension=x$dimension, score=x$score_moy, n_vars=x$n_vars)
  }))

  message("=== Indice d'autonomisation des femmes ===")
  message("  Indice global : ", round(indice_global * 100, 1), "/100")
  for (i in seq_len(nrow(scores_df))) {
    message("  ", scores_df$dimension[i], " : ",
            round(scores_df$score[i] * 100, 1))
  }

  structure(
    list(
      indicateur    = "Indice d'autonomisation des femmes",
      code_ref      = "DHS/MICS",
      indice        = indice_global,
      indice_pct    = round(indice_global * 100, 2),
      scores_dim    = scores_df,
      n_dimensions  = length(dims_actives),
      decomposition = decomp
    ),
    class = "saf_genre"
  )
}

#' @export
print.saf_genre <- function(x, ...) {
  cat("\n===", x$indicateur, "(", x$code_ref, ") ===\n")
  if (!is.null(x$indice)) {
    cat(sprintf("  Indice global : %.1f / 100\n", x$indice_pct))
  }
  if (!is.null(x$taux_pct)) {
    cat(sprintf("  Taux : %.1f%%", x$taux_pct))
    if (!is.null(x$ic_bas)) {
      cat(sprintf("  [IC 95%% : %.1f%% - %.1f%%]", x$ic_bas, x$ic_haut))
    }
    cat("\n")
  }
  if (!is.null(x$isp)) {
    cat(sprintf("  ISP : %.3f  (%s)\n", x$isp, x$statut_parite))
  }
  if (!is.null(x$decomposition) && nrow(x$decomposition) > 0) {
    cat("\nDesagregation :\n")
    for (i in seq_len(nrow(x$decomposition))) {
      cat(sprintf("  %-20s : %s  (n=%d)\n",
                  x$decomposition$groupe[i],
                  x$decomposition[[3]][i],
                  x$decomposition$n[i]))
    }
  }
  invisible(x)
}

# =============================================================================
# 2. VIOLENCES BASEES SUR LE GENRE
# =============================================================================

#' @title Calculer la prevalence des violences basees sur le genre
#' @description Prevalence des violences physiques, sexuelles et/ou
#'   psychologiques exercees par un partenaire intime ou un non-partenaire.
#'   Methodologie DHS/OMS. ODD 5.2.1.
#'
#' @param donnees data.frame -- Donnees femmes (15-49 ans)
#' @param var_violence_physique character ou NULL -- VBG physique (0/1)
#' @param var_violence_sexuelle character ou NULL -- VBG sexuelle (0/1)
#' @param var_violence_psycho character ou NULL -- VBG psychologique (0/1)
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#'
#' @return Un tibble avec prevalence par type de violence
#'
#' @examples
#' set.seed(42)
#' n <- 500
#' femmes <- data.frame(
#'   vbg_phys   = rbinom(n, 1, 0.28),
#'   vbg_sex    = rbinom(n, 1, 0.18),
#'   vbg_psycho = rbinom(n, 1, 0.35),
#'   milieu     = sample(c("urbain","rural"), n, TRUE),
#'   poids      = runif(n, 0.8, 1.3)
#' )
#' violence_basee_genre(femmes,
#'   var_violence_physique  = "vbg_phys",
#'   var_violence_sexuelle  = "vbg_sex",
#'   var_violence_psycho    = "vbg_psycho",
#'   poids = "poids", sous_groupes = "milieu")
#'
#' @export
violence_basee_genre <- function(donnees,
                                  var_violence_physique = NULL,
                                  var_violence_sexuelle = NULL,
                                  var_violence_psycho   = NULL,
                                  poids                 = NULL,
                                  sous_groupes          = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }

  vars_vbg <- c(
    "Physique"      = var_violence_physique,
    "Sexuelle"      = var_violence_sexuelle,
    "Psychologique" = var_violence_psycho
  )
  vars_vbg <- vars_vbg[!is.null(vars_vbg) & !is.na(vars_vbg)]

  if (length(vars_vbg) == 0L) {
    rlang::abort(paste0(
      "Au moins une variable de VBG doit etre fournie.\n",
      "Fournissez var_violence_physique, var_violence_sexuelle ou",
      " var_violence_psycho."
    ))
  }

  vars_abs <- vars_vbg[!vars_vbg %in% names(donnees)]
  if (length(vars_abs) > 0) {
    rlang::abort(paste0(
      "Variables introuvables : ", paste(vars_abs, collapse=", ")
    ))
  }

  w <- if (!is.null(poids) && poids %in% names(donnees)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp) | wp <= 0] <- 1; wp
  } else rep(1, nrow(donnees))

  res <- lapply(names(vars_vbg), function(nm) {
    v  <- as.integer(donnees[[vars_vbg[[nm]]]])
    ok <- !is.na(v)
    tv <- stats::weighted.mean(v[ok], w[ok])
    ic <- .wilson_ic_genre(tv, sum(ok))
    tibble::tibble(
      type_violence  = nm,
      prevalence_pct = round(tv * 100, 2),
      ic_bas         = round(ic[1] * 100, 2),
      ic_haut        = round(ic[2] * 100, 2),
      n_obs          = sum(ok)
    )
  })
  res_df <- dplyr::bind_rows(res)

  # Au moins une forme de VBG
  mat <- sapply(vars_vbg, function(v) {
    x <- as.integer(donnees[[v]]); x[is.na(x)] <- 0L; x
  })
  if (is.null(dim(mat))) mat <- matrix(mat, ncol=1)
  au_moins_une <- as.integer(rowSums(mat) > 0)
  ok_all <- rowSums(!is.na(mat)) > 0
  t_glob <- stats::weighted.mean(au_moins_une[ok_all], w[ok_all])
  ic_g   <- .wilson_ic_genre(t_glob, sum(ok_all))

  res_df <- dplyr::bind_rows(
    res_df,
    tibble::tibble(
      type_violence  = "Au moins une forme",
      prevalence_pct = round(t_glob * 100, 2),
      ic_bas         = round(ic_g[1] * 100, 2),
      ic_haut        = round(ic_g[2] * 100, 2),
      n_obs          = sum(ok_all)
    )
  )

  message("=== Violences basees sur le genre (ODD 5.2.1) ===")
  for (i in seq_len(nrow(res_df))) {
    message("  ", res_df$type_violence[i], " : ",
            res_df$prevalence_pct[i], "%")
  }

  res_df
}

# =============================================================================
# 3. MARIAGE PRECOCE
# =============================================================================

#' @title Calculer le taux de mariage precoce
#' @description Proportion de femmes/hommes maries avant 18 ans (ODD 5.3.1)
#'   avec desagregation et analyse des tendances par cohorte d'age.
#'
#' @param donnees data.frame -- Donnees femmes (15-49 ans)
#' @param var_marie_avant_18 character -- Variable 0/1 : marie(e) avant 18 ans
#' @param var_cohorte character ou NULL -- Variable de cohorte ou groupe
#'   d'age pour analyser les tendances. Defaut : NULL
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#'
#' @return Un objet de classe \code{saf_genre}
#'
#' @examples
#' set.seed(42)
#' n <- 500
#' femmes <- data.frame(
#'   marie_18  = rbinom(n, 1, 0.42),
#'   cohorte   = sample(c("15-19","20-24","25-29","30-34","35-49"),
#'                       n, TRUE),
#'   milieu    = sample(c("urbain","rural"), n, TRUE),
#'   poids     = runif(n, 0.8, 1.3)
#' )
#' mariage_precoce(femmes, "marie_18",
#'                  var_cohorte = "cohorte",
#'                  poids = "poids", sous_groupes = "milieu")
#'
#' @export
mariage_precoce <- function(donnees,
                             var_marie_avant_18,
                             var_cohorte  = NULL,
                             poids        = NULL,
                             sous_groupes = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_marie_avant_18 %in% names(donnees)) {
    rlang::abort(paste0("Variable '", var_marie_avant_18, "' introuvable."))
  }

  v <- as.integer(donnees[[var_marie_avant_18]])
  w <- if (!is.null(poids) && poids %in% names(donnees)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp) | wp <= 0] <- 1; wp
  } else rep(1, nrow(donnees))

  ok   <- !is.na(v)
  taux_val <- stats::weighted.mean(v[ok], w[ok])
  n_obs    <- sum(ok)
  ic       <- .wilson_ic_genre(taux_val, n_obs)

  # Tendances par cohorte
  cohortes_df <- NULL
  if (!is.null(var_cohorte) && var_cohorte %in% names(donnees)) {
    coh <- as.character(donnees[[var_cohorte]])
    cohortes_df <- dplyr::bind_rows(lapply(
      sort(unique(coh[!is.na(coh)])), function(co) {
        idx  <- which(coh == co)
        ok_c <- ok[idx]
        tv   <- stats::weighted.mean(v[idx][ok_c], w[idx][ok_c])
        tibble::tibble(cohorte=co, taux_pct=round(tv*100,2), n=sum(ok_c))
      }))
  }

  # Desagregation
  decomp <- NULL
  if (!is.null(sous_groupes)) {
    decomp <- lapply(sous_groupes, function(sg) {
      if (!sg %in% names(donnees)) return(NULL)
      g <- as.character(donnees[[sg]])
      dplyr::bind_rows(lapply(sort(unique(g[!is.na(g)])), function(gr) {
        idx <- which(g == gr); ok_g <- ok[idx]
        tv  <- stats::weighted.mean(v[idx][ok_g], w[idx][ok_g])
        tibble::tibble(variable=sg, groupe=gr,
                       taux_pct=round(tv*100,2), n=sum(ok_g))
      }))
    })
    decomp <- dplyr::bind_rows(decomp)
  }

  message("=== Mariage precoce (ODD 5.3.1) ===")
  message("  Taux global : ", round(taux_val * 100, 1), "%")
  if (!is.null(cohortes_df)) {
    message("  Tendances par cohorte :")
    for (i in seq_len(nrow(cohortes_df))) {
      message("    ", cohortes_df$cohorte[i], " : ",
              cohortes_df$taux_pct[i], "%")
    }
  }

  structure(
    list(
      indicateur    = "Mariage precoce (avant 18 ans)",
      code_ref      = "ODD 5.3.1",
      taux          = round(taux_val, 4),
      taux_pct      = round(taux_val * 100, 2),
      ic_bas        = round(ic[1] * 100, 2),
      ic_haut       = round(ic[2] * 100, 2),
      n_obs         = n_obs,
      cohortes      = cohortes_df,
      decomposition = decomp
    ),
    class = "saf_genre"
  )
}

# =============================================================================
# 4. PARITE EDUCATION
# =============================================================================

#' @title Calculer l'indice de parite filles/garcons en education
#' @description Calcule l'Indice de Parite entre les Sexes (ISP) pour les
#'   taux de scolarisation bruts et nets. ODD 4.5.1.
#'   ISP = valeur filles / valeur garcons. ISP = 1 = parite parfaite.
#'
#' @param donnees data.frame -- Donnees menages ou enfants
#' @param var_scolarise character -- Variable 0/1 : enfant scolarise
#' @param var_sexe character -- Variable sexe (H/F, M/F, 1/2, homme/femme)
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param var_niveau character ou NULL -- Niveau scolaire pour ISP par
#'   niveau. Defaut : NULL
#'
#' @return Un objet de classe \code{saf_genre}
#'
#' @examples
#' set.seed(42)
#' n <- 600
#' enfants <- data.frame(
#'   scolarise = rbinom(n, 1, 0.72),
#'   sexe      = sample(c("H","F"), n, TRUE),
#'   niveau    = sample(c("primaire","secondaire"), n, TRUE),
#'   poids     = runif(n, 0.8, 1.3)
#' )
#' parite_education(enfants, "scolarise", "sexe",
#'                   poids="poids", var_niveau="niveau")
#'
#' @export
parite_education <- function(donnees,
                              var_scolarise,
                              var_sexe,
                              poids      = NULL,
                              var_niveau = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  for (v in c(var_scolarise, var_sexe)) {
    if (!v %in% names(donnees)) {
      rlang::abort(paste0("Variable '", v, "' introuvable."))
    }
  }

  scol <- as.integer(donnees[[var_scolarise]])
  sexe <- as.character(donnees[[var_sexe]])
  w    <- if (!is.null(poids) && poids %in% names(donnees)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp) | wp <= 0] <- 1; wp
  } else rep(1, nrow(donnees))

  # Standardiser sexe -> "F" et "H"
  sexe <- dplyr::case_when(
    tolower(sexe) %in% c("f","femme","fille","female","2") ~ "F",
    tolower(sexe) %in% c("h","m","homme","garcon","male","1") ~ "H",
    TRUE ~ sexe
  )

  .isp <- function(sc, sx, wp) {
    ok <- !is.na(sc) & !is.na(sx)
    f_idx <- ok & sx == "F"
    h_idx <- ok & sx == "H"
    if (sum(f_idx) < 5L || sum(h_idx) < 5L) return(NA_real_)
    tf <- stats::weighted.mean(sc[f_idx], wp[f_idx])
    th <- stats::weighted.mean(sc[h_idx], wp[h_idx])
    if (th == 0) return(NA_real_)
    round(tf / th, 3)
  }

  isp_global <- .isp(scol, sexe, w)
  statut     <- if (is.na(isp_global)) "Non calculable"
                else if (isp_global < 0.97) "Desavantage filles"
                else if (isp_global > 1.03) "Desavantage garcons"
                else "Parite atteinte"

  # ISP par niveau
  isp_niveau <- NULL
  if (!is.null(var_niveau) && var_niveau %in% names(donnees)) {
    niv <- as.character(donnees[[var_niveau]])
    isp_niveau <- dplyr::bind_rows(lapply(
      sort(unique(niv[!is.na(niv)])), function(n_val) {
        idx <- which(niv == n_val)
        tibble::tibble(
          niveau = n_val,
          isp    = .isp(scol[idx], sexe[idx], w[idx]),
          n      = length(idx)
        )
      }))
  }

  message("=== Indice de Parite (ODD 4.5.1) ===")
  message("  ISP global : ", isp_global, "  (", statut, ")")
  if (!is.null(isp_niveau)) {
    for (i in seq_len(nrow(isp_niveau))) {
      message("  ", isp_niveau$niveau[i], " : ISP = ", isp_niveau$isp[i])
    }
  }

  structure(
    list(
      indicateur     = "Indice de Parite Filles/Garcons (ISP)",
      code_ref       = "ODD 4.5.1",
      isp            = isp_global,
      statut_parite  = statut,
      isp_par_niveau = isp_niveau,
      n_obs          = sum(!is.na(scol)),
      decomposition  = NULL
    ),
    class = "saf_genre"
  )
}

# =============================================================================
# 5. PREVALENCE DU HANDICAP
# =============================================================================

#' @title Calculer la prevalence du handicap
#' @description Prevalence du handicap par type (visuel, auditif, moteur,
#'   cognitif) selon la methodologie Washington Group / recensement.
#'
#' @param donnees data.frame -- Donnees individuelles
#' @param vars_handicap named character -- Vecteur nomme : type de
#'   handicap -> variable 0/1. Ex: c(Visuel="hand_vis", Moteur="hand_mot")
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#'
#' @return Un tibble avec prevalence par type de handicap
#'
#' @examples
#' set.seed(42)
#' n <- 500
#' individus <- data.frame(
#'   hand_vis = rbinom(n, 1, 0.04),
#'   hand_aud = rbinom(n, 1, 0.03),
#'   hand_mot = rbinom(n, 1, 0.05),
#'   sexe     = sample(c("H","F"), n, TRUE),
#'   poids    = runif(n, 0.8, 1.3)
#' )
#' handicap_prevalence(individus,
#'   vars_handicap = c(Visuel="hand_vis", Auditif="hand_aud",
#'                     Moteur="hand_mot"),
#'   poids = "poids")
#'
#' @export
handicap_prevalence <- function(donnees,
                                 vars_handicap,
                                 poids        = NULL,
                                 sous_groupes = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (is.null(names(vars_handicap)) || length(vars_handicap) == 0L) {
    rlang::abort(paste0(
      "`vars_handicap` doit etre un vecteur nomme.\n",
      "Exemple : c(Visuel='hand_vis', Moteur='hand_mot')"
    ))
  }

  vars_abs <- vars_handicap[!vars_handicap %in% names(donnees)]
  if (length(vars_abs) > 0) {
    rlang::abort(paste0(
      "Variables introuvables : ", paste(vars_abs, collapse=", ")
    ))
  }

  w <- if (!is.null(poids) && poids %in% names(donnees)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp) | wp <= 0] <- 1; wp
  } else rep(1, nrow(donnees))

  res <- lapply(names(vars_handicap), function(nm) {
    v  <- as.integer(donnees[[vars_handicap[[nm]]]])
    ok <- !is.na(v)
    tv <- stats::weighted.mean(v[ok], w[ok])
    ic <- .wilson_ic_genre(tv, sum(ok))
    tibble::tibble(
      type_handicap  = nm,
      prevalence_pct = round(tv * 100, 2),
      ic_bas         = round(ic[1] * 100, 2),
      ic_haut        = round(ic[2] * 100, 2),
      n_obs          = sum(ok)
    )
  })

  mat   <- sapply(vars_handicap, function(v) {
    x <- as.integer(donnees[[v]]); x[is.na(x)] <- 0L; x
  })
  if (is.null(dim(mat))) mat <- matrix(mat, ncol=1)
  au_moins_un <- as.integer(rowSums(mat) > 0)
  ok_all <- rowSums(!is.na(mat)) > 0
  t_glob <- stats::weighted.mean(au_moins_un[ok_all], w[ok_all])

  res_df <- dplyr::bind_rows(c(
    res,
    list(tibble::tibble(
      type_handicap  = "Au moins un type",
      prevalence_pct = round(t_glob * 100, 2),
      ic_bas         = round(.wilson_ic_genre(t_glob, sum(ok_all))[1]*100, 2),
      ic_haut        = round(.wilson_ic_genre(t_glob, sum(ok_all))[2]*100, 2),
      n_obs          = sum(ok_all)
    ))
  ))

  message("=== Prevalence du handicap (Washington Group) ===")
  for (i in seq_len(nrow(res_df))) {
    message("  ", res_df$type_handicap[i], " : ",
            res_df$prevalence_pct[i], "%")
  }

  res_df
}

# =============================================================================
# 6. TABLEAU DE BORD GENRE
# =============================================================================

#' @title Tableau de bord des indicateurs de genre et d'inclusion
#' @description Synthetise tous les indicateurs genre en un tableau
#'   institutionnel comparable aux rapports ODD 5 et DHS.
#'
#' @param indicateurs list -- Liste nommee d'objets saf_genre ou tibbles
#' @param pays character -- Nom du pays. Defaut : "Pays"
#' @param annee integer -- Annee. Defaut : annee courante
#' @param source character ou NULL -- Source. Defaut : NULL
#'
#' @return Un tibble institutionnel
#'
#' @examples
#' set.seed(42)
#' n <- 400
#' femmes <- data.frame(
#'   marie_18 = rbinom(n, 1, 0.42),
#'   vbg_phys = rbinom(n, 1, 0.28),
#'   poids    = runif(n, 0.8, 1.3)
#' )
#' rm <- suppressMessages(
#'   mariage_precoce(femmes, "marie_18", poids="poids"))
#' rvbg <- violence_basee_genre(femmes,
#'   var_violence_physique="vbg_phys", poids="poids")
#' tableau_genre(list(mariage=rm, vbg=rvbg), pays="RCA", annee=2026L)
#'
#' @export
tableau_genre <- function(indicateurs,
                           pays   = "Pays",
                           annee  = as.integer(format(Sys.Date(), "%Y")),
                           source = NULL) {

  if (!is.list(indicateurs) || length(indicateurs) == 0L) {
    rlang::abort("`indicateurs` doit etre une liste non vide.")
  }

  rows <- lapply(names(indicateurs), function(nm) {
    ind <- indicateurs[[nm]]
    if (inherits(ind, "saf_genre")) {
      valeur <- if (!is.null(ind$taux_pct)) ind$taux_pct
                else if (!is.null(ind$indice_pct)) ind$indice_pct
                else if (!is.null(ind$isp)) ind$isp
                else NA_real_
      tibble::tibble(
        indicateur = ind$indicateur,
        code_ref   = ind$code_ref,
        valeur     = valeur,
        n_obs      = if (!is.null(ind$n_obs)) ind$n_obs else NA_integer_,
        pays       = pays, annee = annee
      )
    } else if (is.data.frame(ind)) {
      # Pour violence_basee_genre ou handicap_prevalence
      dernier <- ind[nrow(ind), ]
      tibble::tibble(
        indicateur = nm,
        code_ref   = "ODD 5",
        valeur     = if ("prevalence_pct" %in% names(dernier))
          dernier$prevalence_pct[[1]]
        else if ("couverture_pct" %in% names(dernier))
          dernier$couverture_pct[[1]]
        else NA_real_,
        n_obs   = if ("n_obs" %in% names(dernier))
          dernier$n_obs[[1]] else NA_integer_,
        pays    = pays, annee = annee
      )
    } else NULL
  })

  res <- dplyr::bind_rows(rows)
  message("Tableau de bord genre : ", pays, " - ", annee,
          " (", nrow(res), " indicateurs)")
  res
}

# =============================================================================
# FONCTIONS INTERNES
# =============================================================================

#' @keywords internal
.wilson_ic_genre <- function(p, n, alpha = 0.05) {
  if (n == 0) return(c(0, 0))
  z      <- stats::qnorm(1 - alpha/2)
  denom  <- 1 + z^2/n
  centre <- (p + z^2/(2*n)) / denom
  marge  <- z * sqrt(p*(1-p)/n + z^2/(4*n^2)) / denom
  c(max(0, centre - marge), min(1, centre + marge))
}
