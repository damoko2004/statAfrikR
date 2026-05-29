# =============================================================================
# statAfrikR - Module Pauvrete
# Indices FGT (Foster, Greer & Thorbecke, 1984) pour les INS africains
# Reference : Foster J., Greer J., Thorbecke E. (1984). A class of
#   decomposable poverty measures. Econometrica, 52(3), 761-766.
# =============================================================================

# Declaration des variables globales (ggplot2 aes + dplyr mutate)
utils::globalVariables(c(
  "fgt0", "fgt1", "fgt2",
  "fgt_local", "part_population", "contribution_abs", "contribution_rel",
  "valeur", "label", "pct", "indice",
  "niveau", "n_obs",
  ".modalite", ".groupe"
))

# -----------------------------------------------------------------------------
# 1. CALCUL DES INDICES FGT
# -----------------------------------------------------------------------------

#' @title Calcul des indices de pauvrete FGT
#' @description Calcule les indices Foster-Greer-Thorbecke (FGT0, FGT1, FGT2)
#'   avec prise en compte optionnelle du plan de sondage complexe. Les
#'   trois indices mesurent respectivement l'incidence, la profondeur et la
#'   severite de la pauvrete monetaire.
#'
#' @param data data.frame, tibble ou objet \code{svydesign} -- Donnees source
#' @param var_depense character -- Nom de la variable de depenses ou revenus
#'   par tete (en monnaie locale, strictement positive)
#' @param seuil_pauvrete numeric -- Seuil de pauvrete en monnaie locale.
#'   Meme unite que \code{var_depense}
#' @param poids character ou NULL -- Nom de la variable de ponderation.
#'   Ignore si \code{data} est un \code{svydesign}. Defaut : NULL
#' @param strate character ou NULL -- Variable de stratification.
#'   Defaut : NULL
#' @param grappe character ou NULL -- Variable d'identifiant de grappe.
#'   Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de decomposition
#'   (region, milieu, sexe). Defaut : NULL
#' @param alpha numeric -- Parametre de sensibilite : 0, 1, 2 ou vecteur.
#'   Defaut : \code{c(0, 1, 2)}
#' @param ic logical -- Calculer les intervalles de confiance a 95%.
#'   Defaut : TRUE
#' @param na.rm logical -- Exclure les valeurs manquantes. Defaut : TRUE
#'
#' @return Un objet de classe \code{saf_fgt}
#'
#' @references
#' Foster, J., Greer, J., & Thorbecke, E. (1984). A class of decomposable
#' poverty measures. Econometrica, 52(3), 761-766.
#' \doi{10.2307/1913475}
#'
#' @examples
#' set.seed(42)
#' menages <- data.frame(
#'   depense_pc = c(rexp(70, rate = 1/150000), rexp(30, rate = 1/400000)),
#'   poids      = runif(100, 0.8, 1.2),
#'   region     = sample(c("Bangui", "Ombella", "Lobaye"), 100, TRUE),
#'   milieu     = sample(c("urbain", "rural"), 100, TRUE, prob = c(0.4, 0.6))
#' )
#' fgt <- calcul_fgt(menages, var_depense = "depense_pc",
#'                   seuil_pauvrete = 220000, poids = "poids")
#' print(fgt)
#'
#' @export
calcul_fgt <- function(data,
                        var_depense,
                        seuil_pauvrete,
                        poids          = NULL,
                        strate         = NULL,
                        grappe         = NULL,
                        sous_groupes   = NULL,
                        alpha          = c(0, 1, 2),
                        ic             = TRUE,
                        na.rm          = TRUE) {

  est_svydesign <- inherits(data, "survey.design")
  data_brute    <- if (est_svydesign) data$variables else data

  # Validations
  if (!var_depense %in% names(data_brute)) {
    rlang::abort(paste0("Variable introuvable : '", var_depense, "'."))
  }
  if (!is.numeric(data_brute[[var_depense]])) {
    rlang::abort(paste0("'", var_depense, "' doit etre numerique."))
  }
  if (!is.numeric(seuil_pauvrete) || length(seuil_pauvrete) != 1 ||
      seuil_pauvrete <= 0) {
    rlang::abort("`seuil_pauvrete` doit etre un scalaire numerique positif.")
  }
  if (!all(alpha %in% c(0, 1, 2))) {
    rlang::abort("`alpha` doit contenir uniquement 0, 1 et/ou 2.")
  }
  if (!is.null(sous_groupes)) {
    sg_absents <- setdiff(sous_groupes, names(data_brute))
    if (length(sg_absents) > 0) {
      rlang::abort(paste0(
        "Variable(s) de sous-groupe introuvable(s) : ",
        paste(sg_absents, collapse = ", ")
      ))
    }
  }

  # Gestion des NA
  idx_na   <- is.na(data_brute[[var_depense]])
  na_count <- sum(idx_na)

  if (na_count > 0) {
    if (!na.rm) {
      rlang::abort(paste0(
        na_count, " valeurs manquantes dans '", var_depense,
        "'. Utilisez na.rm = TRUE pour les exclure."
      ))
    }
    if (na_count / nrow(data_brute) > 0.05) {
      rlang::warn(paste0(
        na_count, " valeurs manquantes (",
        round(na_count / nrow(data_brute) * 100, 1),
        "%) dans '", var_depense, "' -- exclues du calcul."
      ))
    }
    if (est_svydesign) {
      data <- subset(data, !is.na(data$variables[[var_depense]]))
    } else {
      data <- data[!idx_na, ]
    }
    data_brute <- if (est_svydesign) data$variables else data
  }

  # Construction du plan de sondage
  if (!est_svydesign && (!is.null(poids) || !is.null(strate) ||
                          !is.null(grappe))) {
    .verifier_package("survey", "calcul_fgt (plan de sondage)")

    poids_val <- if (!is.null(poids) && poids %in% names(data_brute)) {
      data_brute[[poids]]
    } else {
      rep(1, nrow(data_brute))
    }

    design_args        <- list(ids = ~1, weights = poids_val,
                               data = data_brute, nest = TRUE)
    if (!is.null(strate) && strate %in% names(data_brute)) {
      design_args$strata <- as.formula(paste0("~", strate))
    }
    if (!is.null(grappe) && grappe %in% names(data_brute)) {
      design_args$ids <- as.formula(paste0("~", grappe))
    }
    data           <- do.call(survey::svydesign, design_args)
    est_svydesign  <- TRUE
    data_brute     <- data$variables
  }

  # Calcul national
  res_national <- .calculer_fgt_interne(
    data       = data,
    data_brute = data_brute,
    var_dep    = var_depense,
    seuil      = seuil_pauvrete,
    alpha      = alpha,
    ic         = ic,
    is_svy     = est_svydesign
  )

  # Calcul par sous-groupes
  res_sg <- NULL
  if (!is.null(sous_groupes)) {
    res_sg <- lapply(sous_groupes, function(sg) {
      modalites <- sort(unique(data_brute[[sg]]))
      modalites <- modalites[!is.na(modalites)]

      tabs <- lapply(modalites, function(mod) {
        if (est_svydesign) {
          data_sg <- subset(data, data$variables[[sg]] == mod)
        } else {
          data_sg <- data[data_brute[[sg]] == mod, ]
        }
        db_sg <- if (est_svydesign) data_sg$variables else data_sg
        res   <- .calculer_fgt_interne(
          data       = data_sg,
          data_brute = db_sg,
          var_dep    = var_depense,
          seuil      = seuil_pauvrete,
          alpha      = alpha,
          ic         = ic,
          is_svy     = est_svydesign
        )
        res$.groupe   <- sg
        res$.modalite <- as.character(mod)
        res
      })
      out <- dplyr::bind_rows(tabs)
      dplyr::select(out,
                    dplyr::all_of(".groupe"),
                    dplyr::all_of(".modalite"),
                    dplyr::everything())
    })
    names(res_sg) <- sous_groupes
  }

  structure(
    list(
      national     = res_national,
      sous_groupes = res_sg,
      n_total      = nrow(data_brute),
      n_pauvres    = sum(data_brute[[var_depense]] < seuil_pauvrete,
                         na.rm = TRUE),
      seuil        = seuil_pauvrete,
      var_depense  = var_depense,
      na_count     = na_count,
      alpha        = alpha,
      appel        = match.call()
    ),
    class = "saf_fgt"
  )
}

