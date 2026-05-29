# =============================================================================
# statAfrikR - Module Rapports parametres
# Generation automatique de documents statistiques reproductibles
# Templates : R Markdown (rmarkdown en Suggests)
# =============================================================================

# =============================================================================
# 1. RAPPORT D'ENQUETE MENAGE
# =============================================================================

#' @title Generer un rapport d'enquete menage parametre
#' @description Genere un rapport statistique complet a partir de donnees
#'   d'enquete menage, en utilisant un template R Markdown pre-construit.
#'   Le rapport inclut une page de garde, des statistiques descriptives,
#'   une pyramide demographique et les indicateurs cles.
#'
#' @param donnees data.frame -- Donnees d'enquete menage
#' @param meta list -- Metadonnees du rapport. Elements attendus :
#'   \code{pays}, \code{titre}, \code{annee}, \code{source},
#'   \code{auteur} (tous optionnels)
#' @param template character -- Nom du template :
#'   \code{"enquete_menage"} ou \code{"bulletin"}.
#'   Defaut : "enquete_menage"
#' @param sortie character -- Format de sortie : \code{"html"},
#'   \code{"pdf"} ou \code{"word"}. Defaut : "html"
#' @param chemin_sortie character -- Repertoire de destination.
#'   Defaut : \code{tempdir()}
#' @param vars_analyse character ou NULL -- Variables a analyser.
#'   Si NULL, detecte automatiquement les variables numeriques.
#'   Defaut : NULL
#' @param var_poids character ou NULL -- Variable de ponderation.
#'   Defaut : NULL
#' @param ouvrir logical -- Ouvrir le rapport apres generation.
#'   Defaut : FALSE
#'
#' @return Chemin du fichier genere (invisible)
#'
#' @examples
#' \dontrun{
#'   set.seed(42)
#'   donnees <- data.frame(
#'     age    = sample(18:70, 200, replace = TRUE),
#'     revenu = rexp(200, rate = 1/250000),
#'     sexe   = sample(c("H","F"), 200, TRUE),
#'     milieu = sample(c("urbain","rural"), 200, TRUE),
#'     poids  = runif(200, 0.8, 1.3)
#'   )
#'   meta <- list(
#'     pays   = "Republique Centrafricaine",
#'     titre  = "Enquete sur les conditions de vie des menages",
#'     annee  = 2026L,
#'     source = "ICASEES",
#'     auteur = "Direction des Statistiques"
#'   )
#'   generer_rapport_enquete(donnees, meta, sortie = "html")
#' }
#'
#' @export
generer_rapport_enquete <- function(donnees,
                                     meta          = list(),
                                     template      = c("enquete_menage",
                                                       "bulletin"),
                                     sortie        = c("html", "pdf", "word"),
                                     chemin_sortie = tempdir(),
                                     vars_analyse  = NULL,
                                     var_poids     = NULL,
                                     ouvrir        = FALSE) {

  .verifier_package("rmarkdown", "generer_rapport_enquete")

  template <- match.arg(template)
  sortie   <- match.arg(sortie)

  if (!is.data.frame(donnees) || nrow(donnees) == 0) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!dir.exists(chemin_sortie)) {
    rlang::abort(paste0("Repertoire de sortie inexistant : ", chemin_sortie))
  }

  # Localiser le template
  template_rmd <- system.file(
    "rmd", paste0(template, ".Rmd"),
    package = "statAfrikR"
  )
  if (!nzchar(template_rmd)) {
    rlang::abort(paste0(
      "Template '", template, ".Rmd' introuvable dans le package statAfrikR.\n",
      "Verifiez l'installation du package."
    ))
  }

  # Detection automatique des variables
  if (is.null(vars_analyse)) {
    vars_analyse <- names(donnees)[sapply(donnees, is.numeric)]
    if (!is.null(var_poids)) {
      vars_analyse <- setdiff(vars_analyse, var_poids)
    }
    if (length(vars_analyse) > 8L) {
      vars_analyse <- vars_analyse[seq_len(8L)]
      rlang::inform(paste0(
        "Variables limitees aux 8 premieres variables numeriques. ",
        "Precisez `vars_analyse` pour personaliser."
      ))
    }
  }

  # Metadonnees avec valeurs par defaut
  meta_complete <- list(
    pays      = if (!is.null(meta$pays))   meta$pays   else "Pays",
    titre     = if (!is.null(meta$titre))  meta$titre  else "Rapport statistique",
    annee     = if (!is.null(meta$annee))  meta$annee  else as.integer(format(Sys.Date(), "%Y")),
    source    = if (!is.null(meta$source)) meta$source else "statAfrikR",
    auteur    = if (!is.null(meta$auteur)) meta$auteur else "statAfrikR Foundation",
    date_gen  = format(Sys.Date(), "%d/%m/%Y")
  )

  # Format de sortie rmarkdown
  output_format <- switch(sortie,
    "html" = rmarkdown::html_document(
      toc            = TRUE,
      toc_float      = TRUE,
      toc_depth      = 3L,
      number_sections = TRUE,
      theme          = "flatly",
      highlight      = "tango",
      css            = NULL
    ),
    "pdf"  = rmarkdown::pdf_document(
      toc            = TRUE,
      toc_depth      = 3L,
      number_sections = TRUE,
      latex_engine   = "xelatex"
    ),
    "word" = rmarkdown::word_document(
      toc            = TRUE,
      toc_depth      = 3L,
      number_sections = TRUE,
      reference_docx = NULL
    )
  )

  # Extension du fichier de sortie
  ext <- switch(sortie, "html" = ".html", "pdf" = ".pdf", "word" = ".docx")
  nom_fichier <- paste0(
    gsub("[^A-Za-z0-9_]", "_",
         meta_complete$pays), "_",
    meta_complete$annee,
    "_rapport", ext
  )
  chemin_output <- file.path(chemin_sortie, nom_fichier)

  # Parametres passes au template
  params_rmd <- list(
    donnees      = donnees,
    meta         = meta_complete,
    vars_analyse = vars_analyse,
    var_poids    = var_poids
  )

  # Rendu du rapport
  message("Generation du rapport en cours...")
  message("  Template  : ", template)
  message("  Format    : ", sortie)
  message("  Pays      : ", meta_complete$pays)
  message("  Fichier   : ", basename(chemin_output))

  tryCatch({
    rmarkdown::render(
      input         = template_rmd,
      output_format = output_format,
      output_file   = chemin_output,
      params        = params_rmd,
      quiet         = TRUE,
      envir         = new.env(parent = globalenv())
    )
  }, error = function(e) {
    rlang::abort(paste0(
      "Erreur lors de la generation du rapport : ",
      conditionMessage(e),
      "\nVerifiez que rmarkdown et ses dependances sont installes."
    ))
  })

  message("Rapport genere : ", chemin_output)

  if (ouvrir && file.exists(chemin_output)) {
    utils::browseURL(chemin_output)
  }

  invisible(chemin_output)
}

