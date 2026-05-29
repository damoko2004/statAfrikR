# =============================================================================
# statAfrikR - Module Tableaux
# Production de tableaux statistiques institutionnels INS
# Exports : Word (flextable) et Excel (openxlsx2)
# =============================================================================

utils::globalVariables(c(
  "variable", "n", "moyenne", "mediane", "ecart_type",
  "min", "max", "ic_bas", "ic_haut", "proportion",
  "pourcentage", "effectif", "modalite", "total"
))

# Palette institutionnelle
.INS_NAVY  <- "#0F2742"
.INS_PETRL <- "#1B4965"
.INS_GOLD  <- "#B8872F"
.INS_GREY  <- "#F4F7FA"

# =============================================================================
# 1. TABLEAU DESCRIPTIF
# =============================================================================

#' @title Tableau de statistiques descriptives institutionnel
#' @description Produit un tableau de statistiques descriptives pondere,
#'   formate selon les conventions des INS africains. Exportable en
#'   Word (flextable) ou Excel (openxlsx2).
#'
#' @param data data.frame, tibble ou objet \code{svydesign} -- Donnees
#' @param vars character -- Variables numeriques a analyser
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param par character ou NULL -- Variable de ventilation (groupe).
#'   Defaut : NULL
#' @param stats character -- Statistiques parmi :
#'   \code{"n"}, \code{"moyenne"}, \code{"mediane"}, \code{"ecart_type"},
#'   \code{"min"}, \code{"max"}, \code{"ic"}. Defaut : toutes
#' @param format character -- \code{"tibble"}, \code{"flextable"} ou
#'   \code{"excel"}. Defaut : "tibble"
#' @param chemin character ou NULL -- Chemin Excel. Defaut : NULL
#' @param titre character ou NULL -- Titre du tableau. Defaut : NULL
#' @param source character ou NULL -- Note source. Defaut : NULL
#'
#' @return Tibble, flextable ou chemin fichier Excel
#'
#' @examples
#' set.seed(42)
#' donnees <- data.frame(
#'   age    = sample(18:65, 200, replace = TRUE),
#'   revenu = rexp(200, rate = 1/250000),
#'   poids  = runif(200, 0.8, 1.3),
#'   milieu = sample(c("urbain", "rural"), 200, TRUE)
#' )
#' tableau_descriptif(donnees, vars = c("age", "revenu"), poids = "poids")
#'
#' @export
tableau_descriptif <- function(data,
                                vars,
                                poids  = NULL,
                                par    = NULL,
                                stats  = c("n", "moyenne", "mediane",
                                           "ecart_type", "min", "max",
                                           "ic"),
                                format = c("tibble", "flextable", "excel"),
                                chemin = NULL,
                                titre  = NULL,
                                source = NULL) {

  format     <- match.arg(format)
  est_svy    <- inherits(data, "survey.design")
  data_brute <- if (est_svy) data$variables else data

  # Validations
  vars_abs <- setdiff(vars, names(data_brute))
  if (length(vars_abs) > 0) {
    rlang::abort(paste0("Variables introuvables : ",
                        paste(vars_abs, collapse = ", ")))
  }
  vars_num <- vars[sapply(data_brute[vars], is.numeric)]
  vars_non <- setdiff(vars, vars_num)
  if (length(vars_non) > 0) {
    rlang::warn(paste0("Variables non numeriques ignorees : ",
                       paste(vars_non, collapse = ", ")))
    vars <- vars_num
  }
  if (length(vars) == 0) rlang::abort("Aucune variable numerique valide.")

  # Calcul
  if (est_svy || (!is.null(poids) && poids %in% names(data_brute))) {
    res <- .desc_pondere(data, data_brute, vars, poids, par, stats, est_svy)
  } else {
    res <- .desc_simple(data_brute, vars, par, stats)
  }

  if (format == "tibble") return(res)

  if (format == "flextable") {
    .verifier_package("flextable", "tableau_descriptif")
    return(.ft_descriptif(res, titre, source))
  }

  if (format == "excel") {
    .verifier_package("openxlsx2", "tableau_descriptif")
    if (is.null(chemin))
      chemin <- file.path(tempdir(), "tableau_descriptif.xlsx")
    .excel_simple(res, chemin, titre, source, sheet = "Descriptif")
    return(invisible(chemin))
  }
}

# =============================================================================
# 2. TABLEAU CROISE INSTITUTIONNEL
# =============================================================================

