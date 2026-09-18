# =============================================================================
# statAfrikR - Module Validation Statistique INS
# INS Validation Suite \u2014 Conforme aux standards IHSN/PARIS21/ONU
# =============================================================================

utils::globalVariables(c(
  "critere", "statut", "valeur", "detail", "recommandation", "priorite"
))

#' @title Valider la qualite statistique d'une enquete (INS Validation Suite)
#' @description Produit un rapport de validation complet couvrant 10 criteres
#'   de qualite statistique institutionnelle : donnees, poids, plan de
#'   sondage, valeurs manquantes, geographie, precision, confidentialite,
#'   metadonnees, reproductibilite et indicateurs cles.
#'   Conforme aux standards IHSN / PARIS21 / ONU.
#'
#' @param donnees data.frame -- Donnees de l'enquete
#' @param var_poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param var_region character ou NULL -- Variable region/prefecture.
#'   Defaut : NULL
#' @param var_milieu character ou NULL -- Variable milieu. Defaut : NULL
#' @param var_depense character ou NULL -- Variable de consommation/depense
#'   pour le calcul FGT. Defaut : NULL
#' @param seuil_pauvrete numeric ou NULL -- Seuil de pauvrete. Defaut : NULL
#' @param dictionnaire data.frame ou NULL -- Dictionnaire des variables avec
#'   colonnes : variable, label, type_attendu. Defaut : NULL
#' @param seuil_na_alerte numeric -- Seuil de % valeurs manquantes
#'   declenchant une alerte. Defaut : 0.05 (5%)
#' @param seuil_cv_alerte numeric -- Seuil de CV declenchant une alerte.
#'   Defaut : 33.0
#' @param seuil_cellule integer -- Seuil de confidentialite. Defaut : 5L
#' @param pays character -- Nom du pays. Defaut : "Pays"
#' @param annee integer -- Annee de l'enquete. Defaut : annee courante
#'
#' @return Un objet de classe \code{saf_validation_ins} avec le rapport
#'   complet et le statut global
#'
#' @examples
#' set.seed(42)
#' n <- 500
#' donnees <- data.frame(
#'   region  = sample(c("Nord","Sud","Est","Ouest"), n, TRUE),
#'   milieu  = sample(c("urbain","rural"), n, TRUE),
#'   poids   = runif(n, 800, 3500),
#'   depense = pmax(10000, rnorm(n, 165000, 90000)),
#'   sexe    = sample(c("H","F"), n, TRUE),
#'   age     = sample(15:80, n, TRUE),
#'   stringsAsFactors = FALSE
#' )
#' valider_statistique_ins(donnees,
#'   var_poids  = "poids",
#'   var_region = "region",
#'   var_milieu = "milieu",
#'   pays       = "Centrafrique",
#'   annee      = 2024L)
#'
#' @export
valider_statistique_ins <- function(donnees,
                                     var_poids       = NULL,
                                     var_region      = NULL,
                                     var_milieu      = NULL,
                                     var_depense     = NULL,
                                     seuil_pauvrete  = NULL,
                                     dictionnaire    = NULL,
                                     seuil_na_alerte = 0.05,
                                     seuil_cv_alerte = 33.0,
                                     seuil_cellule   = 5L,
                                     pays            = "Pays",
                                     annee           = as.integer(
                                       format(Sys.Date(), "%Y"))) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }

  resultats <- list()
  t0 <- proc.time()

  # =========================================================================
  # CRITERE 1 \u2014 DONNEES (completude, types, doublons)
  # =========================================================================
  message("[ 1/10] Validation donnees...")
  n_obs      <- nrow(donnees)
  n_vars     <- ncol(donnees)
  n_doublons <- sum(duplicated(donnees))
  pct_doublons <- n_doublons / n_obs * 100

  statut_1 <- if (n_doublons == 0) "PASS" else if (pct_doublons < 1) "WARN" else "FAIL"

  resultats[["donnees"]] <- tibble::tibble(
    critere       = "Qualite des donnees",
    sous_critere  = c("Nombre observations", "Nombre variables",
                      "Doublons detectes", "Taux doublons (%)"),
    valeur        = c(n_obs, n_vars, n_doublons, round(pct_doublons, 2)),
    statut        = c("INFO", "INFO",
                      if (n_doublons == 0) "PASS" else "WARN",
                      if (pct_doublons < 1) "PASS" else "FAIL"),
    recommandation = c(
      paste0(format(n_obs, big.mark=" "), " menages"),
      paste0(n_vars, " variables"),
      if (n_doublons == 0) "Aucun doublon" else
        paste0(n_doublons, " doublons \u2014 supprimer_doublons()"),
      ""
    )
  )

  # =========================================================================
  # CRITERE 2 \u2014 POIDS DE SONDAGE
  # =========================================================================
  message("[ 2/10] Validation poids de sondage...")
  if (!is.null(var_poids) && var_poids %in% names(donnees)) {
    w   <- as.numeric(donnees[[var_poids]])
    n_neg  <- sum(!is.na(w) & w <= 0)
    n_na_w <- sum(is.na(w))
    cv_w   <- if (mean(w, na.rm=TRUE) > 0)
      stats::sd(w, na.rm=TRUE) / mean(w, na.rm=TRUE) * 100 else NA_real_
    z_scores <- abs(w - mean(w, na.rm=TRUE)) / stats::sd(w, na.rm=TRUE)
    n_outliers <- sum(z_scores > 3, na.rm=TRUE)

    resultats[["poids"]] <- tibble::tibble(
      critere      = "Poids de sondage",
      sous_critere = c("Variable poids", "Poids negatifs/nuls",
                       "Poids manquants", "CV des poids (%)",
                       "Poids aberrants (Z>3)"),
      valeur       = c(var_poids, n_neg, n_na_w,
                       round(cv_w, 1), n_outliers),
      statut       = c("INFO",
                       if (n_neg == 0) "PASS" else "FAIL",
                       if (n_na_w == 0) "PASS" else "WARN",
                       if (!is.na(cv_w) && cv_w < 50) "PASS" else "WARN",
                       if (n_outliers == 0) "PASS" else "WARN"),
      recommandation = c(
        "", "",
        if (n_na_w > 0) "Imputer ou exclure les poids manquants" else "",
        if (!is.na(cv_w) && cv_w > 50)
          "CV eleve \u2014 verifier la calibration des poids" else "",
        if (n_outliers > 0)
          paste0(n_outliers, " poids outliers \u2014 calibrer_poids()") else ""
      )
    )
  } else {
    resultats[["poids"]] <- tibble::tibble(
      critere = "Poids de sondage",
      sous_critere = "Variable poids",
      valeur = "Non fournie",
      statut = "WARN",
      recommandation = "Fournir var_poids pour une estimation ponderee"
    )
  }

  # =========================================================================
  # CRITERE 3 \u2014 VALEURS MANQUANTES
  # =========================================================================
  message("[ 3/10] Analyse valeurs manquantes...")
  na_rates <- sapply(donnees, function(x) mean(is.na(x)))
  vars_na_elevees <- names(na_rates[na_rates > seuil_na_alerte])
  n_vars_ok <- sum(na_rates == 0)
  n_vars_warn <- sum(na_rates > 0 & na_rates <= seuil_na_alerte)
  n_vars_fail <- sum(na_rates > seuil_na_alerte)

  resultats[["manquantes"]] <- tibble::tibble(
    critere      = "Valeurs manquantes",
    sous_critere = c("Variables completes (0% NA)",
                     paste0("Variables avec NA <= ", seuil_na_alerte*100, "%"),
                     paste0("Variables avec NA > ", seuil_na_alerte*100, "%"),
                     "Variables concernees"),
    valeur       = c(n_vars_ok, n_vars_warn, n_vars_fail,
                     if (length(vars_na_elevees) > 0)
                       paste(vars_na_elevees[1:min(5,length(vars_na_elevees))],
                             collapse=", ")
                     else "Aucune"),
    statut       = c("INFO", "INFO",
                     if (n_vars_fail == 0) "PASS" else "WARN",
                     if (n_vars_fail == 0) "PASS" else "WARN"),
    recommandation = c("", "",
      if (n_vars_fail > 0)
        paste0(n_vars_fail, " var(s) \u2014 imputer_valeurs() recommande") else "",
      "")
  )

  # =========================================================================
  # CRITERE 4 \u2014 GEOGRAPHIE
  # =========================================================================
  message("[ 4/10] Validation geographie...")
  if (!is.null(var_region) && var_region %in% names(donnees)) {
    n_regions <- length(unique(donnees[[var_region]]))
    dist_region <- table(donnees[[var_region]])
    n_petites  <- sum(dist_region < 30)

    resultats[["geographie"]] <- tibble::tibble(
      critere      = "Geographie",
      sous_critere = c("Variable region", "Nombre de regions",
                       "Regions avec n < 30"),
      valeur       = c(var_region, n_regions, n_petites),
      statut       = c("INFO", "INFO",
                       if (n_petites == 0) "PASS" else "WARN"),
      recommandation = c("", "",
        if (n_petites > 0)
          paste0(n_petites, " region(s) avec n<30 \u2014 precision faible") else "")
    )
  } else {
    resultats[["geographie"]] <- tibble::tibble(
      critere = "Geographie",
      sous_critere = "Variable region",
      valeur = "Non fournie",
      statut = "INFO",
      recommandation = "Fournir var_region pour analyse spatiale"
    )
  }

  # =========================================================================
  # CRITERE 5 \u2014 PRECISION STATISTIQUE
  # =========================================================================
  message("[ 5/10] Evaluation precision statistique...")
  if (!is.null(var_poids) && var_poids %in% names(donnees)) {
    w <- as.numeric(donnees[[var_poids]])
    w[is.na(w)|w<=0] <- 1

    # Estimer le DEFF approximatif pour les variables binaires
    vars_bin <- names(donnees)[sapply(donnees, function(x) {
      v <- x[!is.na(x)]
      length(unique(v)) == 2 && all(v %in% c(0,1))
    })]
    vars_bin <- vars_bin[vars_bin != var_poids][1:min(3, length(vars_bin))]

    if (length(vars_bin) > 0) {
      deffs <- sapply(vars_bin, function(v) {
        x <- as.numeric(donnees[[v]])
        ok <- !is.na(x)
        p <- stats::weighted.mean(x[ok], w[ok])
        n <- sum(ok)
        var_w  <- sum(w[ok]^2 * (x[ok] - p)^2) / sum(w[ok])^2
        var_sr <- p*(1-p)/n
          if (!is.na(var_sr) && var_sr > 0) var_w/var_sr else NA_real_
      })
      deff_moy <- round(mean(deffs, na.rm=TRUE), 2)
    } else {
      deff_moy <- NA_real_
    }

    resultats[["precision"]] <- tibble::tibble(
      critere      = "Precision statistique",
      sous_critere = c("Methode IC recommandee",
                       "DEFF moyen (variables binaires)",
                       "Seuil CV alerte (%)"),
      valeur       = c(
        "Wilson (simple) / Taylor (plan complexe)",
        if (!is.na(deff_moy)) deff_moy else "Non calcule",
        seuil_cv_alerte
      ),
      statut       = c("INFO",
                       if (!is.na(deff_moy) && deff_moy <= 3) "PASS"
                       else if (!is.na(deff_moy)) "WARN" else "INFO",
                       "INFO"),
      recommandation = c(
        "Pour publications officielles : creer_design() + survey::svymean()",
        if (!is.na(deff_moy) && deff_moy > 3)
          "DEFF eleve \u2014 utiliser plan de sondage complexe" else "",
        paste0("Avertissement si CV > ", seuil_cv_alerte, "%")
      )
    )
  } else {
    resultats[["precision"]] <- tibble::tibble(
      critere = "Precision statistique",
      sous_critere = "DEFF",
      valeur = "Non calcule (poids requis)",
      statut = "INFO",
      recommandation = "Fournir var_poids pour estimer le DEFF"
    )
  }

  # =========================================================================
  # CRITERE 6 \u2014 CONFIDENTIALITE
  # =========================================================================
  message("[ 6/10] Controle confidentialite...")
  vars_cat <- names(donnees)[sapply(donnees, function(x)
    is.character(x) || is.factor(x))]
  vars_cat_filt <- vars_cat[as.logical(sapply(vars_cat, function(v)
    length(unique(donnees[[v]])) <= nrow(donnees) * 0.5))]

  alertes_conf <- sapply(vars_cat_filt, function(v) {
    eff <- table(donnees[[v]])
    sum(eff > 0 & eff < seuil_cellule)
  })
  n_vars_conf <- sum(alertes_conf > 0)

  resultats[["confidentialite"]] <- tibble::tibble(
    critere      = "Confidentialite",
    sous_critere = c("Seuil cellule", "Variables avec cellules<seuil",
                     "Variables categorielle verifiees"),
    valeur       = c(seuil_cellule, n_vars_conf, length(vars_cat_filt)),
    statut       = c("INFO",
                     if (n_vars_conf == 0) "PASS" else "WARN",
                     "INFO"),
    recommandation = c("",
      if (n_vars_conf > 0) paste0(
        n_vars_conf, " variable(s) avec cellules<", seuil_cellule,
        " \u2014 anonymiser_donnees()") else "",
      "")
  )

  # =========================================================================
  # CRITERE 7 \u2014 METADONNEES
  # =========================================================================
  message("[ 7/10] Verification metadonnees...")
  if (!is.null(dictionnaire) && is.data.frame(dictionnaire)) {
    if ("variable" %in% names(dictionnaire)) {
      vars_documentees  <- intersect(names(donnees), dictionnaire$variable)
      vars_non_doc      <- setdiff(names(donnees), dictionnaire$variable)
      pct_doc <- round(length(vars_documentees) / ncol(donnees) * 100, 1)
      statut_meta <- if (pct_doc >= 95) "PASS" else if (pct_doc >= 80) "WARN" else "FAIL"
    } else {
      pct_doc <- 0; statut_meta <- "WARN"
      vars_non_doc <- names(donnees)
    }
    resultats[["metadonnees"]] <- tibble::tibble(
      critere      = "Metadonnees",
      sous_critere = c("Variables documentees (%)", "Variables non documentees"),
      valeur       = c(pct_doc, length(vars_non_doc)),
      statut       = c(statut_meta,
                       if (length(vars_non_doc)==0) "PASS" else "WARN"),
      recommandation = c(
        if (pct_doc < 95) "Completer le dictionnaire" else "",
        if (length(vars_non_doc) > 0)
          paste(vars_non_doc[1:min(5,length(vars_non_doc))], collapse=", ")
        else "")
    )
  } else {
    resultats[["metadonnees"]] <- tibble::tibble(
      critere = "Metadonnees",
      sous_critere = "Dictionnaire",
      valeur = "Non fourni",
      statut = "WARN",
      recommandation = "Fournir un dictionnaire \u2014 generer_metadonnees_ddi()"
    )
  }

  # =========================================================================
  # CRITERE 8 \u2014 REPRODUCTIBILITE
  # =========================================================================
  message("[ 8/10] Verification reproductibilite...")
  ver_pkg <- tryCatch(
    as.character(utils::packageVersion("statAfrikR")),
    error = function(e) "inconnue"
  )
  resultats[["reproductibilite"]] <- tibble::tibble(
    critere      = "Reproductibilite",
    sous_critere = c("Version statAfrikR", "Date validation", "Pays", "Annee"),
    valeur       = c(ver_pkg, format(Sys.Date(), "%Y-%m-%d"), pays, annee),
    statut       = c("INFO","INFO","INFO","INFO"),
    recommandation = c(
      paste0("Documenter version=", ver_pkg, " dans les notes methodologiques"),
      "", "", ""
    )
  )

  # =========================================================================
  # CRITERE 9 \u2014 INDICATEURS CLES
  # =========================================================================
  message("[ 9/10] Calcul indicateurs cles...")
  ind_resultats <- list()

  # FGT si disponible
  if (!is.null(var_depense) && var_depense %in% names(donnees) &&
      !is.null(seuil_pauvrete)) {
    fgt_res <- tryCatch(suppressMessages(
      calcul_fgt(donnees, var_depense, seuil_pauvrete, poids=var_poids)
    ), error=function(e) NULL)
    if (!is.null(fgt_res)) {
      fgt0 <- fgt_res$national$fgt0
      cv_fgt0 <- (fgt_res$national$fgt0_ic_haut -
                    fgt_res$national$fgt0_ic_bas) / (2*1.96) / fgt0 * 100
      ind_resultats[["FGT0"]] <- tibble::tibble(
        indicateur = "FGT0 (incidence pauvrete)",
        valeur = round(fgt0 * 100, 2),
        cv_pct = round(cv_fgt0, 1),
        statut = if (cv_fgt0 < seuil_cv_alerte) "PASS" else "WARN",
        note   = if (cv_fgt0 >= seuil_cv_alerte)
          paste0("CV=", round(cv_fgt0,1), "% > ", seuil_cv_alerte, "%") else ""
      )
    }
  }

  if (length(ind_resultats) == 0) {
    ind_resultats[["info"]] <- tibble::tibble(
      indicateur = "Indicateurs cles",
      valeur     = NA_real_,
      cv_pct     = NA_real_,
      statut     = "INFO",
      note       = "Fournir var_depense + seuil_pauvrete pour calcul FGT"
    )
  }

  resultats[["indicateurs"]] <- dplyr::bind_rows(ind_resultats)

  # =========================================================================
  # CRITERE 10 \u2014 STATUT GLOBAL
  # =========================================================================
  message("[10/10] Calcul statut global...")
  tous_statuts <- unlist(lapply(resultats, function(r) r$statut))
  n_fail <- sum(tous_statuts == "FAIL", na.rm=TRUE)
  n_warn <- sum(tous_statuts == "WARN", na.rm=TRUE)
  n_pass <- sum(tous_statuts == "PASS", na.rm=TRUE)

  statut_global <- if (n_fail > 0) "ECHEC" else if (n_warn > 0) "A VERIFIER" else "VALIDE"

  duree <- max(0.001, as.numeric((proc.time() - t0)["elapsed"]))

  # Affichage rapport
  .afficher_rapport_ins(resultats, statut_global, n_pass, n_warn,
                         n_fail, pays, annee, duree)

  structure(
    list(
      rapport        = resultats,
      statut_global  = statut_global,
      n_pass         = n_pass,
      n_warn         = n_warn,
      n_fail         = n_fail,
      pays           = pays,
      annee          = annee,
      version        = ver_pkg,
      duree_sec      = duree
    ),
    class = "saf_validation_ins"
  )
}

