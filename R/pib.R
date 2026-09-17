# =============================================================================
# statAfrikR - Module PIB & Comptes nationaux
# Systeme de Comptabilite Nationale (SCN 2008)
# Inspire de l'intervention INS Cameroun \u2014 StatsTalk Africa 2026
# =============================================================================

utils::globalVariables(c(
  "annee", "trimestre", "version", "valeur", "taux_croissance_pct",
  "source", "ecart_pct", "secteur", "contribution", "periode",
  "pib_courant", "pib_constant", "deflateur", "composante"
))

# =============================================================================
# 1. COMPARER LE PIB ENTRE SOURCES
# =============================================================================

#' @title Comparer le PIB entre sources (INS vs UNSD vs BM vs FMI)
#' @description Compare les estimations du PIB publiees par l'INS et les
#'   institutions internationales. Identifie les ecarts, leurs causes
#'   probables et produit un tableau de diagnostic. Outil cle pour
#'   renforcer la maitrise du narratif statistique national.
#'
#' @param pib_ins numeric -- PIB publie par l'INS (en milliards FCFA
#'   ou USD selon l'unite choisie)
#' @param pib_intl named numeric -- PIB des institutions internationales.
#'   Vecteur nomme : ex : c(UNSD=245.2, BM=241.8, FMI=248.5)
#' @param pays character -- Nom du pays. Defaut : "Pays"
#' @param annee integer -- Annee de reference
#' @param unite character -- Unite monetaire. Defaut : "Mds FCFA"
#' @param methode_ins character ou NULL -- Methode INS :
#'   "production", "depenses", "revenus". Defaut : NULL
#' @param seuil_alerte numeric -- Seuil d'ecart en % declenchant une
#'   alerte. Defaut : 3.0
#'
#' @return Un objet de classe \code{saf_pib}
#'
#' @examples
#' res <- comparer_pib(
#'   pib_ins  = 2450.5,
#'   pib_intl = c(UNSD=2380.2, BM=2412.8, FMI=2398.5),
#'   pays     = "Cameroun",
#'   annee    = 2023L,
#'   unite    = "Mds FCFA"
#' )
#' print(res)
#'
#' @export
comparer_pib <- function(pib_ins,
                          pib_intl,
                          pays         = "Pays",
                          annee        = as.integer(format(Sys.Date(),"%Y")),
                          unite        = "Mds FCFA",
                          methode_ins  = NULL,
                          seuil_alerte = 3.0) {

  if (!is.numeric(pib_ins) || length(pib_ins) != 1L || pib_ins <= 0) {
    rlang::abort("`pib_ins` doit etre un nombre positif (PIB de l'INS).")
  }
  if (!is.numeric(pib_intl) || length(pib_intl) == 0L) {
    rlang::abort(paste0(
      "`pib_intl` doit etre un vecteur numerique nomme.\n",
      "Exemple : c(UNSD=2380.2, BM=2412.8, FMI=2398.5)"
    ))
  }
  if (is.null(names(pib_intl))) {
    rlang::abort(paste0(
      "`pib_intl` doit etre un vecteur nomme.\n",
      "Exemple : c(UNSD=2380.2, BM=2412.8, FMI=2398.5)"
    ))
  }

  # Calcul des ecarts
  ecarts <- sapply(names(pib_intl), function(src) {
    (pib_ins - pib_intl[[src]]) / pib_intl[[src]] * 100
  })

  # Causes probables des ecarts (heuristique documentee)
  .cause <- function(ecart_pct) {
    dplyr::case_when(
      abs(ecart_pct) < 1  ~ "Ecart negligeable (<1%) \u2014 normal",
      abs(ecart_pct) < 3  ~ "Ecart faible \u2014 vintage ou arrondis differents",
      abs(ecart_pct) < 5  ~ "Ecart modere \u2014 methode de rebasing ou taux change",
      abs(ecart_pct) < 10 ~ "Ecart important \u2014 revision methodologique ou source",
      TRUE                ~ "Ecart majeur \u2014 verification necessaire"
    )
  }

  comp_df <- tibble::tibble(
    source_intl  = names(pib_intl),
    pib_intl     = as.numeric(pib_intl),
    pib_ins_val  = pib_ins,
    ecart_abs    = round(pib_ins - as.numeric(pib_intl), 2),
    ecart_pct    = round(ecarts, 2),
    alerte       = abs(ecarts) >= seuil_alerte,
    cause_probable = sapply(ecarts, .cause)
  )

  n_alertes <- sum(comp_df$alerte)

  message("=== Comparaison PIB ", pays, " - ", annee, " ===")
  message("  PIB INS : ", format(pib_ins, big.mark=" "), " ", unite)
  for (i in seq_len(nrow(comp_df))) {
    alert_tag <- if (comp_df$alerte[i]) " [!]" else ""
    message("  ", comp_df$source_intl[i], " : ",
            format(comp_df$pib_intl[i], big.mark=" "),
            " ", unite, "  Ecart : ", comp_df$ecart_pct[i], "%", alert_tag)
  }
  if (n_alertes > 0) {
    rlang::warn(paste0(
      n_alertes, " source(s) avec ecart >= ", seuil_alerte, "% ",
      "\u2014 verification recommandee.\n",
      "Causes possibles : mill\u00e9sime different, taux de change, ",
      "methodologie de rebasing SCN."
    ))
  }

  structure(
    list(
      pays         = pays,
      annee        = annee,
      unite        = unite,
      pib_ins      = pib_ins,
      comparaisons = comp_df,
      n_alertes    = n_alertes,
      seuil_alerte = seuil_alerte,
      methode_ins  = methode_ins
    ),
    class = "saf_pib"
  )
}

