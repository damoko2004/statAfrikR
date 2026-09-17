# =============================================================================
# statAfrikR - Module IPM : Indice de Pauvrete Multidimensionnelle
# Methode Alkire-Foster (2011) - doi:10.1093/oep/gpr051
# ODD 1.2.2 - Pauvrete multidimensionnelle nationale
# =============================================================================

utils::globalVariables(c(
  "dimension", "indicateur", "poids", "prive", "contribution",
  "groupe", "H", "A", "IPM", "valeur", "zone", "part_contribution",
  ".score", ".pauvre_ipm", ".dim_sante", ".dim_education", ".dim_vie"
))

# Poids Alkire-Foster standard
.POIDS_AF <- list(
  sante      = list(nutrition = 1/6, mortalite_inf = 1/6),
  education  = list(annees_scol = 1/6, scolarisation = 1/6),
  niveau_vie = list(combustible = 1/18, assainissement = 1/18,
                    eau = 1/18, electricite = 1/18,
                    logement = 1/18, actifs = 1/18)
)

# =============================================================================
# 1. CALCUL IPM STANDARD (PNUD/OPHI)
# =============================================================================

#' @title Calculer l'Indice de Pauvrete Multidimensionnelle (IPM)
#' @description Calcule l'IPM standard PNUD/OPHI selon la methode
#'   Alkire-Foster (2011). L'IPM = H x A, ou H est l'incidence
#'   (proportion de menages multidimensionnellement pauvres) et A
#'   l'intensite moyenne de privation parmi les pauvres.
#'
#' @param donnees data.frame -- Donnees menages
#' @param var_nutrition character ou NULL -- Variable nutrition
#'   (1 = prive, 0 = non prive). Defaut : NULL
#' @param var_mortalite_inf character ou NULL -- Deces d'enfant
#'   dans le menage (1 = oui). Defaut : NULL
#' @param var_annees_scol character ou NULL -- Aucun membre >= 6 ans
#'   ayant complete 6 ans de scolarite (1 = prive). Defaut : NULL
#' @param var_scolarisation character ou NULL -- Enfant non scolarise
#'   dans le menage (1 = prive). Defaut : NULL
#' @param var_combustible character ou NULL -- Combustible solide
#'   pour la cuisine (1 = prive). Defaut : NULL
#' @param var_assainissement character ou NULL -- Assainissement
#'   non ameliore (1 = prive). Defaut : NULL
#' @param var_eau character ou NULL -- Eau non potable (1 = prive).
#'   Defaut : NULL
#' @param var_electricite character ou NULL -- Sans electricite
#'   (1 = prive). Defaut : NULL
#' @param var_logement character ou NULL -- Logement inadequat
#'   (1 = prive). Defaut : NULL
#' @param var_actifs character ou NULL -- Pas d'actifs de base
#'   (1 = prive). Defaut : NULL
#' @param poids character ou NULL -- Variable de ponderation.
#'   Defaut : NULL (poids egaux)
#' @param seuil_k numeric -- Seuil de pauvrete multidimensionnelle
#'   (proportion de privations). Defaut : 1/3
#' @param ic logical -- Calculer les intervalles de confiance
#'   (bootstrap). Defaut : FALSE
#' @param n_bootstrap integer -- Nombre de replications bootstrap.
#'   Defaut : 200L
#'
#' @return Un objet de classe \code{saf_ipm} contenant :
#'   \code{IPM}, \code{H}, \code{A}, \code{contributions},
#'   \code{n_obs}, \code{seuil_k}, \code{methode}
#'
#' @references Alkire, S. & Foster, J. (2011). Counting and
#'   multidimensional poverty measurement.
#'   \emph{Journal of Public Economics}, 95(7-8), 476-487.
#'   \doi{10.1016/j.jpubeco.2010.11.006}
#'
#' @examples
#' set.seed(42)
#' n <- 200
#' menages <- data.frame(
#'   nutrition      = rbinom(n, 1, 0.35),
#'   mortalite_inf  = rbinom(n, 1, 0.12),
#'   annees_scol    = rbinom(n, 1, 0.40),
#'   scolarisation  = rbinom(n, 1, 0.28),
#'   combustible    = rbinom(n, 1, 0.55),
#'   assainissement = rbinom(n, 1, 0.48),
#'   eau            = rbinom(n, 1, 0.38),
#'   electricite    = rbinom(n, 1, 0.62),
#'   logement       = rbinom(n, 1, 0.42),
#'   actifs         = rbinom(n, 1, 0.30),
#'   poids          = runif(n, 0.8, 1.3)
#' )
#' res <- calcul_ipm(menages,
#'   var_nutrition      = "nutrition",
#'   var_mortalite_inf  = "mortalite_inf",
#'   var_annees_scol    = "annees_scol",
#'   var_scolarisation  = "scolarisation",
#'   var_combustible    = "combustible",
#'   var_assainissement = "assainissement",
#'   var_eau            = "eau",
#'   var_electricite    = "electricite",
#'   var_logement       = "logement",
#'   var_actifs         = "actifs",
#'   poids              = "poids"
#' )
#' print(res)
#'
#' @export
calcul_ipm <- function(donnees,
                        var_nutrition      = NULL,
                        var_mortalite_inf  = NULL,
                        var_annees_scol    = NULL,
                        var_scolarisation  = NULL,
                        var_combustible    = NULL,
                        var_assainissement = NULL,
                        var_eau            = NULL,
                        var_electricite    = NULL,
                        var_logement       = NULL,
                        var_actifs         = NULL,
                        poids              = NULL,
                        seuil_k            = 1/3,
                        ic                 = FALSE,
                        n_bootstrap        = 200L) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort(paste0(
      "`donnees` doit etre un data.frame non vide.\n",
      "Verifiez vos donnees d'entree."
    ))
  }
  if (seuil_k <= 0 || seuil_k >= 1) {
    rlang::abort(paste0(
      "`seuil_k` doit etre entre 0 et 1 (exclus).\n",
      "Valeur standard : 1/3 (Alkire-Foster)."
    ))
  }

  # Correspondance variables / poids
  vars_poids <- list(
    nutrition      = list(var = var_nutrition,      w = 1/6),
    mortalite_inf  = list(var = var_mortalite_inf,  w = 1/6),
    annees_scol    = list(var = var_annees_scol,    w = 1/6),
    scolarisation  = list(var = var_scolarisation,  w = 1/6),
    combustible    = list(var = var_combustible,    w = 1/18),
    assainissement = list(var = var_assainissement, w = 1/18),
    eau            = list(var = var_eau,            w = 1/18),
    electricite    = list(var = var_electricite,    w = 1/18),
    logement       = list(var = var_logement,       w = 1/18),
    actifs         = list(var = var_actifs,         w = 1/18)
  )

  dims_noms <- list(
    nutrition = "Sante", mortalite_inf = "Sante",
    annees_scol = "Education", scolarisation = "Education",
    combustible = "Niveau de vie", assainissement = "Niveau de vie",
    eau = "Niveau de vie", electricite = "Niveau de vie",
    logement = "Niveau de vie", actifs = "Niveau de vie"
  )

  # Verifier les variables fournies
  vars_actives <- Filter(function(x) !is.null(x$var), vars_poids)
  if (length(vars_actives) == 0L) {
    rlang::abort(paste0(
      "Aucun indicateur de privation fourni.\n",
      "Fournissez au moins 3 variables (ex: var_nutrition, var_eau, var_electricite).\n",
      "Indicateurs disponibles : nutrition, mortalite_inf, annees_scol, scolarisation,\n",
      "  combustible, assainissement, eau, electricite, logement, actifs"
    ))
  }

  # Verifier que les variables existent
  vars_manquantes <- character(0)
  for (nm in names(vars_actives)) {
    v <- vars_actives[[nm]]$var
    if (!v %in% names(donnees)) vars_manquantes <- c(vars_manquantes, v)
  }
  if (length(vars_manquantes) > 0) {
    rlang::abort(paste0(
      "Variables introuvables dans les donnees : ",
      paste(vars_manquantes, collapse = ", "), "\n",
      "Colonnes disponibles : ", paste(names(donnees), collapse = ", ")
    ))
  }

  # Verifier variable poids
  if (!is.null(poids) && !poids %in% names(donnees)) {
    rlang::abort(paste0(
      "Variable de poids '", poids, "' introuvable.\n",
      "Colonnes disponibles : ", paste(names(donnees), collapse = ", ")
    ))
  }

  # Renormaliser les poids si l'ensemble des indicateurs est partiel
  w_total <- sum(sapply(vars_actives, `[[`, "w"))
  for (nm in names(vars_actives)) {
    vars_actives[[nm]]$w_norm <- vars_actives[[nm]]$w / w_total
  }

  # Calcul interne
  .calculer <- function(df) {
    w_pond <- if (!is.null(poids)) df[[poids]] else rep(1, nrow(df))
    w_pond[is.na(w_pond) | w_pond <= 0] <- 1

    # Score de privation pondere pour chaque menage
    score <- numeric(nrow(df))
    for (nm in names(vars_actives)) {
      v   <- vars_actives[[nm]]$var
      wn  <- vars_actives[[nm]]$w_norm
      val <- as.numeric(df[[v]])
      val[is.na(val)] <- 0
      val <- pmax(0, pmin(1, val))
      score <- score + wn * val
    }

    # Identification des pauvres IPM
    pauvre <- as.integer(score >= seuil_k)

    # H : incidence
    H <- stats::weighted.mean(pauvre, w_pond, na.rm = TRUE)

    # A : intensite moyenne parmi les pauvres
    idx_pauvres <- which(pauvre == 1L)
    A <- if (length(idx_pauvres) > 0) {
      stats::weighted.mean(score[idx_pauvres], w_pond[idx_pauvres],
                            na.rm = TRUE)
    } else 0

    # IPM = H x A
    IPM_val <- H * A

    # Contribution de chaque indicateur a l'IPM
    contrib <- sapply(names(vars_actives), function(nm) {
      v  <- vars_actives[[nm]]$var
      wn <- vars_actives[[nm]]$w_norm
      val <- as.numeric(df[[v]])
      val[is.na(val)] <- 0
      val_pauvres <- val[idx_pauvres]
      w_p <- w_pond[idx_pauvres]
      if (length(val_pauvres) == 0 || IPM_val == 0) return(0)
      contrib_i <- H * wn * stats::weighted.mean(val_pauvres, w_p,
                                                   na.rm = TRUE)
      contrib_i / IPM_val
    })

    list(IPM = IPM_val, H = H, A = A,
         score = score, pauvre = pauvre,
         contrib = contrib, n = nrow(df))
  }

  res <- .calculer(donnees)

  # Bootstrap pour IC
  ic_res <- NULL
  if (ic) {
    n_boot <- as.integer(n_bootstrap)
    ipm_boot <- numeric(n_boot)
    h_boot   <- numeric(n_boot)
    a_boot   <- numeric(n_boot)
    set.seed(42L)
    for (b in seq_len(n_boot)) {
      idx     <- sample(nrow(donnees), replace = TRUE)
      rb      <- .calculer(donnees[idx, ])
      ipm_boot[b] <- rb$IPM
      h_boot[b]   <- rb$H
      a_boot[b]   <- rb$A
    }
    ic_res <- list(
      IPM = stats::quantile(ipm_boot, c(0.025, 0.975)),
      H   = stats::quantile(h_boot,   c(0.025, 0.975)),
      A   = stats::quantile(a_boot,   c(0.025, 0.975))
    )
  }

  # Tableau des contributions
  contrib_df <- tibble::tibble(
    indicateur       = names(vars_actives),
    dimension        = unlist(dims_noms[names(vars_actives)]),
    poids            = sapply(vars_actives, function(x) x$w_norm),
    part_contribution = as.numeric(res$contrib)
  )

  structure(
    list(
      IPM              = res$IPM,
      H                = res$H,
      A                = res$A,
      contributions    = contrib_df,
      n_obs            = res$n,
      n_pauvres        = sum(res$pauvre),
      seuil_k          = seuil_k,
      methode          = "Alkire-Foster (2011)",
      ic               = ic_res,
      vars_actives     = names(vars_actives),
      score            = res$score,
      pauvre           = res$pauvre
    ),
    class = "saf_ipm"
  )
}

