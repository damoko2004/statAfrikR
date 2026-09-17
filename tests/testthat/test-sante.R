# =============================================================================
# statAfrikR - Tests module Sante & Nutrition
# testthat edition 3
# =============================================================================

.make_enfants <- function(n = 400, seed = 42) {
  set.seed(seed)
  data.frame(
    haz    = rnorm(n, -1.2, 1.3),
    whz    = rnorm(n, -0.8, 1.1),
    waz    = rnorm(n, -1.0, 1.2),
    milieu = sample(c("urbain","rural"), n, TRUE),
    region = sample(paste0("R", 1:4), n, TRUE),
    poids  = runif(n, 0.8, 1.3),
    stringsAsFactors = FALSE
  )
}

.make_femmes <- function(n = 600, seed = 42) {
  set.seed(seed)
  data.frame(
    hemoglobine         = rnorm(n, 11.5, 2.1),
    naissances_vivantes = rpois(n, 3.5),
    deces_enfants       = rbinom(n, 4, 0.08),
    assiste             = rbinom(n, 1, 0.65),
    milieu              = sample(c("urbain","rural"), n, TRUE),
    poids               = runif(n, 0.8, 1.3),
    stringsAsFactors    = FALSE
  )
}

# =============================================================================
# BLOC 1 - retard_croissance()
# =============================================================================

test_that("retard_croissance() : retourne saf_anthropo", {
  d   <- .make_enfants()
  res <- suppressMessages(
    retard_croissance(d, var_taille_age_z="haz", poids="poids"))
  expect_s3_class(res, "saf_anthropo")
})

test_that("retard_croissance() : taux entre 0 et 1", {
  d   <- .make_enfants()
  res <- suppressMessages(
    retard_croissance(d, var_taille_age_z="haz", poids="poids"))
  expect_gte(res$taux, 0)
  expect_lte(res$taux, 1)
})

test_that("retard_croissance() : IC coherent", {
  d   <- .make_enfants()
  res <- suppressMessages(
    retard_croissance(d, var_taille_age_z="haz", poids="poids"))
  expect_lte(res$ic_bas, res$taux_pct)
  expect_gte(res$ic_haut, res$taux_pct)
})

test_that("retard_croissance() : variable introuvable => erreur", {
  d <- .make_enfants()
  expect_error(
    retard_croissance(d, var_taille_age_z="xxx"),
    regexp="introuvable")
})

test_that("retard_croissance() : donnees vides => erreur", {
  expect_error(
    retard_croissance(data.frame(), var_taille_age_z="haz"),
    regexp="non vide")
})

test_that("retard_croissance() : avec sous_groupes", {
  d   <- .make_enfants()
  res <- suppressMessages(
    retard_croissance(d, var_taille_age_z="haz",
                      poids="poids", sous_groupes="milieu"))
  expect_false(is.null(res$decomposition))
  expect_equal(nrow(res$decomposition), 2L)
})

test_that("retard_croissance() : print sans erreur", {
  d   <- .make_enfants()
  res <- suppressMessages(
    retard_croissance(d, var_taille_age_z="haz"))
  expect_output(print(res), "stunting")
})

test_that("retard_croissance() : seuil -3 => moins de cas", {
  d <- .make_enfants()
  r1 <- suppressMessages(
    retard_croissance(d, var_taille_age_z="haz", seuil=-2))
  r2 <- suppressMessages(
    retard_croissance(d, var_taille_age_z="haz", seuil=-3))
  expect_gte(r1$taux, r2$taux)
})

# =============================================================================
# BLOC 2 - emaciation()
# =============================================================================

test_that("emaciation() : retourne saf_anthropo", {
  d   <- .make_enfants()
  res <- suppressMessages(
    emaciation(d, var_poids_taille_z="whz", poids="poids"))
  expect_s3_class(res, "saf_anthropo")
})

test_that("emaciation() : taux entre 0 et 1", {
  d   <- .make_enfants()
  res <- suppressMessages(
    emaciation(d, var_poids_taille_z="whz"))
  expect_gte(res$taux, 0)
  expect_lte(res$taux, 1)
})

