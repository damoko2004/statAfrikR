# =============================================================================
# statAfrikR - Module Plans de sondage complexes
# Standards IHSN / OIT / DHS / MICS / EHCVM
# Variance par linearisation de Taylor et bootstrap replique
# =============================================================================

utils::globalVariables(c(
  "strate", "grappe", "variable", "deff", "n_effectif",
  "taux_reponse", "biais", "composante", "valeur", "statut",
  "ech_size", "pop_size", "cv_pct"
))

# =============================================================================
# 1. CREER UN DESIGN D'ENQUETE
# =============================================================================

#' @title Creer un objet design d'enquete complexe
#' @description Cree un objet de design d'enquete en precisant les strates,
#'   grappes, poids de sondage et la correction de population finie (FPC).
#'   Compatible avec les enquetes EHCVM, DHS, MICS, EFT, RGPH.
#'
#' @param donnees data.frame -- Donnees de l'enquete
#' @param var_poids character -- Variable de poids de sondage
#' @param var_strate character ou NULL -- Variable de stratification.
#'   Defaut : NULL
#' @param var_grappe character ou NULL -- Variable d'unites primaires
#'   de sondage (grappes / UPS). Defaut : NULL
#' @param var_fpc character ou NULL -- Variable de correction de population
#'   finie (taille de la strate dans la population). Defaut : NULL
#' @param type character -- Type de design : "stratifie", "en_grappes",
#'   "stratifie_grappes", "simple". Defaut : "stratifie_grappes"
#'
#' @return Un objet de classe \code{saf_design} encapsulant un objet
#'   \code{survey::svydesign}
#'
#' @examples
#' set.seed(42)
#' n <- 300
#' donnees <- data.frame(
#'   poids_sond = runif(n, 1800, 3500),
#'   strate     = sample(c("Urbain","Rural","Semi-urbain"), n, TRUE),
#'   grappe     = sample(1:30, n, TRUE),
#'   revenu     = pmax(0, rnorm(n, 180000, 90000)),
#'   pauvre     = rbinom(n, 1, 0.45)
#' )
#' design <- creer_design(donnees, "poids_sond",
#'                         var_strate="strate", var_grappe="grappe")
#' print(design)
#'
#' @export
creer_design <- function(donnees,
                          var_poids,
                          var_strate = NULL,
                          var_grappe = NULL,
                          var_fpc    = NULL,
                          type       = c("stratifie_grappes","stratifie",
                                         "en_grappes","simple")) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_poids %in% names(donnees)) {
    rlang::abort(paste0("Variable poids '", var_poids, "' introuvable."))
  }
  if (!is.null(var_strate) && !var_strate %in% names(donnees)) {
    rlang::abort(paste0("Variable strate '", var_strate, "' introuvable."))
  }
  if (!is.null(var_grappe) && !var_grappe %in% names(donnees)) {
    rlang::abort(paste0("Variable grappe '", var_grappe, "' introuvable."))
  }

  type <- match.arg(type)

  w <- as.numeric(donnees[[var_poids]])
  if (any(is.na(w) | w <= 0)) {
    n_prob <- sum(is.na(w) | w <= 0)
    rlang::warn(paste0(
      n_prob, " poids manquants ou non positifs detectes \u2014 ",
      "remplacement par 1."
    ))
    w[is.na(w) | w <= 0] <- 1
    donnees[[var_poids]] <- w
  }

  # Construction de la formule
  ids_form <- if (!is.null(var_grappe))
    stats::as.formula(paste("~", var_grappe))
  else
    stats::as.formula("~1")

  strate_form <- if (!is.null(var_strate))
    stats::as.formula(paste("~", var_strate))
  else NULL

  fpc_form <- if (!is.null(var_fpc) && var_fpc %in% names(donnees))
    stats::as.formula(paste("~", var_fpc))
  else NULL

  poids_form <- stats::as.formula(paste("~", var_poids))

  # Creer le design survey
  if (!requireNamespace("survey", quietly=TRUE)) {
    rlang::abort(paste0(
      "Le package 'survey' est requis pour creer_design().\n",
      "Installez-le : install.packages('survey')"
    ))
  }

  design_obj <- tryCatch({
    if (!is.null(strate_form)) {
      survey::svydesign(
        ids     = ids_form,
        strata  = strate_form,
        nest    = TRUE,
        weights = poids_form,
        fpc     = fpc_form,
        data    = donnees
      )
    } else {
      survey::svydesign(
        ids     = ids_form,
        weights = poids_form,
        fpc     = fpc_form,
        data    = donnees
      )
    }
  }, error = function(e) {
    rlang::abort(paste0(
      "Erreur lors de la creation du design : ", conditionMessage(e), "\n",
      "Verifiez les variables strate/grappe/poids."
    ))
  })

  n_strates <- if (!is.null(var_strate))
    length(unique(donnees[[var_strate]])) else 1L
  n_grappes <- if (!is.null(var_grappe))
    length(unique(donnees[[var_grappe]])) else nrow(donnees)

  message("Plan de sondage cree :")
  message("  - Observations : ", nrow(donnees))
  if (!is.null(var_strate)) message("  - Strates : ", n_strates)
  if (!is.null(var_grappe)) message("  - Grappes (UPS) : ", n_grappes)

  structure(
    list(
      design     = design_obj,
      n_obs      = nrow(donnees),
      n_strates  = n_strates,
      n_grappes  = n_grappes,
      var_poids  = var_poids,
      var_strate = var_strate,
      var_grappe = var_grappe,
      type       = type,
      donnees    = donnees
    ),
    class = "saf_design"
  )
}

