# =============================================================================
# statAfrikR — Module Diffusion
# Fonctions de production, anonymisation et diffusion des données
# =============================================================================

# -----------------------------------------------------------------------------
# 1. GÉNÉRATION DE RAPPORT
# -----------------------------------------------------------------------------

#' @title Générer un rapport statistique officiel
#' @description Produit un rapport Word (.docx) ou PDF à partir d'un template
#'   R Markdown. Intègre automatiquement les tableaux, graphiques et métadonnées.
#'   Compatible avec les templates AFRISTAT et PARIS21.
#' @param donnees data.frame ou tibble — Données à inclure dans le rapport
#' @param template character — Chemin vers le template .Rmd ou nom d'un
#'   template intégré : \code{"bulletin_mensuel"}, \code{"rapport_annuel"},
#'   \code{"fiche_pays"}. Défaut : "bulletin_mensuel".
#' @param format_sortie character — \code{"word"} ou \code{"pdf"}.
#'   Défaut : "word".
#' @param fichier_sortie character ou NULL — Chemin du fichier de sortie.
#'   Si NULL, génère un nom automatique. Défaut : NULL.
#' @param metadonnees list ou NULL — Liste de métadonnées à injecter :
#'   titre, auteur, pays, annee, institution. Défaut : NULL.
#' @param ouvrir logical — Ouvrir le rapport après génération. Défaut : FALSE.
#' @return Chemin du fichier généré (invisible).
#' @examples
#' \donttest{
#'   generer_rapport(
#'     donnees        = resultats_enquete,
#'     template       = "bulletin_mensuel",
#'     format_sortie  = "word",
#'     metadonnees    = list(
#'       titre       = "Bulletin mensuel — Mars 2024",
#'       pays        = "Bénin",
#'       institution = "INSAE",
#'       annee       = 2024
#'     )
#'   )
#' }
#' @export
generer_rapport <- function(donnees,
                             template       = "bulletin_mensuel",
                             format_sortie  = c("word", "pdf"),
                             fichier_sortie = NULL,
                             metadonnees    = NULL,
                             ouvrir         = FALSE) {

  format_sortie <- match.arg(format_sortie)
  .verifier_package("rmarkdown", "generer_rapport")

  if (!is.data.frame(donnees)) {
    rlang::abort("`donnees` doit \u00eatre un data.frame ou tibble.")
  }

  # Résolution du template
  templates_integres <- c("bulletin_mensuel", "rapport_annuel", "fiche_pays")

  if (template %in% templates_integres) {
    chemin_template <- system.file(
      "extdata", "templates",
      paste0(template, ".Rmd"),
      package = "statAfrikR"
    )
    if (!nzchar(chemin_template) || !file.exists(chemin_template)) {
      # Template de secours généré à la volée
      chemin_template <- .creer_template_secours(template, metadonnees)
    }
  } else {
    if (!file.exists(template)) {
      rlang::abort(paste0("Template introuvable : '", template, "'."))
    }
    chemin_template <- template
  }

  # Nom du fichier de sortie
  ext <- if (format_sortie == "word") ".docx" else ".pdf"
  if (is.null(fichier_sortie)) {
    horodatage     <- format(Sys.time(), "%Y%m%d_%H%M%S")
    fichier_sortie <- file.path(tempdir(), paste0("rapport_", template, "_", horodatage, ext))
  }

  # Création du répertoire de sortie si nécessaire
  dir_sortie <- dirname(fichier_sortie)
  if (!dir.exists(dir_sortie) && dir_sortie != ".") {
    dir.create(dir_sortie, recursive = TRUE)
  }

  # Paramètres pour le Rmd
  params_rmd <- list(
    donnees     = donnees,
    metadonnees = metadonnees %||% list(
      titre       = paste0("Rapport statistique \u2014 ", template),
      auteur      = "statAfrikR",
      pays        = "Afrique",
      annee       = format(Sys.Date(), "%Y"),
      institution = "INS"
    )
  )

  # Format de sortie rmarkdown
  output_format <- if (format_sortie == "word") {
    rmarkdown::word_document(
      toc            = TRUE,
      toc_depth      = 3,
      number_sections = TRUE
    )
  } else {
    rmarkdown::pdf_document(
      toc            = TRUE,
      toc_depth      = 3,
      number_sections = TRUE,
      latex_engine   = "xelatex"
    )
  }

  tryCatch({
    rmarkdown::render(
      input         = chemin_template,
      output_format = output_format,
      output_file   = fichier_sortie,
      params        = params_rmd,
      quiet         = TRUE,
      envir         = new.env(parent = globalenv())
    )
  }, error = function(e) {
    rlang::abort(paste0(
      "Erreur lors de la g\u00e9n\u00e9ration du rapport : ", conditionMessage(e),
      "\nV\u00e9rifiez que le template est valide et que les packages n\u00e9cessaires ",
      "sont install\u00e9s."
    ))
  })

  if (!file.exists(fichier_sortie)) {
    rlang::abort("Le rapport n'a pas \u00e9t\u00e9 g\u00e9n\u00e9r\u00e9. V\u00e9rifiez le template.")
  }

  taille <- file.size(fichier_sortie)
  message("Rapport g\u00e9n\u00e9r\u00e9 : ", fichier_sortie,
          " (", round(taille / 1024, 1), " Ko)")

  if (ouvrir) {
    tryCatch(
      utils::browseURL(fichier_sortie),
      error = function(e) message("Impossible d'ouvrir automatiquement le fichier.")
    )
  }

  invisible(fichier_sortie)
}