test_that("emaciation() : variable introuvable => erreur", {
  d <- .make_enfants()
  expect_error(emaciation(d, "xxx"), regexp="introuvable")
})

# =============================================================================
# BLOC 3 - insuffisance_ponderale()
# =============================================================================

test_that("insuffisance_ponderale() : retourne saf_anthropo", {
  d   <- .make_enfants()
  res <- suppressMessages(
    insuffisance_ponderale(d, var_poids_age_z="waz", poids="poids"))
  expect_s3_class(res, "saf_anthropo")
})

test_that("insuffisance_ponderale() : n_obs correct", {
  d <- .make_enfants(200)
  res <- suppressMessages(
    insuffisance_ponderale(d, var_poids_age_z="waz"))
  expect_equal(res$n_obs, 200L)
})

# =============================================================================
# BLOC 4 - anemie()
# =============================================================================

test_that("anemie() : retourne tibble avec 5 lignes", {
  d   <- .make_femmes()
  res <- suppressMessages(
    anemie(d, var_hemoglobine="hemoglobine", poids="poids"))
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 5L)
})

test_that("anemie() : total anemie + normale = 100%", {
  d   <- .make_femmes()
  res <- suppressMessages(
    anemie(d, var_hemoglobine="hemoglobine"))
  total <- res$prevalence_pct[4] + res$prevalence_pct[5]
  expect_equal(total, 100, tolerance = 0.5)
})

test_that("anemie() : variable introuvable => erreur", {
  d <- .make_femmes()
  expect_error(anemie(d, "xxx"), regexp="introuvable")
})

test_that("anemie() : prevalences entre 0 et 100", {
  d   <- .make_femmes()
  res <- suppressMessages(anemie(d, "hemoglobine"))
  expect_true(all(res$prevalence_pct >= 0))
  expect_true(all(res$prevalence_pct <= 100))
})

test_that("anemie() : severe <= totale", {
  d   <- .make_femmes()
  res <- suppressMessages(anemie(d, "hemoglobine"))
  expect_lte(res$prevalence_pct[1], res$prevalence_pct[4])
})

# =============================================================================
# BLOC 5 - vaccination()
# =============================================================================

test_that("vaccination() : retourne tibble", {
  set.seed(42); n <- 500
  d <- data.frame(
    dtc3     = rbinom(n,1,0.72), rougeole = rbinom(n,1,0.68),
    poids    = runif(n,0.8,1.3)
  )
  res <- suppressMessages(
    vaccination(d, vars_vaccins=c(DTC3="dtc3",Rougeole="rougeole"),
                poids="poids"))
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 2L)
})

test_that("vaccination() : couvertures entre 0 et 100", {
  set.seed(42); n <- 300
  d <- data.frame(dtc3=rbinom(n,1,0.7), poids=runif(n,0.8,1.3))
  res <- suppressMessages(
    vaccination(d, vars_vaccins=c(DTC3="dtc3"), poids="poids"))
  expect_gte(res$couverture_pct[1], 0)
  expect_lte(res$couverture_pct[1], 100)
})

test_that("vaccination() : vecteur non nomme => erreur", {
  set.seed(42)
  d <- data.frame(dtc3=rbinom(100,1,0.7))
  expect_error(vaccination(d, vars_vaccins=c("dtc3")),
               regexp="nomme")
})

test_that("vaccination() : variable introuvable => erreur", {
  set.seed(42)
  d <- data.frame(dtc3=rbinom(100,1,0.7))
  expect_error(
    vaccination(d, vars_vaccins=c(DTC3="xxx")),
    regexp="introuvable")
})

test_that("vaccination() : colonne ecart_objectif presente", {
  set.seed(42); n <- 200
  d <- data.frame(bcg=rbinom(n,1,0.9), poids=runif(n,0.8,1.3))
  res <- suppressMessages(
    vaccination(d, vars_vaccins=c(BCG="bcg")))
  expect_true("ecart_objectif" %in% names(res))
})

# =============================================================================
# BLOC 6 - mortalite_5ans()
# =============================================================================