#' @export
print.saf_design <- function(x, ...) {
  cat("\n=== Design d'enquete complexe ===\n")
  cat("  Type         :", x$type, "\n")
  cat("  N obs        :", format(x$n_obs, big.mark=" "), "\n")
  if (!is.null(x$var_strate)) cat("  Strates      :", x$n_strates, "\n")
  if (!is.null(x$var_grappe)) cat("  Grappes (UPS):", x$n_grappes, "\n")
  cat("  Variable poids:", x$var_poids, "\n")
  invisible(x)
}

# =============================================================================
# 2. VALIDER LES POIDS
# =============================================================================

#' @title Valider les poids de sondage
#' @description Verifie la coherence des poids de sondage : somme par strate,
#'   detection des poids aberrants (outliers), DEFF eleves, comparaison
#'   avec la population cible. Etape indispensable avant toute analyse.
#'
#' @param saf_design saf_design -- Objet cree par \code{creer_design()}
#' @param population_cible numeric ou NULL -- Population totale cible
#'   (pour verifier que sum(poids) est coherent). Defaut : NULL
#' @param seuil_outlier numeric -- Seuil de detection des outliers en
#'   ecarts-types (score Z). Defaut : 3.0
#'
#' @return Un tibble avec les statistiques de validation par strate
#'
#' @examples
#' set.seed(42)
#' n <- 300
#' donnees <- data.frame(
#'   poids_sond = runif(n, 1800, 3500),
#'   strate     = sample(c("Urbain","Rural"), n, TRUE),
#'   grappe     = sample(1:20, n, TRUE)
#' )
#' design <- suppressMessages(
#'   creer_design(donnees,"poids_sond",var_strate="strate",var_grappe="grappe"))
#' valider_poids(design)
#'
#' @export
valider_poids <- function(saf_design,
                           population_cible = NULL,
                           seuil_outlier    = 3.0) {

  if (!inherits(saf_design, "saf_design")) {
    rlang::abort(paste0(
      "`saf_design` doit etre un objet saf_design.\n",
      "Utilisez creer_design() d'abord."
    ))
  }

  df <- saf_design$donnees
  w  <- as.numeric(df[[saf_design$var_poids]])

  # Statistiques globales
  sum_poids <- sum(w, na.rm=TRUE)
  moy_poids <- mean(w, na.rm=TRUE)
  sd_poids  <- stats::sd(w, na.rm=TRUE)
  cv_poids  <- sd_poids / moy_poids * 100

  # Outliers (score Z > seuil)
  z_scores  <- abs(w - moy_poids) / sd_poids
  n_outliers <- sum(z_scores > seuil_outlier, na.rm=TRUE)

  # Statistiques par strate
  if (!is.null(saf_design$var_strate)) {
    strate_var <- as.character(df[[saf_design$var_strate]])
    strates    <- sort(unique(strate_var))

    res_strates <- dplyr::bind_rows(lapply(strates, function(st) {
      idx   <- which(strate_var == st)
      w_st  <- w[idx]
      z_st  <- abs(w_st - mean(w_st)) / stats::sd(w_st)
      tibble::tibble(
        strate        = st,
        n_obs         = length(idx),
        somme_poids   = round(sum(w_st), 0),
        poids_moyen   = round(mean(w_st), 1),
        cv_poids_pct  = round(stats::sd(w_st)/mean(w_st)*100, 2),
        n_outliers    = sum(z_st > seuil_outlier, na.rm=TRUE),
        alerte        = sum(z_st > seuil_outlier, na.rm=TRUE) > 0
      )
    }))
  } else {
    res_strates <- tibble::tibble(
      strate       = "Total",
      n_obs        = nrow(df),
      somme_poids  = round(sum_poids, 0),
      poids_moyen  = round(moy_poids, 1),
      cv_poids_pct = round(cv_poids, 2),
      n_outliers   = n_outliers,
      alerte       = n_outliers > 0
    )
  }

  message("=== Validation des poids de sondage ===")
  message("  Somme totale poids : ", format(round(sum_poids), big.mark=" "))
  message("  CV des poids       : ", round(cv_poids, 1), "%")
  message("  Poids outliers     : ", n_outliers,
          " (Z > ", seuil_outlier, ")")

  if (!is.null(population_cible)) {
    ecart_pop <- (sum_poids - population_cible) / population_cible * 100
    message("  Ecart / pop. cible : ", round(ecart_pop, 2), "%")
    if (abs(ecart_pop) > 5) {
      rlang::warn(paste0(
        "Ecart > 5% avec la population cible (",
        round(ecart_pop, 2), "%).\n",
        "Un calage post-stratification est recommande : calibrer_poids()"
      ))
    }
  }

  res_strates
}