# -----------------------------------------------------------------------------
# 2. ANONYMISATION DES DONNÉES
# -----------------------------------------------------------------------------

#' @title Anonymiser un jeu de données
#' @description Applique les techniques d'anonymisation conformes aux
#'   standards IHSN/PARIS21 : suppression, masquage, generalisation,
#'   perturbation et pseudonymisation des variables sensibles.
#' @param data data.frame ou tibble — Données à anonymiser
#' @param vars_supprimer character ou NULL — Variables à supprimer
#'   entièrement. Défaut : NULL.
#' @param vars_masquer character ou NULL — Variables à remplacer par
#'   des codes anonymes. Défaut : NULL.
#' @param vars_perturber character ou NULL — Variables numériques à
#'   perturber par bruit aléatoire. Défaut : NULL.
#' @param vars_generaliser list ou NULL — Liste nommée de variables à
#'   généraliser avec les bornes : \code{list(age = 5, revenu = 10000)}.
#'   Défaut : NULL.
#' @param niveau_bruit numeric — Niveau de bruit pour la perturbation
#'   (proportion de l'écart-type). Défaut : 0.05.
#' @param graine integer — Graine aléatoire. Défaut : 42.
#' @param rapport logical — Produire un rapport d'anonymisation. Défaut : TRUE.
#' @return Si \code{rapport = FALSE} : tibble anonymisé.
#'   Si \code{rapport = TRUE} : liste avec \code{$donnees} et \code{$rapport}.
#' @examples
#' \donttest{
#'   resultat <- anonymiser_donnees(
#'     donnees_enquete,
#'     vars_supprimer  = c("nom", "prenom", "telephone"),
#'     vars_masquer    = c("id_menage", "id_individu"),
#'     vars_perturber  = c("revenu_mensuel"),
#'     vars_generaliser = list(age = 5)
#'   )
#'   donnees_anon <- resultat$donnees
#' }
#' @export
anonymiser_donnees <- function(data,
                                vars_supprimer   = NULL,
                                vars_masquer     = NULL,
                                vars_perturber   = NULL,
                                vars_generaliser = NULL,
                                niveau_bruit     = 0.05,
                                graine           = 42L,
                                rapport          = TRUE) {

  if (!is.data.frame(data)) {
    rlang::abort("`data` doit \u00eatre un data.frame ou tibble.")
  }

  set.seed(graine)
  data_anon    <- data
  operations   <- list()

  # 1. Suppression
  if (!is.null(vars_supprimer)) {
    vars_ok <- intersect(vars_supprimer, names(data_anon))
    vars_ko <- setdiff(vars_supprimer, names(data_anon))
    if (length(vars_ko) > 0) {
      rlang::warn(paste0(
        "Variables \u00e0 supprimer introuvables (ignor\u00e9es) : ",
        paste(vars_ko, collapse = ", ")
      ))
    }
    if (length(vars_ok) > 0) {
      data_anon <- data_anon[, !names(data_anon) %in% vars_ok, drop = FALSE]
      operations[["suppression"]] <- vars_ok
      message("Supprim\u00e9es : ", paste(vars_ok, collapse = ", "))
    }
  }

  # 2. Masquage (pseudonymisation)
  if (!is.null(vars_masquer)) {
    vars_ok <- intersect(vars_masquer, names(data_anon))
    vars_ko <- setdiff(vars_masquer, names(data_anon))
    if (length(vars_ko) > 0) {
      rlang::warn(paste0(
        "Variables \u00e0 masquer introuvables : ",
        paste(vars_ko, collapse = ", ")
      ))
    }
    for (var in vars_ok) {
      vals_uniques  <- unique(data_anon[[var]])
      n_uniques     <- length(vals_uniques)
      codes_pseudo  <- paste0("ID_",
                               stringr::str_pad(
                                 sample(n_uniques * 10, n_uniques),
                                 width = nchar(n_uniques * 10),
                                 pad   = "0"
                               ))
      mapping       <- stats::setNames(codes_pseudo, as.character(vals_uniques))
      data_anon[[var]] <- mapping[as.character(data_anon[[var]])]
      operations[["masquage"]] <- c(operations[["masquage"]], var)
    }
    if (length(vars_ok) > 0) {
      message("Masqu\u00e9es (pseudonymis\u00e9es) : ", paste(vars_ok, collapse = ", "))
    }
  }

  # 3. Perturbation par bruit additif
  if (!is.null(vars_perturber)) {
    vars_ok <- intersect(vars_perturber, names(data_anon))
    vars_ko <- setdiff(vars_perturber, names(data_anon))
    if (length(vars_ko) > 0) {
      rlang::warn(paste0(
        "Variables \u00e0 perturber introuvables : ",
        paste(vars_ko, collapse = ", ")
      ))
    }
    for (var in vars_ok) {
      x <- data_anon[[var]]
      if (!is.numeric(x)) {
        rlang::warn(paste0(
          "Variable '", var, "' non num\u00e9rique \u2014 perturbation ignor\u00e9e."
        ))
        next
      }
      sigma <- stats::sd(x, na.rm = TRUE) * niveau_bruit
      bruit <- stats::rnorm(length(x), mean = 0, sd = sigma)
      data_anon[[var]] <- x + bruit
      operations[["perturbation"]] <- c(operations[["perturbation"]], var)
    }
    if (length(vars_ok) > 0) {
      message("Perturb\u00e9es (bruit ", niveau_bruit * 100, "% \u03c3) : ",
              paste(vars_ok, collapse = ", "))
    }
  }

  # 4. Généralisation (regroupement en classes)
  if (!is.null(vars_generaliser)) {
    if (!is.list(vars_generaliser)) {
      rlang::abort("`vars_generaliser` doit \u00eatre une liste nomm\u00e9e.")
    }
    for (var in names(vars_generaliser)) {
      if (!var %in% names(data_anon)) {
        rlang::warn(paste0("Variable \u00e0 g\u00e9n\u00e9raliser introuvable : '", var, "'."))
        next
      }
      x       <- data_anon[[var]]
      largeur <- vars_generaliser[[var]]
      if (!is.numeric(x)) {
        rlang::warn(paste0(
          "Variable '", var, "' non num\u00e9rique \u2014 g\u00e9n\u00e9ralisation ignor\u00e9e."
        ))
        next
      }
      min_val <- floor(min(x, na.rm = TRUE) / largeur) * largeur
      max_val <- ceiling(max(x, na.rm = TRUE) / largeur) * largeur
      breaks  <- seq(min_val, max_val + largeur, by = largeur)
      labels  <- paste0(
        seq(min_val, max_val, by = largeur), "-",
        seq(min_val + largeur - 1, max_val + largeur - 1, by = largeur)
      )
      data_anon[[paste0(var, "_classe")]] <- cut(
        x, breaks = breaks, labels = labels,
        right = FALSE, include.lowest = TRUE
      )
      operations[["generalisation"]] <- c(
        operations[["generalisation"]], var
      )
    }
    message("G\u00e9n\u00e9ralis\u00e9es : ",
            paste(names(vars_generaliser), collapse = ", "))
  }

  # Rapport d'anonymisation
  rapport_anon <- tibble::tibble(
    operation    = names(operations),
    variables    = sapply(operations, paste, collapse = ", "),
    n_variables  = sapply(operations, length)
  )

  message("Anonymisation termin\u00e9e : ",
          nrow(data_anon), " lignes x ",
          ncol(data_anon), " colonnes.")

  if (rapport) {
    list(donnees = tibble::as_tibble(data_anon), rapport = rapport_anon)
  } else {
    tibble::as_tibble(data_anon)
  }
}