#' @export
print.saf_ipm <- function(x, ...) {
  cat("\n=== Indice de Pauvrete Multidimensionnelle (IPM) ===\n")
  cat("Methode    :", x$methode, "\n")
  cat("Seuil k    :", round(x$seuil_k * 100, 1), "%\n")
  cat("N obs      :", format(x$n_obs, big.mark = " "), "\n\n")
  cat(sprintf("  IPM = %.4f  (H x A)\n", x$IPM))
  cat(sprintf("  H   = %.1f%% (incidence)\n",  x$H * 100))
  cat(sprintf("  A   = %.1f%% (intensite)\n\n", x$A * 100))

  cat("Contributions par indicateur :\n")
  contrib <- x$contributions
  contrib$pct_contrib <- round(contrib$part_contribution * 100, 1)
  for (i in seq_len(nrow(contrib))) {
    cat(sprintf("  %-20s [%-15s] %5.1f%%\n",
                contrib$indicateur[i],
                contrib$dimension[i],
                contrib$pct_contrib[i]))
  }
  if (!is.null(x$ic)) {
    cat("\nIntervalles de confiance 95% (bootstrap) :\n")
    cat(sprintf("  IPM : [%.4f ; %.4f]\n", x$ic$IPM[1], x$ic$IPM[2]))
    cat(sprintf("  H   : [%.3f ; %.3f]\n", x$ic$H[1],   x$ic$H[2]))
    cat(sprintf("  A   : [%.3f ; %.3f]\n", x$ic$A[1],   x$ic$A[2]))
  }
  invisible(x)
}

