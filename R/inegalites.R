# =============================================================================
# statAfrikR - Module Inegalites & Bien-etre
# Gini, Lorenz, Palma, Theil, Atkinson, Decomposition
# Webinaire CEA/ACS : Statistiques des inegalites et du chomage en Afrique
# =============================================================================

utils::globalVariables(c(
  "cum_pop", "cum_rev", "groupe", "part_rev", "part_pop",
  "inegalite", "valeur", "composante", "contribution_pct",
  "inter", "intra", "quintile", "decile", "part"
))

# =============================================================================
# 1. COEFFICIENT DE GINI
# =============================================================================

#' @title Calculer le coefficient de Gini
#' @description Calcule le coefficient de Gini avec intervalle de confiance
#'   par bootstrap. Le Gini mesure l'inegalite de distribution d'une variable
#'   de revenu ou de consommation (0 = egalite parfaite, 1 = inegalite maximale).
#'
#' @param donnees data.frame -- Donnees menages
#' @param var_revenu character -- Variable de revenu ou de consommation
#'   (valeurs strictement positives)
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param ic logical -- Calculer l'IC 95% par bootstrap. Defaut : FALSE
#' @param n_bootstrap integer -- Replications bootstrap. Defaut : 200L
#' @param sous_groupes character ou NULL -- Variables de sous-groupe pour
#'   decomposition. Defaut : NULL
#'
#' @return Un objet de classe \code{saf_gini}
#'
#' @examples
#' set.seed(42)
#' n <- 300
#' menages <- data.frame(
#'   depense = c(rexp(200, 1/150000), rexp(100, 1/500000)),
#'   milieu  = sample(c("urbain","rural"), n, TRUE),
#'   poids   = runif(n, 0.8, 1.3)
#' )
#' res <- calcul_gini(menages, "depense", poids = "poids")
#' print(res)
#'
#' @export
calcul_gini <- function(donnees,
                         var_revenu,
                         poids       = NULL,
                         ic          = FALSE,
                         n_bootstrap = 200L,
                         sous_groupes = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_revenu %in% names(donnees)) {
    rlang::abort(paste0(
      "Variable '", var_revenu, "' introuvable.\n",
      "Colonnes disponibles : ", paste(names(donnees), collapse = ", ")
    ))
  }
  if (!is.null(poids) && !poids %in% names(donnees)) {
    rlang::abort(paste0("Variable de poids '", poids, "' introuvable."))
  }

  x <- as.numeric(donnees[[var_revenu]])
  x[is.na(x) | x < 0] <- NA
  if (sum(!is.na(x)) < 10L) {
    rlang::abort("Moins de 10 valeurs non-manquantes. Impossible de calculer le Gini.")
  }
  if (all(x[!is.na(x)] >= 0) && any(x[!is.na(x)] < 0)) {
    rlang::warn("Valeurs negatives detectees \u2014 elles seront exclues du calcul.")
  }

  w <- if (!is.null(poids)) {
    wp <- as.numeric(donnees[[poids]])
    wp[is.na(wp) | wp <= 0] <- 1
    wp
  } else rep(1, nrow(donnees))

  .gini_calc <- function(x, w) {
    idx <- !is.na(x)
    x <- x[idx]; w <- w[idx]
    ord <- order(x)
    x <- x[ord]; w <- w[ord]
    w <- w / sum(w)
    mu  <- sum(w * x)
    n   <- length(x)
    cum_w <- cumsum(w)
    2 * sum(w * x * (cum_w - w/2)) / mu - 1
  }

  gini_val <- .gini_calc(x, w)

  # Bootstrap IC
  ic_res <- NULL
  if (ic) {
    set.seed(42L)
    gini_b <- numeric(as.integer(n_bootstrap))
    for (b in seq_len(n_bootstrap)) {
      idx <- sample(length(x), replace = TRUE)
      gini_b[b] <- .gini_calc(x[idx], w[idx])
    }
    ic_res <- stats::quantile(gini_b, c(0.025, 0.975))
  }

  # Decomposition par sous-groupe
  decomp <- NULL
  if (!is.null(sous_groupes)) {
    for (sg in sous_groupes) {
      if (!sg %in% names(donnees)) {
        rlang::warn(paste0("Variable '", sg, "' introuvable \u2014 ignoree."))
        next
      }
      g <- as.character(donnees[[sg]])
      groupes <- sort(unique(g[!is.na(g)]))
      decomp_sg <- lapply(groupes, function(gr) {
        idx <- which(g == gr)
        tibble::tibble(
          variable = sg, groupe = gr,
          gini = round(.gini_calc(x[idx], w[idx]), 4),
          n    = length(idx)
        )
      })
      decomp <- dplyr::bind_rows(decomp, decomp_sg)
    }
  }

  structure(
    list(
      gini         = round(gini_val, 4),
      interpretation = .interpreter_gini(gini_val),
      ic           = ic_res,
      n_obs        = sum(!is.na(x)),
      var_revenu   = var_revenu,
      decomposition = decomp
    ),
    class = "saf_gini"
  )
}