# -----------------------------------------------------------------------------
# 3. EXPORT SDMX
# -----------------------------------------------------------------------------

#' @title Exporter des données au format SDMX
#' @description Génère un fichier SDMX-CSV ou SDMX-ML (Structure Data Message)
#'   conforme aux standards SDMX 2.1 pour l'échange de données statistiques
#'   avec les organisations internationales (FMI, BM, OCDE, etc.).
#' @param data data.frame ou tibble — Données à exporter
#' @param flux_donnees character — Identifiant du flux de données (DataFlow).
#'   Ex: "BEN_EMOP_2023"
#' @param agence character — Identifiant de l'agence productrice.
#'   Ex: "INSAE", "INSD". Défaut : "INS".
#' @param vars_dimensions character — Variables identifiant les dimensions
#'   (axes d'analyse). Ex: c("PAYS", "ANNEE", "REGION").
#' @param vars_mesures character — Variables contenant les valeurs mesurées.
#' @param vars_attributs character ou NULL — Variables d'attributs
#'   (métadonnées). Défaut : NULL.
#' @param fichier_sortie character — Chemin du fichier de sortie (.csv).
#' @param version character — Version SDMX. Défaut : "2.1".
#' @return Chemin du fichier exporté (invisible).
#' @examples
#' \donttest{
#'   exporter_sdmx(
#'     data            = indicateurs_regionaux,
#'     flux_donnees    = "BEN_IDH_2023",
#'     agence          = "INSAE",
#'     vars_dimensions = c("region", "annee"),
#'     vars_mesures    = c("idh", "taux_pauvrete"),
#'     fichier_sortie  = file.path(tempdir(), "indicateurs_sdmx.csv")
#'   )
#' }
#' @export
exporter_sdmx <- function(data,
                            flux_donnees,
                            agence          = "INS",
                            vars_dimensions,
                            vars_mesures,
                            vars_attributs  = NULL,
                            fichier_sortie,
                            version         = "2.1") {

  if (!is.data.frame(data)) {
    rlang::abort("`data` doit \u00eatre un data.frame ou tibble.")
  }

  if (missing(flux_donnees) || !nzchar(flux_donnees)) {
    rlang::abort("`flux_donnees` est obligatoire (ex: 'BEN_EMOP_2023').")
  }

  if (missing(fichier_sortie) || !nzchar(fichier_sortie)) {
    rlang::abort("`fichier_sortie` est obligatoire.")
  }

  # Vérification des variables
  toutes_vars <- c(vars_dimensions, vars_mesures,
                   if (!is.null(vars_attributs)) vars_attributs)
  vars_abs    <- setdiff(toutes_vars, names(data))
  if (length(vars_abs) > 0) {
    rlang::abort(paste0(
      "Variables introuvables : ", paste(vars_abs, collapse = ", ")
    ))
  }

  # Construction du header SDMX-CSV
  header_sdmx <- paste0(
    "SDMX-CSV;version=", version, "\n",
    "DATAFLOW,", agence, ":", flux_donnees, "[", version, "]"
  )

  # Colonnes SDMX : DATAFLOW, dimensions, mesures, attributs
  data_sdmx <- data[, toutes_vars, drop = FALSE]

  # Normalisation des noms de colonnes en MAJUSCULES (convention SDMX)
  noms_sdmx <- toupper(names(data_sdmx))
  names(data_sdmx) <- noms_sdmx

  # Ajout colonne DATAFLOW
  data_sdmx <- tibble::add_column(
    data_sdmx,
    DATAFLOW = paste0(agence, ":", flux_donnees, "[", version, "]"),
    .before  = 1
  )

  # Séparation OBS_VALUE pour chaque mesure (format SDMX long)
  data_long <- data_sdmx |>
    tidyr::pivot_longer(
      cols      = dplyr::all_of(toupper(vars_mesures)),
      names_to  = "CONCEPT",
      values_to = "OBS_VALUE"
    )

  # Création du répertoire si nécessaire
  dir_sortie <- dirname(fichier_sortie)
  if (!dir.exists(dir_sortie) && dir_sortie != ".") {
    dir.create(dir_sortie, recursive = TRUE)
  }

  # Écriture : header + données
  # Écriture du header SDMX puis des données
  con <- file(fichier_sortie, open = "wt", encoding = "UTF-8")
  writeLines(header_sdmx, con = con)
  close(con)
  
  suppressWarnings(
    utils::write.table(
      data_long,
      file      = fichier_sortie,
      sep       = ",",
      row.names = FALSE,
      col.names = TRUE,
      quote     = TRUE,
      append    = TRUE
    )
  )

  n_obs <- nrow(data_long)
  message("Export SDMX-CSV : ", fichier_sortie)
  message("  Flux : ", flux_donnees, " | Agence : ", agence)
  message("  ", n_obs, " observations | ",
          length(vars_dimensions), " dimension(s) | ",
          length(vars_mesures), " mesure(s)")

  invisible(fichier_sortie)
}