#' @title Tableau croise pondere - format institutionnel INS
#' @description Produit un tableau de contingence pondere avec marges,
#'   pourcentages et test du chi-deux.
#'
#' @param data data.frame, tibble ou \code{svydesign} -- Donnees
#' @param ligne character -- Variable en ligne
#' @param colonne character -- Variable en colonne
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param type_pct character -- \code{"colonne"}, \code{"ligne"} ou
#'   \code{"total"}. Defaut : "colonne"
#' @param marges logical -- Afficher les totaux. Defaut : TRUE
#' @param chi2 logical -- Calculer le test du chi-deux. Defaut : TRUE
#' @param format character -- \code{"tibble"}, \code{"flextable"} ou
#'   \code{"excel"}. Defaut : "tibble"
#' @param chemin character ou NULL -- Chemin Excel. Defaut : NULL
#' @param titre character ou NULL -- Titre. Defaut : NULL
#'
#' @return Tibble, flextable ou chemin Excel
#'
#' @examples
#' set.seed(42)
#' donnees <- data.frame(
#'   region = sample(c("Nord", "Sud", "Est", "Ouest"), 300, TRUE),
#'   milieu = sample(c("urbain", "rural"), 300, TRUE, prob = c(0.4, 0.6)),
#'   poids  = runif(300, 0.7, 1.4)
#' )
#' tableau_croise_ins(donnees, "region", "milieu", poids = "poids")
#'
#' @export
tableau_croise_ins <- function(data,
                                ligne,
                                colonne,
                                poids    = NULL,
                                type_pct = c("colonne", "ligne", "total"),
                                marges   = TRUE,
                                chi2     = TRUE,
                                format   = c("tibble", "flextable", "excel"),
                                chemin   = NULL,
                                titre    = NULL) {

  type_pct   <- match.arg(type_pct)
  format     <- match.arg(format)
  est_svy    <- inherits(data, "survey.design")
  data_brute <- if (est_svy) data$variables else data

  for (v in c(ligne, colonne)) {
    if (!v %in% names(data_brute)) {
      rlang::abort(paste0("Variable introuvable : '", v, "'."))
    }
  }

  w <- if (!is.null(poids) && poids %in% names(data_brute)) {
    data_brute[[poids]]
  } else {
    rep(1, nrow(data_brute))
  }

  # Table ponderee
  tab_pond <- stats::xtabs(w ~ data_brute[[ligne]] + data_brute[[colonne]])
  names(dimnames(tab_pond)) <- c(ligne, colonne)

  tab_pct <- switch(type_pct,
    "colonne" = prop.table(tab_pond, margin = 2) * 100,
    "ligne"   = prop.table(tab_pond, margin = 1) * 100,
    "total"   = prop.table(tab_pond) * 100
  )

  # Tibble long
  res_eff <- as.data.frame(tab_pond, stringsAsFactors = FALSE)
  names(res_eff) <- c(ligne, colonne, "effectif")
  res_pct <- as.data.frame(tab_pct, stringsAsFactors = FALSE)
  names(res_pct) <- c(ligne, colonne, "pourcentage")
  res_pct$pourcentage <- round(res_pct$pourcentage, 1)
  res <- dplyr::left_join(res_eff, res_pct, by = c(ligne, colonne))

  # Format large
  res_large <- tidyr::pivot_wider(
    res,
    id_cols     = dplyr::all_of(ligne),
    names_from  = dplyr::all_of(colonne),
    values_from = "pourcentage"
  )
  eff_total <- dplyr::summarise(
    dplyr::group_by(res, dplyr::across(dplyr::all_of(ligne))),
    N = sum(.data$effectif), .groups = "drop"
  )
  res_large <- dplyr::left_join(res_large, eff_total, by = ligne)

  # Marges
  if (marges) {
    total_row         <- as.data.frame(t(colSums(res_large[sapply(res_large,
                                                                    is.numeric)],
                                                  na.rm = TRUE)))
    total_row[[ligne]] <- "Total"
    res_large <- dplyr::bind_rows(res_large, total_row)
  }

  # Chi-deux
  chi2_res <- NULL
  if (chi2) {
    tab_brute <- table(data_brute[[ligne]], data_brute[[colonne]])
    chi2_res  <- tryCatch(
      stats::chisq.test(tab_brute),
      warning = function(w) suppressWarnings(stats::chisq.test(tab_brute))
    )
  }

  attr(res_large, "chi2")    <- chi2_res
  attr(res_large, "titre")   <- titre
  attr(res_large, "ligne")   <- ligne
  attr(res_large, "colonne") <- colonne

  if (format == "tibble") return(res_large)

  if (format == "flextable") {
    .verifier_package("flextable", "tableau_croise_ins")
    return(.ft_croise(res_large, chi2_res, titre, ligne, colonne))
  }

  if (format == "excel") {
    .verifier_package("openxlsx2", "tableau_croise_ins")
    if (is.null(chemin))
      chemin <- file.path(tempdir(), "tableau_croise.xlsx")
    note_chi2 <- if (!is.null(chi2_res)) {
      paste0("Chi-deux = ", round(chi2_res$statistic, 3),
             "  p = ", round(chi2_res$p.value, 4))
    } else NULL
    .excel_simple(res_large, chemin, titre, note_chi2,
                  sheet = "Croisement")
    return(invisible(chemin))
  }
}