# =============================================================================
# 2. IPM NATIONAL PERSONNALISE
# =============================================================================

#' @title Calculer un IPM national personnalise
#' @description Calcule un IPM national adapte aux realites locales
#'   (ODD 1.2.2). L'INS peut choisir ses indicateurs, leurs poids et
#'   le seuil k.
#'
#' @param donnees data.frame -- Donnees menages
#' @param indicateurs list -- Liste nommee definissant les indicateurs :
#'   chaque element contient \code{var} (nom de variable), \code{poids}
#'   (poids numerique) et \code{dimension} (nom de la dimension).
#' @param poids character ou NULL -- Variable de ponderation.
#'   Defaut : NULL
#' @param seuil_k numeric -- Seuil de pauvrete. Defaut : 1/3
#' @param ic logical -- Intervalles de confiance bootstrap. Defaut : FALSE
#' @param n_bootstrap integer -- Replications bootstrap. Defaut : 200L
#'
#' @return Un objet \code{saf_ipm}
#'
#' @examples
#' set.seed(42)
#' n <- 150
#' menages <- data.frame(
#'   eau        = rbinom(n, 1, 0.45),
#'   electricite = rbinom(n, 1, 0.60),
#'   scol       = rbinom(n, 1, 0.35),
#'   sante      = rbinom(n, 1, 0.25),
#'   poids      = runif(n, 0.8, 1.3)
#' )
#' indics <- list(
#'   acces_eau   = list(var = "eau",        poids = 0.25,
#'                      dimension = "Conditions de vie"),
#'   acces_elec  = list(var = "electricite", poids = 0.25,
#'                      dimension = "Conditions de vie"),
#'   education   = list(var = "scol",       poids = 0.30,
#'                      dimension = "Education"),
#'   sante_base  = list(var = "sante",      poids = 0.20,
#'                      dimension = "Sante")
#' )
#' res <- calcul_ipm_national(menages, indicateurs = indics,
#'                             poids = "poids", seuil_k = 1/3)
#' print(res)
#'
#' @export
calcul_ipm_national <- function(donnees,
                                  indicateurs,
                                  poids       = NULL,
                                  seuil_k     = 1/3,
                                  ic          = FALSE,
                                  n_bootstrap = 200L) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!is.list(indicateurs) || length(indicateurs) == 0L) {
    rlang::abort(paste0(
      "`indicateurs` doit etre une liste non vide.\n",
      "Format : list(nom = list(var='col', poids=0.25, dimension='Sante'))"
    ))
  }
  if (seuil_k <= 0 || seuil_k >= 1) {
    rlang::abort("`seuil_k` doit etre entre 0 et 1 exclus.")
  }

  # Validation de la structure
  for (nm in names(indicateurs)) {
    ind <- indicateurs[[nm]]
    if (is.null(ind$var)) {
      rlang::abort(paste0("Indicateur '", nm, "' : element 'var' manquant."))
    }
    if (is.null(ind$poids)) {
      rlang::abort(paste0("Indicateur '", nm, "' : element 'poids' manquant."))
    }
    if (!ind$var %in% names(donnees)) {
      rlang::abort(paste0(
        "Variable '", ind$var, "' (indicateur '", nm, "') ",
        "introuvable dans les donnees."
      ))
    }
  }

  if (!is.null(poids) && !poids %in% names(donnees)) {
    rlang::abort(paste0("Variable de poids '", poids, "' introuvable."))
  }

  # Renormaliser les poids
  w_total <- sum(sapply(indicateurs, `[[`, "poids"))
  if (abs(w_total - 1) > 0.01) {
    rlang::inform(paste0(
      "Somme des poids = ", round(w_total, 4),
      " (renormalisation automatique a 1)."
    ))
  }
  for (nm in names(indicateurs)) {
    indicateurs[[nm]]$poids_norm <- indicateurs[[nm]]$poids / w_total
  }

  # Calcul
  .calc <- function(df) {
    w_pond <- if (!is.null(poids)) df[[poids]] else rep(1, nrow(df))
    w_pond[is.na(w_pond) | w_pond <= 0] <- 1

    score <- numeric(nrow(df))
    for (nm in names(indicateurs)) {
      v  <- indicateurs[[nm]]$var
      wn <- indicateurs[[nm]]$poids_norm
      val <- as.numeric(df[[v]])
      val[is.na(val)] <- 0
      val <- pmax(0, pmin(1, val))
      score <- score + wn * val
    }

    pauvre <- as.integer(score >= seuil_k)
    H      <- stats::weighted.mean(pauvre, w_pond, na.rm = TRUE)
    idx_p  <- which(pauvre == 1L)
    A      <- if (length(idx_p) > 0)
      stats::weighted.mean(score[idx_p], w_pond[idx_p], na.rm = TRUE)
    else 0
    IPM_v  <- H * A

    contrib <- sapply(names(indicateurs), function(nm) {
      v  <- indicateurs[[nm]]$var
      wn <- indicateurs[[nm]]$poids_norm
      val <- as.numeric(df[[v]])
      val[is.na(val)] <- 0
      if (length(idx_p) == 0 || IPM_v == 0) return(0)
      H * wn * stats::weighted.mean(val[idx_p], w_pond[idx_p],
                                     na.rm = TRUE) / IPM_v
    })

    list(IPM = IPM_v, H = H, A = A, score = score,
         pauvre = pauvre, contrib = contrib, n = nrow(df))
  }

  res <- .calc(donnees)

  ic_res <- NULL
  if (ic) {
    nb <- as.integer(n_bootstrap)
    ipm_b <- h_b <- a_b <- numeric(nb)
    set.seed(42L)
    for (b in seq_len(nb)) {
      idx <- sample(nrow(donnees), replace = TRUE)
      rb  <- .calc(donnees[idx, ])
      ipm_b[b] <- rb$IPM; h_b[b] <- rb$H; a_b[b] <- rb$A
    }
    ic_res <- list(
      IPM = stats::quantile(ipm_b, c(0.025, 0.975)),
      H   = stats::quantile(h_b,   c(0.025, 0.975)),
      A   = stats::quantile(a_b,   c(0.025, 0.975))
    )
  }

  contrib_df <- tibble::tibble(
    indicateur        = names(indicateurs),
    dimension         = sapply(indicateurs, function(x)
      if (!is.null(x$dimension)) x$dimension else "Non specifie"),
    poids             = sapply(indicateurs, `[[`, "poids_norm"),
    part_contribution = as.numeric(res$contrib)
  )

  structure(
    list(
      IPM           = res$IPM,
      H             = res$H,
      A             = res$A,
      contributions = contrib_df,
      n_obs         = res$n,
      n_pauvres     = sum(res$pauvre),
      seuil_k       = seuil_k,
      methode       = "IPM National (Alkire-Foster adapte) - ODD 1.2.2",
      ic            = ic_res,
      vars_actives  = sapply(indicateurs, `[[`, "var"),
      score         = res$score,
      pauvre        = res$pauvre
    ),
    class = "saf_ipm"
  )
}

