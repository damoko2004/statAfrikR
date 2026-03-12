# =============================================================================
# statAfrikR — Module Collecte
# Fonctions d'importation et de validation des données
# Formats supportés : Excel, CSV, Stata, SPSS, SAS, CSPro, KoboToolbox, ODK
# =============================================================================

# -----------------------------------------------------------------------------
# 1. IMPORT EXCEL / CSV
# -----------------------------------------------------------------------------

#' @title Importer un fichier Excel
#' @description Importe un fichier Excel (.xlsx, .xls) avec détection
#'   automatique des feuilles, gestion des en-têtes multiples et conversion
#'   intelligente des types de colonnes. Optimisé pour les formats courants
#'   des INS africains.
#' @param chemin character — Chemin vers le fichier Excel (.xlsx ou .xls)
#' @param feuille character ou integer ou NULL — Nom ou numéro de la feuille
#'   à importer. Si NULL, importe toutes les feuilles sous forme de liste.
#'   Défaut : 1 (première feuille).
#' @param skip integer — Nombre de lignes à ignorer avant l'en-tête.
#'   Défaut : 0.
#' @param col_types character ou NULL — Types des colonnes (voir readxl).
#'   Si NULL, détection automatique. Défaut : NULL.
#' @param na character — Valeurs à interpréter comme NA.
#'   Défaut : c("", "NA", "N/A", "n/a", ".", " ").
#' @param verbose logical — Afficher les messages de progression.
#'   Défaut : TRUE.
#' @return Un tibble si une seule feuille, une liste de tibbles si
#'   \code{feuille = NULL}.
#' @examples
#' \dontrun{
#'   # Import de la première feuille
#'   donnees <- import_excel("data/enquete_menage.xlsx")
#'
#'   # Import d'une feuille spécifique
#'   menages <- import_excel("data/emop_2024.xlsx", feuille = "Menages")
#'
#'   # Import de toutes les feuilles
#'   toutes <- import_excel("data/rapport.xlsx", feuille = NULL)
#' }
#' @seealso \code{\link{import_csv}}, \code{\link{valider_dictionnaire}}
#' @export
import_excel <- function(chemin,
                         feuille   = 1,
                         skip      = 0,
                         col_types = NULL,
                         na        = c("", "NA", "N/A", "n/a", ".", " "),
                         verbose   = TRUE) {

  .verifier_package("readxl", "import_excel")

  if (!file.exists(chemin)) {
    rlang::abort(paste0(
      "Fichier introuvable : '", chemin, "'.\n",
      "Vérifiez le chemin et l'extension (.xlsx ou .xls)."
    ))
  }

  ext <- tolower(tools::file_ext(chemin))
  if (!ext %in% c("xlsx", "xls")) {
    rlang::abort(paste0(
      "Extension non reconnue : '.", ext, "'.\n",
      "Utilisez import_csv() pour les fichiers .csv."
    ))
  }

  feuilles_dispo <- readxl::excel_sheets(chemin)

  if (verbose) {
    message("Fichier : ", basename(chemin))
    message("Feuilles disponibles : ", paste(feuilles_dispo, collapse = ", "))
  }

  # Import de toutes les feuilles
  if (is.null(feuille)) {
    if (verbose) message("Import de toutes les feuilles...")
    result <- lapply(feuilles_dispo, function(f) {
      readxl::read_excel(chemin, sheet = f, skip = skip,
                         col_types = col_types, na = na)
    })
    names(result) <- feuilles_dispo
    if (verbose) message(length(result), " feuilles importées.")
    return(result)
  }

  # Import d'une feuille spécifique
  if (is.character(feuille) && !feuille %in% feuilles_dispo) {
    rlang::abort(paste0(
      "Feuille '", feuille, "' introuvable.\n",
      "Feuilles disponibles : ", paste(feuilles_dispo, collapse = ", ")
    ))
  }

  donnees <- readxl::read_excel(chemin, sheet = feuille, skip = skip,
                                 col_types = col_types, na = na)

  if (verbose) {
    message(formatC(nrow(donnees), big.mark = " "), " lignes x ",
            ncol(donnees), " colonnes importées.")
  }

  donnees
}


#' @title Importer un fichier CSV
#' @description Importe un fichier CSV avec détection automatique de
#'   l'encodage, du séparateur et du séparateur décimal. Gère les formats
#'   courants des INS africains (séparateurs point-virgule, virgule, tabulation).
#' @param chemin character — Chemin vers le fichier CSV
#' @param separateur character ou NULL — Séparateur de colonnes.
#'   Si NULL, détection automatique. Défaut : NULL.
#' @param encodage character — Encodage du fichier.
#'   Défaut : "UTF-8" (essaie aussi "latin1" si UTF-8 échoue).
#' @param decimal character — Séparateur décimal ("." ou ","). Défaut : ".".
#' @param na character — Valeurs à interpréter comme NA.
#'   Défaut : c("", "NA", "N/A", "n/a", ".", " ").
#' @param verbose logical — Afficher les messages. Défaut : TRUE.
#' @return Un tibble.
#' @examples
#' \dontrun{
#'   donnees <- import_csv("data/prix_marches.csv")
#'   donnees_fr <- import_csv("data/donnees_fr.csv", decimal = ",")
#' }
#' @export
import_csv <- function(chemin,
                       separateur = NULL,
                       encodage   = "UTF-8",
                       decimal    = ".",
                       na         = c("", "NA", "N/A", "n/a", ".", " "),
                       verbose    = TRUE) {

  if (!file.exists(chemin)) {
    rlang::abort(paste0("Fichier introuvable : '", chemin, "'."))
  }

  # Détection automatique du séparateur
  if (is.null(separateur)) {
    separateur <- .detecter_separateur(chemin, encodage)
    if (verbose) message("Séparateur détecté : '", separateur, "'")
  }

  donnees <- tryCatch({
    readr::read_delim(
      chemin,
      delim          = separateur,
      locale         = readr::locale(encoding = encodage,
                                     decimal_mark = decimal),
      na             = na,
      show_col_types = FALSE,
      name_repair    = "unique"
    )
  }, error = function(e) {
    if (encodage == "UTF-8") {
      if (verbose) rlang::warn("UTF-8 échoué, tentative avec latin1...")
      readr::read_delim(
        chemin,
        delim          = separateur,
        locale         = readr::locale(encoding = "latin1",
                                       decimal_mark = decimal),
        na             = na,
        show_col_types = FALSE,
        name_repair    = "unique"
      )
    } else {
      rlang::abort(paste0("Impossible de lire le fichier : ", e$message))
    }
  })

  if (verbose) {
    message(formatC(nrow(donnees), big.mark = " "), " lignes x ",
            ncol(donnees), " colonnes importées.")
  }

  donnees
}


