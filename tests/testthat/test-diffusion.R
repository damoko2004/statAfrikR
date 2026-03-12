# =============================================================================
# Tests unitaires — Module Diffusion
# statAfrikR
# =============================================================================

set.seed(77)
donnees_test <- tibble::tibble(
  id         = 1:100,
  nom        = paste0("Individu_", 1:100),
  telephone  = paste0("+229 9", sample(1000000:9999999, 100)),
  age        = sample(18:75, 100, replace = TRUE),
  sexe       = sample(c("Masculin", "Féminin"), 100, replace = TRUE),
  region     = sample(c("Alibori", "Atacora", "Atlantique", "Borgou"), 100,
                       replace = TRUE),
  revenu     = abs(rnorm(100, 150000, 60000)),
  depense    = abs(rnorm(100, 120000, 50000)),
  annee      = sample(2020:2023, 100, replace = TRUE),
  indicateur = sample(c("IDH", "IPM", "Pauvrete"), 100, replace = TRUE)
)

# --- anonymiser_donnees ------------------------------------------------------

test_that("anonymiser_donnees() supprime les variables demandées", {
  result <- anonymiser_donnees(
    donnees_test,
    vars_supprimer = c("nom", "telephone"),
    rapport = FALSE
  )
  expect_false("nom" %in% names(result))
  expect_false("telephone" %in% names(result))
})

test_that("anonymiser_donnees() conserve les autres variables", {
  result <- anonymiser_donnees(
    donnees_test,
    vars_supprimer = c("nom"),
    rapport = FALSE
  )
  expect_true("age" %in% names(result))
  expect_true("revenu" %in% names(result))
})

test_that("anonymiser_donnees() masque les identifiants", {
  result <- anonymiser_donnees(
    donnees_test,
    vars_masquer = c("id"),
    rapport = FALSE
  )
  expect_true("id" %in% names(result))
  expect_false(any(result$id %in% 1:100))
})

test_that("anonymiser_donnees() perturbe les variables numériques", {
  result <- anonymiser_donnees(
    donnees_test,
    vars_perturber = c("revenu"),
    rapport = FALSE
  )
  # Les valeurs doivent avoir changé
  expect_false(identical(result$revenu, donnees_test$revenu))
  # Mais rester dans le même ordre de grandeur
  expect_gt(cor(result$revenu, donnees_test$revenu), 0.95)
})

test_that("anonymiser_donnees() généralise les variables numériques", {
  result <- anonymiser_donnees(
    donnees_test,
    vars_generaliser = list(age = 5),
    rapport = FALSE
  )
  expect_true("age_classe" %in% names(result))
  expect_s3_class(result$age_classe, "factor")
})

test_that("anonymiser_donnees() retourne une liste si rapport = TRUE", {
  result <- anonymiser_donnees(
    donnees_test,
    vars_supprimer = c("nom"),
    rapport = TRUE
  )
  expect_type(result, "list")
  expect_true("donnees" %in% names(result))
  expect_true("rapport" %in% names(result))
})

test_that("anonymiser_donnees() retourne un tibble si rapport = FALSE", {
  result <- anonymiser_donnees(
    donnees_test,
    vars_supprimer = c("nom"),
    rapport = FALSE
  )
  expect_s3_class(result, "tbl_df")
})

test_that("anonymiser_donnees() avertit sur variables inexistantes", {
  expect_warning(
    anonymiser_donnees(donnees_test, vars_supprimer = c("var_inexistante")),
    regexp = "introuvable"
  )
})

test_that("anonymiser_donnees() échoue si data non data.frame", {
  expect_error(
    anonymiser_donnees("pas_un_df"),
    regexp = "data.frame"
  )
})

test_that("anonymiser_donnees() combine plusieurs opérations", {
  result <- anonymiser_donnees(
    donnees_test,
    vars_supprimer   = c("telephone"),
    vars_masquer     = c("id"),
    vars_perturber   = c("revenu"),
    vars_generaliser = list(age = 10),
    rapport          = TRUE
  )
  expect_false("telephone" %in% names(result$donnees))
  expect_true("age_classe" %in% names(result$donnees))
  expect_equal(nrow(result$rapport), 4)
})