# -----------------------------------------------------------------------------
# 4. MÉTADONNÉES DDI
# -----------------------------------------------------------------------------

#' @title Générer une fiche de métadonnées DDI
#' @description Produit une fiche de métadonnées au format DDI (Data
#'   Documentation Initiative) Codebook 2.5, standard international pour
#'   l'archivage des enquêtes statistiques (IHSN, NADA, NESSTAR).
#' @param data data.frame ou tibble — Données de l'enquête
#' @param titre character — Titre de l'enquête
#' @param pays character — Pays concerné
#' @param annee integer ou character — Année de l'enquête
#' @param institution character — Institution productrice
#' @param auteurs character ou NULL — Auteurs. Défaut : NULL.
#' @param description character ou NULL — Description de l'enquête.
#'   Défaut : NULL.
#' @param fichier_sortie character — Chemin du fichier XML de sortie
#' @param langue character — Langue principale. Défaut : "fr".
#' @return Chemin du fichier généré (invisible).
#' @examples
#' \donttest{
#'   generer_metadonnees_ddi(
#'     data        = donnees_emop,
#'     titre       = "Enquête Modulaire sur les Conditions de Vie — 2023",
#'     pays        = "Bénin",
#'     annee       = 2023,
#'     institution = "INSAE",
#'     fichier_sortie = file.path(tempdir(), "emop_2023_ddi.xml")
#'   )
#' }
#' @export
generer_metadonnees_ddi <- function(data,
                                     titre          = NULL,
                                     pays           = NULL,
                                     annee          = NULL,
                                     institution    = NULL,
                                     auteurs        = NULL,
                                     description    = NULL,
                                     fichier_sortie = NULL,
                                     langue         = "fr") {

  if (!is.data.frame(data)) {
    rlang::abort("`data` doit \u00eatre un data.frame ou tibble.")
  }

  if (is.null(titre)         || !nzchar(as.character(titre)))         rlang::abort("`titre` est obligatoire.")
  if (is.null(pays)          || !nzchar(as.character(pays)))          rlang::abort("`pays` est obligatoire.")
  if (is.null(annee)         || !nzchar(as.character(annee)))         rlang::abort("`annee` est obligatoire.")
  if (is.null(institution)   || !nzchar(as.character(institution)))   rlang::abort("`institution` est obligatoire.")
  if (is.null(fichier_sortie)|| !nzchar(as.character(fichier_sortie)))rlang::abort("`fichier_sortie` est obligatoire.")

  # Statistiques sur les variables
  stats_vars <- lapply(names(data), function(var) {
    x    <- data[[var]]
    type <- dplyr::case_when(
      is.numeric(x)   ~ "continuous",
      is.character(x) ~ "character",
      is.factor(x)    ~ "discrete",
      is.logical(x)   ~ "discrete",
      TRUE            ~ "other"
    )
    list(
      nom      = var,
      type     = type,
      n_valide = sum(!is.na(x)),
      n_na     = sum(is.na(x)),
      n_unique = length(unique(x[!is.na(x)]))
    )
  })

  # Construction XML DDI Codebook 2.5
  date_prod <- format(Sys.Date(), "%Y-%m-%d")
  id_etude  <- paste0(
    toupper(substr(pays, 1, 3)), "_",
    annee, "_",
    toupper(substr(gsub("[^A-Za-z]", "", titre), 1, 6))
  )

  lignes_xml <- c(
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<codeBook xmlns="ddi:codebook:2_5"',
    '  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"',
    '  xsi:schemaLocation="ddi:codebook:2_5 https://www.ddialliance.org/Specification/DDI-Codebook/2.5/XMLSchema/codebook.xsd"',
    paste0('  xml:lang="', langue, '" version="2.5">'),

    # Document description
    '<docDscr>',
    '<citation>',
    paste0('<titlStmt><titl>', .echapper_xml(titre),
           ' \u2014 Documentation</titl></titlStmt>'),
    paste0('<prodStmt><producer>', .echapper_xml(institution),
           '</producer>'),
    paste0('<prodDate>', date_prod, '</prodDate></prodStmt>'),
    '</citation>',
    '</docDscr>',

    # Study description
    '<stdyDscr>',
    '<citation>',
    paste0('<titlStmt>'),
    paste0('  <titl>', .echapper_xml(titre), '</titl>'),
    paste0('  <IDNo agency="', .echapper_xml(institution), '">',
           id_etude, '</IDNo>'),
    '</titlStmt>',
    paste0('<rspStmt>'),
    paste0('  <AuthEnty affiliation="', .echapper_xml(institution), '">',
           if (!is.null(auteurs)) .echapper_xml(paste(auteurs, collapse = "; "))
           else .echapper_xml(institution), '</AuthEnty>'),
    '</rspStmt>',
    paste0('<prodStmt>'),
    paste0('  <producer abbr="', .echapper_xml(institution), '">',
           .echapper_xml(institution), '</producer>'),
    paste0('  <prodDate date="', annee, '">', annee, '</prodDate>'),
    '</prodStmt>',
    '</citation>',

    '<stdyInfo>',
    paste0('<subject>'),
    paste0('  <keyword>statistiques officielles</keyword>'),
    paste0('  <keyword>enqu\u00eate m\u00e9nage</keyword>'),
    paste0('  <keyword>', .echapper_xml(pays), '</keyword>'),
    '</subject>',
    paste0('<abstract>',
           if (!is.null(description)) .echapper_xml(description)
           else paste0("Enqu\u00eate statistique \u2014 ", pays, " ", annee),
           '</abstract>'),
    '</stdyInfo>',

    '<method>',
    '<dataColl>',
    paste0('<timePrd event="start">', annee, '</timePrd>'),
    paste0('<nation>', .echapper_xml(pays), '</nation>'),
    '</dataColl>',
    '</method>',

    # Informations sur les fichiers
    '<dataAccs>',
    '<useStmt>',
    paste0('<restrctn>',
           'Donn\u00e9es produites par ', .echapper_xml(institution),
           '. Utilisation soumise \u00e0 autorisation.',
           '</restrctn>'),
    '</useStmt>',
    '</dataAccs>',
    '</stdyDscr>',

    # Description des variables
    '<fileDscr>',
    paste0('<fileTxt>'),
    paste0('<fileName>', id_etude, '.csv</fileName>'),
    paste0('<dimensns>'),
    paste0('  <caseQnty>', nrow(data), '</caseQnty>'),
    paste0('  <varQnty>', ncol(data), '</varQnty>'),
    '</dimensns>',
    '</fileTxt>',
    '</fileDscr>',

    '<dataDscr>'
  )

  # Variables
  for (i in seq_along(stats_vars)) {
    sv <- stats_vars[[i]]
    lignes_xml <- c(lignes_xml,
      paste0('<var ID="V', i, '" name="', sv$nom,
             '" intrvl="', sv$type, '">'),
      paste0('  <labl>', .echapper_xml(sv$nom), '</labl>'),
      paste0('  <sumStat type="vald">', sv$n_valide, '</sumStat>'),
      paste0('  <sumStat type="invd">', sv$n_na, '</sumStat>'),
      paste0('  <notes>', sv$n_unique,
             ' valeur(s) unique(s)</notes>'),
      '</var>'
    )
  }

  lignes_xml <- c(lignes_xml, '</dataDscr>', '</codeBook>')

  # Écriture du fichier
  dir_sortie <- dirname(fichier_sortie)
  if (!dir.exists(dir_sortie) && dir_sortie != ".") {
    dir.create(dir_sortie, recursive = TRUE)
  }

  writeLines(lignes_xml, con = fichier_sortie, useBytes = FALSE)

  message("M\u00e9tadonn\u00e9es DDI g\u00e9n\u00e9r\u00e9es : ", fichier_sortie)
  message("  \u00c9tude : ", id_etude)
  message("  Variables document\u00e9es : ", ncol(data))

  invisible(fichier_sortie)
}