#' @export
print.saf_fgt <- function(x, ...) {
  cat("\n=== Indices FGT -- statAfrikR ===\n")
  cat("Seuil de pauvrete :", format(x$seuil, big.mark = " "), "\n")
  cat("Variable          :", x$var_depense, "\n")
  cat("Effectif total    :", x$n_total, "menages\n")
  cat("Dont pauvres      :", x$n_pauvres,
      paste0("(", round(x$n_pauvres / x$n_total * 100, 1), "% brut)\n"))
  if (x$na_count > 0) cat("NA exclus         :", x$na_count, "\n")
  cat("\n")
  print(x$national)
  if (!is.null(x$sous_groupes)) {
    for (sg in names(x$sous_groupes)) {
      cat("\n--- Decomposition par", sg, "---\n")
      print(x$sous_groupes[[sg]])
    }
  }
  invisible(x)
}

#' @export
summary.saf_fgt <- function(object, ...) {
  print(object, ...)
}

#' @export
as.data.frame.saf_fgt <- function(x, ...) {
  as.data.frame(x$national)
}

# -----------------------------------------------------------------------------
# 2. DECOMPOSITION FGT
# -----------------------------------------------------------------------------

#' @title Decomposer les indices FGT par sous-groupe
#' @description Decompose un indice FGT en contributions relatives de
#'   chaque sous-groupe a la pauvrete nationale.
#'
#' @param fgt_obj objet \code{saf_fgt} -- Resultat de \code{calcul_fgt()}
#'   avec \code{sous_groupes} renseigne
#' @param variable character -- Sous-groupe a decomposer
#' @param alpha_cible numeric -- Indice a decomposer : 0, 1 ou 2.
#'   Defaut : 0
#'
#' @return Tibble avec contributions absolues et relatives
#'
#' @examples
#' set.seed(42)
#' menages <- data.frame(
#'   depense_pc = c(rexp(70, rate = 1/150000), rexp(30, rate = 1/400000)),
#'   poids  = runif(100, 0.8, 1.2),
#'   milieu = sample(c("urbain", "rural"), 100, TRUE, prob = c(0.4, 0.6))
#' )
#' fgt <- calcul_fgt(menages, "depense_pc", 220000,
#'                   poids = "poids", sous_groupes = "milieu")
#' decomposer_fgt(fgt, "milieu", alpha_cible = 0)
#'
#' @export
decomposer_fgt <- function(fgt_obj, variable, alpha_cible = 0) {

  if (!inherits(fgt_obj, "saf_fgt")) {
    rlang::abort("`fgt_obj` doit etre un objet `saf_fgt`.")
  }
  if (!alpha_cible %in% c(0, 1, 2)) {
    rlang::abort("`alpha_cible` doit etre 0, 1 ou 2.")
  }
  if (is.null(fgt_obj$sous_groupes) ||
      !variable %in% names(fgt_obj$sous_groupes)) {
    rlang::abort(paste0(
      "Sous-groupe '", variable, "' introuvable. ",
      "Relancez calcul_fgt() avec sous_groupes = '", variable, "'."
    ))
  }

  col_fgt     <- paste0("fgt", alpha_cible)
  fgt_national <- fgt_obj$national[[col_fgt]]
  tab_sg       <- fgt_obj$sous_groupes[[variable]]

  if (!col_fgt %in% names(tab_sg)) {
    rlang::abort(paste0(
      "FGT", alpha_cible, " non present. ",
      "Relancez calcul_fgt() avec alpha = c(0,1,2)."
    ))
  }

  # Renommer proprement sans .data[[]]
  tab_sg2 <- tab_sg
  names(tab_sg2)[names(tab_sg2) == ".modalite"] <- "modalite"
  names(tab_sg2)[names(tab_sg2) == col_fgt]     <- "fgt_local"
  names(tab_sg2)[names(tab_sg2) == "n_obs"]     <- "n"

  decomp <- dplyr::select(
    tab_sg2,
    dplyr::all_of(c("modalite", "fgt_local", "n"))
  )

  decomp <- dplyr::mutate(
    decomp,
    part_population  = round(.data$n / sum(.data$n), 4),
    contribution_abs = round(.data$fgt_local * .data$part_population, 6),
    contribution_rel = round(
      .data$contribution_abs / max(fgt_national, 1e-10) * 100, 2
    )
  )

  attr(decomp, "fgt_national") <- round(fgt_national, 4)
  attr(decomp, "alpha")        <- alpha_cible
  attr(decomp, "variable")     <- variable

  message("FGT", alpha_cible, " national : ", round(fgt_national, 4))
  message("Total contributions : ",
          round(sum(decomp$contribution_rel), 1), "% (doit = 100%)")

  decomp
}