# =============================================================================
# 3. DECOMPOSITION IPM
# =============================================================================

#' @title Decomposer l'IPM par sous-groupe
#' @description Decompose l'IPM par region, milieu ou sexe du chef de
#'   menage. Retourne H, A et IPM par groupe, ainsi que la contribution
#'   de chaque groupe a l'IPM national.
#'
#' @param res_ipm saf_ipm -- Resultat de \code{calcul_ipm()} ou
#'   \code{calcul_ipm_national()}
#' @param donnees data.frame -- Donnees originales (meme ordre que
#'   lors du calcul de l'IPM)
#' @param var_groupe character -- Variable de sous-groupe
#'   (ex : "region", "milieu", "sexe_cm")
#' @param poids character ou NULL -- Variable de ponderation.
#'   Defaut : NULL
#'
#' @return Un tibble avec H, A, IPM, n_obs et contribution par groupe
#'
#' @examples
#' set.seed(42)
#' n <- 300
#' menages <- data.frame(
#'   nutrition      = rbinom(n, 1, 0.35),
#'   electricite    = rbinom(n, 1, 0.60),
#'   eau            = rbinom(n, 1, 0.40),
#'   milieu         = sample(c("urbain","rural"), n, TRUE),
#'   poids          = runif(n, 0.8, 1.3)
#' )
#' res <- calcul_ipm(menages,
#'   var_nutrition = "nutrition", var_electricite = "electricite",
#'   var_eau = "eau", poids = "poids")
#' decomposer_ipm(res, menages, var_groupe = "milieu", poids = "poids")
#'
#' @export
decomposer_ipm <- function(res_ipm, donnees, var_groupe,
                             poids = NULL) {

  if (!inherits(res_ipm, "saf_ipm")) {
    rlang::abort(paste0(
      "`res_ipm` doit etre un objet saf_ipm.\n",
      "Utilisez calcul_ipm() ou calcul_ipm_national() d'abord."
    ))
  }
  if (!is.data.frame(donnees)) {
    rlang::abort("`donnees` doit etre un data.frame.")
  }
  if (!var_groupe %in% names(donnees)) {
    rlang::abort(paste0(
      "Variable '", var_groupe, "' introuvable.\n",
      "Colonnes disponibles : ", paste(names(donnees), collapse = ", ")
    ))
  }
  if (nrow(donnees) != length(res_ipm$score)) {
    rlang::abort(paste0(
      "Nombre de lignes different entre `donnees` (", nrow(donnees),
      ") et l'objet saf_ipm (", length(res_ipm$score), ").\n",
      "Utilisez les memes donnees que lors du calcul de l'IPM."
    ))
  }

  w_pond <- if (!is.null(poids) && poids %in% names(donnees))
    donnees[[poids]] else rep(1, nrow(donnees))
  w_pond[is.na(w_pond) | w_pond <= 0] <- 1

  score  <- res_ipm$score
  pauvre <- res_ipm$pauvre
  groupe <- as.character(donnees[[var_groupe]])
  groupes <- sort(unique(groupe[!is.na(groupe)]))

  resultats <- lapply(groupes, function(g) {
    idx <- which(groupe == g & !is.na(groupe))
    if (length(idx) < 5L) {
      rlang::warn(paste0("Groupe '", g, "' : moins de 5 observations."))
    }
    sc_g <- score[idx]; pa_g <- pauvre[idx]; wp_g <- w_pond[idx]
    H_g  <- stats::weighted.mean(pa_g, wp_g, na.rm = TRUE)
    idx_p <- which(pa_g == 1L)
    A_g  <- if (length(idx_p) > 0)
      stats::weighted.mean(sc_g[idx_p], wp_g[idx_p], na.rm = TRUE)
    else 0
    tibble::tibble(
      groupe = g, H = H_g, A = A_g,
      IPM = H_g * A_g, n_obs = length(idx),
      poids_groupe = sum(wp_g)
    )
  })

  res_df <- dplyr::bind_rows(resultats)

  # Contribution de chaque groupe a l'IPM national
  poids_total <- sum(res_df$poids_groupe)
  res_df$contribution_pct <- round(
    (res_df$IPM * res_df$poids_groupe / poids_total) /
      res_ipm$IPM * 100, 1
  )
  res_df$H   <- round(res_df$H   * 100, 2)
  res_df$A   <- round(res_df$A   * 100, 2)
  res_df$IPM <- round(res_df$IPM, 4)

  names(res_df)[1] <- var_groupe
  message("Decomposition IPM par ", var_groupe,
          " : ", length(groupes), " groupes")
  res_df
}