.interpreter_gini <- function(g) {
  if (g < 0.25) "Faible inegalite"
  else if (g < 0.35) "Inegalite moderee"
  else if (g < 0.45) "Inegalite elevee"
  else if (g < 0.55) "Inegalite tres elevee"
  else "Inegalite extreme"
}

#' @export
print.saf_gini <- function(x, ...) {
  cat("\n=== Coefficient de Gini ===\n")
  cat(sprintf("  Gini = %.4f  (%s)\n", x$gini, x$interpretation))
  cat("  N   =", format(x$n_obs, big.mark = " "), "observations\n")
  if (!is.null(x$ic)) {
    cat(sprintf("  IC 95%% : [%.4f ; %.4f]\n", x$ic[1], x$ic[2]))
  }
  if (!is.null(x$decomposition) && nrow(x$decomposition) > 0) {
    cat("\nGini par sous-groupe :\n")
    for (i in seq_len(nrow(x$decomposition))) {
      cat(sprintf("  %-20s : %.4f (n=%d)\n",
                  x$decomposition$groupe[i],
                  x$decomposition$gini[i],
                  x$decomposition$n[i]))
    }
  }
  invisible(x)
}

# =============================================================================
# 2. COURBE DE LORENZ
# =============================================================================

#' @title Tracer la courbe de Lorenz
#' @description Produit la courbe de Lorenz institutionnelle montrant la
#'   distribution cumulee des revenus. L'aire entre la diagonale et la
#'   courbe est egale a Gini/2.
#'
#' @param donnees data.frame -- Donnees menages
#' @param var_revenu character -- Variable de revenu
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param var_groupe character ou NULL -- Variable de groupe pour
#'   comparaison. Defaut : NULL
#' @param titre character ou NULL -- Titre. Defaut : NULL
#' @param source character ou NULL -- Source. Defaut : NULL
#'
#' @return Un objet \code{ggplot2}
#'
#' @examples
#' set.seed(42)
#' menages <- data.frame(
#'   depense = c(rexp(150, 1/150000), rexp(50, 1/500000)),
#'   milieu  = sample(c("urbain","rural"), 200, TRUE),
#'   poids   = runif(200, 0.8, 1.3)
#' )
#' courbe_lorenz(menages, "depense", poids = "poids")
#'
#' @export
courbe_lorenz <- function(donnees,
                           var_revenu,
                           poids      = NULL,
                           var_groupe = NULL,
                           titre      = NULL,
                           source     = NULL) {

  if (!is.data.frame(donnees)) {
    rlang::abort("`donnees` doit etre un data.frame.")
  }
  if (!var_revenu %in% names(donnees)) {
    rlang::abort(paste0("Variable '", var_revenu, "' introuvable."))
  }

  .lorenz_df <- function(df, label = "Total") {
    x <- as.numeric(df[[var_revenu]])
    w <- if (!is.null(poids) && poids %in% names(df)) {
      wp <- as.numeric(df[[poids]]); wp[is.na(wp) | wp <= 0] <- 1; wp
    } else rep(1, nrow(df))
    idx <- !is.na(x) & x >= 0
    x <- x[idx]; w <- w[idx]
    ord <- order(x)
    x <- x[ord]; w <- w[ord]
    w_norm <- w / sum(w)
    tibble::tibble(
      cum_pop = c(0, cumsum(w_norm)),
      cum_rev = c(0, cumsum(w_norm * x) / sum(w_norm * x)),
      groupe  = label
    )
  }

  if (!is.null(var_groupe) && var_groupe %in% names(donnees)) {
    groupes <- sort(unique(as.character(donnees[[var_groupe]])))
    df_plot <- dplyr::bind_rows(lapply(groupes, function(g) {
      .lorenz_df(donnees[donnees[[var_groupe]] == g, ], label = g)
    }))
  } else {
    df_plot <- .lorenz_df(donnees)
  }

  # Calculer le Gini pour le titre
  res_g <- calcul_gini(donnees, var_revenu, poids = poids)

  g <- ggplot2::ggplot(df_plot,
    ggplot2::aes(x = .data$cum_pop, y = .data$cum_rev,
                 color = .data$groupe, group = .data$groupe)) +
    ggplot2::geom_abline(slope = 1, intercept = 0,
                          linetype = "dashed", color = "#94A3B8",
                          linewidth = 0.8) +
    ggplot2::geom_line(linewidth = 1.2) +
    ggplot2::geom_ribbon(
      ggplot2::aes(ymin = .data$cum_rev, ymax = .data$cum_pop),
      alpha = 0.08, fill = "#1B4965", color = NA
    ) +
    ggplot2::scale_x_continuous(labels = scales::percent_format()) +
    ggplot2::scale_y_continuous(labels = scales::percent_format()) +
    ggplot2::scale_color_manual(
      values = c("#1B4965","#DC2626","#16A34A","#EA580C","#7C3AED"),
      name   = if (!is.null(var_groupe)) var_groupe else NULL
    ) +
    ggplot2::theme_minimal(base_size = 11) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill = "#F0F7FF", color = NA),
      plot.title      = ggplot2::element_text(size = 13, face = "bold",
                                               color = "#0F2742"),
      plot.caption    = ggplot2::element_text(size = 8, color = "#94A3B8",
                                               hjust = 1),
      legend.position = if (!is.null(var_groupe)) "bottom" else "none",
      panel.grid.minor = ggplot2::element_blank()
    ) +
    ggplot2::labs(
      title   = if (!is.null(titre)) titre
                else paste0("Courbe de Lorenz (Gini = ",
                            round(res_g$gini, 3), ")"),
      x       = "Part cumulee de la population (%)",
      y       = "Part cumulee du revenu (%)",
      caption = if (!is.null(source))
        paste0("Source : ", source, " | statAfrikR")
      else "statAfrikR Foundation"
    )
  g
}