#' @export
print.saf_pib <- function(x, ...) {
  cat("\n=== Comparaison PIB ===\n")
  cat("  Pays      :", x$pays, "\n")
  cat("  Annee     :", x$annee, "\n")
  cat("  PIB INS   :", format(x$pib_ins, big.mark=" "), x$unite, "\n\n")
  cat(sprintf("  %-10s  %-12s  %-12s  %s\n",
              "Source", "PIB", "Ecart", "Statut"))
  cat("  ", strrep("-", 55), "\n")
  for (i in seq_len(nrow(x$comparaisons))) {
    r <- x$comparaisons
    cat(sprintf("  %-10s  %-12s  %+.2f%%      %s\n",
                r$source_intl[i],
                format(r$pib_intl[i], big.mark=" "),
                r$ecart_pct[i],
                if (r$alerte[i]) "[ALERTE]" else "OK"))
  }
  if (x$n_alertes > 0) {
    cat("\n  Alertes :", x$n_alertes, "source(s) avec ecart >=",
        x$seuil_alerte, "%\n")
  }
  invisible(x)
}

# =============================================================================
# 2. SUIVI DES REVISIONS DU PIB
# =============================================================================

#' @title Suivre les revisions du PIB
#' @description Analyse les revisions entre les estimations preliminaires,
#'   provisoires et definitives du PIB. Produit un tableau et un graphique
#'   de suivi conforme aux bonnes pratiques de communication des INS.
#'
#' @param donnees data.frame -- Donnees avec colonnes annee, version, valeur.
#'   Versions attendues : "preliminaire", "provisoire", "definitif"
#' @param var_annee character -- Variable annee. Defaut : "annee"
#' @param var_version character -- Variable version du PIB.
#'   Defaut : "version"
#' @param var_valeur character -- Variable valeur du PIB. Defaut : "valeur"
#' @param pays character -- Nom du pays. Defaut : "Pays"
#' @param unite character -- Unite. Defaut : "Mds FCFA"
#'
#' @return Un objet de classe \code{saf_revision_pib}
#'
#' @examples
#' revisions <- data.frame(
#'   annee   = rep(2019:2022, each=3),
#'   version = rep(c("preliminaire","provisoire","definitif"), 4),
#'   valeur  = c(2210,2225,2240, 2320,2335,2348,
#'               2415,2430,NA,   2510,NA,NA),
#'   stringsAsFactors = FALSE
#' )
#' suivre_revisions_pib(revisions, pays="Cameroun", unite="Mds FCFA")
#'
#' @export
suivre_revisions_pib <- function(donnees,
                                  var_annee   = "annee",
                                  var_version = "version",
                                  var_valeur  = "valeur",
                                  pays        = "Pays",
                                  unite       = "Mds FCFA") {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  for (v in c(var_annee, var_version, var_valeur)) {
    if (!v %in% names(donnees)) {
      rlang::abort(paste0("Variable '", v, "' introuvable."))
    }
  }

  df <- donnees
  names(df)[names(df) == var_annee]   <- "annee"
  names(df)[names(df) == var_version] <- "version"
  names(df)[names(df) == var_valeur]  <- "valeur"

  df$annee  <- as.integer(df$annee)
  df$valeur <- as.numeric(df$valeur)

  versions_ordre <- c("preliminaire","provisoire","definitif")
  df$version_fac <- factor(df$version, levels=versions_ordre)

  # Calcul des revisions
  annees <- sort(unique(df$annee))
  revisions <- lapply(annees, function(a) {
    df_a <- df[df$annee == a, ]
    val_p  <- df_a$valeur[df_a$version == "preliminaire"]
    val_pr <- df_a$valeur[df_a$version == "provisoire"]
    val_d  <- df_a$valeur[df_a$version == "definitif"]
    val_p  <- if (length(val_p)  > 0 && !is.na(val_p[1]))  val_p[1]  else NA_real_
    val_pr <- if (length(val_pr) > 0 && !is.na(val_pr[1])) val_pr[1] else NA_real_
    val_d  <- if (length(val_d)  > 0 && !is.na(val_d[1]))  val_d[1]  else NA_real_

    rev_p_pr <- if (!is.na(val_p) && !is.na(val_pr) && val_p != 0)
      round((val_pr - val_p) / val_p * 100, 2) else NA_real_
    rev_pr_d <- if (!is.na(val_pr) && !is.na(val_d) && val_pr != 0)
      round((val_d - val_pr) / val_pr * 100, 2) else NA_real_

    tibble::tibble(
      annee         = a,
      preliminaire  = val_p,
      provisoire    = val_pr,
      definitif     = val_d,
      rev_prel_prov = rev_p_pr,
      rev_prov_def  = rev_pr_d
    )
  })

  rev_df <- dplyr::bind_rows(revisions)

  message("=== Revisions du PIB \u2014 ", pays, " ===")
  for (i in seq_len(nrow(rev_df))) {
    r <- rev_df[i, ]
    msg_r <- paste0("  ", r$annee, " :")
    if (!is.na(r$definitif))
      msg_r <- paste0(msg_r, "  Def=", format(r$definitif, big.mark=" "))
    if (!is.na(r$rev_prel_prov))
      msg_r <- paste0(msg_r, "  Rev prel->prov: ",
                      sprintf("%+.2f%%", r$rev_prel_prov))
    if (!is.na(r$rev_prov_def))
      msg_r <- paste0(msg_r, "  Rev prov->def: ",
                      sprintf("%+.2f%%", r$rev_prov_def))
    message(msg_r)
  }

  # Graphique
  df_plot <- df[!is.na(df$valeur), ]
  g <- ggplot2::ggplot(df_plot,
    ggplot2::aes(x = .data$annee, y = .data$valeur,
                 color = .data$version_fac,
                 group = .data$version_fac,
                 linetype = .data$version_fac)) +
    ggplot2::geom_line(linewidth = 1.1) +
    ggplot2::geom_point(size = 2.5) +
    ggplot2::scale_color_manual(
      values = c(preliminaire="#94A3B8", provisoire="#F59E0B",
                 definitif="#1B4965"),
      name = "Version"
    ) +
    ggplot2::scale_linetype_manual(
      values = c(preliminaire="dashed", provisoire="dotdash",
                 definitif="solid"),
      name = "Version"
    ) +
    ggplot2::scale_x_continuous(breaks = scales::pretty_breaks()) +
    ggplot2::scale_y_continuous(
      labels = function(x) paste0(format(x, big.mark=" "))
    ) +
    ggplot2::theme_minimal(base_size=11) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill="#F0F7FF", color=NA),
      plot.title      = ggplot2::element_text(size=13, face="bold",
                                               color="#0F2742"),
      legend.position = "bottom"
    ) +
    ggplot2::labs(
      title   = paste0("Revisions du PIB \u2014 ", pays),
      x       = "Annee",
      y       = paste0("PIB (", unite, ")"),
      caption = "statAfrikR | SCN 2008"
    )

  structure(
    list(
      pays       = pays,
      unite      = unite,
      revisions  = rev_df,
      donnees    = df,
      graphique  = g
    ),
    class = "saf_revision_pib"
  )
}