# =============================================================================
# 4. COMPARAISON GLOBAL MPI vs NATIONAL MPI
# =============================================================================

#' @title Comparer l'IPM global et l'IPM national
#' @description Compare les resultats du MPI global PNUD/OPHI et d'un
#'   IPM national. Produit un tableau des ecarts et un graphique.
#'
#' @param ipm_global saf_ipm -- Resultat IPM global (calcul_ipm())
#' @param ipm_national saf_ipm -- Resultat IPM national
#'   (calcul_ipm_national())
#' @param pays character -- Nom du pays. Defaut : "Pays"
#' @param annee integer -- Annee. Defaut : annee courante
#'
#' @return Un tibble comparatif + graphique (invisible)
#'
#' @examples
#' set.seed(42)
#' n <- 200
#' men <- data.frame(
#'   nutr = rbinom(n,1,0.35), elec = rbinom(n,1,0.6),
#'   eau  = rbinom(n,1,0.4),  scol = rbinom(n,1,0.3),
#'   mort = rbinom(n,1,0.12), comb = rbinom(n,1,0.5),
#'   poids = runif(n,0.8,1.3)
#' )
#' ipm_g <- calcul_ipm(men, var_nutrition="nutr",
#'   var_electricite="elec", var_eau="eau",
#'   var_scolarisation="scol", var_mortalite_inf="mort",
#'   var_combustible="comb", poids="poids")
#' ipm_n <- calcul_ipm_national(men,
#'   indicateurs=list(
#'     eau  = list(var="eau",  poids=0.4, dimension="Vie"),
#'     elec = list(var="elec", poids=0.35, dimension="Vie"),
#'     scol = list(var="scol", poids=0.25, dimension="Education")
#'   ), poids="poids")
#' comparer_ipm(ipm_g, ipm_n, pays="Centrafrique", annee=2026L)
#'
#' @export
comparer_ipm <- function(ipm_global, ipm_national,
                          pays = "Pays",
                          annee = as.integer(format(Sys.Date(), "%Y"))) {

  if (!inherits(ipm_global,   "saf_ipm")) {
    rlang::abort("`ipm_global` doit etre un objet saf_ipm.")
  }
  if (!inherits(ipm_national, "saf_ipm")) {
    rlang::abort("`ipm_national` doit etre un objet saf_ipm.")
  }

  comp <- tibble::tibble(
    indicateur = c("IPM", "H - Incidence (%)", "A - Intensite (%)"),
    global     = c(round(ipm_global$IPM,    4),
                   round(ipm_global$H  * 100, 2),
                   round(ipm_global$A  * 100, 2)),
    national   = c(round(ipm_national$IPM,  4),
                   round(ipm_national$H * 100, 2),
                   round(ipm_national$A * 100, 2))
  )
  comp$ecart <- comp$national - comp$global
  comp$ecart_pct <- round((comp$ecart / comp$global) * 100, 1)

  message("=== Comparaison MPI Global vs IPM National === ",
          pays, " - ", annee)
  message("  IPM Global   : ", round(ipm_global$IPM,   4),
          "  (H=", round(ipm_global$H * 100, 1), "%, A=",
          round(ipm_global$A * 100, 1), "%)")
  message("  IPM National : ", round(ipm_national$IPM, 4),
          "  (H=", round(ipm_national$H * 100, 1), "%, A=",
          round(ipm_national$A * 100, 1), "%)")
  message("  Ecart IPM   : ", round(comp$ecart[1], 4),
          "  (", round(comp$ecart_pct[1], 1), "%)")

  invisible(comp)
}