# =============================================================================
# 3. PARTS PAR QUINTILE / DECILE
# =============================================================================

#' @title Calculer les parts de revenu par quintile ou decile
#' @description Calcule la part de revenu ou de consommation detenue par
#'   chaque quintile (ou decile) de la population. Inclut les ratios
#'   Palma et Q5/Q1.
#'
#' @param donnees data.frame -- Donnees menages
#' @param var_revenu character -- Variable de revenu
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param n_groupes integer -- 5 (quintiles) ou 10 (deciles). Defaut : 5L
#'
#' @return Un tibble avec parts par groupe + ratios Palma et Q5/Q1
#'
#' @examples
#' set.seed(42)
#' menages <- data.frame(
#'   depense = c(rexp(200, 1/150000), rexp(100, 1/500000)),
#'   poids   = runif(300, 0.8, 1.3)
#' )
#' part_quintile(menages, "depense", poids = "poids")
#'
#' @export
part_quintile <- function(donnees,
                           var_revenu,
                           poids     = NULL,
                           n_groupes = 5L) {

  if (!is.data.frame(donnees)) {
    rlang::abort("`donnees` doit etre un data.frame.")
  }
  if (!var_revenu %in% names(donnees)) {
    rlang::abort(paste0("Variable '", var_revenu, "' introuvable."))
  }
  n_groupes <- as.integer(n_groupes)
  if (!n_groupes %in% c(5L, 10L)) {
    rlang::abort("`n_groupes` doit etre 5 (quintiles) ou 10 (deciles).")
  }

  x <- as.numeric(donnees[[var_revenu]])
  w <- if (!is.null(poids) && poids %in% names(donnees)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp) | wp <= 0] <- 1; wp
  } else rep(1, nrow(donnees))

  idx <- !is.na(x) & x >= 0
  x <- x[idx]; w <- w[idx]

  # Assigner chaque observation a un groupe
  probs   <- seq(0, 1, length.out = n_groupes + 1)
  bornes  <- stats::quantile(x, probs = probs,
                              weights = w, type = 7)
  groupe_label <- if (n_groupes == 5L) "Quintile" else "Decile"
  groupes <- cut(x, breaks = bornes, include.lowest = TRUE,
                  labels = paste0(groupe_label, " ", seq_len(n_groupes)))

  df_temp <- data.frame(x = x, w = w, groupe = groupes)
  total_rev <- sum(w * x)

  res <- lapply(levels(groupes), function(g) {
    df_g <- df_temp[df_temp$groupe == g & !is.na(df_temp$groupe), ]
    tibble::tibble(
      groupe        = g,
      revenu_moyen  = round(stats::weighted.mean(df_g$x, df_g$w), 0),
      part_revenu   = round(sum(df_g$w * df_g$x) / total_rev * 100, 2),
      n_obs         = nrow(df_g)
    )
  })
  res_df <- dplyr::bind_rows(res)

  # Ratios
  if (n_groupes == 5L) {
    q5_q1  <- res_df$part_revenu[5] / res_df$part_revenu[1]
    top10  <- res_df$part_revenu[5]
    bot40  <- sum(res_df$part_revenu[1:2])
    palma  <- top10 / bot40
    attr(res_df, "ratios") <- list(
      Q5_Q1 = round(q5_q1, 2),
      Palma = round(palma, 2),
      top10_pct = round(top10, 2),
      bot40_pct = round(bot40, 2)
    )
    message("Ratios : Q5/Q1 = ", round(q5_q1, 2),
            " | Palma = ", round(palma, 2),
            " (top 10% / bottom 40%)")
  }

  res_df
}