# --- exporter_sdmx -----------------------------------------------------------

test_that("exporter_sdmx() crée un fichier CSV", {
  tmp <- tempfile(fileext = ".csv")
  exporter_sdmx(
    data            = donnees_test,
    flux_donnees    = "TEST_001",
    agence          = "INSAE",
    vars_dimensions = c("region", "annee"),
    vars_mesures    = c("revenu", "depense"),
    fichier_sortie  = tmp
  )
  expect_true(file.exists(tmp))
  unlink(tmp)
})

test_that("exporter_sdmx() le fichier contient le header SDMX", {
  tmp <- tempfile(fileext = ".csv")
  exporter_sdmx(
    data            = donnees_test,
    flux_donnees    = "TEST_001",
    agence          = "INSAE",
    vars_dimensions = c("region"),
    vars_mesures    = c("revenu"),
    fichier_sortie  = tmp
  )
  contenu <- readLines(tmp, n = 2)
  expect_true(any(grepl("SDMX-CSV", contenu)))
  unlink(tmp)
})

test_that("exporter_sdmx() échoue sans flux_donnees", {
  expect_error(
    exporter_sdmx(
      data            = donnees_test,
      flux_donnees    = "",
      vars_dimensions = c("region"),
      vars_mesures    = c("revenu"),
      fichier_sortie  = tempfile()
    ),
    regexp = "flux_donnees"
  )
})

test_that("exporter_sdmx() échoue sur variables inexistantes", {
  expect_error(
    exporter_sdmx(
      data            = donnees_test,
      flux_donnees    = "TEST",
      vars_dimensions = c("var_inexistante"),
      vars_mesures    = c("revenu"),
      fichier_sortie  = tempfile()
    ),
    regexp = "introuvable"
  )
})

test_that("exporter_sdmx() retourne le chemin du fichier", {
  tmp <- tempfile(fileext = ".csv")
  result <- exporter_sdmx(
    data            = donnees_test,
    flux_donnees    = "TEST_002",
    agence          = "TEST",
    vars_dimensions = c("region"),
    vars_mesures    = c("revenu"),
    fichier_sortie  = tmp
  )
  expect_equal(result, tmp)
  unlink(tmp)
})

# --- generer_metadonnees_ddi -------------------------------------------------

test_that("generer_metadonnees_ddi() crée un fichier XML", {
  tmp <- tempfile(fileext = ".xml")
  generer_metadonnees_ddi(
    data           = donnees_test,
    titre          = "Enquête Test 2023",
    pays           = "Bénin",
    annee          = 2023,
    institution    = "INSAE",
    fichier_sortie = tmp
  )
  expect_true(file.exists(tmp))
  unlink(tmp)
})

test_that("generer_metadonnees_ddi() produit un XML valide", {
  tmp <- tempfile(fileext = ".xml")
  generer_metadonnees_ddi(
    data           = donnees_test,
    titre          = "Test",
    pays           = "Bénin",
    annee          = 2023,
    institution    = "INSAE",
    fichier_sortie = tmp
  )
  contenu <- readLines(tmp)
  expect_true(any(grepl("<?xml", contenu, fixed = TRUE)))
  expect_true(any(grepl("codeBook", contenu)))
  unlink(tmp)
})

test_that("generer_metadonnees_ddi() documente toutes les variables", {
  tmp <- tempfile(fileext = ".xml")
  generer_metadonnees_ddi(
    data           = donnees_test,
    titre          = "Test",
    pays           = "Bénin",
    annee          = 2023,
    institution    = "INSAE",
    fichier_sortie = tmp
  )
  contenu <- paste(readLines(tmp), collapse = "\n")
  # Vérifier que les variables sont documentées
  for (var in names(donnees_test)) {
    expect_true(grepl(var, contenu, fixed = TRUE))
  }
  unlink(tmp)
})