# -----------------------------------------------------------------------------
# 5. PACKAGE DE DIFFUSION
# -----------------------------------------------------------------------------

#' @title Compresser un package de diffusion
#' @description Crée une archive ZIP structurée prête à diffuser, incluant
#'   les données, la documentation, les métadonnées et les scripts de
#'   traitement. Conforme aux standards IHSN de documentation des enquêtes.
#' @param donnees data.frame ou tibble — Données à archiver
#' @param repertoire_sortie character — Répertoire de destination de l'archive
#' @param nom_package character — Nom de base de l'archive (sans extension)
#' @param inclure_csv logical — Inclure les données en CSV. Défaut : TRUE.
#' @param inclure_rds logical — Inclure les données en RDS. Défaut : TRUE.
#' @param fichiers_supplementaires character ou NULL — Chemins vers des
#'   fichiers additionnels à inclure (rapports, scripts, etc.). Défaut : NULL.
#' @param metadonnees list ou NULL — Métadonnées à inclure dans un fichier
#'   README automatique. Défaut : NULL.
#' @return Chemin de l'archive ZIP (invisible).
#' @examples
#' \donttest{
#'   compresser_package_diffusion(
#'     donnees              = donnees_emop_anon,
#'     repertoire_sortie    = "diffusion/",
#'     nom_package          = "EMOP_BEN_2023_v1",
#'     fichiers_supplementaires = c(file.path(tempdir(), "rapport.docx"),
#'                                   file.path(tempdir(), "emop_ddi.xml")),
#'     metadonnees = list(
#'       titre       = "EMOP Bénin 2023",
#'       institution = "INSAE",
#'       version     = "1.0"
#'     )
#'   )
#' }
#' @export
compresser_package_diffusion <- function(donnees,
                                          repertoire_sortie,
                                          nom_package,
                                          inclure_csv              = TRUE,
                                          inclure_rds              = TRUE,
                                          fichiers_supplementaires = NULL,
                                          metadonnees              = NULL) {

  if (!is.data.frame(donnees)) {
    rlang::abort("`donnees` doit \u00eatre un data.frame ou tibble.")
  }

  if (missing(repertoire_sortie) || !nzchar(repertoire_sortie)) {
    rlang::abort("`repertoire_sortie` est obligatoire.")
  }

  if (missing(nom_package) || !nzchar(nom_package)) {
    rlang::abort("`nom_package` est obligatoire.")
  }

  # Création du répertoire temporaire de staging
  dir_temp <- file.path(
    tempdir(),
    paste0(nom_package, "_", format(Sys.time(), "%Y%m%d%H%M%S"))
  )
  dir.create(dir_temp, recursive = TRUE)
  on.exit(unlink(dir_temp, recursive = TRUE), add = TRUE)

  fichiers_inclus <- character(0)

  # Données CSV
  if (inclure_csv) {
    chemin_csv <- file.path(dir_temp, paste0(nom_package, ".csv"))
    utils::write.csv(donnees, chemin_csv, row.names = FALSE,
                     fileEncoding = "UTF-8")
    fichiers_inclus <- c(fichiers_inclus, chemin_csv)
    message("  + Donn\u00e9es CSV : ", basename(chemin_csv))
  }

  # Données RDS
  if (inclure_rds) {
    chemin_rds <- file.path(dir_temp, paste0(nom_package, ".rds"))
    saveRDS(donnees, chemin_rds)
    fichiers_inclus <- c(fichiers_inclus, chemin_rds)
    message("  + Donn\u00e9es RDS : ", basename(chemin_rds))
  }

  # README automatique
  readme_contenu <- .generer_readme(nom_package, donnees, metadonnees)
  chemin_readme  <- file.path(dir_temp, "README.md")
  writeLines(readme_contenu, chemin_readme)
  fichiers_inclus <- c(fichiers_inclus, chemin_readme)

  # Fichiers supplémentaires
  if (!is.null(fichiers_supplementaires)) {
    for (fich in fichiers_supplementaires) {
      if (file.exists(fich)) {
        dest <- file.path(dir_temp, basename(fich))
        file.copy(fich, dest)
        fichiers_inclus <- c(fichiers_inclus, dest)
        message("  + Fichier : ", basename(fich))
      } else {
        rlang::warn(paste0("Fichier introuvable (ignor\u00e9) : '", fich, "'."))
      }
    }
  }

  # Création du répertoire de sortie
  if (!dir.exists(repertoire_sortie)) {
    dir.create(repertoire_sortie, recursive = TRUE)
  }

  # Compression en ZIP
  chemin_zip <- file.path(
    repertoire_sortie,
    paste0(nom_package, "_",
           format(Sys.Date(), "%Y%m%d"), ".zip")
  )

  utils::zip(
    zipfile = chemin_zip,
    files   = fichiers_inclus,
    flags   = "-j"  # -j = pas de chemins dans l'archive
  )

  if (!file.exists(chemin_zip)) {
    rlang::abort("\u00c9chec de la cr\u00e9ation de l'archive ZIP.")
  }

  taille <- file.size(chemin_zip)
  taille_fmt <- if (taille > 1e6) {
    paste0(round(taille / 1e6, 1), " Mo")
  } else {
    paste0(round(taille / 1e3, 1), " Ko")
  }

  message("Package de diffusion cr\u00e9\u00e9 : ", chemin_zip)
  message("  Fichiers inclus : ", length(fichiers_inclus))
  message("  Taille : ", taille_fmt)

  invisible(chemin_zip)
}