# =============================================================================
# 4. INDICE DE PALMA
# =============================================================================

#' @title Calculer l'indice de Palma
#' @description L'indice de Palma est le rapport entre la part de revenu
#'   des 10% les plus riches et celle des 40% les plus pauvres. Il est
#'   plus sensible aux extremes que le coefficient de Gini.
#'
#' @param donnees data.frame -- Donnees menages
#' @param var_revenu character -- Variable de revenu
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#'
#' @return Un scalaire numerique (indice de Palma)
#'
#' @examples
#' set.seed(42)
#' menages <- data.frame(
#'   depense = c(rexp(200, 1/150000), rexp(100, 1/500000)),
#'   poids   = runif(300, 0.8, 1.3)
#' )
#' indice_palma(menages, "depense", poids = "poids")
#'
#' @export
indice_palma <- function(donnees, var_revenu, poids = NULL) {
  res <- part_quintile(donnees, var_revenu, poids = poids, n_groupes = 5L)
  r   <- attr(res, "ratios")
  if (!is.null(r)) {
    message("Palma = ", r$Palma,
            " (top 10% = ", r$top10_pct,
            "% | bottom 40% = ", r$bot40_pct, "%)")
    invisible(r$Palma)
  } else {
    rlang::abort("Impossible de calculer le Palma.")
  }
}

