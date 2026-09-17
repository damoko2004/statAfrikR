# =============================================================================
# statAfrikR - Tests module Bien-etre subjectif
# testthat edition 3
# =============================================================================

.make_indiv_bs <- function(n = 500, seed = 42) {
  set.seed(seed)
  data.frame(
    satisfaction  = pmin(10, pmax(0, round(rnorm(n, 5.8, 2.1)))),
    bonheur       = sample(1:4, n, TRUE, prob=c(0.20,0.45,0.25,0.10)),
    bonheur_bin   = rbinom(n, 1, 0.62),
    econ_ok       = rbinom(n, 1, 0.38),
    manque_nour   = rbinom(n, 1, 0.48),
    manque_eau    = rbinom(n, 1, 0.35),
    manque_med    = rbinom(n, 1, 0.58),
    stress        = rbinom(n, 1, 0.38),
    anxiete       = rbinom(n, 1, 0.28),
    isolement     = rbinom(n, 1, 0.22),
    conf_gouv     = rbinom(n, 1, 0.35),
    conf_just     = rbinom(n, 1, 0.42),
    securise      = rbinom(n, 1, 0.52),
    sexe          = sample(c("H","F"), n, TRUE),
    milieu        = sample(c("urbain","rural"), n, TRUE),
    quintile      = sample(paste0("Q", 1:5), n, TRUE),
    poids         = runif(n, 0.8, 1.3),
    stringsAsFactors = FALSE
  )
}

# =============================================================================
# BLOC 1 - satisfaction_vie()
# =============================================================================

test_that("satisfaction_vie() : retourne saf_subjectif", {
  d   <- .make_indiv_bs()
  res <- suppressMessages(
    satisfaction_vie(d, "satisfaction", poids="poids"))
  expect_s3_class(res, "saf_subjectif")
})

test_that("satisfaction_vie() : score entre 0 et 10", {
  d   <- .make_indiv_bs()
  res <- suppressMessages(satisfaction_vie(d, "satisfaction"))
  expect_gte(res$score_moy, 0)
  expect_lte(res$score_moy, 10)
})

test_that("satisfaction_vie() : distribution presente", {
  d   <- .make_indiv_bs()
  res <- suppressMessages(satisfaction_vie(d, "satisfaction"))
  expect_false(is.null(res$distribution))
  expect_equal(nrow(res$distribution), 4L)
})

test_that("satisfaction_vie() : avec desagregation", {
  d   <- .make_indiv_bs()
  res <- suppressMessages(
    satisfaction_vie(d, "satisfaction", poids="poids",
                     sous_groupes=c("milieu","sexe")))
  expect_false(is.null(res$decomposition))
  expect_gte(nrow(res$decomposition), 4L)
})

test_that("satisfaction_vie() : variable introuvable => erreur", {
  d <- .make_indiv_bs()
  expect_error(satisfaction_vie(d, "xxx"), regexp="introuvable")
})

test_that("satisfaction_vie() : donnees vides => erreur", {
  expect_error(satisfaction_vie(data.frame(), "x"), regexp="non vide")
})

test_that("satisfaction_vie() : print sans erreur", {
  d   <- .make_indiv_bs()
  res <- suppressMessages(satisfaction_vie(d, "satisfaction"))
  expect_output(print(res), "Score")
})

test_that("satisfaction_vie() : poids introuvable => erreur", {
  d <- .make_indiv_bs()
  expect_error(satisfaction_vie(d,"satisfaction",poids="xxx"),
               regexp="introuvable")
})

# =============================================================================
# BLOC 2 - bonheur_declare()
# =============================================================================

test_that("bonheur_declare() : retourne saf_subjectif", {
  d   <- .make_indiv_bs()
  res <- suppressMessages(
    bonheur_declare(d, "bonheur", codes_heureux=c(1,2), poids="poids"))
  expect_s3_class(res, "saf_subjectif")
})