# =============================================================================
# 2. BULLETIN STATISTIQUE
# =============================================================================

#' @title Generer un bulletin statistique periodique
#' @description Genere un bulletin statistique mensuel ou trimestriel
#'   avec indicateurs cles, graphiques de tendance et tableau de bord.
#'
#' @param indicateurs data.frame -- Tableau des indicateurs avec colonnes :
#'   \code{indicateur}, \code{valeur}, \code{unite}, \code{periode}
#' @param periode character -- Periode de reference (ex : "T1 2026",
#'   "Janvier 2026")
#' @param pays character -- Nom du pays. Defaut : "Pays"
#' @param sortie character -- Format : \code{"html"} ou \code{"word"}.
#'   Defaut : "html"
#' @param chemin_sortie character -- Repertoire de destination.
#'   Defaut : \code{tempdir()}
#' @param ouvrir logical -- Ouvrir apres generation. Defaut : FALSE
#'
#' @return Chemin du fichier genere (invisible)
#'
#' @examples
#' \dontrun{
#'   indicateurs <- data.frame(
#'     indicateur = c("Taux de pauvrete", "Taux de chomage",
#'                    "Acces eau potable", "Taux alphabetisation"),
#'     valeur     = c(71.8, 14.5, 42.3, 56.7),
#'     unite      = c("%", "%", "%", "%"),
#'     periode    = rep("2026", 4)
#'   )
#'   generer_bulletin(indicateurs, periode = "T1 2026",
#'                    pays = "Republique Centrafricaine")
#' }
#'
#' @export
generer_bulletin <- function(indicateurs,
                              periode,
                              pays          = "Pays",
                              sortie        = c("html", "word"),
                              chemin_sortie = tempdir(),
                              ouvrir        = FALSE) {

  .verifier_package("rmarkdown", "generer_bulletin")

  sortie <- match.arg(sortie)

  if (!is.data.frame(indicateurs) || nrow(indicateurs) == 0) {
    rlang::abort("`indicateurs` doit etre un data.frame non vide.")
  }
  cols_req <- c("indicateur", "valeur", "unite")
  cols_abs <- setdiff(cols_req, names(indicateurs))
  if (length(cols_abs) > 0) {
    rlang::abort(paste0(
      "Colonnes manquantes dans `indicateurs` : ",
      paste(cols_abs, collapse = ", ")
    ))
  }

  template_rmd <- system.file("rmd", "bulletin.Rmd",
                               package = "statAfrikR")
  if (!nzchar(template_rmd)) {
    rlang::abort("Template 'bulletin.Rmd' introuvable.")
  }

  ext <- if (sortie == "html") ".html" else ".docx"
  nom_fichier  <- paste0(
    gsub("[^A-Za-z0-9_]", "_", pays), "_",
    gsub("[^A-Za-z0-9_]", "_", periode),
    "_bulletin", ext
  )
  chemin_output <- file.path(chemin_sortie, nom_fichier)

  output_format <- if (sortie == "html") {
    rmarkdown::html_document(toc = TRUE, theme = "flatly",
                              number_sections = FALSE)
  } else {
    rmarkdown::word_document(toc = TRUE, toc_depth = 2L)
  }

  params_rmd <- list(
    indicateurs = indicateurs,
    periode     = periode,
    pays        = pays,
    date_gen    = format(Sys.Date(), "%d/%m/%Y")
  )

  message("Generation du bulletin...")
  message("  Pays    : ", pays)
  message("  Periode : ", periode)
  message("  Format  : ", sortie)

  tryCatch({
    rmarkdown::render(
      input         = template_rmd,
      output_format = output_format,
      output_file   = chemin_output,
      params        = params_rmd,
      quiet         = TRUE,
      envir         = new.env(parent = globalenv())
    )
  }, error = function(e) {
    rlang::abort(paste0(
      "Erreur generation bulletin : ", conditionMessage(e)
    ))
  })

  message("Bulletin genere : ", chemin_output)
  if (ouvrir && file.exists(chemin_output)) utils::browseURL(chemin_output)
  invisible(chemin_output)
}