# =============================================================================
# 3. EXPORT EXCEL MULTI-FEUILLES
# =============================================================================

#' @title Export Excel institutionnel multi-feuilles
#' @description Exporte une liste de tableaux dans un classeur Excel
#'   avec feuille de sommaire.
#'
#' @param tableaux list -- Liste nommee de data.frames a exporter
#' @param chemin character -- Chemin du fichier Excel
#' @param titre_classeur character -- Titre general.
#'   Defaut : \code{"Statistiques INS"}
#' @param pays character ou NULL -- Pays/organisation. Defaut : NULL
#' @param annee integer ou NULL -- Annee de reference. Defaut : NULL
#' @param style character -- Style : \code{"ins_standard"} ou
#'   \code{"minimal"}. Defaut : "ins_standard"
#'
#' @return Chemin du fichier cree (invisible)
#'
#' @examples
#' \dontrun{
#'   tableaux <- list(
#'     "Descriptif" = data.frame(
#'       variable = c("age", "revenu"),
#'       n        = c(200L, 200L),
#'       moyenne  = c(38.2, 245000)
#'     ),
#'     "Croisement" = data.frame(
#'       region = c("Nord", "Sud"),
#'       urbain = c(45.2, 32.1),
#'       rural  = c(54.8, 67.9)
#'     )
#'   )
#'   chemin <- file.path(tempdir(), "stats_ins.xlsx")
#'   exporter_excel_ins(tableaux, chemin,
#'                      titre_classeur = "Enquete menages 2026",
#'                      pays = "Centrafrique", annee = 2026L)
#' }
#'
#' @export
exporter_excel_ins <- function(tableaux,
                                chemin,
                                titre_classeur = "Statistiques INS",
                                pays           = NULL,
                                annee          = NULL,
                                style          = c("ins_standard",
                                                   "minimal")) {

  style <- match.arg(style)
  .verifier_package("openxlsx2", "exporter_excel_ins")

  if (!is.list(tableaux) || length(tableaux) == 0) {
    rlang::abort("`tableaux` doit etre une liste non vide.")
  }
  if (!is.character(chemin) || nchar(chemin) == 0) {
    rlang::abort("`chemin` doit etre un chemin valide.")
  }
  if (!dir.exists(dirname(chemin))) {
    rlang::abort(paste0("Repertoire inexistant : ", dirname(chemin)))
  }

  noms <- names(tableaux)
  if (is.null(noms) || any(noms == "")) {
    noms <- paste0("Tableau_", seq_along(tableaux))
    names(tableaux) <- noms
  }

  wb <- openxlsx2::wb_workbook()

  # Feuille Sommaire
  wb <- openxlsx2::wb_add_worksheet(wb, sheet = "Sommaire")

  meta_lines <- c(
    titre_classeur,
    if (!is.null(pays))  paste0("Pays / Organisation : ", pays),
    if (!is.null(annee)) paste0("Annee de reference : ", annee),
    paste0("Date de production : ", format(Sys.Date(), "%d/%m/%Y")),
    "Produit avec statAfrikR -- cran.r-project.org"
  )
  meta_lines <- meta_lines[!sapply(meta_lines, is.null)]

  for (i in seq_along(meta_lines)) {
    wb <- openxlsx2::wb_add_data(wb, sheet = "Sommaire",
                                  x = meta_lines[[i]],
                                  start_row = i, start_col = 1,
                                  col_names = FALSE)
  }

  debut_index <- length(meta_lines) + 2L
  index_df    <- data.frame(
    Feuille  = noms,
    Lignes   = sapply(tableaux, nrow),
    Colonnes = sapply(tableaux, ncol)
  )
  wb <- openxlsx2::wb_add_data(wb, sheet = "Sommaire",
                                x = index_df,
                                start_row = debut_index)

  # Une feuille par tableau
  for (nm in noms) {
    tab      <- tableaux[[nm]]
    sheet_nm <- substr(nm, 1, 31)
    wb <- openxlsx2::wb_add_worksheet(wb, sheet = sheet_nm)
    wb <- openxlsx2::wb_add_data(wb, sheet = sheet_nm,
                                  x = nm, start_row = 1L, start_col = 1L,
                                  col_names = FALSE)
    wb <- openxlsx2::wb_add_data(wb, sheet = sheet_nm,
                                  x = tab, start_row = 2L)

    if (style == "ins_standard") {
      n_cols <- ncol(tab)
      wb <- openxlsx2::wb_add_fill(
        wb, sheet = sheet_nm,
        color = openxlsx2::wb_color(.INS_NAVY),
        dims  = openxlsx2::wb_dims(rows = 2L, cols = seq_len(n_cols))
      )
      wb <- openxlsx2::wb_add_font(
        wb, sheet = sheet_nm,
        bold  = TRUE,
        color = openxlsx2::wb_color("FFFFFF"),
        dims  = openxlsx2::wb_dims(rows = 2L, cols = seq_len(n_cols))
      )
    }
  }

  openxlsx2::wb_save(wb, file = chemin, overwrite = TRUE)
  message("Classeur exporte : ", chemin,
          " (", length(tableaux), " feuilles)")
  invisible(chemin)
}