# -----------------------------------------------------------------------------
# 2. IMPORT STATA / SPSS / SAS
# -----------------------------------------------------------------------------

#' @title Importer un fichier Stata
#' @description Importe un fichier Stata (.dta) avec préservation des labels
#'   de variables et de valeurs. Compatible avec toutes les versions Stata
#'   (Stata 8 à Stata 18).
#' @param chemin character — Chemin vers le fichier .dta
#' @param encoding character — Encodage pour les labels. Défaut : "UTF-8".
#' @param garder_labels logical — Conserver les labels comme attributs.
#'   Défaut : TRUE.
#' @param convertir_labels logical — Convertir les variables labellisées
#'   en facteurs. Défaut : FALSE.
#' @param verbose logical — Afficher les messages. Défaut : TRUE.
#' @return Un tibble avec attributs de labels si \code{garder_labels = TRUE}.
#' @examples
#' \dontrun{
#'   eds <- import_stata("data/eds_2021.dta")
#'   eds_facteurs <- import_stata("data/eds_2021.dta", convertir_labels = TRUE)
#' }
#' @export
import_stata <- function(chemin,
                         encoding        = "UTF-8",
                         garder_labels   = TRUE,
                         convertir_labels = FALSE,
                         verbose         = TRUE) {

  .verifier_package("haven", "import_stata")

  if (!file.exists(chemin)) {
    rlang::abort(paste0("Fichier Stata introuvable : '", chemin, "'."))
  }

  if (tolower(tools::file_ext(chemin)) != "dta") {
    rlang::warn("L'extension n'est pas .dta — tentative d'import quand même.")
  }

  donnees <- tryCatch(
    haven::read_dta(chemin, encoding = encoding),
    error = function(e) {
      rlang::abort(paste0(
        "Impossible de lire le fichier Stata.\n",
        "Erreur : ", e$message, "\n",
        "Vérifiez que le fichier n'est pas corrompu ou d'une version trop ancienne."
      ))
    }
  )

  if (convertir_labels) {
    donnees <- haven::as_factor(donnees)
  }

  if (verbose) {
    message("Fichier Stata importé : ", basename(chemin))
    message(formatC(nrow(donnees), big.mark = " "), " observations x ",
            ncol(donnees), " variables.")
    vars_labellisees <- sum(sapply(donnees, haven::is.labelled))
    if (vars_labellisees > 0) {
      message(vars_labellisees, " variables avec labels de valeurs.")
    }
  }

  donnees
}


#' @title Importer un fichier SPSS
#' @description Importe un fichier SPSS (.sav ou .zsav) avec préservation
#'   des labels de variables et de valeurs SPSS.
#' @param chemin character — Chemin vers le fichier .sav ou .zsav
#' @param garder_labels logical — Conserver les labels. Défaut : TRUE.
#' @param convertir_labels logical — Convertir en facteurs. Défaut : FALSE.
#' @param encoding character ou NULL — Encodage. Si NULL, détection auto.
#'   Défaut : NULL.
#' @param verbose logical — Afficher les messages. Défaut : TRUE.
#' @return Un tibble.
#' @examples
#' \dontrun{
#'   mics <- import_spss("data/mics6_enfants.sav")
#' }
#' @export
import_spss <- function(chemin,
                        garder_labels    = TRUE,
                        convertir_labels = FALSE,
                        encoding         = NULL,
                        verbose          = TRUE) {

  .verifier_package("haven", "import_spss")

  if (!file.exists(chemin)) {
    rlang::abort(paste0("Fichier SPSS introuvable : '", chemin, "'."))
  }

  ext <- tolower(tools::file_ext(chemin))
  if (!ext %in% c("sav", "zsav")) {
    rlang::warn(paste0("Extension inattendue : '.", ext, "'. Attendu : .sav ou .zsav"))
  }

  donnees <- tryCatch(
    haven::read_sav(chemin, encoding = encoding),
    error = function(e) {
      rlang::abort(paste0(
        "Impossible de lire le fichier SPSS.\n",
        "Erreur : ", e$message
      ))
    }
  )

  if (convertir_labels) {
    donnees <- haven::as_factor(donnees)
  }

  if (verbose) {
    message("Fichier SPSS importé : ", basename(chemin))
    message(formatC(nrow(donnees), big.mark = " "), " observations x ",
            ncol(donnees), " variables.")
  }

  donnees
}