test_that("generer_metadonnees_ddi() retourne le chemin du fichier", {
  tmp <- tempfile(fileext = ".xml")
  result <- generer_metadonnees_ddi(
    data           = donnees_test,
    titre          = "Test",
    pays           = "Bénin",
    annee          = 2023,
    institution    = "INSAE",
    fichier_sortie = tmp
  )
  expect_equal(result, tmp)
  unlink(tmp)
})

test_that("generer_metadonnees_ddi() échappe les caractères XML spéciaux", {
  tmp <- tempfile(fileext = ".xml")
  generer_metadonnees_ddi(
    data           = donnees_test,
    titre          = "Enquête & Étude <Test> 2023",
    pays           = "Côte d'Ivoire",
    annee          = 2023,
    institution    = "INS-CI",
    fichier_sortie = tmp
  )
  contenu <- paste(readLines(tmp), collapse = "\n")
  expect_true(grepl("&amp;", contenu, fixed = TRUE))
  unlink(tmp)
})

# --- compresser_package_diffusion --------------------------------------------

test_that("compresser_package_diffusion() crée une archive ZIP", {
  dir_tmp <- tempdir()
  result <- compresser_package_diffusion(
    donnees           = donnees_test,
    repertoire_sortie = dir_tmp,
    nom_package       = "TEST_PACKAGE"
  )
  expect_true(file.exists(result))
  expect_true(grepl("\\.zip$", result))
  unlink(result)
})

test_that("compresser_package_diffusion() inclut CSV si demandé", {
  dir_tmp <- tempdir()
  result <- compresser_package_diffusion(
    donnees           = donnees_test,
    repertoire_sortie = dir_tmp,
    nom_package       = "TEST_CSV",
    inclure_csv       = TRUE,
    inclure_rds       = FALSE
  )
  contenu_zip <- tryCatch(
    utils::unzip(result, list = TRUE)$Name,
    error = function(e) character(0)
  )
  expect_true(any(grepl("\\.csv$", contenu_zip)))
  unlink(result)
})

test_that("compresser_package_diffusion() inclut RDS si demandé", {
  dir_tmp <- tempdir()
  result <- compresser_package_diffusion(
    donnees           = donnees_test,
    repertoire_sortie = dir_tmp,
    nom_package       = "TEST_RDS",
    inclure_csv       = FALSE,
    inclure_rds       = TRUE
  )
  contenu_zip <- tryCatch(
    utils::unzip(result, list = TRUE)$Name,
    error = function(e) character(0)
  )
  expect_true(any(grepl("\\.rds$", contenu_zip)))
  unlink(result)
})

test_that("compresser_package_diffusion() inclut README", {
  dir_tmp <- tempdir()
  result <- compresser_package_diffusion(
    donnees           = donnees_test,
    repertoire_sortie = dir_tmp,
    nom_package       = "TEST_README"
  )
  contenu_zip <- tryCatch(
    utils::unzip(result, list = TRUE)$Name,
    error = function(e) character(0)
  )
  expect_true(any(grepl("README", contenu_zip)))
  unlink(result)
})

test_that("compresser_package_diffusion() retourne le chemin ZIP", {
  dir_tmp <- tempdir()
  result <- compresser_package_diffusion(
    donnees           = donnees_test,
    repertoire_sortie = dir_tmp,
    nom_package       = "TEST_CHEMIN"
  )
  expect_type(result, "character")
  expect_true(file.exists(result))
  unlink(result)
})

test_that("compresser_package_diffusion() échoue si data non data.frame", {
  expect_error(
    compresser_package_diffusion("pas_df", tempdir(), "TEST"),
    regexp = "data.frame"
  )
})

test_that("compresser_package_diffusion() intègre les métadonnées", {
  dir_tmp <- tempdir()
  result <- compresser_package_diffusion(
    donnees           = donnees_test,
    repertoire_sortie = dir_tmp,
    nom_package       = "TEST_META",
    metadonnees       = list(
      titre       = "EMOP 2023",
      institution = "INSAE",
      version     = "1.0"
    )
  )
  expect_true(file.exists(result))
  unlink(result)
})