# =============================================================================
# 3. CALCULER LE DEFLATEUR
# =============================================================================

#' @title Calculer et appliquer le deflateur du PIB
#' @description Convertit les valeurs en prix courants en prix constants
#'   (volume) en utilisant le deflateur implicite du PIB ou un indice
#'   de prix fourni. Base annee referencee configurable.
#'
#' @param donnees data.frame -- Donnees avec PIB courant et deflateur
#' @param var_pib_courant character -- Variable PIB en prix courants
#' @param var_deflateur character ou NULL -- Variable deflateur (base 100).
#'   Si NULL, calcule depuis var_ipc. Defaut : NULL
#' @param var_ipc character ou NULL -- Indice des prix a la consommation
#'   (si deflateur non fourni). Defaut : NULL
#' @param annee_base integer -- Annee de base du deflateur. Defaut : 2015L
#' @param var_annee character -- Variable annee. Defaut : "annee"
#'
#' @return Un tibble avec PIB courant, deflateur et PIB constant
#'
#' @examples
#' comptes <- data.frame(
#'   annee        = 2015:2022,
#'   pib_courant  = c(2100,2180,2250,2310,2195,2280,2380,2450),
#'   deflateur    = c(100,103.2,106.8,110.5,109.2,113.5,118.2,122.8)
#' )
#' calculer_deflateur(comptes, "pib_courant",
#'                    var_deflateur="deflateur",
#'                    annee_base=2015L)
#'
#' @export
calculer_deflateur <- function(donnees,
                                var_pib_courant,
                                var_deflateur = NULL,
                                var_ipc       = NULL,
                                annee_base    = 2015L,
                                var_annee     = "annee") {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_pib_courant %in% names(donnees)) {
    rlang::abort(paste0("Variable '", var_pib_courant, "' introuvable."))
  }
  if (is.null(var_deflateur) && is.null(var_ipc)) {
    rlang::abort(paste0(
      "Fournissez `var_deflateur` ou `var_ipc`.\n",
      "Si les deux sont NULL, le calcul est impossible."
    ))
  }

  df <- donnees
  pib_c <- as.numeric(df[[var_pib_courant]])

  # Deflateur
  if (!is.null(var_deflateur) && var_deflateur %in% names(df)) {
    defl <- as.numeric(df[[var_deflateur]])
  } else if (!is.null(var_ipc) && var_ipc %in% names(df)) {
    ipc  <- as.numeric(df[[var_ipc]])
    # Rebaser sur annee_base
    if (var_annee %in% names(df)) {
      annees <- as.integer(df[[var_annee]])
      base_val <- ipc[annees == annee_base]
      base_val <- if (length(base_val) > 0) base_val[1] else mean(ipc, na.rm=TRUE)
    } else {
      base_val <- mean(ipc, na.rm=TRUE)
    }
    defl <- ipc / base_val * 100
  } else {
    rlang::abort(paste0(
      "Variable deflateur/IPC introuvable dans les donnees."
    ))
  }

  pib_const <- pib_c / defl * 100

  res <- tibble::tibble(
    pib_courant   = round(pib_c,     2),
    deflateur     = round(defl,      2),
    pib_constant  = round(pib_const, 2),
    annee_base    = annee_base
  )

  if (var_annee %in% names(df)) {
    res <- tibble::add_column(res, annee=as.integer(df[[var_annee]]), .before=1)
    # Taux de croissance reel
    res$croissance_reelle_pct <- c(NA_real_,
      round(diff(res$pib_constant) / res$pib_constant[-nrow(res)] * 100, 2))
  }

  message("=== Deflateur PIB (base ", annee_base, ") ===")
  message("  Periodes : ", nrow(res))
  if ("croissance_reelle_pct" %in% names(res)) {
    croiss_ok <- res$croissance_reelle_pct[!is.na(res$croissance_reelle_pct)]
    message("  Croissance reelle moy : ", round(mean(croiss_ok), 2), "% par an")
  }

  res
}