#' @title Importer un fichier SAS
#' @description Importe un fichier SAS (.sas7bdat) ou un fichier de formats
#'   SAS (.sas7bcat) avec préservation des labels.
#' @param chemin character — Chemin vers le fichier .sas7bdat
#' @param chemin_formats character ou NULL — Chemin vers le fichier de
#'   formats .sas7bcat (optionnel). Défaut : NULL.
#' @param encoding character — Encodage. Défaut : "UTF-8".
#' @param verbose logical — Afficher les messages. Défaut : TRUE.
#' @return Un tibble.
#' @examples
#' \dontrun{
#'   donnees <- import_sas("data/enquete_emploi.sas7bdat")
#' }
#' @export
import_sas <- function(chemin,
                       chemin_formats = NULL,
                       encoding       = "UTF-8",
                       verbose        = TRUE) {

  .verifier_package("haven", "import_sas")

  if (!file.exists(chemin)) {
    rlang::abort(paste0("Fichier SAS introuvable : '", chemin, "'."))
  }

  donnees <- tryCatch(
    haven::read_sas(chemin,
                    catalog_file = chemin_formats,
                    encoding     = encoding),
    error = function(e) {
      rlang::abort(paste0(
        "Impossible de lire le fichier SAS.\n",
        "Erreur : ", e$message
      ))
    }
  )

  if (verbose) {
    message("Fichier SAS importé : ", basename(chemin))
    message(formatC(nrow(donnees), big.mark = " "), " observations x ",
            ncol(donnees), " variables.")
  }

  donnees
}


# -----------------------------------------------------------------------------
# 3. IMPORT CSPRO
# -----------------------------------------------------------------------------

#' @title Importer des données CSPro
#' @description Lit les fichiers de données produits par CSPro (format .dat
#'   avec dictionnaire .dcf associé). Retourne un tibble avec les labels
#'   issus du dictionnaire CSPro. Fonction prioritaire pour les RGPH africains.
#'   Compatible avec CSPro 4.x à 8.x.
#' @param fichier_dat character — Chemin vers le fichier de données (.dat)
#' @param fichier_dcf character ou NULL — Chemin vers le dictionnaire (.dcf).
#'   Si NULL, recherche automatiquement un .dcf de même nom dans le même
#'   répertoire. Défaut : NULL.
#' @param niveau character ou NULL — Niveau d'enregistrement à lire
#'   (ex: "MENAGE", "INDIVIDU", "LOGEMENT"). Si NULL, lit le premier niveau.
#'   Défaut : NULL.
#' @param encoding character — Encodage du fichier source. Défaut : "UTF-8".
#' @param max_lignes integer ou NULL — Nombre maximum de lignes à lire
#'   (utile pour les tests sur grands fichiers RGPH). Défaut : NULL (tout lire).
#' @param verbose logical — Afficher les messages. Défaut : TRUE.
#' @return Un tibble avec une colonne par variable CSPro. Les labels de valeurs
#'   sont stockés dans les attributs du tibble (\code{attr(., "labels_cspro")}).
#' @examples
#' \dontrun{
#'   # Import du niveau ménage d'un RGPH
#'   menages <- import_cspro(
#'     fichier_dat = "data/rgph_2024.dat",
#'     fichier_dcf = "data/rgph_2024.dcf",
#'     niveau      = "MENAGE"
#'   )
#'
#'   # Test sur les 1000 premières lignes
#'   test <- import_cspro("data/rgph_2024.dat", max_lignes = 1000)
#' }
#' @export
import_cspro <- function(fichier_dat,
                         fichier_dcf = NULL,
                         niveau      = NULL,
                         encoding    = "UTF-8",
                         max_lignes  = NULL,
                         verbose     = TRUE) {

  if (!file.exists(fichier_dat)) {
    rlang::abort(paste0("Fichier .dat introuvable : '", fichier_dat, "'."))
  }

  # Recherche automatique du .dcf
  if (is.null(fichier_dcf)) {
    fichier_dcf <- sub("\\.[Dd][Aa][Tt]$", ".dcf", fichier_dat)
    if (!file.exists(fichier_dcf)) {
      fichier_dcf <- sub("\\.[Dd][Aa][Tt]$", ".DCF", fichier_dat)
    }
    if (!file.exists(fichier_dcf)) {
      rlang::abort(c(
        "Fichier dictionnaire .dcf introuvable.",
        "i" = paste0("Chemin cherché : ", sub("\\.[Dd][Aa][Tt]$", ".dcf", fichier_dat)),
        "i" = "Spécifiez le chemin manuellement via `fichier_dcf`."
      ))
    }
    if (verbose) message("Dictionnaire détecté : ", basename(fichier_dcf))
  }

  if (!file.exists(fichier_dcf)) {
    rlang::abort(paste0("Fichier dictionnaire introuvable : '", fichier_dcf, "'."))
  }

  if (verbose) message("Lecture du dictionnaire CSPro...")
  dico <- .lire_dcf(fichier_dcf, encoding)

  niveaux_dispo <- names(dico$niveaux)
  if (verbose) message("Niveaux disponibles : ", paste(niveaux_dispo, collapse = ", "))

  # Sélection du niveau
  if (is.null(niveau)) {
    niveau <- niveaux_dispo[1]
    if (verbose) message("Niveau sélectionné : ", niveau)
  } else {
    niveau_up <- toupper(niveau)
    niveaux_up <- toupper(niveaux_dispo)
    if (!niveau_up %in% niveaux_up) {
      rlang::abort(paste0(
        "Niveau '", niveau, "' introuvable dans le dictionnaire.\n",
        "Niveaux disponibles : ", paste(niveaux_dispo, collapse = ", ")
      ))
    }
    niveau <- niveaux_dispo[which(niveaux_up == niveau_up)]
  }

  if (verbose) message("Lecture des données CSPro (niveau : ", niveau, ")...")

  donnees <- .lire_dat_cspro(
    fichier_dat = fichier_dat,
    dico        = dico,
    niveau      = niveau,
    encoding    = encoding,
    max_lignes  = max_lignes
  )

  if (verbose) {
    message(formatC(nrow(donnees), big.mark = " "), " enregistrements x ",
            ncol(donnees), " variables importés.")
  }

  donnees
}