test_that("mortalite_5ans() : retourne saf_mortalite", {
  d   <- .make_femmes()
  res <- suppressMessages(
    mortalite_5ans(d, "naissances_vivantes", "deces_enfants",
                   poids="poids"))
  expect_s3_class(res, "saf_mortalite")
})

test_that("mortalite_5ans() : U5MR positif", {
  d   <- .make_femmes()
  res <- suppressMessages(
    mortalite_5ans(d, "naissances_vivantes", "deces_enfants",
                   poids="poids"))
  expect_gt(res$u5mr, 0)
})

test_that("mortalite_5ans() : IC coherent", {
  d   <- .make_femmes()
  res <- suppressMessages(
    mortalite_5ans(d, "naissances_vivantes", "deces_enfants"))
  expect_lte(res$ic_bas,  res$u5mr)
  expect_gte(res$ic_haut, res$u5mr)
})

test_that("mortalite_5ans() : variable introuvable => erreur", {
  d <- .make_femmes()
  expect_error(
    mortalite_5ans(d, "xxx", "deces_enfants"),
    regexp="introuvable")
})

test_that("mortalite_5ans() : print sans erreur", {
  d   <- .make_femmes()
  res <- suppressMessages(
    mortalite_5ans(d, "naissances_vivantes", "deces_enfants"))
  expect_output(print(res), "U5MR")
})

test_that("mortalite_5ans() : avec sous_groupes", {
  d   <- .make_femmes(600)
  res <- suppressMessages(
    mortalite_5ans(d, "naissances_vivantes", "deces_enfants",
                   poids="poids", sous_groupes="milieu"))
  expect_false(is.null(res$decomposition))
})

# =============================================================================
# BLOC 7 - accouchements_assistes()
# =============================================================================

test_that("accouchements_assistes() : retourne tibble", {
  d   <- .make_femmes()
  res <- suppressMessages(
    accouchements_assistes(d, "assiste", poids="poids"))
  expect_s3_class(res, "data.frame")
})

test_that("accouchements_assistes() : taux entre 0 et 100", {
  d   <- .make_femmes()
  res <- suppressMessages(
    accouchements_assistes(d, "assiste", poids="poids"))
  expect_gte(res$taux_pct[1], 0)
  expect_lte(res$taux_pct[1], 100)
})

test_that("accouchements_assistes() : avec desagregation", {
  d   <- .make_femmes()
  res <- suppressMessages(
    accouchements_assistes(d, "assiste", poids="poids",
                            sous_groupes=c("milieu")))
  expect_gt(nrow(res), 1L)
})

test_that("accouchements_assistes() : variable introuvable => erreur", {
  d <- .make_femmes()
  expect_error(accouchements_assistes(d, "xxx"), regexp="introuvable")
})

# =============================================================================
# BLOC 8 - tableau_sante()
# =============================================================================

test_that("tableau_sante() : retourne tibble", {
  d  <- .make_enfants()
  r1 <- suppressMessages(
    retard_croissance(d, "haz", poids="poids"))
  r2 <- suppressMessages(
    emaciation(d, "whz", poids="poids"))
  res <- suppressMessages(
    tableau_sante(list(stunting=r1, wasting=r2),
                  pays="RCA", annee=2026L))
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 2L)
})

test_that("tableau_sante() : colonnes attendues", {
  d  <- .make_enfants()
  r1 <- suppressMessages(retard_croissance(d, "haz"))
  res <- suppressMessages(
    tableau_sante(list(stunting=r1), pays="RCA", annee=2026L))
  expect_true(all(c("indicateur","code_odd","valeur_pct","pays","annee")
                  %in% names(res)))
})

test_that("tableau_sante() : liste vide => erreur", {
  expect_error(tableau_sante(list()), regexp="non vide")
})

test_that("tableau_sante() : avec mortalite", {
  d  <- .make_femmes()
  rm <- suppressMessages(
    mortalite_5ans(d, "naissances_vivantes", "deces_enfants"))
  res <- suppressMessages(
    tableau_sante(list(mortalite=rm), pays="RCA"))
  expect_equal(nrow(res), 1L)
})
