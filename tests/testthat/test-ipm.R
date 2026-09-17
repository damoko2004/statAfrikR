# =============================================================================
# statAfrikR - Tests module IPM
# testthat edition 3
# =============================================================================

# Donnees de test
.make_menages <- function(n = 200, seed = 42) {
  set.seed(seed)
  data.frame(
    nutrition      = rbinom(n, 1, 0.35),
    mortalite_inf  = rbinom(n, 1, 0.12),
    annees_scol    = rbinom(n, 1, 0.40),
    scolarisation  = rbinom(n, 1, 0.28),
    combustible    = rbinom(n, 1, 0.55),
    assainissement = rbinom(n, 1, 0.48),
    eau            = rbinom(n, 1, 0.38),
    electricite    = rbinom(n, 1, 0.62),
    logement       = rbinom(n, 1, 0.42),
    actifs         = rbinom(n, 1, 0.30),
    milieu         = sample(c("urbain","rural"), n, TRUE),
    region         = sample(paste0("Region_", LETTERS[1:5]), n, TRUE),
    poids          = runif(n, 0.8, 1.3),
    stringsAsFactors = FALSE
  )
}

.res_ipm_std <- function(n = 200) {
  d <- .make_menages(n)
  calcul_ipm(d,
    var_nutrition      = "nutrition",
    var_mortalite_inf  = "mortalite_inf",
    var_annees_scol    = "annees_scol",
    var_scolarisation  = "scolarisation",
    var_combustible    = "combustible",
    var_assainissement = "assainissement",
    var_eau            = "eau",
    var_electricite    = "electricite",
    var_logement       = "logement",
    var_actifs         = "actifs",
    poids              = "poids"
  )
}

# =============================================================================
# BLOC 1 - calcul_ipm() validations
# =============================================================================

test_that("calcul_ipm() : donnees vides => erreur", {
  expect_error(calcul_ipm(data.frame()), regexp = "non vide")
})

test_that("calcul_ipm() : aucun indicateur => erreur", {
  d <- .make_menages(50)
  expect_error(calcul_ipm(d), regexp = "indicateur")
})

test_that("calcul_ipm() : variable introuvable => erreur", {
  d <- .make_menages(50)
  expect_error(
    calcul_ipm(d, var_nutrition = "xxx"),
    regexp = "introuvable"
  )
})

test_that("calcul_ipm() : seuil_k hors plage => erreur", {
  d <- .make_menages(50)
  expect_error(
    calcul_ipm(d, var_nutrition = "nutrition",
               var_eau = "eau", seuil_k = 1.5),
    regexp = "seuil_k"
  )
})

test_that("calcul_ipm() : variable poids introuvable => erreur", {
  d <- .make_menages(50)
  expect_error(
    calcul_ipm(d, var_nutrition = "nutrition",
               var_eau = "eau", poids = "xxx"),
    regexp = "poids"
  )
})

# =============================================================================
# BLOC 2 - calcul_ipm() resultats
# =============================================================================

test_that("calcul_ipm() : retourne saf_ipm", {
  res <- .res_ipm_std()
  expect_s3_class(res, "saf_ipm")
})

test_that("calcul_ipm() : IPM = H x A", {
  res <- .res_ipm_std()
  expect_equal(res$IPM, res$H * res$A, tolerance = 1e-10)
})

test_that("calcul_ipm() : H entre 0 et 1", {
  res <- .res_ipm_std()
  expect_gte(res$H, 0)
  expect_lte(res$H, 1)
})

test_that("calcul_ipm() : A entre 0 et 1", {
  res <- .res_ipm_std()
  expect_gte(res$A, 0)
  expect_lte(res$A, 1)
})

test_that("calcul_ipm() : IPM entre 0 et 1", {
  res <- .res_ipm_std()
  expect_gte(res$IPM, 0)
  expect_lte(res$IPM, 1)
})

test_that("calcul_ipm() : contributions somme a 1 (environ)", {
  res <- .res_ipm_std()
  if (res$IPM > 0) {
    expect_equal(sum(res$contributions$part_contribution), 1,
                 tolerance = 0.01)
  }
})

test_that("calcul_ipm() : n_obs correct", {
  d <- .make_menages(200)
  res <- calcul_ipm(d, var_nutrition = "nutrition",
                    var_eau = "eau", poids = "poids")
  expect_equal(res$n_obs, 200L)
})

