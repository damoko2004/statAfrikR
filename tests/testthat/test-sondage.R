# =============================================================================
# statAfrikR - Tests module Plans de sondage complexes
# testthat edition 3
# =============================================================================

.make_enquete <- function(n = 300, seed = 42) {
  set.seed(seed)
  data.frame(
    poids_sond = runif(n, 1800, 3500),
    strate     = sample(c("Urbain","Rural","Semi-urbain"), n, TRUE),
    grappe     = sample(1:30, n, TRUE),
    revenu     = pmax(0, rnorm(n, 180000, 90000)),
    pauvre     = rbinom(n, 1, 0.45),
    scolarise  = rbinom(n, 1, 0.72),
    sexe       = sample(c("H","F"), n, TRUE),
    milieu     = sample(c("urbain","rural"), n, TRUE),
    repondu    = rbinom(n, 1, 0.88),
    age_cm     = sample(25:65, n, TRUE),
    stringsAsFactors = FALSE
  )
}

.make_design <- function(n = 300) {
  d <- .make_enquete(n)
  suppressMessages(
    creer_design(d, "poids_sond",
                 var_strate="strate", var_grappe="grappe"))
}

# =============================================================================
# BLOC 1 - creer_design()
# =============================================================================

test_that("creer_design() : retourne saf_design", {
  d   <- .make_enquete()
  res <- suppressMessages(
    creer_design(d, "poids_sond",
                 var_strate="strate", var_grappe="grappe"))
  expect_s3_class(res, "saf_design")
})

test_that("creer_design() : n_obs correct", {
  d   <- .make_enquete(200)
  res <- suppressMessages(
    creer_design(d, "poids_sond"))
  expect_equal(res$n_obs, 200L)
})

test_that("creer_design() : contient un objet survey", {
  des <- .make_design()
  expect_true(!is.null(des$design))
  expect_true(inherits(des$design, "survey.design") ||
              inherits(des$design, "svyrep.design"))
})

test_that("creer_design() : variable poids introuvable => erreur", {
  d <- .make_enquete()
  expect_error(creer_design(d, "xxx"), regexp="introuvable")
})

test_that("creer_design() : variable strate introuvable => erreur", {
  d <- .make_enquete()
  expect_error(
    creer_design(d, "poids_sond", var_strate="xxx"),
    regexp="introuvable")
})

test_that("creer_design() : variable grappe introuvable => erreur", {
  d <- .make_enquete()
  expect_error(
    creer_design(d, "poids_sond", var_grappe="xxx"),
    regexp="introuvable")
})

test_that("creer_design() : donnees vides => erreur", {
  expect_error(creer_design(data.frame(), "x"), regexp="non vide")
})

test_that("creer_design() : sans strate ni grappe fonctionne", {
  d   <- .make_enquete(100)
  res <- suppressMessages(creer_design(d, "poids_sond"))
  expect_s3_class(res, "saf_design")
})

test_that("creer_design() : print sans erreur", {
  des <- .make_design()
  expect_output(print(des), "Design")
})

test_that("creer_design() : n_strates correct", {
  des <- .make_design()
  expect_equal(des$n_strates, 3L)
})

# =============================================================================
# BLOC 2 - valider_poids()
# =============================================================================

test_that("valider_poids() : retourne tibble", {
  des <- .make_design()
  res <- suppressMessages(valider_poids(des))
  expect_s3_class(res, "data.frame")
})

test_that("valider_poids() : 3 strates -> 3 lignes", {
  des <- .make_design()
  res <- suppressMessages(valider_poids(des))
  expect_equal(nrow(res), 3L)
})

test_that("valider_poids() : non saf_design => erreur", {
  expect_error(valider_poids(list()), regexp="saf_design")
})

test_that("valider_poids() : colonnes attendues", {
  des <- .make_design()
  res <- suppressMessages(valider_poids(des))
  expect_true(all(c("strate","n_obs","somme_poids","cv_poids_pct")
                  %in% names(res)))
})

test_that("valider_poids() : avec population cible", {
  des <- .make_design()
  res <- suppressWarnings(suppressMessages(
    valider_poids(des, population_cible=500000)))
  expect_s3_class(res, "data.frame")
})

# =============================================================================
# BLOC 3 - calcul_deff()
# =============================================================================

test_that("calcul_deff() : retourne tibble", {
  des <- .make_design()
  res <- suppressMessages(calcul_deff(des, "pauvre"))
  expect_s3_class(res, "data.frame")
})