# =============================================================================
# FONCTIONS INTERNES
# =============================================================================

#' @keywords internal
.desc_simple <- function(data, vars, par, stats) {
  calc <- function(df, v) {
    x   <- df[[v]][!is.na(df[[v]])]
    n   <- length(x)
    res <- tibble::tibble(variable = v, n = n)
    if ("moyenne"    %in% stats) res$moyenne    <- round(mean(x), 3)
    if ("mediane"    %in% stats) res$mediane    <- round(stats::median(x), 3)
    if ("ecart_type" %in% stats) res$ecart_type <- round(stats::sd(x), 3)
    if ("min"        %in% stats) res$min        <- round(min(x), 3)
    if ("max"        %in% stats) res$max        <- round(max(x), 3)
    if ("ic"         %in% stats) {
      se          <- stats::sd(x) / sqrt(n)
      res$ic_bas  <- round(mean(x) - 1.96 * se, 3)
      res$ic_haut <- round(mean(x) + 1.96 * se, 3)
    }
    res
  }

  if (!is.null(par) && par %in% names(data)) {
    groupes <- sort(unique(data[[par]][!is.na(data[[par]])]))
    out <- lapply(groupes, function(g) {
      df_g      <- data[!is.na(data[[par]]) & data[[par]] == g, ]
      res       <- dplyr::bind_rows(lapply(vars, calc, df = df_g))
      res[[par]] <- as.character(g)
      dplyr::select(res, dplyr::all_of(par), dplyr::everything())
    })
    return(dplyr::bind_rows(out))
  }

  dplyr::bind_rows(lapply(vars, calc, df = data))
}

#' @keywords internal
.desc_pondere <- function(data, data_brute, vars, poids, par,
                           stats, est_svy) {
  if (!est_svy) {
    .verifier_package("survey", "tableau_descriptif (pondere)")
    pw   <- data_brute[[poids]]
    data <- survey::svydesign(ids = ~1, weights = pw, data = data_brute)
    est_svy <- TRUE
  }

  calc_svy <- function(svy, v) {
    f   <- as.formula(paste0("~", v))
    n   <- sum(!is.na(svy$variables[[v]]))
    res <- tibble::tibble(variable = v, n = n)

    if ("moyenne" %in% stats || "ic" %in% stats) {
      m   <- survey::svymean(f, svy, na.rm = TRUE)
      moy <- as.numeric(m)
      if ("moyenne" %in% stats) res$moyenne <- round(moy, 3)
      if ("ic"      %in% stats) {
        se          <- sqrt(as.numeric(attr(m, "var")))
        res$ic_bas  <- round(moy - 1.96 * se, 3)
        res$ic_haut <- round(moy + 1.96 * se, 3)
      }
    }
    if ("mediane" %in% stats) {
      q           <- survey::svyquantile(f, svy, quantiles = 0.5,
                                          na.rm = TRUE)
      res$mediane <- round(as.numeric(q[[1]]), 3)
    }
    if ("ecart_type" %in% stats) {
      vr             <- survey::svyvar(f, svy, na.rm = TRUE)
      res$ecart_type <- round(sqrt(as.numeric(vr)), 3)
    }
    if ("min" %in% stats)
      res$min <- round(min(svy$variables[[v]], na.rm = TRUE), 3)
    if ("max" %in% stats)
      res$max <- round(max(svy$variables[[v]], na.rm = TRUE), 3)
    res
  }

  if (!is.null(par) && par %in% names(data_brute)) {
    groupes <- sort(unique(data_brute[[par]][!is.na(data_brute[[par]])]))
    out <- lapply(groupes, function(g) {
      svy_g     <- subset(data, data$variables[[par]] == g)
      res       <- dplyr::bind_rows(lapply(vars, calc_svy, svy = svy_g))
      res[[par]] <- as.character(g)
      dplyr::select(res, dplyr::all_of(par), dplyr::everything())
    })
    return(dplyr::bind_rows(out))
  }

  dplyr::bind_rows(lapply(vars, calc_svy, svy = data))
}