# =============================================================================
# 5. GRAPHIQUE IPM
# =============================================================================

#' @title Graphique des contributions IPM
#' @description Produit un graphique en barres des contributions de chaque
#'   indicateur et chaque dimension a l'IPM. Retourne un objet ggplot2.
#'
#' @param res_ipm saf_ipm -- Resultat de \code{calcul_ipm()} ou
#'   \code{calcul_ipm_national()}
#' @param type character -- \code{"indicateurs"} ou \code{"dimensions"}.
#'   Defaut : "indicateurs"
#' @param titre character ou NULL -- Titre du graphique. Defaut : NULL
#' @param source character ou NULL -- Note de source. Defaut : NULL
#'
#' @return Un objet \code{ggplot2}
#'
#' @examples
#' set.seed(42)
#' n <- 200
#' menages <- data.frame(
#'   nutrition   = rbinom(n,1,0.35), electricite = rbinom(n,1,0.60),
#'   eau         = rbinom(n,1,0.40), scolarisation = rbinom(n,1,0.30),
#'   poids       = runif(n,0.8,1.3)
#' )
#' res <- calcul_ipm(menages, var_nutrition="nutrition",
#'   var_electricite="electricite", var_eau="eau",
#'   var_scolarisation="scolarisation", poids="poids")
#' graphique_ipm(res)
#'
#' @export
graphique_ipm <- function(res_ipm,
                           type   = c("indicateurs", "dimensions"),
                           titre  = NULL,
                           source = NULL) {

  if (!inherits(res_ipm, "saf_ipm")) {
    rlang::abort(paste0(
      "`res_ipm` doit etre un objet saf_ipm.\n",
      "Utilisez calcul_ipm() ou calcul_ipm_national() d'abord."
    ))
  }

  type <- match.arg(type)
  contrib <- res_ipm$contributions

  if (type == "indicateurs") {
    df_plot <- contrib
    df_plot$label <- paste0(round(df_plot$part_contribution * 100, 1), "%")
    df_plot$indicateur <- factor(
      df_plot$indicateur,
      levels = df_plot$indicateur[order(df_plot$part_contribution)]
    )

    couleurs_dim <- c(
      "Sante"         = "#DC2626",
      "Education"     = "#7C3AED",
      "Niveau de vie" = "#1B4965",
      "Conditions de vie" = "#1B4965",
      "Non specifie"  = "#64748B"
    )

    g <- ggplot2::ggplot(df_plot,
      ggplot2::aes(x = .data$indicateur,
                   y = .data$part_contribution * 100,
                   fill = .data$dimension)) +
      ggplot2::geom_col(width = 0.7, alpha = 0.9) +
      ggplot2::geom_text(ggplot2::aes(label = .data$label),
                          hjust = -0.1, size = 3.2,
                          color = "#1E293B", fontface = "bold") +
      ggplot2::scale_fill_manual(values = couleurs_dim,
                                  name = "Dimension") +
      ggplot2::scale_y_continuous(
        expand = ggplot2::expansion(mult = c(0, 0.2)),
        labels = function(x) paste0(x, "%")
      ) +
      ggplot2::coord_flip() +
      ggplot2::theme_minimal(base_size = 11) +
      ggplot2::theme(
        plot.background = ggplot2::element_rect(
          fill = "#F0F7FF", color = NA),
        plot.title      = ggplot2::element_text(
          size = 13, face = "bold", color = "#0F2742"),
        plot.caption    = ggplot2::element_text(
          size = 8, color = "#94A3B8", hjust = 1),
        panel.grid.major.y = ggplot2::element_blank(),
        legend.position = "bottom"
      ) +
      ggplot2::labs(
        title   = if (!is.null(titre)) titre
                  else "Contribution des indicateurs a l'IPM",
        x       = NULL,
        y       = "Contribution (%)",
        caption = if (!is.null(source))
          paste0("Source : ", source, " | statAfrikR")
        else "statAfrikR Foundation | Methode Alkire-Foster (2011)"
      )

  } else {
    # Agregation par dimension
    df_dim <- contrib |>
      dplyr::group_by(.data$dimension) |>
      dplyr::summarise(
        contribution = sum(.data$part_contribution),
        .groups = "drop"
      )
    df_dim$label <- paste0(round(df_dim$contribution * 100, 1), "%")
    df_dim$dimension <- factor(
      df_dim$dimension,
      levels = df_dim$dimension[order(df_dim$contribution)]
    )

    g <- ggplot2::ggplot(df_dim,
      ggplot2::aes(x = .data$dimension,
                   y = .data$contribution * 100,
                   fill = .data$dimension)) +
      ggplot2::geom_col(width = 0.6, alpha = 0.9) +
      ggplot2::geom_text(ggplot2::aes(label = .data$label),
                          hjust = -0.1, size = 4, fontface = "bold",
                          color = "#1E293B") +
      ggplot2::scale_fill_manual(
        values = c("Sante" = "#DC2626", "Education" = "#7C3AED",
                   "Niveau de vie" = "#1B4965",
                   "Conditions de vie" = "#1B4965"),
        guide = "none"
      ) +
      ggplot2::scale_y_continuous(
        expand = ggplot2::expansion(mult = c(0, 0.25)),
        labels = function(x) paste0(x, "%")
      ) +
      ggplot2::coord_flip() +
      ggplot2::theme_minimal(base_size = 12) +
      ggplot2::theme(
        plot.background = ggplot2::element_rect(
          fill = "#F0F7FF", color = NA),
        plot.title      = ggplot2::element_text(
          size = 13, face = "bold", color = "#0F2742"),
        panel.grid.major.y = ggplot2::element_blank()
      ) +
      ggplot2::labs(
        title   = if (!is.null(titre)) titre
                  else "Contribution des dimensions a l'IPM",
        x       = NULL,
        y       = "Contribution (%)",
        caption = if (!is.null(source))
          paste0("Source : ", source, " | statAfrikR")
        else "statAfrikR Foundation | Methode Alkire-Foster (2011)"
      )
  }
  g
}