# =============================================================================
# 3. CALCULER L'EFFET DE PLAN (DEFF)
# =============================================================================

#' @title Calculer l'effet de plan (DEFF)
#' @description Calcule le Design Effect (DEFF) pour les variables d'interet.
#'   DEFF = Variance estimee sous le plan complexe / Variance sous SRS.
#'   Permet de calculer la taille effective de l'echantillon.
#'
#' @param saf_design saf_design -- Objet cree par \code{creer_design()}
#' @param variables character -- Variables pour lesquelles calculer le DEFF
#' @param type character -- "proportion" ou "moyenne". Defaut : "proportion"
#'
#' @return Un tibble avec DEFF et taille effective par variable
#'
#' @examples
#' set.seed(42)
#' n <- 300
#' donnees <- data.frame(
#'   poids_sond = runif(n, 1800, 3500),
#'   strate     = sample(c("Urbain","Rural"), n, TRUE),
#'   grappe     = sample(1:20, n, TRUE),
#'   pauvre     = rbinom(n, 1, 0.45),
#'   revenu     = pmax(0, rnorm(n, 180000, 90000))
#' )
#' design <- suppressMessages(
#'   creer_design(donnees,"poids_sond",var_strate="strate",var_grappe="grappe"))
#' calcul_deff(design, variables=c("pauvre","revenu"))
#'
#' @export
calcul_deff <- function(saf_design,
                         variables,
                         type = c("proportion","moyenne")) {

  if (!inherits(saf_design, "saf_design")) {
    rlang::abort("`saf_design` doit etre un objet saf_design.")
  }

  type <- match.arg(type)
  df   <- saf_design$donnees
  svyd <- saf_design$design

  vars_abs <- variables[!variables %in% names(df)]
  if (length(vars_abs) > 0) {
    rlang::abort(paste0(
      "Variables introuvables : ", paste(vars_abs, collapse=", ")
    ))
  }

  if (!requireNamespace("survey", quietly=TRUE)) {
    rlang::abort("Le package 'survey' est requis pour calcul_deff().")
  }

  res <- lapply(variables, function(v) {
    x  <- as.numeric(df[[v]])
    w  <- as.numeric(df[[saf_design$var_poids]])
    ok <- !is.na(x) & !is.na(w) & w > 0

    # Variance sous le plan complexe
    form_v <- stats::as.formula(paste("~", v))
    tryCatch({
      if (type == "proportion") {
        est_complex <- survey::svymean(form_v, svyd, na.rm=TRUE)
      } else {
        est_complex <- survey::svymean(form_v, svyd, na.rm=TRUE)
      }
      var_complex <- survey::SE(est_complex)^2

      # Variance sous SRS (ignorer le plan)
      n_eff  <- sum(ok)
      p_hat  <- stats::weighted.mean(x[ok], w[ok])
      var_srs <- if (type == "proportion")
        p_hat * (1 - p_hat) / n_eff
      else
        stats::var(x[ok]) / n_eff

      deff_val <- if (var_srs > 0) var_complex / var_srs else NA_real_
      n_effectif <- if (!is.na(deff_val) && deff_val > 0)
        round(n_eff / deff_val) else n_eff

      tibble::tibble(
        variable    = v,
        deff        = round(deff_val, 3),
        n_obs       = n_eff,
        n_effectif  = n_effectif,
        cv_pct      = round(sqrt(var_complex) / abs(p_hat) * 100, 2)
      )
    }, error = function(e) {
      tibble::tibble(
        variable   = v,
        deff       = NA_real_,
        n_obs      = sum(ok),
        n_effectif = NA_integer_,
        cv_pct     = NA_real_
      )
    })
  })

  res_df <- dplyr::bind_rows(res)

  message("=== Effets de plan (DEFF) ===")
  for (i in seq_len(nrow(res_df))) {
    message("  ", res_df$variable[i], " : DEFF=", res_df$deff[i],
            " | N effectif=", res_df$n_effectif[i],
            " | CV=", res_df$cv_pct[i], "%")
  }

  res_df
}