test_that("bonheur_declare() : taux entre 0 et 100", {
  d   <- .make_indiv_bs()
  res <- suppressMessages(
    bonheur_declare(d, "bonheur", codes_heureux=c(1,2)))
  expect_gte(res$taux_pct, 0)
  expect_lte(res$taux_pct, 100)
})

test_that("bonheur_declare() : avec variable binaire directe", {
  d   <- .make_indiv_bs()
  res <- suppressMessages(
    bonheur_declare(d, "bonheur_bin", codes_heureux=c(1)))
  expect_s3_class(res, "saf_subjectif")
})

test_that("bonheur_declare() : variable introuvable => erreur", {
  d <- .make_indiv_bs()
  expect_error(bonheur_declare(d, "xxx"), regexp="introuvable")
})

# =============================================================================
# BLOC 3 - perception_economique()
# =============================================================================

test_that("perception_economique() : retourne saf_subjectif", {
  d   <- .make_indiv_bs()
  res <- suppressMessages(
    perception_economique(d, "econ_ok", poids="poids"))
  expect_s3_class(res, "saf_subjectif")
})

test_that("perception_economique() : taux entre 0 et 100", {
  d   <- .make_indiv_bs()
  res <- suppressMessages(perception_economique(d, "econ_ok"))
  expect_gte(res$taux_pct, 0)
  expect_lte(res$taux_pct, 100)
})

test_that("perception_economique() : variable introuvable => erreur", {
  d <- .make_indiv_bs()
  expect_error(perception_economique(d, "xxx"), regexp="introuvable")
})

# =============================================================================
# BLOC 4 - privations_ressenties()
# =============================================================================

test_that("privations_ressenties() : retourne tibble", {
  d   <- .make_indiv_bs()
  res <- suppressMessages(
    privations_ressenties(d,
      vars_privations=c(Nourriture="manque_nour", Eau="manque_eau"),
      poids="poids"))
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 3L)
})

test_that("privations_ressenties() : ligne 'au moins une' presente", {
  d   <- .make_indiv_bs()
  res <- suppressMessages(
    privations_ressenties(d,
      vars_privations=c(Nour="manque_nour", Eau="manque_eau")))
  expect_true(any(grepl("Au moins", res$type_privation)))
})

test_that("privations_ressenties() : vecteur non nomme => erreur", {
  d <- .make_indiv_bs()
  expect_error(
    privations_ressenties(d, vars_privations=c("manque_nour")),
    regexp="nomme")
})

test_that("privations_ressenties() : variable introuvable => erreur", {
  d <- .make_indiv_bs()
  expect_error(
    privations_ressenties(d, vars_privations=c(Test="xxx")),
    regexp="introuvable")
})

test_that("privations_ressenties() : au moins une >= toutes", {
  d   <- .make_indiv_bs()
  res <- suppressMessages(
    privations_ressenties(d,
      vars_privations=c(Nour="manque_nour", Eau="manque_eau")))
  max_part <- max(res$prevalence_pct[1:(nrow(res)-1)])
  globale  <- res$prevalence_pct[nrow(res)]
  expect_gte(globale, max_part)
})

# =============================================================================
# BLOC 5 - sante_mentale()
# =============================================================================

test_that("sante_mentale() : retourne tibble", {
  d   <- .make_indiv_bs()
  res <- suppressMessages(
    sante_mentale(d, var_stress="stress",
                   var_anxiete="anxiete", poids="poids"))
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 2L)
})

test_that("sante_mentale() : aucune variable => erreur", {
  d <- .make_indiv_bs()
  expect_error(sante_mentale(d), regexp="indicateur")
})

test_that("sante_mentale() : variable introuvable => erreur", {
  d <- .make_indiv_bs()
  expect_error(sante_mentale(d, var_stress="xxx"), regexp="introuvable")
})

test_that("sante_mentale() : avec 3 indicateurs", {
  d   <- .make_indiv_bs()
  res <- suppressMessages(
    sante_mentale(d, var_stress="stress",
                   var_anxiete="anxiete", var_isolement="isolement"))
  expect_equal(nrow(res), 3L)
})