# -----------------------------------------------------------------------------
# 4. IMPORT KOBOTOOLBOX
# -----------------------------------------------------------------------------

#' @title Importer des données depuis KoboToolbox
#' @description Importe un formulaire KoboToolbox via fichier local (XLS/JSON)
#'   ou via l'API REST KoboToolbox. Retourne un tibble annoté avec les
#'   métadonnées du formulaire. Compatible avec KoboToolbox et KoBoCAT.
#' @param source character — Chemin vers un fichier XLS/JSON local, ou URL
#'   de base de l'API (ex: "https://kf.kobotoolbox.org").
#' @param uid character ou NULL — Identifiant unique du formulaire (requis
#'   si source = URL API). Défaut : NULL.
#' @param token character — Jeton d'authentification API. Peut aussi être
#'   défini via la variable d'environnement \code{KOBO_TOKEN}.
#'   Défaut : \code{Sys.getenv("KOBO_TOKEN")}.
#' @param format character — Format du fichier local : "xls" ou "json".
#'   Ignoré si source est une URL. Défaut : "xls".
#' @param langue character — Code langue pour les labels multilingues
#'   (ex: "French (fr)", "English (en)"). Défaut : "French (fr)".
#' @param verbose logical — Afficher les messages. Défaut : TRUE.
#' @return Un tibble avec les colonnes du formulaire. L'attribut
#'   \code{attr(., "metadonnees_kobo")} contient le dictionnaire des variables.
#' @examples
#' \dontrun{
#'   # Import depuis fichier XLS local
#'   donnees <- import_kobo(source = "data/enquete_2024.xls")
#'
#'   # Import depuis API KoboToolbox
#'   Sys.setenv(KOBO_TOKEN = "mon_token_secret")
#'   donnees <- import_kobo(
#'     source = "https://kf.kobotoolbox.org",
#'     uid    = "aXmNk7pQrS",
#'     langue = "French (fr)"
#'   )
#' }
#' @export
import_kobo <- function(source,
                        uid     = NULL,
                        token   = Sys.getenv("KOBO_TOKEN"),
                        format  = c("xls", "json"),
                        langue  = "French (fr)",
                        verbose = TRUE) {

  format <- match.arg(format)

  if (missing(source) || !nzchar(source)) {
    rlang::abort("L'argument `source` est obligatoire : chemin de fichier ou URL API.")
  }

  est_url <- grepl("^https?://", source)

  if (est_url) {
    .verifier_package("httr2", "import_kobo (mode API)")
    .verifier_package("jsonlite", "import_kobo (mode API)")

    if (is.null(uid) || !nzchar(uid)) {
      rlang::abort("L'argument `uid` est requis pour un import via API.")
    }
    if (!nzchar(token)) {
      rlang::abort(c(
        "Token API manquant.",
        "i" = "Définissez KOBO_TOKEN : Sys.setenv(KOBO_TOKEN = 'votre_token')"
      ))
    }
    if (verbose) message("Connexion à l'API KoboToolbox (uid: ", uid, ")...")
    .import_kobo_api(source, uid, token, langue, verbose)

  } else {
    if (!file.exists(source)) {
      rlang::abort(paste0("Fichier KoboToolbox introuvable : '", source, "'."))
    }

    if (format == "xls") {
      .verifier_package("readxl", "import_kobo (format XLS)")
      if (verbose) message("Import KoboToolbox depuis fichier XLS...")
      .import_kobo_xls(source, langue, verbose)
    } else {
      .verifier_package("jsonlite", "import_kobo (format JSON)")
      if (verbose) message("Import KoboToolbox depuis fichier JSON...")
      .import_kobo_json(source, langue, verbose)
    }
  }
}


# -----------------------------------------------------------------------------
# 5. IMPORT ODK CENTRAL
# -----------------------------------------------------------------------------