# =============================================================================
# FONCTIONS INTERNES
# =============================================================================

#' @keywords internal
.echapper_xml <- function(x) {
  x <- as.character(x)
  x <- gsub("&",  "&amp;",  x, fixed = TRUE)
  x <- gsub("<",  "&lt;",   x, fixed = TRUE)
  x <- gsub(">",  "&gt;",   x, fixed = TRUE)
  x <- gsub("\"", "&quot;", x, fixed = TRUE)
  x <- gsub("'",  "&apos;", x, fixed = TRUE)
  x
}

#' @keywords internal
.generer_readme <- function(nom_package, donnees, metadonnees = NULL) {
  meta <- metadonnees %||% list()
  c(
    paste0("# ", nom_package),
    "",
    paste0("**Date de cr\u00e9ation :** ", format(Sys.Date(), "%d %B %Y")),
    paste0("**G\u00e9n\u00e9r\u00e9 par :** statAfrikR (package R)"),
    "",
    "## Contenu",
    "",
    paste0("- Observations : ", formatC(nrow(donnees),
                                         big.mark = " ", format = "d")),
    paste0("- Variables    : ", ncol(donnees)),
    paste0("- Variables    : ", paste(names(donnees), collapse = ", ")),
    "",
    if (!is.null(meta$titre)) paste0("## Titre\n\n", meta$titre) else NULL,
    if (!is.null(meta$institution)) paste0("\n## Institution\n\n",
                                            meta$institution) else NULL,
    if (!is.null(meta$version)) paste0("\n## Version\n\n",
                                        meta$version) else NULL,
    "",
    "## Utilisation",
    "",
    "```r",
    paste0('donnees <- readRDS("', nom_package, '.rds")'),
    "```",
    "",
    "---",
    "_Package statAfrikR \u2014 INS africains_"
  )
}