# =============================================================================
# 4. TAUX DE CROISSANCE ET CONTRIBUTIONS SECTORIELLES
# =============================================================================

#' @title Calculer les taux de croissance du PIB et contributions
#' @description Calcule les taux de croissance reels et nominaux du PIB
#'   et la contribution de chaque secteur a la croissance. Conforme
#'   aux methodes SCN 2008.
#'
#' @param donnees data.frame -- Donnees de comptes nationaux avec secteurs
#' @param var_pib character -- Variable PIB total (prix constants)
#' @param vars_secteurs named character ou NULL -- Vecteur nomme des
#'   variables sectorielles. Ex : c(Agriculture="agri", Industrie="indus")
#' @param var_annee character -- Variable annee. Defaut : "annee"
#' @param var_trimestre character ou NULL -- Variable trimestre (si donnees
#'   trimestrielles). Defaut : NULL
#'
#' @return Un tibble avec taux de croissance et contributions sectorielles
#'
#' @examples
#' comptes <- data.frame(
#'   annee = 2018:2022,
#'   pib   = c(2100, 2180, 2250, 2195, 2380),
#'   agri  = c(420,  440,  460,  445,  490),
#'   indus = c(630,  660,  680,  660,  715),
#'   serv  = c(1050, 1080, 1110, 1090, 1175)
#' )
#' taux_croissance(comptes, "pib",
#'   vars_secteurs = c(Agriculture="agri",
#'                     Industrie="indus",
#'                     Services="serv"),
#'   var_annee = "annee")
#'
#' @export
taux_croissance <- function(donnees,
                             var_pib,
                             vars_secteurs = NULL,
                             var_annee     = "annee",
                             var_trimestre = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_pib %in% names(donnees)) {
    rlang::abort(paste0("Variable PIB '", var_pib, "' introuvable."))
  }
  if (!var_annee %in% names(donnees)) {
    rlang::abort(paste0("Variable annee '", var_annee, "' introuvable."))
  }

  # Trier par annee
  df <- donnees[order(as.integer(donnees[[var_annee]])), ]

  pib    <- as.numeric(df[[var_pib]])
  annees <- as.integer(df[[var_annee]])

  croiss_pib <- c(NA_real_,
    round(diff(pib) / pib[-length(pib)] * 100, 2))

  res <- tibble::tibble(annee = annees, pib = pib,
                         croissance_pct = croiss_pib)

  # Contributions sectorielles : delta_secteur / PIB_t-1
  if (!is.null(vars_secteurs)) {
    vars_abs <- vars_secteurs[!vars_secteurs %in% names(df)]
    if (length(vars_abs) > 0) {
      rlang::warn(paste0(
        "Variables sectorielles introuvables : ",
        paste(vars_abs, collapse=", "), " \u2014 ignorees."
      ))
      vars_secteurs <- vars_secteurs[vars_secteurs %in% names(df)]
    }

    for (nm in names(vars_secteurs)) {
      v  <- as.numeric(df[[vars_secteurs[[nm]]]])
      contrib <- c(NA_real_,
        round(diff(v) / pib[-length(pib)] * 100, 2))
      res[[paste0("contrib_", nm)]] <- contrib
    }
  }

  message("=== Croissance du PIB ===")
  for (i in seq_len(nrow(res))) {
    if (!is.na(res$croissance_pct[i])) {
      message("  ", res$annee[i], " : ",
              sprintf("%+.2f%%", res$croissance_pct[i]))
    }
  }

  res
}