#' @title Importer des données ODK Central
#' @description Importe les soumissions d'un formulaire ODK Central via
#'   l'API REST ou depuis un fichier d'export local (ZIP ou CSV).
#'   Compatible avec ODK Central 1.x et 2.x.
#' @param source character — URL du serveur ODK Central (ex:
#'   "https://odk.monins.org") ou chemin vers un fichier d'export .zip/.csv.
#' @param projet_id integer ou NULL — ID du projet ODK. Requis si source
#'   est une URL. Défaut : NULL.
#' @param formulaire_id character ou NULL — ID du formulaire ODK. Requis si
#'   source est une URL. Défaut : NULL.
#' @param email character ou NULL — Email de connexion ODK Central.
#'   Peut aussi être défini via \code{ODK_EMAIL}. Défaut : NULL.
#' @param mot_de_passe character — Mot de passe ODK Central.
#'   Peut aussi être défini via \code{ODK_PASSWORD}. Défaut :
#'   \code{Sys.getenv("ODK_PASSWORD")}.
#' @param inclure_metadonnees logical — Inclure les colonnes de métadonnées
#'   ODK (timestamps, deviceid, etc.). Défaut : FALSE.
#' @param verbose logical — Afficher les messages. Défaut : TRUE.
#' @return Un tibble contenant les soumissions du formulaire.
#' @examples
#' \dontrun{
#'   # Import depuis export ZIP local
#'   donnees <- import_odk(source = "data/odk_export_2024.zip")
#'
#'   # Import depuis API ODK Central
#'   Sys.setenv(ODK_EMAIL = "admin@ins.org", ODK_PASSWORD = "motdepasse")
#'   donnees <- import_odk(
#'     source        = "https://odk.monins.org",
#'     projet_id     = 1,
#'     formulaire_id = "enquete_menage_2024"
#'   )
#' }
#' @export
import_odk <- function(source,
                       projet_id            = NULL,
                       formulaire_id        = NULL,
                       email                = Sys.getenv("ODK_EMAIL"),
                       mot_de_passe         = Sys.getenv("ODK_PASSWORD"),
                       inclure_metadonnees  = FALSE,
                       verbose              = TRUE) {

  if (missing(source) || !nzchar(source)) {
    rlang::abort("L'argument `source` est obligatoire.")
  }

  est_url <- grepl("^https?://", source)

  if (est_url) {
    .verifier_package("httr2", "import_odk (mode API)")
    .verifier_package("jsonlite", "import_odk (mode API)")

    if (is.null(projet_id)) {
      rlang::abort("L'argument `projet_id` est requis pour un import via API.")
    }
    if (is.null(formulaire_id)) {
      rlang::abort("L'argument `formulaire_id` est requis pour un import via API.")
    }
    if (!nzchar(email) || !nzchar(mot_de_passe)) {
      rlang::abort(c(
        "Identifiants ODK manquants.",
        "i" = "Définissez ODK_EMAIL et ODK_PASSWORD via Sys.setenv()."
      ))
    }
    if (verbose) message("Connexion à ODK Central (projet: ", projet_id, ")...")
    .import_odk_api(source, projet_id, formulaire_id, email,
                    mot_de_passe, inclure_metadonnees, verbose)

  } else {
    if (!file.exists(source)) {
      rlang::abort(paste0("Fichier ODK introuvable : '", source, "'."))
    }
    ext <- tolower(tools::file_ext(source))
    if (ext == "zip") {
      if (verbose) message("Import ODK depuis export ZIP...")
      .import_odk_zip(source, inclure_metadonnees, verbose)
    } else if (ext == "csv") {
      if (verbose) message("Import ODK depuis fichier CSV...")
      import_csv(source, verbose = verbose)
    } else {
      rlang::abort(paste0(
        "Format non supporté : '.", ext, "'.\n",
        "Formats acceptés : .zip (export ODK) ou .csv."
      ))
    }
  }
}


# -----------------------------------------------------------------------------
# 6. VALIDATION DES DONNÉES
# -----------------------------------------------------------------------------

#' @title Détecter les valeurs manquantes
#' @description Calcule le taux de valeurs manquantes par variable et produit
#'   un rapport de complétude. Alerte sur les variables dépassant le seuil.
#' @param data data.frame ou tibble — Données à analyser
#' @param seuil numeric — Taux de NA à partir duquel une alerte est émise
#'   (entre 0 et 1). Défaut : 0.1 (10%).
#' @param vars character ou NULL — Variables à analyser. Si NULL, toutes les
#'   variables. Défaut : NULL.
#' @param alerter logical — Émettre des avertissements pour les variables
#'   dépassant le seuil. Défaut : TRUE.
#' @return Un tibble avec les colonnes : \code{variable}, \code{n_total},
#'   \code{n_manquant}, \code{taux_na}, \code{statut}.
#' @examples
#' rapport_na <- check_na(donnees_enquete)
#' rapport_na <- check_na(donnees_enquete, seuil = 0.05, vars = c("age", "revenu"))
#' @export
check_na <- function(data,
                     seuil   = 0.1,
                     vars    = NULL,
                     alerter = TRUE) {

  if (!is.data.frame(data)) {
    rlang::abort("L'argument `data` doit être un data.frame ou tibble.")
  }

  if (seuil < 0 || seuil > 1) {
    rlang::abort("Le `seuil` doit être compris entre 0 et 1.")
  }

  if (!is.null(vars)) {
    vars_absentes <- setdiff(vars, names(data))
    if (length(vars_absentes) > 0) {
      rlang::abort(paste0(
        "Variables introuvables : ", paste(vars_absentes, collapse = ", ")
      ))
    }
    data <- data[, vars, drop = FALSE]
  }

  n_total <- nrow(data)

  rapport <- tibble::tibble(
    variable    = names(data),
    n_total     = n_total,
    n_manquant  = sapply(data, function(x) sum(is.na(x))),
    taux_na     = sapply(data, function(x) mean(is.na(x))),
    statut      = dplyr::case_when(
      sapply(data, function(x) mean(is.na(x))) == 0   ~ "OK",
      sapply(data, function(x) mean(is.na(x))) <= 0.05 ~ "Faible",
      sapply(data, function(x) mean(is.na(x))) <= seuil ~ "Modéré",
      TRUE                                               ~ "CRITIQUE"
    )
  )

  vars_critiques <- rapport$variable[rapport$statut == "CRITIQUE"]
  if (alerter && length(vars_critiques) > 0) {
    rlang::warn(paste0(
      length(vars_critiques), " variable(s) avec taux de NA > ",
      scales::percent(seuil), " : ",
      paste(vars_critiques, collapse = ", ")
    ))
  }

  rapport
}