#' @rdname indice_palma
#' @export
palma <- indice_palma

# =============================================================================
# 5. DECOMPOSITION THEIL
# =============================================================================

#' @title Decomposer les inegalites selon l'indice de Theil
#' @description Decompose l'inegalite totale en composantes inter-groupe
#'   et intra-groupe selon l'indice de Theil T (entropie generalisee GE(1)).
#'   Indispensable pour identifier les sources spatiales ou sociales
#'   de l'inegalite.
#'
#' @param donnees data.frame -- Donnees menages
#' @param var_revenu character -- Variable de revenu
#' @param var_groupe character -- Variable de groupe (region, milieu, sexe_cm)
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#'
#' @return Un tibble avec Theil total, inter-groupe, intra-groupe et
#'   contribution de chaque groupe
#'
#' @examples
#' set.seed(42)
#' menages <- data.frame(
#'   depense = c(rexp(200, 1/150000), rexp(100, 1/500000)),
#'   milieu  = sample(c("urbain","rural"), 300, TRUE),
#'   poids   = runif(300, 0.8, 1.3)
#' )
#' decomposer_theil(menages, "depense", "milieu", poids = "poids")
#'
#' @export
decomposer_theil <- function(donnees, var_revenu, var_groupe,
                              poids = NULL) {

  if (!is.data.frame(donnees)) {
    rlang::abort("`donnees` doit etre un data.frame.")
  }
  if (!var_revenu %in% names(donnees)) {
    rlang::abort(paste0("Variable revenu '", var_revenu, "' introuvable."))
  }
  if (!var_groupe %in% names(donnees)) {
    rlang::abort(paste0("Variable groupe '", var_groupe, "' introuvable."))
  }

  x <- as.numeric(donnees[[var_revenu]])
  w <- if (!is.null(poids) && poids %in% names(donnees)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp) | wp <= 0] <- 1; wp
  } else rep(1, nrow(donnees))

  idx <- !is.na(x) & x > 0
  x <- x[idx]; w <- w[idx]
  g <- as.character(donnees[[var_groupe]])[idx]

  .theil <- function(x, w) {
    w_n  <- w / sum(w)
    mu   <- sum(w_n * x)
    sum(w_n * (x / mu) * log(x / mu), na.rm = TRUE)
  }

  theil_total <- .theil(x, w)
  mu_total    <- stats::weighted.mean(x, w)
  w_total     <- sum(w)

  groupes <- sort(unique(g))
  res_g   <- lapply(groupes, function(gr) {
    idx_g  <- which(g == gr)
    x_g    <- x[idx_g]; w_g <- w[idx_g]
    mu_g   <- stats::weighted.mean(x_g, w_g)
    s_g    <- sum(w_g) / w_total
    y_g    <- sum(w_g * x_g) / sum(w * x)
    theil_g <- .theil(x_g, w_g)

    tibble::tibble(
      groupe          = gr,
      n               = length(idx_g),
      revenu_moyen    = round(mu_g, 0),
      part_population = round(s_g * 100, 2),
      part_revenu     = round(y_g * 100, 2),
      theil_interne   = round(theil_g, 4),
      contribution_intra = round(y_g * theil_g, 4)
    )
  })
  res_df <- dplyr::bind_rows(res_g)

  # Composante inter-groupe
  theil_intra <- sum(res_df$contribution_intra)
  theil_inter <- theil_total - theil_intra

  message("=== Decomposition Theil (",var_groupe,") ===")
  message("  Theil total : ", round(theil_total, 4))
  message("  Intra-groupe : ", round(theil_intra, 4),
          " (", round(theil_intra/theil_total*100, 1), "%)")
  message("  Inter-groupe : ", round(theil_inter, 4),
          " (", round(theil_inter/theil_total*100, 1), "%)")

  structure(
    list(
      theil_total  = round(theil_total, 4),
      theil_inter  = round(theil_inter, 4),
      theil_intra  = round(theil_intra, 4),
      pct_inter    = round(theil_inter / theil_total * 100, 1),
      pct_intra    = round(theil_intra / theil_total * 100, 1),
      par_groupe   = res_df,
      var_groupe   = var_groupe
    ),
    class = "saf_theil"
  )
}