# =============================================================================
# 5. TABLEAU DE BORD PIB
# =============================================================================

#' @title Tableau de bord des comptes nationaux
#' @description Produit un tableau de bord institutionnel du PIB combinant
#'   croissance, deflateur, comparaison de sources et revisions. Format
#'   comparable aux publications des INS africains.
#'
#' @param donnees data.frame -- Donnees de comptes nationaux
#' @param var_pib_courant character -- PIB en prix courants
#' @param var_pib_constant character ou NULL -- PIB en prix constants.
#'   Defaut : NULL
#' @param var_annee character -- Variable annee. Defaut : "annee"
#' @param vars_secteurs named character ou NULL -- Secteurs economiques.
#'   Defaut : NULL
#' @param pays character -- Nom du pays. Defaut : "Pays"
#' @param unite character -- Unite. Defaut : "Mds FCFA"
#'
#' @return Un tibble du tableau de bord PIB
#'
#' @examples
#' comptes <- data.frame(
#'   annee       = 2018:2022,
#'   pib_courant = c(2100,2180,2250,2195,2380),
#'   pib_cst     = c(2000,2060,2110,2060,2210)
#' )
#' tableau_bord_pib(comptes, "pib_courant",
#'                   var_pib_constant="pib_cst",
#'                   pays="Cameroun", unite="Mds FCFA")
#'
#' @export
tableau_bord_pib <- function(donnees,
                              var_pib_courant,
                              var_pib_constant = NULL,
                              var_annee        = "annee",
                              vars_secteurs    = NULL,
                              pays             = "Pays",
                              unite            = "Mds FCFA") {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_pib_courant %in% names(donnees)) {
    rlang::abort(paste0("Variable '", var_pib_courant, "' introuvable."))
  }
  if (!var_annee %in% names(donnees)) {
    rlang::abort(paste0("Variable annee '", var_annee, "' introuvable."))
  }

  df    <- donnees[order(as.integer(donnees[[var_annee]])), ]
  pib_c <- as.numeric(df[[var_pib_courant]])
  annee <- as.integer(df[[var_annee]])

  # Croissance nominale
  croiss_nom <- c(NA_real_, round(diff(pib_c)/pib_c[-length(pib_c)]*100, 2))

  res <- tibble::tibble(
    annee           = annee,
    pib_courant     = round(pib_c, 2),
    croissance_nom  = croiss_nom
  )

  # Croissance reelle si PIB constant fourni
  if (!is.null(var_pib_constant) && var_pib_constant %in% names(df)) {
    pib_k <- as.numeric(df[[var_pib_constant]])
    croiss_reel <- c(NA_real_, round(diff(pib_k)/pib_k[-length(pib_k)]*100, 2))
    defl <- round(pib_c / pib_k * 100, 2)
    res$pib_constant   <- round(pib_k, 2)
    res$croissance_reel <- croiss_reel
    res$deflateur       <- defl
  }

  # Contributions sectorielles
  if (!is.null(vars_secteurs)) {
    vars_ok <- vars_secteurs[vars_secteurs %in% names(df)]
    for (nm in names(vars_ok)) {
      v <- as.numeric(df[[vars_ok[[nm]]]])
      res[[paste0("part_", nm, "_pct")]] <- round(v/pib_c*100, 2)
    }
  }

  res$pays  <- pays
  res$unite <- unite

  message("Tableau de bord PIB : ", pays,
          " (", min(annee), "-", max(annee), ")")
  message("  N periodes : ", nrow(res))
  if ("croissance_reel" %in% names(res)) {
    cr_ok <- res$croissance_reel[!is.na(res$croissance_reel)]
    message("  Croissance reelle moy : ", round(mean(cr_ok), 2), "%/an")
  }

  res
}