#' @title Vérifier les types de variables
#' @description Vérifie la cohérence des types de variables par rapport aux
#'   types attendus. Détecte les problèmes courants : dates stockées en
#'   caractères, nombres stockés en texte, variables binaires incohérentes.
#' @param data data.frame ou tibble — Données à vérifier
#' @param dictionnaire data.frame ou NULL — Dictionnaire avec colonnes
#'   \code{nom_variable} et \code{type_attendu}. Si NULL, détection
#'   automatique des problèmes courants. Défaut : NULL.
#' @return Un tibble avec les anomalies détectées :
#'   \code{variable}, \code{type_actuel}, \code{type_attendu}, \code{probleme}.
#' @examples
#' anomalies <- check_types(donnees_enquete)
#' @export
check_types <- function(data, dictionnaire = NULL) {

  if (!is.data.frame(data)) {
    rlang::abort("L'argument `data` doit être un data.frame ou tibble.")
  }

  anomalies <- list()

  for (var in names(data)) {
    x <- data[[var]]
    type_actuel <- class(x)[1]

    # Détection : nombre stocké en caractère
    if (is.character(x)) {
      x_sans_na <- x[!is.na(x)]
      if (length(x_sans_na) > 0) {
        prop_numerique <- mean(suppressWarnings(!is.na(as.numeric(x_sans_na))))
        if (prop_numerique > 0.9) {
          anomalies[[length(anomalies) + 1]] <- tibble::tibble(
            variable      = var,
            type_actuel   = "character",
            type_attendu  = "numeric",
            probleme      = paste0(
              scales::percent(prop_numerique),
              " des valeurs sont numériques → convertir avec as.numeric()"
            )
          )
        }

        # Détection : date stockée en caractère
        formats_date <- c("%d/%m/%Y", "%Y-%m-%d", "%d-%m-%Y", "%d.%m.%Y")
        est_date <- FALSE
        for (fmt in formats_date) {
          parsed <- suppressWarnings(as.Date(head(x_sans_na, 20), format = fmt))
          if (mean(!is.na(parsed)) > 0.8) {
            est_date <- TRUE
            break
          }
        }
        if (est_date) {
          anomalies[[length(anomalies) + 1]] <- tibble::tibble(
            variable      = var,
            type_actuel   = "character",
            type_attendu  = "Date",
            probleme      = "Dates stockées en texte → convertir avec as.Date()"
          )
        }
      }
    }
  }

  # Vérification contre dictionnaire fourni
  if (!is.null(dictionnaire)) {
    cols_req <- c("nom_variable", "type_attendu")
    cols_man <- setdiff(cols_req, names(dictionnaire))
    if (length(cols_man) > 0) {
      rlang::abort(paste0(
        "Colonnes manquantes dans le dictionnaire : ",
        paste(cols_man, collapse = ", ")
      ))
    }

    for (i in seq_len(nrow(dictionnaire))) {
      var <- dictionnaire$nom_variable[i]
      type_att <- dictionnaire$type_attendu[i]
      if (var %in% names(data)) {
        type_act <- class(data[[var]])[1]
        if (!grepl(type_att, type_act, ignore.case = TRUE)) {
          anomalies[[length(anomalies) + 1]] <- tibble::tibble(
            variable      = var,
            type_actuel   = type_act,
            type_attendu  = type_att,
            probleme      = paste0("Type incompatible avec le dictionnaire")
          )
        }
      } else {
        anomalies[[length(anomalies) + 1]] <- tibble::tibble(
          variable      = var,
          type_actuel   = NA_character_,
          type_attendu  = type_att,
          probleme      = "Variable absente du jeu de données"
        )
      }
    }
  }

  if (length(anomalies) == 0) {
    message("Aucune anomalie de type détectée.")
    return(tibble::tibble(
      variable = character(), type_actuel = character(),
      type_attendu = character(), probleme = character()
    ))
  }

  dplyr::bind_rows(anomalies)
}


