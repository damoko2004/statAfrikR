# =============================================================================
# statAfrikR - Tests module Rapports
# testthat edition 3 - rmarkdown en Suggests
# =============================================================================

# Donnees de test
donnees_rapport <- local({
  set.seed(2024)
  data.frame(
    age    = sample(18:70, 100, replace = TRUE),
    revenu = pmax(10000, rnorm(100, 250000, 80000)),
    poids  = runif(100, 0.8, 1.3),
    milieu = sample(c("urbain","rural"), 100, TRUE)
  )
})

meta_test <- list(
  pays   = "Republique Centrafricaine",
  titre  = "Rapport test statAfrikR",
  annee  = 2026L,
  source = "Donnees simulees",
  auteur = "statAfrikR Foundation"
)

ind_test <- data.frame(
  indicateur = c("Taux de pauvrete","Taux chomage",
                  "Eau potable","Electricite"),
  valeur     = c(71.8, 14.5, 42.3, 38.6),
  unite      = rep("%", 4),
  stringsAsFactors = FALSE
)

# =============================================================================
# BLOC 1 - lister_templates()
# =============================================================================

test_that("lister_templates() : retourne un tibble", {
  res <- lister_templates()
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 3L)
  expect_true(all(c("nom","description","fonction","formats") %in% names(res)))
})

test_that("lister_templates() : contient les 3 templates", {
  res <- lister_templates()
  expect_true("enquete_menage" %in% res$nom)
  expect_true("bulletin"       %in% res$nom)
  expect_true("rapport_odd"    %in% res$nom)
})

# =============================================================================
# BLOC 2 - generer_rapport_enquete() : validations
# =============================================================================

test_that("generer_rapport_enquete() : donnees vides => erreur", {
  expect_error(
    generer_rapport_enquete(data.frame(), meta_test),
    regexp = "non vide"
  )
})

test_that("generer_rapport_enquete() : non data.frame => erreur", {
  expect_error(
    generer_rapport_enquete(list(x = 1), meta_test),
    regexp = "non vide"
  )
})

test_that("generer_rapport_enquete() : repertoire inexistant => erreur", {
  skip_if_not_installed("rmarkdown")
  expect_error(
    generer_rapport_enquete(donnees_rapport, meta_test,
                             chemin_sortie = "/tmp/inexistant_xyz/"),
    regexp = "inexistant"
  )
})

test_that("generer_rapport_enquete() : sans rmarkdown => erreur claire", {
  skip_if(requireNamespace("rmarkdown", quietly = TRUE),
          "rmarkdown est installe")
  expect_error(
    generer_rapport_enquete(donnees_rapport, meta_test),
    regexp = "rmarkdown"
  )
})

# =============================================================================
# BLOC 3 - generer_rapport_enquete() : rendu HTML
# =============================================================================

test_that("generer_rapport_enquete() : rendu HTML fonctionne", {
  skip_if_not_installed("rmarkdown")
  skip_if_not_installed("knitr")
  chemin <- suppressMessages(
    generer_rapport_enquete(
      donnees_rapport, meta_test,
      sortie = "html",
      chemin_sortie = tempdir()
    )
  )
  expect_true(file.exists(chemin))
  expect_true(grepl("\\.html$", chemin))
  withr::defer(unlink(chemin))
})

test_that("generer_rapport_enquete() : retourne le chemin invisible", {
  skip_if_not_installed("rmarkdown")
  skip_if_not_installed("knitr")
  res <- suppressMessages(
    generer_rapport_enquete(
      donnees_rapport, meta_test,
      sortie = "html",
      chemin_sortie = tempdir()
    )
  )
  expect_true(is.character(res))
  expect_true(nchar(res) > 0)
  withr::defer(unlink(res))
})

test_that("generer_rapport_enquete() : meta par defaut fonctionne", {
  skip_if_not_installed("rmarkdown")
  skip_if_not_installed("knitr")
  res <- suppressMessages(
    generer_rapport_enquete(
      donnees_rapport,
      meta = list(),
      sortie = "html",
      chemin_sortie = tempdir()
    )
  )
  expect_true(file.exists(res))
  withr::defer(unlink(res))
})

# =============================================================================
# BLOC 4 - generer_bulletin() : validations
# =============================================================================

test_that("generer_bulletin() : indicateurs vides => erreur", {
  expect_error(
    generer_bulletin(data.frame(), periode = "T1 2026"),
    regexp = "non vide"
  )
})

test_that("generer_bulletin() : colonnes manquantes => erreur", {
  expect_error(
    generer_bulletin(data.frame(x = 1), periode = "T1 2026"),
    regexp = "manquantes"
  )
})

test_that("generer_bulletin() : rendu HTML fonctionne", {
  skip_if_not_installed("rmarkdown")
  skip_if_not_installed("knitr")
  res <- suppressMessages(
    generer_bulletin(ind_test, periode = "T1 2026",
                     pays = "Centrafrique",
                     sortie = "html",
                     chemin_sortie = tempdir())
  )
  expect_true(file.exists(res))
  expect_true(grepl("\\.html$", res))
  withr::defer(unlink(res))
})

# =============================================================================
# BLOC 5 - generer_rapport_odd() : validations
# =============================================================================

test_that("generer_rapport_odd() : liste vide => erreur", {
  expect_error(
    generer_rapport_odd(list(), pays = "Centrafrique"),
    regexp = "non vide"
  )
})

test_that("generer_rapport_odd() : element non saf_odd => erreur", {
  expect_error(
    generer_rapport_odd(list(data.frame(x=1)), pays = "Centrafrique"),
    regexp = "saf_odd"
  )
})

test_that("generer_rapport_odd() : rendu HTML fonctionne", {
  skip_if_not_installed("rmarkdown")
  skip_if_not_installed("knitr")

  menages_odd <- data.frame(
    depense_pc  = c(rexp(70, 1/150000), rexp(30, 1/500000)),
    electricite = sample(c(0L,1L), 100, TRUE, c(0.45,0.55))
  )
  r1 <- odd_indicateur(menages_odd, "1.2.1",
                        var_depense = "depense_pc", seuil = 200000)
  r2 <- odd_indicateur(menages_odd, "7.1.1",
                        var_indicateur = "electricite")

  res <- suppressMessages(
    generer_rapport_odd(
      list(r1, r2),
      pays          = "Centrafrique",
      annee         = 2026L,
      cibles        = list("1.2.1" = 50, "7.1.1" = 80),
      sortie        = "html",
      chemin_sortie = tempdir()
    )
  )
  expect_true(file.exists(res))
  expect_true(grepl("\\.html$", res))
  withr::defer(unlink(res))
})