# =============================================================================
# 6. TABLEAU IPM INSTITUTIONNEL
# =============================================================================

#' @title Tableau institutionnel IPM
#' @description Genere un tableau flextable institutionnel (style INS/PARIS21)
#'   des resultats IPM, exportable en Word ou Excel.
#'
#' @param res_ipm saf_ipm -- Resultat de calcul_ipm() ou
#'   calcul_ipm_national()
#' @param pays character -- Nom du pays. Defaut : "Pays"
#' @param annee integer -- Annee de reference
#' @param chemin_word character ou NULL -- Chemin Word (.docx).
#'   Si NULL, retourne l'objet flextable. Defaut : NULL
#'
#' @return Un objet \code{flextable} (invisible si chemin_word fourni)
#'
#' @examples
#' set.seed(42)
#' n <- 200
#' menages <- data.frame(
#'   nutrition   = rbinom(n,1,0.35), electricite = rbinom(n,1,0.60),
#'   eau         = rbinom(n,1,0.40), poids = runif(n,0.8,1.3)
#' )
#' res <- calcul_ipm(menages, var_nutrition="nutrition",
#'   var_electricite="electricite", var_eau="eau", poids="poids")
#' tableau_ipm(res, pays="Centrafrique", annee=2026L)
#'
#' @export
tableau_ipm <- function(res_ipm,
                         pays        = "Pays",
                         annee       = as.integer(format(Sys.Date(), "%Y")),
                         chemin_word = NULL) {

  if (!inherits(res_ipm, "saf_ipm")) {
    rlang::abort("`res_ipm` doit etre un objet saf_ipm.")
  }
  if (!requireNamespace("flextable", quietly = TRUE)) {
    rlang::abort(paste0(
      "Le package 'flextable' est requis pour tableau_ipm().\n",
      "Installez-le avec : install.packages('flextable')"
    ))
  }

  # Tableau principal
  df_tab <- tibble::tibble(
    Indicateur  = c("IPM (H x A)", "H - Incidence",
                    "A - Intensite", "N observations", "N pauvres MPI"),
    Valeur      = c(round(res_ipm$IPM,       4),
                    paste0(round(res_ipm$H * 100, 2), "%"),
                    paste0(round(res_ipm$A * 100, 2), "%"),
                    format(res_ipm$n_obs,    big.mark = " "),
                    format(res_ipm$n_pauvres, big.mark = " ")),
    Description = c("Indice de Pauvrete Multidimensionnelle",
                    "Proportion de menages multidimensionnellement pauvres",
                    "Intensite moyenne de privation parmi les pauvres",
                    "Taille de l'echantillon analyse",
                    paste0("Menages avec score >= ",
                           round(res_ipm$seuil_k * 100, 0), "%"))
  )

  ft <- flextable::flextable(df_tab) |>
    flextable::set_caption(paste0(
      "Indice de Pauvrete Multidimensionnelle \u2014 ",
      pays, " \u2014 ", annee
    )) |>
    flextable::theme_vanilla() |>
    flextable::bg(i = 1, bg = "#1B4965", part = "header") |>
    flextable::color(i = 1, color = "white", part = "header") |>
    flextable::bold(i = 1, part = "header") |>
    flextable::bold(j = "Indicateur") |>
    flextable::bg(i = c(1, 3, 5), bg = "#E8F4FA") |>
    flextable::autofit() |>
    flextable::add_footer_lines(paste0(
      "Methode : ", res_ipm$methode,
      " | Seuil k = ", round(res_ipm$seuil_k * 100, 0), "% | ",
      "statAfrikR Foundation"
    ))

  if (!is.null(chemin_word)) {
    if (!requireNamespace("officer", quietly = TRUE)) {
      rlang::abort("Le package 'officer' est requis pour l'export Word.")
    }
    doc <- officer::read_docx()
    doc <- flextable::body_add_flextable(doc, ft)
    print(doc, target = chemin_word)
    message("Tableau IPM exporte : ", chemin_word)
    return(invisible(ft))
  }

  ft
}