# =============================================================================
# BLOC 6 - confiance_institutions()
# =============================================================================

test_that("confiance_institutions() : retourne tibble", {
  d   <- .make_indiv_bs()
  res <- suppressMessages(
    confiance_institutions(d,
      vars_institutions=c(Gouvernement="conf_gouv",
                           Justice="conf_just"),
      poids="poids"))
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 2L)
})

test_that("confiance_institutions() : confiances entre 0 et 100", {
  d   <- .make_indiv_bs()
  res <- suppressMessages(
    confiance_institutions(d,
      vars_institutions=c(Gouvernement="conf_gouv")))
  expect_gte(res$confiance_pct[1], 0)
  expect_lte(res$confiance_pct[1], 100)
})

test_that("confiance_institutions() : vecteur non nomme => erreur", {
  d <- .make_indiv_bs()
  expect_error(
    confiance_institutions(d, vars_institutions=c("conf_gouv")),
    regexp="nomme")
})

test_that("confiance_institutions() : variable introuvable => erreur", {
  d <- .make_indiv_bs()
  expect_error(
    confiance_institutions(d, vars_institutions=c(Test="xxx")),
    regexp="introuvable")
})

# =============================================================================
# BLOC 7 - sentiment_securite()
# =============================================================================

test_that("sentiment_securite() : retourne saf_subjectif", {
  d   <- .make_indiv_bs()
  res <- suppressMessages(
    sentiment_securite(d, "securise", poids="poids"))
  expect_s3_class(res, "saf_subjectif")
})

test_that("sentiment_securite() : taux entre 0 et 100", {
  d   <- .make_indiv_bs()
  res <- suppressMessages(sentiment_securite(d, "securise"))
  expect_gte(res$taux_pct, 0)
  expect_lte(res$taux_pct, 100)
})

test_that("sentiment_securite() : avec desagregation sexe", {
  d   <- .make_indiv_bs()
  res <- suppressMessages(
    sentiment_securite(d, "securise", poids="poids",
                        sous_groupes="sexe"))
  expect_equal(nrow(res$decomposition), 2L)
})

test_that("sentiment_securite() : variable introuvable => erreur", {
  d <- .make_indiv_bs()
  expect_error(sentiment_securite(d, "xxx"), regexp="introuvable")
})

# =============================================================================
# BLOC 8 - tableau_bien_etre_subjectif()
# =============================================================================

test_that("tableau_bien_etre_subjectif() : retourne tibble", {
  d  <- .make_indiv_bs()
  r1 <- suppressMessages(satisfaction_vie(d,"satisfaction",poids="poids"))
  r2 <- suppressMessages(sentiment_securite(d,"securise",poids="poids"))
  res <- suppressMessages(
    tableau_bien_etre_subjectif(list(satisf=r1, securite=r2),
                                 pays="RCA", annee=2026L))
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 2L)
})

test_that("tableau_bien_etre_subjectif() : colonnes attendues", {
  d  <- .make_indiv_bs()
  r1 <- suppressMessages(satisfaction_vie(d, "satisfaction"))
  res <- suppressMessages(
    tableau_bien_etre_subjectif(list(satisf=r1), pays="RCA"))
  expect_true(all(c("indicateur","code_ref","valeur","pays","annee")
                  %in% names(res)))
})

test_that("tableau_bien_etre_subjectif() : liste vide => erreur", {
  expect_error(tableau_bien_etre_subjectif(list()), regexp="non vide")
})

test_that("tableau_bien_etre_subjectif() : avec privations tibble", {
  d  <- .make_indiv_bs()
  rp <- suppressMessages(
    privations_ressenties(d, vars_privations=c(Nour="manque_nour")))
  res <- suppressMessages(
    tableau_bien_etre_subjectif(list(privations=rp), pays="RCA"))
  expect_equal(nrow(res), 1L)
})