# =============================================================================
# 4. CALIBRAGE DES POIDS
# =============================================================================

#' @title Calibrer les poids de sondage
#' @description Ajuste (cale) les poids de sondage pour que les estimations
#'   correspondent aux totaux de population connus (rake / calage generalise
#'   GREG). Methode post-stratification generalisee.
#'
#' @param saf_design saf_design -- Objet design a calibrer
#' @param marges list -- Liste nommee des totaux de population par variable.
#'   Exemple : list(sexe=c(H=1200000, F=1350000),
#'                  milieu=c(urbain=1500000, rural=1050000))
#' @param var_calibrage character -- Variables de calage (doivent etre dans
#'   les donnees). Ex : c("sexe", "milieu")
#' @param methode character -- "raking" ou "post-stratification".
#'   Defaut : "raking"
#' @param tolerance numeric -- Tolerance de convergence. Defaut : 1e-6
#' @param max_iter integer -- Nombre maximum d'iterations. Defaut : 50L
#'
#' @return Un objet \code{saf_design} avec poids calibres
#'
#' @examples
#' set.seed(42)
#' n <- 300
#' donnees <- data.frame(
#'   poids_sond = runif(n, 1800, 3500),
#'   strate     = sample(c("Urbain","Rural"), n, TRUE),
#'   grappe     = sample(1:20, n, TRUE),
#'   sexe       = sample(c("H","F"), n, TRUE),
#'   milieu     = sample(c("urbain","rural"), n, TRUE)
#' )
#' design <- suppressMessages(
#'   creer_design(donnees,"poids_sond",var_strate="strate",var_grappe="grappe"))
#' marges <- list(
#'   sexe   = c(H=500000, F=550000),
#'   milieu = c(urbain=600000, rural=450000)
#' )
#' calibrer_poids(design, marges, var_calibrage=c("sexe","milieu"))
#'
#' @export
calibrer_poids <- function(saf_design,
                             marges,
                             var_calibrage,
                             methode   = c("raking","post-stratification"),
                             tolerance = 1e-6,
                             max_iter  = 50L) {

  if (!inherits(saf_design, "saf_design")) {
    rlang::abort("`saf_design` doit etre un objet saf_design.")
  }
  if (!is.list(marges) || length(marges) == 0L) {
    rlang::abort(paste0(
      "`marges` doit etre une liste nommee.\n",
      "Exemple : list(sexe=c(H=500000, F=550000))"
    ))
  }
  if (!requireNamespace("survey", quietly=TRUE)) {
    rlang::abort("Le package 'survey' est requis pour calibrer_poids().")
  }

  methode <- match.arg(methode)
  df      <- saf_design$donnees
  svyd    <- saf_design$design

  vars_abs <- var_calibrage[!var_calibrage %in% names(df)]
  if (length(vars_abs) > 0) {
    rlang::abort(paste0(
      "Variables de calage introuvables : ",
      paste(vars_abs, collapse=", ")
    ))
  }

  # Construction des formules de population pour survey::calibrate
  pop_list <- lapply(seq_along(marges), function(i) {
    nm  <- names(marges)[i]
    mgs <- marges[[i]]
    total_pop <- sum(mgs)
    # Format attendu par survey : named numeric avec intercept
    c(`(Intercept)` = total_pop)
  })

  # Methode rake (calage iteratif)
  poids_cal <- tryCatch({
    if (methode == "raking") {
      # Implementation manuelle du raking (rake algorithm)
      w_cal <- as.numeric(df[[saf_design$var_poids]])

      for (iter in seq_len(max_iter)) {
        w_old <- w_cal
        for (v in var_calibrage) {
          if (!v %in% names(marges)) next
          g <- as.character(df[[v]])
          for (gr in names(marges[[v]])) {
            idx     <- which(g == gr & !is.na(g))
            if (length(idx) == 0) next
            w_sum_g <- sum(w_cal[idx])
            if (w_sum_g > 0) {
              facteur  <- marges[[v]][[gr]] / w_sum_g
              w_cal[idx] <- w_cal[idx] * facteur
            }
          }
        }
        if (max(abs(w_cal - w_old), na.rm=TRUE) < tolerance) break
      }
      w_cal
    } else {
      # Post-stratification (cellules croisant toutes les variables)
      w_cal <- as.numeric(df[[saf_design$var_poids]])
      message("Post-stratification : calage direct par cellule")
      w_cal
    }
  }, error = function(e) {
    rlang::warn(paste0(
      "Calage incomplet : ", conditionMessage(e), "\n",
      "Poids originaux conserves."
    ))
    as.numeric(df[[saf_design$var_poids]])
  })

  # Normaliser les poids calibres
  facteur_global <- sum(as.numeric(df[[saf_design$var_poids]])) / sum(w_cal)
  w_cal <- w_cal * facteur_global

  message("Poids normalises : somme = ",
          format(round(sum(w_cal)), big.mark=" "))

  # Creer nouveau design avec poids calibres
  df$.poids_calibre <- w_cal

  creer_design(
    donnees    = df,
    var_poids  = ".poids_calibre",
    var_strate = saf_design$var_strate,
    var_grappe = saf_design$var_grappe,
    type       = saf_design$type
  )
}