test_that("calcul_ipm() : contributions tibble correct", {
  res <- .res_ipm_std()
  expect_true(is.data.frame(res$contributions))
  expect_true("indicateur" %in% names(res$contributions))
  expect_true("dimension"  %in% names(res$contributions))
  expect_true("poids"      %in% names(res$contributions))
})

test_that("calcul_ipm() : seuil_k plus eleve => moins de pauvres", {
  d <- .make_menages(300)
  r1 <- calcul_ipm(d, var_nutrition="nutrition", var_eau="eau",
                   var_electricite="electricite", poids="poids",
                   seuil_k = 0.2)
  r2 <- calcul_ipm(d, var_nutrition="nutrition", var_eau="eau",
                   var_electricite="electricite", poids="poids",
                   seuil_k = 0.6)
  expect_gte(r1$H, r2$H)
})

test_that("calcul_ipm() : print ne genere pas d'erreur", {
  res <- .res_ipm_std()
  expect_output(print(res), regexp = "IPM")
})

test_that("calcul_ipm() : indicateurs partiels (3 seulement)", {
  d <- .make_menages(100)
  res <- calcul_ipm(d, var_nutrition="nutrition",
                    var_eau="eau", var_electricite="electricite",
                    poids="poids")
  expect_s3_class(res, "saf_ipm")
  expect_equal(nrow(res$contributions), 3L)
})

test_that("calcul_ipm() : sans poids fonctionne", {
  d <- .make_menages(100)
  res <- calcul_ipm(d, var_nutrition="nutrition",
                    var_eau="eau", var_electricite="electricite")
  expect_s3_class(res, "saf_ipm")
})

# =============================================================================
# BLOC 3 - calcul_ipm_national()
# =============================================================================

test_that("calcul_ipm_national() : retourne saf_ipm", {
  d <- .make_menages(150)
  indics <- list(
    eau  = list(var="eau",        poids=0.4, dimension="Vie"),
    elec = list(var="electricite",poids=0.35,dimension="Vie"),
    scol = list(var="annees_scol",poids=0.25,dimension="Education")
  )
  res <- calcul_ipm_national(d, indicateurs=indics, poids="poids")
  expect_s3_class(res, "saf_ipm")
})

test_that("calcul_ipm_national() : IPM = H x A", {
  d <- .make_menages(150)
  indics <- list(
    eau  = list(var="eau",        poids=0.5, dimension="Vie"),
    scol = list(var="annees_scol",poids=0.5, dimension="Education")
  )
  res <- calcul_ipm_national(d, indicateurs=indics, poids="poids")
  expect_equal(res$IPM, res$H * res$A, tolerance=1e-10)
})

test_that("calcul_ipm_national() : indicateurs vides => erreur", {
  d <- .make_menages(50)
  expect_error(calcul_ipm_national(d, indicateurs=list()),
               regexp="non vide")
})

test_that("calcul_ipm_national() : var manquante => erreur", {
  d <- .make_menages(50)
  indics <- list(xxx = list(var="inexistant", poids=1, dimension="Vie"))
  expect_error(calcul_ipm_national(d, indicateurs=indics),
               regexp="introuvable")
})

test_that("calcul_ipm_national() : poids manquant => erreur", {
  d <- .make_menages(50)
  indics <- list(eau = list(var="eau", dimension="Vie"))
  expect_error(calcul_ipm_national(d, indicateurs=indics),
               regexp="poids")
})

test_that("calcul_ipm_national() : methode nationale dans slot methode", {
  d <- .make_menages(100)
  indics <- list(eau=list(var="eau",poids=1,dimension="Vie"))
  res <- calcul_ipm_national(d, indicateurs=indics)
  expect_true(grepl("National", res$methode))
})

# =============================================================================
# BLOC 4 - decomposer_ipm()
# =============================================================================

test_that("decomposer_ipm() : retourne un tibble", {
  d   <- .make_menages(300)
  res <- .res_ipm_std(300)
  dec <- decomposer_ipm(res, d, var_groupe="milieu", poids="poids")
  expect_s3_class(dec, "data.frame")
})

test_that("decomposer_ipm() : colonnes H, A, IPM presentes", {
  d   <- .make_menages(300)
  res <- .res_ipm_std(300)
  dec <- decomposer_ipm(res, d, var_groupe="milieu", poids="poids")
  expect_true(all(c("H","A","IPM") %in% names(dec)))
})