# -----------------------------------------------------------------------------
# 3. TABLEAU FGT INSTITUTIONNEL
# -----------------------------------------------------------------------------

#' @title Tableau institutionnel des indices FGT
#' @description Genere un tableau des indices FGT formate selon les
#'   conventions des INS africains et de la Banque mondiale (EHCVM).
#'
#' @param fgt_obj objet \code{saf_fgt} -- Resultat de \code{calcul_fgt()}
#' @param format character -- Format de sortie : \code{"tibble"},
#'   \code{"flextable"} ou \code{"excel"}. Defaut : "tibble"
#' @param chemin character ou NULL -- Chemin du fichier Excel.
#'   Si NULL, utilise \code{tempdir()}. Defaut : NULL
#' @param titre character -- Titre du tableau
#' @param inclure_sous_groupes logical -- Inclure les tableaux par
#'   sous-groupe. Defaut : TRUE
#'
#' @return Tibble, flextable ou chemin du fichier Excel
#'
#' @examples
#' set.seed(42)
#' menages <- data.frame(
#'   depense_pc = c(rexp(70, rate = 1/150000), rexp(30, rate = 1/400000)),
#'   poids      = runif(100, 0.8, 1.2)
#' )
#' fgt <- calcul_fgt(menages, "depense_pc", 220000, poids = "poids")
#' tableau_fgt(fgt)
#'
#' @export
tableau_fgt <- function(fgt_obj,
                         format               = c("tibble", "flextable",
                                                   "excel"),
                         chemin               = NULL,
                         titre                = NULL,
                         inclure_sous_groupes = TRUE) {

  if (!inherits(fgt_obj, "saf_fgt")) {
    rlang::abort("`fgt_obj` doit etre un objet `saf_fgt`.")
  }
  format <- match.arg(format)

  if (is.null(titre)) {
    titre <- paste0(
      "Indices de pauvrete FGT -- Seuil : ",
      format(fgt_obj$seuil, big.mark = " ", scientific = FALSE)
    )
  }

  # Tableau national
  tab_nat <- dplyr::mutate(fgt_obj$national,
                            niveau = "National", .before = 1)

  # Sous-groupes
  if (inclure_sous_groupes && !is.null(fgt_obj$sous_groupes)) {
    tabs_sg <- lapply(names(fgt_obj$sous_groupes), function(sg) {
      tmp <- fgt_obj$sous_groupes[[sg]]
      names(tmp)[names(tmp) == ".modalite"] <- "niveau"
      tmp <- dplyr::select(tmp, -dplyr::any_of(".groupe"))
      tmp$niveau <- paste0("  ", sg, " : ", tmp$niveau)
      tmp
    })
    tableau_complet <- dplyr::bind_rows(tab_nat,
                                         dplyr::bind_rows(tabs_sg))
  } else {
    tableau_complet <- tab_nat
  }

  # FGT0 en pourcentage
  if ("fgt0" %in% names(tableau_complet)) {
    tableau_complet$fgt0 <- round(tableau_complet$fgt0 * 100, 1)
  }

  # Renommage pour publication
  nms <- names(tableau_complet)
  nms[nms == "niveau"]       <- "Niveau"
  nms[nms == "n_obs"]        <- "N"
  nms[nms == "fgt0"]         <- "FGT0 (%)"
  nms[nms == "fgt0_ic_bas"]  <- "IC bas FGT0"
  nms[nms == "fgt0_ic_haut"] <- "IC haut FGT0"
  nms[nms == "fgt1"]         <- "FGT1"
  nms[nms == "fgt1_ic_bas"]  <- "IC bas FGT1"
  nms[nms == "fgt1_ic_haut"] <- "IC haut FGT1"
  nms[nms == "fgt2"]         <- "FGT2"
  nms[nms == "fgt2_ic_bas"]  <- "IC bas FGT2"
  nms[nms == "fgt2_ic_haut"] <- "IC haut FGT2"
  names(tableau_complet) <- nms

  if (format == "tibble") return(tableau_complet)

  if (format == "flextable") {
    .verifier_package("flextable", "tableau_fgt (format flextable)")
    ft <- flextable::flextable(tableau_complet) |>
      flextable::set_caption(caption = titre) |>
      flextable::theme_vanilla() |>
      flextable::bold(part = "header") |>
      flextable::bold(j = 1) |>
      flextable::autofit()
    return(ft)
  }

  if (format == "excel") {
    .verifier_package("openxlsx2", "tableau_fgt (format excel)")
    if (is.null(chemin)) {
      chemin <- file.path(tempdir(), "fgt_tableau.xlsx")
    }
    # openxlsx2 : assignation explicite a chaque etape
    wb <- openxlsx2::wb_workbook()
    wb <- openxlsx2::wb_add_worksheet(wb, sheet = "FGT")
    wb <- openxlsx2::wb_add_data(wb, sheet = "FGT",
                                  x = titre,
                                  start_row = 1, start_col = 1)
    wb <- openxlsx2::wb_add_data(wb, sheet = "FGT",
                                  x = tableau_complet,
                                  start_row = 2)
    openxlsx2::wb_save(wb, file = chemin, overwrite = TRUE)
    message("Tableau exporte : ", chemin)
    return(invisible(chemin))
  }
}