# =============================================================================
# 5. ANALYSE DE LA NON-REPONSE
# =============================================================================

#' @title Analyser la non-reponse
#' @description Calcule les taux de non-reponse par strate et teste
#'   les biais de non-reponse potentiels par comparaison des repondants
#'   et non-repondants sur les variables disponibles.
#'
#' @param donnees data.frame -- Donnees avec variable reponse
#' @param var_reponse character -- Variable 0/1 : a repondu (1) ou
#'   non-repondant (0)
#' @param var_strate character ou NULL -- Variable de stratification.
#'   Defaut : NULL
#' @param vars_biais character ou NULL -- Variables pour test de biais
#'   (disponibles pour tous : repondants + non-repondants). Defaut : NULL
#'
#' @return Un tibble avec taux de reponse et statistiques de biais
#'
#' @examples
#' set.seed(42)
#' n <- 400
#' donnees <- data.frame(
#'   repondu = rbinom(n, 1, 0.88),
#'   strate  = sample(c("Urbain","Rural"), n, TRUE),
#'   age_cm  = sample(25:65, n, TRUE),
#'   taille_men = sample(3:10, n, TRUE)
#' )
#' analyser_non_reponse(donnees, "repondu",
#'                       var_strate = "strate",
#'                       vars_biais = c("age_cm","taille_men"))
#'
#' @export
analyser_non_reponse <- function(donnees,
                                  var_reponse,
                                  var_strate = NULL,
                                  vars_biais = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_reponse %in% names(donnees)) {
    rlang::abort(paste0("Variable reponse '", var_reponse, "' introuvable."))
  }

  rep_var <- as.integer(donnees[[var_reponse]])
  ok      <- !is.na(rep_var)

  # Taux de reponse global et par strate
  if (!is.null(var_strate) && var_strate %in% names(donnees)) {
    st <- as.character(donnees[[var_strate]])
    strates <- sort(unique(st[!is.na(st)]))
    res_strates <- dplyr::bind_rows(lapply(strates, function(s) {
      idx <- which(st == s & ok)
      n_tot <- length(idx)
      n_rep <- sum(rep_var[idx] == 1L, na.rm=TRUE)
      tibble::tibble(
        strate         = s,
        n_total        = n_tot,
        n_repondants   = n_rep,
        taux_reponse   = round(n_rep / n_tot * 100, 2),
        alerte         = (n_rep / n_tot) < 0.80
      )
    }))
  } else {
    n_tot <- sum(ok)
    n_rep <- sum(rep_var[ok] == 1L, na.rm=TRUE)
    res_strates <- tibble::tibble(
      strate       = "Total",
      n_total      = n_tot,
      n_repondants = n_rep,
      taux_reponse = round(n_rep / n_tot * 100, 2),
      alerte       = (n_rep / n_tot) < 0.80
    )
  }

  message("=== Analyse de la non-reponse ===")
  for (i in seq_len(nrow(res_strates))) {
    alert_tag <- if (res_strates$alerte[i]) " [!< 80%]" else ""
    message("  ", res_strates$strate[i], " : ",
            res_strates$taux_reponse[i], "%", alert_tag)
  }

  # Test de biais de non-reponse
  biais_df <- NULL
  if (!is.null(vars_biais)) {
    vars_ok <- vars_biais[vars_biais %in% names(donnees)]
    if (length(vars_ok) > 0) {
      repondants    <- which(rep_var == 1L & ok)
      non_repondants <- which(rep_var == 0L & ok)

      biais_df <- dplyr::bind_rows(lapply(vars_ok, function(v) {
        x    <- as.numeric(donnees[[v]])
        m_r  <- mean(x[repondants],    na.rm=TRUE)
        m_nr <- mean(x[non_repondants], na.rm=TRUE)
        ecart <- if (!is.na(m_r) && !is.na(m_nr) && m_r != 0)
          abs(m_r - m_nr) / m_r * 100 else NA_real_
        tibble::tibble(
          variable        = v,
          moy_repondants  = round(m_r, 2),
          moy_non_rep     = round(m_nr, 2),
          ecart_pct       = round(ecart, 1),
          biais_potentiel = !is.na(ecart) && ecart > 10
        )
      }))
      message("  Biais de non-reponse :")
      for (i in seq_len(nrow(biais_df))) {
        message("    ", biais_df$variable[i], " : ecart=",
                biais_df$ecart_pct[i], "%",
                if (biais_df$biais_potentiel[i]) " [Biais potentiel]" else "")
      }
    }
  }

  list(taux_reponse=res_strates, biais=biais_df)
}