# =============================================================================
# 3. RAPPORT ODD
# =============================================================================

#' @title Generer un rapport de suivi des ODD parametre
#' @description Genere un rapport de suivi des Objectifs de Developpement
#'   Durable au format standard PARIS21/Nations Unies.
#'
#' @param resultats_odd list -- Liste d'objets \code{saf_odd}
#'   (resultats de \code{odd_indicateur()})
#' @param pays character -- Nom du pays. Defaut : "Pays"
#' @param annee integer -- Annee de reference. Defaut : annee courante
#' @param cibles list ou NULL -- Cibles nationales par code ODD.
#'   Defaut : NULL
#' @param sortie character -- Format : \code{"html"}, \code{"pdf"} ou
#'   \code{"word"}. Defaut : "html"
#' @param chemin_sortie character -- Repertoire. Defaut : \code{tempdir()}
#' @param ouvrir logical -- Ouvrir apres generation. Defaut : FALSE
#'
#' @return Chemin du fichier genere (invisible)
#'
#' @examples
#' \dontrun{
#'   set.seed(42)
#'   menages <- data.frame(
#'     depense_pc  = c(rexp(70, 1/150000), rexp(30, 1/500000)),
#'     electricite = sample(c(0L,1L), 100, TRUE, c(0.45, 0.55)),
#'     internet    = sample(c(0L,1L), 100, TRUE, c(0.72, 0.28))
#'   )
#'   r1 <- odd_indicateur(menages, "1.2.1",
#'                        var_depense = "depense_pc", seuil = 200000)
#'   r2 <- odd_indicateur(menages, "7.1.1",
#'                        var_indicateur = "electricite")
#'   generer_rapport_odd(
#'     list(r1, r2),
#'     pays  = "Republique Centrafricaine",
#'     annee = 2026L,
#'     cibles = list("1.2.1" = 50, "7.1.1" = 80)
#'   )
#' }
#'
#' @export
generer_rapport_odd <- function(resultats_odd,
                                 pays          = "Pays",
                                 annee         = as.integer(format(Sys.Date(),
                                                                    "%Y")),
                                 cibles        = NULL,
                                 sortie        = c("html", "pdf", "word"),
                                 chemin_sortie = tempdir(),
                                 ouvrir        = FALSE) {

  .verifier_package("rmarkdown", "generer_rapport_odd")

  sortie <- match.arg(sortie)

  if (!is.list(resultats_odd) || length(resultats_odd) == 0) {
    rlang::abort("`resultats_odd` doit etre une liste non vide.")
  }
  non_odd <- !sapply(resultats_odd, inherits, what = "saf_odd")
  if (any(non_odd)) {
    rlang::abort(paste0(
      length(which(non_odd)),
      " element(s) ne sont pas des objets saf_odd.",
      "\nUtilisez odd_indicateur() pour produire les resultats."
    ))
  }

  template_rmd <- system.file("rmd", "rapport_odd.Rmd",
                               package = "statAfrikR")
  if (!nzchar(template_rmd)) {
    rlang::abort("Template 'rapport_odd.Rmd' introuvable.")
  }

  # Construire le tableau de suivi ODD
  tab_odd <- tableau_odd(resultats_odd, pays = pays,
                          annee = annee, cibles = cibles)

  ext <- switch(sortie, "html" = ".html", "pdf" = ".pdf", "word" = ".docx")
  nom_fichier   <- paste0(
    gsub("[^A-Za-z0-9_]", "_", pays), "_",
    annee, "_rapport_odd", ext
  )
  chemin_output <- file.path(chemin_sortie, nom_fichier)

  output_format <- switch(sortie,
    "html" = rmarkdown::html_document(toc = TRUE, theme = "flatly",
                                       number_sections = TRUE),
    "pdf"  = rmarkdown::pdf_document(toc = TRUE, latex_engine = "xelatex"),
    "word" = rmarkdown::word_document(toc = TRUE)
  )

  params_rmd <- list(
    tab_odd  = tab_odd,
    resultats = resultats_odd,
    pays     = pays,
    annee    = annee,
    cibles   = cibles,
    date_gen = format(Sys.Date(), "%d/%m/%Y")
  )

  message("Generation rapport ODD...")
  message("  Pays       : ", pays)
  message("  Annee      : ", annee)
  message("  Indicateurs: ", length(resultats_odd))

  tryCatch({
    rmarkdown::render(
      input         = template_rmd,
      output_format = output_format,
      output_file   = chemin_output,
      params        = params_rmd,
      quiet         = TRUE,
      envir         = new.env(parent = globalenv())
    )
  }, error = function(e) {
    rlang::abort(paste0(
      "Erreur generation rapport ODD : ", conditionMessage(e)
    ))
  })

  message("Rapport ODD genere : ", chemin_output)
  if (ouvrir && file.exists(chemin_output)) utils::browseURL(chemin_output)
  invisible(chemin_output)
}

# =============================================================================
# 4. LISTE DES TEMPLATES DISPONIBLES
# =============================================================================

#' @title Lister les templates de rapport disponibles
#' @description Retourne la liste des templates R Markdown disponibles
#'   dans statAfrikR avec leur description et parametres.
#'
#' @return Un tibble avec : nom, description, parametres, format_sortie
#'
#' @examples
#' lister_templates()
#'
#' @export
lister_templates <- function() {
  tibble::tibble(
    nom = c(
      "enquete_menage",
      "bulletin",
      "rapport_odd"
    ),
    description = c(
      "Rapport complet d'enquete menage : page de garde, stats descriptives, indicateurs cles",
      "Bulletin statistique periodique : tableau de bord, indicateurs, evolution",
      "Rapport de suivi ODD : indicateurs SDG, cibles, ecarts, graphiques progression"
    ),
    fonction = c(
      "generer_rapport_enquete()",
      "generer_bulletin()",
      "generer_rapport_odd()"
    ),
    formats = c(
      "html, pdf, word",
      "html, word",
      "html, pdf, word"
    )
  )
}