#' @keywords internal
.creer_template_secours <- function(nom_template, metadonnees = NULL) {
  tmp <- tempfile(fileext = ".Rmd")
  meta <- metadonnees %||% list(
    titre       = paste0("Rapport \u2014 ", nom_template),
    auteur      = "statAfrikR",
    institution = "INS",
    annee       = format(Sys.Date(), "%Y")
  )
  contenu <- c(
    "---",
    paste0('title: "', meta$titre %||% nom_template, '"'),
    paste0('author: "', meta$auteur %||% "statAfrikR", '"'),
    paste0('date: "', format(Sys.Date(), "%d %B %Y"), '"'),
    "output:",
    "  word_document:",
    "    toc: true",
    "params:",
    "  donnees: NULL",
    "  metadonnees: NULL",
    "---",
    "",
    "```{r setup, include=FALSE}",
    "knitr::opts_chunk$set(echo = FALSE, warning = FALSE, message = FALSE)",
    "```",
    "",
    "## R\u00e9sum\u00e9",
    "",
    "```{r resume}",
    "if (!is.null(params$donnees)) {",
    "  cat('Observations :', nrow(params$donnees), '\\n')",
    "  cat('Variables    :', ncol(params$donnees), '\\n')",
    "}",
    "```",
    "",
    "## Statistiques descriptives",
    "",
    "```{r stats}",
    "if (!is.null(params$donnees)) {",
    "  vars_num <- names(params$donnees)[sapply(params$donnees, is.numeric)]",
    "  if (length(vars_num) > 0) {",
    "    knitr::kable(summary(params$donnees[, head(vars_num, 5)]))",
    "  }",
    "}",
    "```"
  )
  writeLines(contenu, tmp)
  tmp
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

#' @keywords internal
`%||%` <- function(a, b) if (!is.null(a)) a else b