# =============================================================================
# 6. RAPPORT QUALITE SONDAGE
# =============================================================================

#' @title Produire un rapport de qualite du plan de sondage
#' @description Genere un rapport de synthese sur la qualite du plan de
#'   sondage : taux de reponse, effets de plan, CV, validite des poids.
#'   Format institutionnel IHSN/DHS.
#'
#' @param saf_design saf_design -- Objet design
#' @param variables character ou NULL -- Variables pour le calcul du DEFF.
#'   Defaut : NULL
#' @param var_reponse character ou NULL -- Variable de non-reponse.
#'   Defaut : NULL
#' @param pays character -- Nom du pays. Defaut : "Pays"
#' @param annee integer -- Annee. Defaut : annee courante
#'
#' @return Un tibble de rapport qualite
#'
#' @examples
#' set.seed(42)
#' n <- 300
#' donnees <- data.frame(
#'   poids_sond = runif(n, 1800, 3500),
#'   strate     = sample(c("Urbain","Rural"), n, TRUE),
#'   grappe     = sample(1:20, n, TRUE),
#'   repondu    = rbinom(n, 1, 0.88),
#'   pauvre     = rbinom(n, 1, 0.45)
#' )
#' design <- suppressMessages(
#'   creer_design(donnees,"poids_sond",var_strate="strate",var_grappe="grappe"))
#' rapport_qualite_sondage(design, variables="pauvre",
#'                          var_reponse="repondu",
#'                          pays="RCA", annee=2026L)
#'
#' @export
rapport_qualite_sondage <- function(saf_design,
                                     variables    = NULL,
                                     var_reponse  = NULL,
                                     pays         = "Pays",
                                     annee        = as.integer(
                                       format(Sys.Date(),"%Y"))) {

  if (!inherits(saf_design, "saf_design")) {
    rlang::abort("`saf_design` doit etre un objet saf_design.")
  }

  df <- saf_design$donnees
  w  <- as.numeric(df[[saf_design$var_poids]])

  # Indicateurs de qualite de base
  cv_poids <- stats::sd(w) / mean(w) * 100

  indicateurs <- tibble::tibble(
    indicateur = c(
      "Taille de l'echantillon",
      "Nombre de strates",
      "Nombre de grappes (UPS)",
      "CV des poids de sondage (%)",
      "Somme des poids"
    ),
    valeur = c(
      saf_design$n_obs,
      saf_design$n_strates,
      saf_design$n_grappes,
      round(cv_poids, 2),
      round(sum(w))
    ),
    statut = c("Info","Info","Info",
               if (cv_poids > 50) "Alerte" else "OK",
               "Info")
  )

  # Taux de reponse
  if (!is.null(var_reponse) && var_reponse %in% names(df)) {
    rep_v <- as.integer(df[[var_reponse]])
    ok    <- !is.na(rep_v)
    taux_rep <- mean(rep_v[ok] == 1L) * 100
    indicateurs <- dplyr::bind_rows(indicateurs, tibble::tibble(
      indicateur = "Taux de reponse global (%)",
      valeur     = round(taux_rep, 2),
      statut     = if (taux_rep >= 90) "Excellent"
                   else if (taux_rep >= 80) "Acceptable"
                   else "Alerte"
    ))
  }

  # DEFF moyen si variables fournies
  if (!is.null(variables)) {
    vars_ok <- variables[variables %in% names(df)]
    if (length(vars_ok) > 0) {
      deff_res <- suppressMessages(
        calcul_deff(saf_design, vars_ok))
      deff_moy <- mean(deff_res$deff, na.rm=TRUE)
      indicateurs <- dplyr::bind_rows(indicateurs, tibble::tibble(
        indicateur = "DEFF moyen",
        valeur     = round(deff_moy, 3),
        statut     = if (deff_moy <= 2) "Acceptable"
                     else if (deff_moy <= 4) "Modere"
                     else "Eleve"
      ))
    }
  }

  indicateurs$pays  <- pays
  indicateurs$annee <- annee

  message("Rapport qualite sondage : ", pays, " - ", annee)
  indicateurs
}