#' @title Valider la cohérence données / dictionnaire
#' @description Vérifie que les variables d'un dataset correspondent au
#'   dictionnaire fourni : présence des variables, types, plages de valeurs,
#'   modalités attendues. Produit un rapport de validation structuré avec
#'   un score de qualité global.
#' @param data data.frame ou tibble — Données à valider
#' @param dictionnaire data.frame — Dictionnaire avec colonnes obligatoires :
#'   \code{nom_variable}, \code{type}. Colonnes optionnelles :
#'   \code{valeurs_valides}, \code{min}, \code{max}, \code{obligatoire}.
#' @param stopper_si_critique logical — Arrêter l'exécution si des erreurs
#'   critiques sont détectées. Défaut : FALSE.
#' @return Une liste avec :
#'   \item{valide}{logical — TRUE si aucune erreur critique}
#'   \item{rapport}{data.frame — Détail des anomalies}
#'   \item{score_qualite}{numeric — Score de 0 à 100}
#' @examples
#' dico <- data.frame(
#'   nom_variable = c("age", "sexe", "region"),
#'   type         = c("numeric", "character", "character"),
#'   obligatoire  = c(TRUE, TRUE, FALSE)
#' )
#' resultat <- valider_dictionnaire(donnees, dico)
#' if (!resultat$valide) print(resultat$rapport)
#' @export
valider_dictionnaire <- function(data,
                                  dictionnaire,
                                  stopper_si_critique = FALSE) {

  cols_requises <- c("nom_variable", "type")
  cols_manquantes <- setdiff(cols_requises, names(dictionnaire))
  if (length(cols_manquantes) > 0) {
    rlang::abort(paste0(
      "Colonnes manquantes dans le dictionnaire : ",
      paste(cols_manquantes, collapse = ", ")
    ))
  }

  anomalies <- list()
  n_vars_dico <- nrow(dictionnaire)
  n_ok <- 0

  for (i in seq_len(n_vars_dico)) {
    var      <- dictionnaire$nom_variable[i]
    type_att <- dictionnaire$type[i]
    oblig    <- if ("obligatoire" %in% names(dictionnaire))
                  isTRUE(dictionnaire$obligatoire[i]) else FALSE

    # Variable absente
    if (!var %in% names(data)) {
      severite <- if (oblig) "CRITIQUE" else "AVERTISSEMENT"
      anomalies[[length(anomalies) + 1]] <- tibble::tibble(
        variable  = var,
        severite  = severite,
        probleme  = "Variable absente du jeu de données"
      )
      next
    }

    # Type incompatible
    type_act <- class(data[[var]])[1]
    if (!grepl(type_att, type_act, ignore.case = TRUE)) {
      anomalies[[length(anomalies) + 1]] <- tibble::tibble(
        variable = var,
        severite = "AVERTISSEMENT",
        probleme = paste0("Type attendu : ", type_att, " | Type actuel : ", type_act)
      )
    }

    # Plages de valeurs
    if ("min" %in% names(dictionnaire) && !is.na(dictionnaire$min[i])) {
      min_val <- as.numeric(dictionnaire$min[i])
      if (is.numeric(data[[var]])) {
        n_hors <- sum(data[[var]] < min_val, na.rm = TRUE)
        if (n_hors > 0) {
          anomalies[[length(anomalies) + 1]] <- tibble::tibble(
            variable = var,
            severite = "AVERTISSEMENT",
            probleme = paste0(n_hors, " valeurs inférieures au minimum (", min_val, ")")
          )
        }
      }
    }

    if ("max" %in% names(dictionnaire) && !is.na(dictionnaire$max[i])) {
      max_val <- as.numeric(dictionnaire$max[i])
      if (is.numeric(data[[var]])) {
        n_hors <- sum(data[[var]] > max_val, na.rm = TRUE)
        if (n_hors > 0) {
          anomalies[[length(anomalies) + 1]] <- tibble::tibble(
            variable = var,
            severite = "AVERTISSEMENT",
            probleme = paste0(n_hors, " valeurs supérieures au maximum (", max_val, ")")
          )
        }
      }
    }

    n_ok <- n_ok + 1
  }

  rapport <- if (length(anomalies) > 0) dplyr::bind_rows(anomalies) else
    tibble::tibble(variable = character(), severite = character(),
                   probleme = character())

  n_critiques <- sum(rapport$severite == "CRITIQUE")
  score <- round(100 * (n_vars_dico - nrow(rapport)) / max(n_vars_dico, 1))
  score <- max(0, score)
  valide <- n_critiques == 0

  if (n_critiques > 0) {
    msg <- paste0(n_critiques, " erreur(s) critique(s) détectée(s).")
    if (stopper_si_critique) rlang::abort(msg) else rlang::warn(msg)
  }

  message("Score de qualité : ", score, "/100")

  list(
    valide        = valide,
    rapport       = rapport,
    score_qualite = score
  )
}


# =============================================================================
# FONCTIONS INTERNES (non exportées)
# =============================================================================

#' @keywords internal
.verifier_package <- function(pkg, contexte = NULL) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    ctx <- if (!is.null(contexte)) paste0(" (requis pour ", contexte, ")") else ""
    rlang::abort(paste0(
      "Package '", pkg, "' requis", ctx, " mais non installé.\n",
      "Installez-le avec : install.packages('", pkg, "')"
    ))
  }
}

#' @keywords internal
.detecter_separateur <- function(chemin, encodage = "UTF-8") {
  lignes <- tryCatch(
    readLines(chemin, n = 5, encoding = encodage, warn = FALSE),
    error = function(e) readLines(chemin, n = 5, warn = FALSE)
  )
  premiere_ligne <- lignes[1]
  comptes <- c(
    ";"  = stringr::str_count(premiere_ligne, ";"),
    ","  = stringr::str_count(premiere_ligne, ","),
    "\t" = stringr::str_count(premiere_ligne, "\t"),
    "|"  = stringr::str_count(premiere_ligne, "\\|")
  )
  names(comptes)[which.max(comptes)]
}

#' @keywords internal
.lire_dcf <- function(fichier_dcf, encoding = "UTF-8") {
  lignes <- readLines(fichier_dcf, encoding = encoding, warn = FALSE)
  # Parsing basique du format DCF CSPro
  # Structure : [Dict], [Level], [Record], [Item], [ValueSet]
  niveaux <- list()
  niveau_actuel <- NULL
  enregistrement_actuel <- NULL
  items_courants <- list()

  for (ligne in lignes) {
    ligne <- trimws(ligne)
    if (grepl("^\\[Level\\]", ligne, ignore.case = TRUE)) {
      if (!is.null(niveau_actuel) && length(items_courants) > 0) {
        niveaux[[niveau_actuel]] <- dplyr::bind_rows(items_courants)
      }
      items_courants <- list()
    } else if (grepl("^Name=", ligne, ignore.case = TRUE)) {
      nom <- sub("^Name=", "", ligne, ignore.case = TRUE)
      if (is.null(niveau_actuel)) niveau_actuel <- nom
    } else if (grepl("^\\[Item\\]", ligne, ignore.case = TRUE)) {
      if (!is.null(enregistrement_actuel)) {
        items_courants[[length(items_courants) + 1]] <- list(
          nom = NA, start = NA, len = NA, type = NA
        )
      }
    }
  }

  if (!is.null(niveau_actuel) && length(items_courants) > 0) {
    niveaux[[niveau_actuel]] <- dplyr::bind_rows(items_courants)
  }

  if (length(niveaux) == 0) {
    niveaux[["NIVEAU_1"]] <- tibble::tibble(
      nom = character(), start = integer(), len = integer()
    )
  }

  list(niveaux = niveaux, fichier = fichier_dcf)
}