#' @keywords internal
.ft_descriptif <- function(tab, titre, source) {
  n_rows <- nrow(tab)
  idx_even <- if (n_rows >= 2) seq(2, n_rows, by = 2) else integer(0)

  ft <- flextable::flextable(tab) |>
    flextable::set_caption(
      caption = if (!is.null(titre)) titre
                else "Statistiques descriptives"
    ) |>
    flextable::bg(bg = .INS_NAVY, part = "header") |>
    flextable::color(color = "white", part = "header") |>
    flextable::bold(part = "header") |>
    flextable::bold(j = 1) |>
    flextable::font(fontname = "Arial", part = "all") |>
    flextable::fontsize(size = 10, part = "all") |>
    flextable::fontsize(size = 11, part = "header") |>
    flextable::autofit()

  if (length(idx_even) > 0) {
    ft <- flextable::bg(ft, i = idx_even, bg = .INS_GREY, part = "body")
  }

  if (!is.null(source)) {
    ft <- flextable::add_footer_lines(ft,
                                       values = paste0("Source : ", source))
    ft <- flextable::color(ft, color = "#64748B", part = "footer")
    ft <- flextable::fontsize(ft, size = 9, part = "footer")
  }
  ft
}

#' @keywords internal
.ft_croise <- function(tab, chi2_res, titre, ligne, colonne) {
  ft <- flextable::flextable(tab) |>
    flextable::set_caption(
      caption = if (!is.null(titre)) titre
                else paste0("Repartition de ", ligne,
                            " par ", colonne, " (%)")
    ) |>
    flextable::bg(bg = .INS_NAVY, part = "header") |>
    flextable::color(color = "white", part = "header") |>
    flextable::bold(part = "header") |>
    flextable::bold(j = 1) |>
    flextable::font(fontname = "Arial", part = "all") |>
    flextable::fontsize(size = 10, part = "all") |>
    flextable::autofit()

  if (!is.null(chi2_res)) {
    note <- paste0(
      "Chi-deux = ", round(chi2_res$statistic, 3),
      ", df = ",     chi2_res$parameter,
      ", p = ",      round(chi2_res$p.value, 4)
    )
    ft <- flextable::add_footer_lines(ft, values = note)
    ft <- flextable::color(ft, color = "#64748B", part = "footer")
    ft <- flextable::fontsize(ft, size = 9, part = "footer")
  }
  ft
}

#' @keywords internal
.excel_simple <- function(tab, chemin, titre, note, sheet = "Tableau") {
  wb <- openxlsx2::wb_workbook()
  wb <- openxlsx2::wb_add_worksheet(wb, sheet = sheet)

  debut <- 1L
  if (!is.null(titre)) {
    wb    <- openxlsx2::wb_add_data(wb, sheet = sheet,
                                     x = titre, start_row = 1L,
                                     start_col = 1L, col_names = FALSE)
    debut <- 2L
  }

  wb <- openxlsx2::wb_add_data(wb, sheet = sheet,
                                x = tab, start_row = debut)

  # Style header
  wb <- openxlsx2::wb_add_fill(
    wb, sheet = sheet,
    color = openxlsx2::wb_color(.INS_NAVY),
    dims  = openxlsx2::wb_dims(rows = debut, cols = seq_len(ncol(tab)))
  )
  wb <- openxlsx2::wb_add_font(
    wb, sheet = sheet,
    bold  = TRUE,
    color = openxlsx2::wb_color("FFFFFF"),
    dims  = openxlsx2::wb_dims(rows = debut, cols = seq_len(ncol(tab)))
  )

  if (!is.null(note)) {
    wb <- openxlsx2::wb_add_data(
      wb, sheet = sheet,
      x         = note,
      start_row = debut + nrow(tab) + 1L,
      col_names = FALSE
    )
  }

  openxlsx2::wb_save(wb, file = chemin, overwrite = TRUE)
  message("Tableau exporte : ", chemin)
}