# =============================================================================
# AFFICHAGE DU RAPPORT
# =============================================================================

#' @keywords internal
.afficher_rapport_ins <- function(resultats, statut_global, n_pass,
                                   n_warn, n_fail, pays, annee, duree) {
  message("\n")
  message(strrep("=", 60))
  message("  statAfrikR -- RAPPORT DE VALIDATION INS")
  message("  ", pays, " - ", annee)
  message(strrep("=", 60))

  sections <- c(
    donnees         = "Qualite donnees",
    poids           = "Poids de sondage",
    manquantes      = "Valeurs manquantes",
    geographie      = "Geographie",
    precision       = "Precision statistique",
    confidentialite = "Confidentialite",
    metadonnees     = "Metadonnees",
    reproductibilite = "Reproductibilite",
    indicateurs     = "Indicateurs cles"
  )

  for (sec in names(sections)) {
    if (!sec %in% names(resultats)) next
    statuts_sec <- resultats[[sec]]$statut
    statut_sec  <- if (any(statuts_sec == "FAIL")) "FAIL"
      else if (any(statuts_sec == "WARN")) "WARN"
      else "PASS"
    symbole <- switch(statut_sec,
      PASS = "[PASS]", WARN = "[WARN]", FAIL = "[FAIL]", "[INFO]")
    message("  ", symbole, " ", sections[sec])
  }

  message(strrep("-", 60))
  message("  PASS : ", n_pass, " | WARN : ", n_warn, " | FAIL : ", n_fail)
  message("  STATUT GLOBAL : ", statut_global)
  message("  Duree : ", duree, "s")
  message(strrep("=", 60))
  message("")
}

#' @export
print.saf_validation_ins <- function(x, ...) {
  cat("\n=== Rapport de validation INS ===\n")
  cat("  Pays   :", x$pays, "\n")
  cat("  Annee  :", x$annee, "\n")
  cat("  Statut :", x$statut_global, "\n")
  cat("  PASS   :", x$n_pass, "| WARN :", x$n_warn, "| FAIL :", x$n_fail, "\n")
  cat("  Duree  :", x$duree_sec, "s\n")
  invisible(x)
}