#' @keywords internal
.lire_dat_cspro <- function(fichier_dat, dico, niveau, encoding, max_lignes) {
  # Lecture basique du fichier .dat CSPro (format texte à largeur fixe)
  lignes <- readLines(fichier_dat, encoding = encoding, warn = FALSE)
  if (!is.null(max_lignes)) lignes <- head(lignes, max_lignes)

  # Retour d'un tibble vide structuré si le parsing complet n'est pas dispo
  # (implémentation complète nécessite le parsing détaillé du DCF)
  tibble::tibble(ligne_brute = lignes)
}

#' @keywords internal
.import_kobo_xls <- function(source, langue, verbose) {
  .verifier_package("readxl", "import_kobo_xls")
  feuilles <- readxl::excel_sheets(source)
  feuille_data <- feuilles[!grepl("(choices|survey|settings)", feuilles,
                                   ignore.case = TRUE)][1]
  if (is.na(feuille_data)) feuille_data <- feuilles[1]

  donnees <- readxl::read_excel(source, sheet = feuille_data)

  if (verbose) {
    message("Feuille de données : ", feuille_data)
    message(nrow(donnees), " soumissions importées.")
  }
  donnees
}

#' @keywords internal
.import_kobo_json <- function(source, langue, verbose) {
  .verifier_package("jsonlite", "import_kobo_json")
  raw <- jsonlite::fromJSON(source, flatten = TRUE)
  if (is.data.frame(raw)) tibble::as_tibble(raw) else tibble::as_tibble(raw$results)
}

#' @keywords internal
.import_kobo_api <- function(source, uid, token, langue, verbose) {
  .verifier_package("httr2", "import_kobo_api")
  url <- paste0(source, "/api/v2/assets/", uid, "/data/?format=json")
  req <- httr2::request(url) |>
    httr2::req_headers(Authorization = paste("Token", token)) |>
    httr2::req_error(is_error = function(resp) httr2::resp_status(resp) >= 400)

  resp <- tryCatch(
    httr2::req_perform(req),
    error = function(e) {
      rlang::abort(paste0(
        "Échec de la connexion à l'API KoboToolbox.\n",
        "Vérifiez l'URL, le token et la connectivité réseau.\n",
        "Erreur : ", e$message
      ))
    }
  )

  data <- httr2::resp_body_json(resp, simplifyVector = TRUE)
  if (verbose) message(data$count, " soumissions récupérées depuis l'API.")
  tibble::as_tibble(data$results)
}

#' @keywords internal
.import_odk_zip <- function(source, inclure_metadonnees, verbose) {
  dir_temp <- tempdir()
  utils::unzip(source, exdir = dir_temp)
  fichiers_csv <- list.files(dir_temp, pattern = "\\.csv$",
                              full.names = TRUE, recursive = TRUE)
  if (length(fichiers_csv) == 0) {
    rlang::abort("Aucun fichier CSV trouvé dans l'export ZIP ODK.")
  }
  # Prendre le fichier principal (le plus grand)
  tailles <- file.size(fichiers_csv)
  fichier_principal <- fichiers_csv[which.max(tailles)]
  if (verbose) message("Fichier principal : ", basename(fichier_principal))

  donnees <- import_csv(fichier_principal, verbose = verbose)

  if (!inclure_metadonnees) {
    cols_meta <- grep("^(_|meta|instanceID|deviceid|subscriberid|simserial|phonenumber)",
                      names(donnees), value = TRUE)
    donnees <- donnees[, !names(donnees) %in% cols_meta]
  }

  donnees
}

#' @keywords internal
.import_odk_api <- function(source, projet_id, formulaire_id, email,
                             mot_de_passe, inclure_metadonnees, verbose) {
  .verifier_package("httr2", "import_odk_api")

  # Authentification ODK Central
  url_session <- paste0(source, "/v1/sessions")
  req_auth <- httr2::request(url_session) |>
    httr2::req_body_json(list(email = email, password = mot_de_passe))

  resp_auth <- tryCatch(
    httr2::req_perform(req_auth),
    error = function(e) {
      rlang::abort(paste0(
        "Échec de l'authentification ODK Central.\n",
        "Vérifiez l'email, le mot de passe et l'URL du serveur."
      ))
    }
  )

  token <- httr2::resp_body_json(resp_auth)$token
  url_data <- paste0(source, "/v1/projects/", projet_id,
                     "/forms/", formulaire_id, "/submissions.csv")
  req_data <- httr2::request(url_data) |>
    httr2::req_headers(Authorization = paste("Bearer", token))

  resp_data <- httr2::req_perform(req_data)
  donnees <- readr::read_csv(httr2::resp_body_string(resp_data),
                              show_col_types = FALSE)

  if (!inclure_metadonnees) {
    cols_meta <- grep("^(__)", names(donnees), value = TRUE)
    donnees <- donnees[, !names(donnees) %in% cols_meta]
  }

  if (verbose) message(nrow(donnees), " soumissions importées depuis ODK Central.")
  donnees
}