# -----------------------------------------------------------------------------
# 4. GRAPHIQUE FGT
# -----------------------------------------------------------------------------

#' @title Graphique des indices FGT
#' @description Visualise les indices FGT nationaux et/ou par sous-groupe.
#'
#' @param fgt_obj objet \code{saf_fgt} -- Resultat de \code{calcul_fgt()}
#' @param type character -- \code{"barres"} ou \code{"indices"}.
#'   Defaut : "barres"
#' @param variable character ou NULL -- Variable de sous-groupe a representer
#' @param couleur character -- Couleur principale. Defaut : \code{"#1B4965"}
#'
#' @return Objet \code{ggplot2}
#'
#' @examples
#' \donttest{
#'   set.seed(42)
#'   menages <- data.frame(
#'     depense_pc = c(rexp(70, 1/150000), rexp(30, 1/400000)),
#'     poids  = runif(100, 0.8, 1.2),
#'     milieu = sample(c("urbain", "rural"), 100, TRUE, c(0.4, 0.6))
#'   )
#'   fgt <- calcul_fgt(menages, "depense_pc", 220000,
#'                     poids = "poids", sous_groupes = "milieu")
#'   graphique_fgt(fgt, type = "barres", variable = "milieu")
#' }
#' @export
graphique_fgt <- function(fgt_obj,
                           type     = c("barres", "indices"),
                           variable = NULL,
                           couleur  = "#1B4965") {

  if (!inherits(fgt_obj, "saf_fgt")) {
    rlang::abort("`fgt_obj` doit etre un objet `saf_fgt`.")
  }
  type <- match.arg(type)

  if (type == "barres") {
    if (is.null(variable)) {
      if (!is.null(fgt_obj$sous_groupes)) {
        variable <- names(fgt_obj$sous_groupes)[1]
      } else {
        rlang::abort(
          "Aucun sous-groupe disponible. Relancez calcul_fgt() avec sous_groupes."
        )
      }
    }
    if (!variable %in% names(fgt_obj$sous_groupes)) {
      rlang::abort(paste0("Sous-groupe '", variable, "' introuvable."))
    }

    tab_sg     <- fgt_obj$sous_groupes[[variable]]
    fgt0_nat   <- fgt_obj$national$fgt0

    # Renommer .modalite pour ggplot2
    names(tab_sg)[names(tab_sg) == ".modalite"] <- "modalite"

    g <- ggplot2::ggplot(
      tab_sg,
      ggplot2::aes(x = stats::reorder(.data$modalite, .data$fgt0),
                   y = .data$fgt0 * 100)
    ) +
      ggplot2::geom_col(fill = couleur, alpha = 0.88, width = 0.65) +
      ggplot2::geom_hline(yintercept = fgt0_nat * 100,
                          linetype = "dashed", color = "#B8872F",
                          linewidth = 0.8) +
      ggplot2::geom_text(
        ggplot2::aes(label = paste0(round(.data$fgt0 * 100, 1), "%")),
        hjust = -0.15, size = 3.2, color = "#1E293B"
      ) +
      ggplot2::coord_flip() +
      ggplot2::annotate("text",
        x = 0.6, y = fgt0_nat * 100 + 1,
        label = paste0("National : ", round(fgt0_nat * 100, 1), "%"),
        color = "#B8872F", size = 3, hjust = 0
      ) +
      ggplot2::scale_y_continuous(
        labels = function(x) paste0(x, "%"),
        expand = ggplot2::expansion(mult = c(0, 0.18))
      ) +
      ggplot2::labs(
        title   = paste0("Incidence de la pauvrete (FGT0) par ", variable),
        subtitle = paste0("Seuil : ",
                          format(fgt_obj$seuil, big.mark = " "),
                          " -- N = ", fgt_obj$n_total),
        x       = NULL,
        y       = "Taux de pauvrete (%)",
        caption = "Source : statAfrikR | FGT (1984)"
      ) +
      ggplot2::theme_minimal(base_size = 11) +
      ggplot2::theme(
        plot.title = ggplot2::element_text(face = "bold", color = "#0F2742"),
        plot.subtitle = ggplot2::element_text(color = "#475569"),
        panel.grid.major.y = ggplot2::element_blank()
      )

  } else {
    # Graphique FGT0/1/2 national
    indices_dispo <- intersect(c("fgt0", "fgt1", "fgt2"),
                               names(fgt_obj$national))
    tab_nat <- fgt_obj$national |>
      dplyr::select(dplyr::all_of(indices_dispo)) |>
      tidyr::pivot_longer(
        cols      = dplyr::all_of(indices_dispo),
        names_to  = "indice",
        values_to = "valeur"
      ) |>
      dplyr::mutate(
        label = dplyr::case_when(
          .data$indice == "fgt0" ~ "FGT0\nIncidence",
          .data$indice == "fgt1" ~ "FGT1\nProfondeur",
          .data$indice == "fgt2" ~ "FGT2\nSeverite"
        ),
        pct = round(.data$valeur * 100, 2)
      )

    g <- ggplot2::ggplot(
      tab_nat,
      ggplot2::aes(x = .data$label, y = .data$pct, fill = .data$indice)
    ) +
      ggplot2::geom_col(width = 0.5, show.legend = FALSE) +
      ggplot2::geom_text(
        ggplot2::aes(label = paste0(.data$pct, "%")),
        vjust = -0.5, size = 4, fontface = "bold", color = "#0F2742"
      ) +
      ggplot2::scale_fill_manual(values = c(
        fgt0 = "#1B4965", fgt1 = "#245C73", fgt2 = "#B8872F"
      )) +
      ggplot2::scale_y_continuous(
        labels = function(x) paste0(x, "%"),
        expand = ggplot2::expansion(mult = c(0, 0.15))
      ) +
      ggplot2::labs(
        title    = "Indices de pauvrete FGT -- Niveau national",
        subtitle = paste0("Seuil : ",
                          format(fgt_obj$seuil, big.mark = " "),
                          " -- N = ", fgt_obj$n_total),
        x        = NULL,
        y        = "Valeur (%)",
        caption  = "Source : statAfrikR | FGT (1984)"
      ) +
      ggplot2::theme_minimal(base_size = 11) +
      ggplot2::theme(
        plot.title = ggplot2::element_text(face = "bold", color = "#0F2742"),
        panel.grid.major.x = ggplot2::element_blank()
      )
  }

  g
}