test_that("calcul_deff() : DEFF positif", {
  des <- .make_design()
  res <- suppressMessages(calcul_deff(des, "pauvre"))
  expect_true(is.na(res$deff[1]) || res$deff[1] > 0)
})

test_that("calcul_deff() : plusieurs variables", {
  des <- .make_design()
  res <- suppressMessages(calcul_deff(des, c("pauvre","scolarise")))
  expect_equal(nrow(res), 2L)
})

test_that("calcul_deff() : variable introuvable => erreur", {
  des <- .make_design()
  expect_error(calcul_deff(des, "xxx"), regexp="introuvable")
})

test_that("calcul_deff() : non saf_design => erreur", {
  expect_error(calcul_deff(list(), "pauvre"), regexp="saf_design")
})

# =============================================================================
# BLOC 4 - calibrer_poids()
# =============================================================================

test_that("calibrer_poids() : retourne saf_design", {
  des <- .make_design()
  marges <- list(
    sexe   = c(H=500000, F=550000),
    milieu = c(urbain=600000, rural=450000)
  )
  res <- suppressMessages(
    calibrer_poids(des, marges, var_calibrage=c("sexe","milieu")))
  expect_s3_class(res, "saf_design")
})

test_that("calibrer_poids() : marges non liste => erreur", {
  des <- .make_design()
  expect_error(calibrer_poids(des, list()), regexp="nommee")
})

test_that("calibrer_poids() : non saf_design => erreur", {
  expect_error(
    calibrer_poids(list(), list(x=c(a=1))),
    regexp="saf_design")
})

test_that("calibrer_poids() : variable calibrage introuvable => erreur", {
  des <- .make_design()
  marges <- list(inexistant=c(a=100, b=200))
  expect_error(
    calibrer_poids(des, marges, var_calibrage=c("inexistant")),
    regexp="introuvable")
})

# =============================================================================
# BLOC 5 - analyser_non_reponse()
# =============================================================================

test_that("analyser_non_reponse() : retourne liste", {
  d   <- .make_enquete()
  res <- suppressMessages(
    analyser_non_reponse(d, "repondu", var_strate="strate"))
  expect_true(is.list(res))
  expect_true("taux_reponse" %in% names(res))
})

test_that("analyser_non_reponse() : 3 strates -> 3 lignes", {
  d   <- .make_enquete()
  res <- suppressMessages(
    analyser_non_reponse(d, "repondu", var_strate="strate"))
  expect_equal(nrow(res$taux_reponse), 3L)
})

test_that("analyser_non_reponse() : taux entre 0 et 100", {
  d   <- .make_enquete()
  res <- suppressMessages(analyser_non_reponse(d, "repondu"))
  expect_true(all(res$taux_reponse$taux_reponse >= 0))
  expect_true(all(res$taux_reponse$taux_reponse <= 100))
})

test_that("analyser_non_reponse() : avec variables biais", {
  d   <- .make_enquete()
  res <- suppressMessages(
    analyser_non_reponse(d, "repondu",
                          vars_biais=c("age_cm")))
  expect_false(is.null(res$biais))
})

test_that("analyser_non_reponse() : variable introuvable => erreur", {
  d <- .make_enquete()
  expect_error(analyser_non_reponse(d, "xxx"), regexp="introuvable")
})

test_that("analyser_non_reponse() : donnees vides => erreur", {
  expect_error(
    analyser_non_reponse(data.frame(), "repondu"),
    regexp="non vide")
})

# =============================================================================
# BLOC 6 - rapport_qualite_sondage()
# =============================================================================

test_that("rapport_qualite_sondage() : retourne tibble", {
  des <- .make_design()
  res <- suppressMessages(
    rapport_qualite_sondage(des, pays="RCA", annee=2026L))
  expect_s3_class(res, "data.frame")
})

test_that("rapport_qualite_sondage() : avec taux reponse", {
  des <- .make_design()
  res <- suppressMessages(
    rapport_qualite_sondage(des, var_reponse="repondu",
                             pays="RCA"))
  expect_true(any(grepl("reponse", res$indicateur)))
})

test_that("rapport_qualite_sondage() : avec DEFF", {
  des <- .make_design()
  res <- suppressMessages(
    rapport_qualite_sondage(des, variables="pauvre",
                             pays="RCA"))
  expect_true(any(grepl("DEFF", res$indicateur)))
})

test_that("rapport_qualite_sondage() : non saf_design => erreur", {
  expect_error(rapport_qualite_sondage(list()), regexp="saf_design")
})