#' @export
print.saf_theil <- function(x, ...) {
  cat("\n=== Decomposition Theil T ===\n")
  cat(sprintf("  Theil total  : %.4f\n", x$theil_total))
  cat(sprintf("  Inter-groupe : %.4f  (%s%%)\n",
              x$theil_inter, x$pct_inter))
  cat(sprintf("  Intra-groupe : %.4f  (%s%%)\n",
              x$theil_intra, x$pct_intra))
  cat("\nPar groupe (", x$var_groupe, ") :\n")
  for (i in seq_len(nrow(x$par_groupe))) {
    cat(sprintf("  %-20s : Theil=%.4f | Part pop=%s%% | Part rev=%s%%\n",
                x$par_groupe$groupe[i],
                x$par_groupe$theil_interne[i],
                x$par_groupe$part_population[i],
                x$par_groupe$part_revenu[i]))
  }
  invisible(x)
}

#' @rdname decomposer_theil
#' @export
theil <- decomposer_theil

# =============================================================================
# 6. INDICE D'ATKINSON
# =============================================================================

#' @title Calculer l'indice d'Atkinson
#' @description L'indice d'Atkinson est une mesure d'inegalite parametrique
#'   dont le parametre epsilon reflete l aversion a l'inegalite de la societe.
#'   Epsilon = 0 : indifference ; Epsilon = 1 : forte aversion.
#'
#' @param donnees data.frame -- Donnees menages
#' @param var_revenu character -- Variable de revenu
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param epsilon numeric -- Parametre d'aversion a l'inegalite (>0).
#'   Defaut : 1.0
#'
#' @return Un scalaire numerique (indice d'Atkinson)
#'
#' @examples
#' set.seed(42)
#' menages <- data.frame(
#'   depense = c(rexp(200, 1/150000), rexp(100, 1/500000)),
#'   poids   = runif(300, 0.8, 1.3)
#' )
#' indice_atkinson(menages, "depense", poids = "poids", epsilon = 1)
#'
#' @export
indice_atkinson <- function(donnees, var_revenu,
                             poids   = NULL,
                             epsilon = 1.0) {

  if (!is.data.frame(donnees)) {
    rlang::abort("`donnees` doit etre un data.frame.")
  }
  if (!var_revenu %in% names(donnees)) {
    rlang::abort(paste0("Variable '", var_revenu, "' introuvable."))
  }
  if (epsilon <= 0) {
    rlang::abort("`epsilon` doit etre strictement positif.")
  }

  x <- as.numeric(donnees[[var_revenu]])
  w <- if (!is.null(poids) && poids %in% names(donnees)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp) | wp <= 0] <- 1; wp
  } else rep(1, nrow(donnees))

  idx <- !is.na(x) & x > 0
  x <- x[idx]; w <- w[idx]
  w_n <- w / sum(w)
  mu  <- sum(w_n * x)

  # Formule Atkinson
  ede <- if (abs(epsilon - 1) < 1e-10) {
    exp(sum(w_n * log(x)))  # Cas limite epsilon = 1 (moyenne geometrique)
  } else {
    (sum(w_n * x^(1 - epsilon)))^(1 / (1 - epsilon))
  }

  atkinson <- 1 - ede / mu
  atkinson <- max(0, min(1, atkinson))

  message("Atkinson (epsilon=", epsilon, ") = ", round(atkinson, 4))
  invisible(round(atkinson, 4))
}

#' @rdname indice_atkinson
#' @export
atkinson <- indice_atkinson

# =============================================================================
# 7. TABLEAU DE BORD INEGALITES
# =============================================================================