# =============================================================================
# 7. CARTE IPM
# =============================================================================

#' @title Carte des privations IPM par zone
#' @description Cartographie l'IPM ou une composante (H, A, ou un
#'   indicateur de privation) par zone geographique. Necessite un objet
#'   sf et les resultats de decomposer_ipm().
#'
#' @param decomp_ipm tibble -- Resultat de \code{decomposer_ipm()}
#' @param sf_obj sf -- Fond de carte (depuis \code{carte_zones()})
#' @param cle_sf character -- Variable cle dans \code{sf_obj}
#' @param cle_decomp character -- Variable cle dans \code{decomp_ipm}
#' @param var character -- Variable a cartographier :
#'   \code{"IPM"}, \code{"H"} ou \code{"A"}. Defaut : "IPM"
#' @param titre character ou NULL -- Titre. Defaut : NULL
#' @param source character ou NULL -- Source. Defaut : NULL
#'
#' @return Un objet \code{ggplot2}
#'
#' @examples
#' \dontrun{
#'   rca <- carte_zones("rca")
#'   res <- calcul_ipm(menages_rca, ...)
#'   decomp <- decomposer_ipm(res, menages_rca, "prefecture")
#'   carte_ipm(decomp, rca, cle_sf="prefecture",
#'             cle_decomp="prefecture")
#' }
#'
#' @export
carte_ipm <- function(decomp_ipm,
                       sf_obj,
                       cle_sf,
                       cle_decomp,
                       var    = c("IPM", "H", "A"),
                       titre  = NULL,
                       source = NULL) {

  if (!is.data.frame(decomp_ipm)) {
    rlang::abort("`decomp_ipm` doit etre un tibble (resultat de decomposer_ipm()).")
  }
  if (!inherits(sf_obj, "sf")) {
    rlang::abort("`sf_obj` doit etre un objet sf.")
  }

  var <- match.arg(var)

  if (!var %in% names(decomp_ipm)) {
    rlang::abort(paste0("Variable '", var, "' absente de decomp_ipm."))
  }

  # Jointure
  sf_enr <- suppressMessages(
    carte_joindre(sf_obj, as.data.frame(decomp_ipm),
                  cle_geo  = cle_sf,
                  cle_data = cle_decomp,
                  type     = "gauche")
  )

  label_var <- switch(var,
    "IPM" = "IPM",
    "H"   = "Incidence H (%)",
    "A"   = "Intensite A (%)"
  )

  titre_auto <- switch(var,
    "IPM" = "Indice de Pauvrete Multidimensionnelle (IPM)",
    "H"   = "Incidence de la pauvrete multidimensionnelle (H)",
    "A"   = "Intensite de la pauvrete multidimensionnelle (A)"
  )

  carte_choroplethe(
    sf_obj    = sf_enr,
    var       = var,
    titre     = if (!is.null(titre)) titre else titre_auto,
    legende   = label_var,
    palette   = "pauvrete",
    methode   = "quantile",
    source    = if (!is.null(source)) source
                else "statAfrikR | Alkire-Foster (2011)"
  )
}