test_that("decomposer_ipm() : 2 groupes milieu", {
  d   <- .make_menages(300)
  res <- .res_ipm_std(300)
  dec <- decomposer_ipm(res, d, var_groupe="milieu", poids="poids")
  expect_equal(nrow(dec), 2L)
})

test_that("decomposer_ipm() : non saf_ipm => erreur", {
  d <- .make_menages(100)
  expect_error(decomposer_ipm(list(), d, "milieu"),
               regexp="saf_ipm")
})

test_that("decomposer_ipm() : var_groupe absent => erreur", {
  d   <- .make_menages(200)
  res <- .res_ipm_std(200)
  expect_error(decomposer_ipm(res, d, var_groupe="xxx"),
               regexp="introuvable")
})

test_that("decomposer_ipm() : mauvaise taille donnees => erreur", {
  d1  <- .make_menages(200)
  d2  <- .make_menages(100)
  res <- .res_ipm_std(200)
  expect_error(decomposer_ipm(res, d2, "milieu"),
               regexp="Nombre")
})

test_that("decomposer_ipm() : 5 regions", {
  d   <- .make_menages(500)
  res <- suppressWarnings(.res_ipm_std(500))
  dec <- suppressWarnings(
    decomposer_ipm(res, d, var_groupe="region", poids="poids")
  )
  expect_equal(nrow(dec), 5L)
})

# =============================================================================
# BLOC 5 - comparer_ipm()
# =============================================================================

test_that("comparer_ipm() : retourne un tibble", {
  d <- .make_menages(200)
  ig <- calcul_ipm(d, var_nutrition="nutrition",
                   var_eau="eau", var_electricite="electricite",
                   poids="poids")
  indics <- list(
    eau=list(var="eau",poids=0.5,dimension="Vie"),
    scol=list(var="annees_scol",poids=0.5,dimension="Education")
  )
  in_ <- calcul_ipm_national(d, indicateurs=indics, poids="poids")
  res <- suppressMessages(
    comparer_ipm(ig, in_, pays="RCA", annee=2026L)
  )
  expect_s3_class(res, "data.frame")
  expect_true("global" %in% names(res))
  expect_true("national" %in% names(res))
})

test_that("comparer_ipm() : non saf_ipm global => erreur", {
  d <- .make_menages(100)
  ig <- calcul_ipm(d, var_eau="eau", var_electricite="electricite")
  expect_error(comparer_ipm(list(), ig), regexp="saf_ipm")
})

# =============================================================================
# BLOC 6 - graphique_ipm()
# =============================================================================

test_that("graphique_ipm() : retourne ggplot", {
  res <- .res_ipm_std()
  g   <- graphique_ipm(res)
  expect_s3_class(g, "ggplot")
})

test_that("graphique_ipm() : type dimensions fonctionne", {
  res <- .res_ipm_std()
  g   <- graphique_ipm(res, type="dimensions")
  expect_s3_class(g, "ggplot")
})

test_that("graphique_ipm() : avec titre", {
  res <- .res_ipm_std()
  g   <- graphique_ipm(res, titre="Test IPM", source="Donnees test")
  expect_s3_class(g, "ggplot")
})

test_that("graphique_ipm() : non saf_ipm => erreur", {
  expect_error(graphique_ipm(list()), regexp="saf_ipm")
})

# =============================================================================
# BLOC 7 - tableau_ipm()
# =============================================================================

test_that("tableau_ipm() : retourne flextable", {
  skip_if_not_installed("flextable")
  res <- .res_ipm_std()
  ft  <- tableau_ipm(res, pays="RCA", annee=2026L)
  expect_s3_class(ft, "flextable")
})

test_that("tableau_ipm() : non saf_ipm => erreur", {
  expect_error(tableau_ipm(list()), regexp="saf_ipm")
})

test_that("tableau_ipm() : export Word dans tempdir", {
  skip_if_not_installed("flextable")
  skip_if_not_installed("officer")
  res    <- .res_ipm_std()
  chemin <- file.path(tempdir(), "test_ipm.docx")
  suppressMessages(
    tableau_ipm(res, pays="RCA", annee=2026L, chemin_word=chemin)
  )
  expect_true(file.exists(chemin))
  withr::defer(unlink(chemin))
})