#' @title Tableau de bord des inegalites
#' @description Calcule toutes les mesures d'inegalite en une seule fonction
#'   et les presente dans un tableau institutionnel. Inclut Gini, Palma,
#'   Theil, Atkinson et les parts par quintile.
#'
#' @param donnees data.frame -- Donnees menages
#' @param var_revenu character -- Variable de revenu
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param var_groupe character ou NULL -- Variable de groupe pour
#'   decomposition. Defaut : NULL
#' @param pays character -- Nom du pays. Defaut : "Pays"
#' @param annee integer -- Annee. Defaut : annee courante
#'
#' @return Un tibble avec toutes les mesures d'inegalite
#'
#' @examples
#' set.seed(42)
#' menages <- data.frame(
#'   depense = c(rexp(200, 1/150000), rexp(100, 1/500000)),
#'   milieu  = sample(c("urbain","rural"), 300, TRUE),
#'   poids   = runif(300, 0.8, 1.3)
#' )
#' tableau_inegalites(menages, "depense", poids="poids",
#'                    var_groupe="milieu", pays="Centrafrique",
#'                    annee=2026L)
#'
#' @export
tableau_inegalites <- function(donnees,
                                var_revenu,
                                poids      = NULL,
                                var_groupe = NULL,
                                pays       = "Pays",
                                annee      = as.integer(
                                  format(Sys.Date(), "%Y"))) {

  if (!is.data.frame(donnees)) {
    rlang::abort("`donnees` doit etre un data.frame.")
  }
  if (!var_revenu %in% names(donnees)) {
    rlang::abort(paste0("Variable '", var_revenu, "' introuvable."))
  }

  # Calculs
  gini_res <- calcul_gini(donnees, var_revenu, poids = poids)
  quint    <- suppressMessages(
    part_quintile(donnees, var_revenu, poids = poids))
  ratios   <- attr(quint, "ratios")
  atk      <- suppressMessages(
    indice_atkinson(donnees, var_revenu, poids = poids, epsilon = 1))

  x <- as.numeric(donnees[[var_revenu]])
  w <- if (!is.null(poids) && poids %in% names(donnees)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp) | wp <= 0] <- 1; wp
  } else rep(1, nrow(donnees))
  idx <- !is.na(x) & x > 0
  theil_val <- suppressMessages({
    w_n <- w[idx] / sum(w[idx])
    xi  <- x[idx]
    mu  <- sum(w_n * xi)
    sum(w_n * (xi/mu) * log(xi/mu), na.rm = TRUE)
  })

  res <- tibble::tibble(
    indicateur = c(
      "Coefficient de Gini",
      "Indice de Palma (top 10% / bottom 40%)",
      "Part Q1 (20% les plus pauvres)",
      "Part Q5 (20% les plus riches)",
      "Ratio Q5/Q1",
      "Indice de Theil T",
      "Indice d'Atkinson (epsilon=1)"
    ),
    valeur = c(
      round(gini_res$gini,    4),
      if (!is.null(ratios)) round(ratios$Palma, 2) else NA_real_,
      if (nrow(quint) >= 1) round(quint$part_revenu[1], 2) else NA_real_,
      if (nrow(quint) >= 5) round(quint$part_revenu[5], 2) else NA_real_,
      if (!is.null(ratios)) round(ratios$Q5_Q1, 2) else NA_real_,
      round(theil_val, 4),
      round(atk, 4)
    ),
    interpretation = c(
      gini_res$interpretation,
      if (!is.null(ratios) && ratios$Palma > 2) "Inegalite elevee" else "Inegalite moderee",
      "Part des revenus",
      "Part des revenus",
      "Rapport de richesse",
      if (theil_val > 0.4) "Inegalite elevee" else "Inegalite moderee",
      "Perte de bien-etre due aux inegalites"
    ),
    pays  = pays,
    annee = annee
  )

  if (!is.null(var_groupe) && var_groupe %in% names(donnees)) {
    message("Decomposition Theil par '", var_groupe,
            "' disponible via decomposer_theil()")
  }

  res
}