# =============================================================================
# FONCTIONS INTERNES
# =============================================================================

#' @keywords internal
.calculer_fgt_interne <- function(data, data_brute, var_dep, seuil,
                                   alpha, ic, is_svy) {
  n_obs      <- nrow(data_brute)
  y          <- data_brute[[var_dep]]
  resultats  <- tibble::tibble(n_obs = n_obs)

  for (a in alpha) {
    col_fgt <- paste0("fgt", a)

    if (is_svy) {
      .verifier_package("survey", "calcul_fgt (interne)")
      gap_var <- paste0(".gap_fgt", a)
      data_brute[[gap_var]] <- ifelse(
        y < seuil, ((seuil - y) / seuil) ^ a, 0
      )
      data$variables[[gap_var]] <- data_brute[[gap_var]]
      formule <- as.formula(paste0("~", gap_var))
      est     <- survey::svymean(formule, data, na.rm = TRUE)
      val     <- as.numeric(est)

      resultats[[col_fgt]] <- round(val, 6)
      if (ic) {
        se_val <- sqrt(as.numeric(attr(est, "var")))
        resultats[[paste0(col_fgt, "_ic_bas")]]  <-
          round(max(0, val - 1.96 * se_val), 6)
        resultats[[paste0(col_fgt, "_ic_haut")]] <-
          round(val + 1.96 * se_val, 6)
      }
    } else {
      gaps <- ifelse(y < seuil, ((seuil - y) / seuil) ^ a, 0)
      val  <- mean(gaps, na.rm = TRUE)

      resultats[[col_fgt]] <- round(val, 6)
      if (ic) {
        se_val <- stats::sd(gaps, na.rm = TRUE) / sqrt(n_obs)
        resultats[[paste0(col_fgt, "_ic_bas")]]  <-
          round(max(0, val - 1.96 * se_val), 6)
        resultats[[paste0(col_fgt, "_ic_haut")]] <-
          round(val + 1.96 * se_val, 6)
      }
    }
  }
  resultats
}
