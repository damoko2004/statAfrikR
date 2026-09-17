# =============================================================================
# statAfrikR - Tests module Genre & Inclusion
# testthat edition 3
# =============================================================================

.make_femmes_genre <- function(n = 500, seed = 42) {
  set.seed(seed)
  data.frame(
    dec_achat   = rbinom(n, 1, 0.55),
    dec_sante   = rbinom(n, 1, 0.48),
    compte_ban  = rbinom(n, 1, 0.32),
    rev_propre  = rbinom(n, 1, 0.41),
    libre_dep   = rbinom(n, 1, 0.62),
    vbg_phys    = rbinom(n, 1, 0.28),
    vbg_sex     = rbinom(n, 1, 0.18),
    vbg_psycho  = rbinom(n, 1, 0.35),
    marie_18    = rbinom(n, 1, 0.42),
    scolarise   = rbinom(n, 1, 0.72),
    hand_vis    = rbinom(n, 1, 0.04),
    hand_mot    = rbinom(n, 1, 0.05),
    sexe        = sample(c("H","F"), n, TRUE),
    cohorte     = sample(c("15-19","20-24","25-29","30-34"), n, TRUE),
    niveau      = sample(c("primaire","secondaire"), n, TRUE),
    milieu      = sample(c("urbain","rural"), n, TRUE),
    poids       = runif(n, 0.8, 1.3),
    stringsAsFactors = FALSE
  )
}

# =============================================================================
# BLOC 1 - autonomisation_femmes()
# =============================================================================

test_that("autonomisation_femmes() : retourne saf_genre", {
  d   <- .make_femmes_genre()
  res <- suppressMessages(
    autonomisation_femmes(d,
      vars_decision   = c("dec_achat","dec_sante"),
      vars_ressources = c("compte_ban","rev_propre"),
      poids = "poids"))
  expect_s3_class(res, "saf_genre")
})

test_that("autonomisation_femmes() : indice entre 0 et 1", {
  d   <- .make_femmes_genre()
  res <- suppressMessages(
    autonomisation_femmes(d,
      vars_decision = c("dec_achat"), poids="poids"))
  expect_gte(res$indice, 0)
  expect_lte(res$indice, 1)
})

test_that("autonomisation_femmes() : aucune dimension => erreur", {
  d <- .make_femmes_genre()
  expect_error(autonomisation_femmes(d), regexp="dimension")
})

test_that("autonomisation_femmes() : variable introuvable => erreur", {
  d <- .make_femmes_genre()
  expect_error(
    autonomisation_femmes(d, vars_decision=c("xxx")),
    regexp="introuvable")
})

test_that("autonomisation_femmes() : poids introuvable => erreur", {
  d <- .make_femmes_genre()
  expect_error(
    autonomisation_femmes(d, vars_decision=c("dec_achat"), poids="xxx"),
    regexp="introuvable")
})

test_that("autonomisation_femmes() : avec desagregation", {
  d   <- .make_femmes_genre()
  res <- suppressMessages(
    autonomisation_femmes(d,
      vars_decision = c("dec_achat","dec_sante"),
      poids="poids", sous_groupes="milieu"))
  expect_false(is.null(res$decomposition))
  expect_equal(nrow(res$decomposition), 2L)
})

test_that("autonomisation_femmes() : print sans erreur", {
  d   <- .make_femmes_genre()
  res <- suppressMessages(
    autonomisation_femmes(d, vars_decision=c("dec_achat")))
  expect_output(print(res), "autonomisation")
})

test_that("autonomisation_femmes() : 3 dimensions => 3 scores", {
  d   <- .make_femmes_genre()
  res <- suppressMessages(
    autonomisation_femmes(d,
      vars_decision   = c("dec_achat"),
      vars_ressources = c("compte_ban"),
      vars_mobilite   = c("libre_dep")))
  expect_equal(nrow(res$scores_dim), 3L)
})

# =============================================================================
# BLOC 2 - violence_basee_genre()
# =============================================================================

test_that("violence_basee_genre() : retourne tibble", {
  d   <- .make_femmes_genre()
  res <- violence_basee_genre(d,
    var_violence_physique="vbg_phys",
    var_violence_sexuelle="vbg_sex",
    poids="poids")
  expect_s3_class(res, "data.frame")
})

test_that("violence_basee_genre() : ligne 'au moins une' presente", {
  d   <- .make_femmes_genre()
  res <- violence_basee_genre(d,
    var_violence_physique="vbg_phys",
    var_violence_sexuelle="vbg_sex")
  expect_true(any(grepl("Au moins", res$type_violence)))
})

test_that("violence_basee_genre() : prevalences entre 0 et 100", {
  d   <- .make_femmes_genre()
  res <- violence_basee_genre(d, var_violence_physique="vbg_phys")
  expect_true(all(res$prevalence_pct >= 0))
  expect_true(all(res$prevalence_pct <= 100))
})

test_that("violence_basee_genre() : aucune variable => erreur", {
  d <- .make_femmes_genre()
  expect_error(violence_basee_genre(d), regexp="variable de VBG")
})

test_that("violence_basee_genre() : variable introuvable => erreur", {
  d <- .make_femmes_genre()
  expect_error(
    violence_basee_genre(d, var_violence_physique="xxx"),
    regexp="introuvable")
})

test_that("violence_basee_genre() : au moins une >= physique", {
  d   <- .make_femmes_genre()
  res <- violence_basee_genre(d,
    var_violence_physique="vbg_phys",
    var_violence_sexuelle="vbg_sex")
  phys    <- res$prevalence_pct[res$type_violence=="Physique"]
  globale <- res$prevalence_pct[grepl("Au moins", res$type_violence)]
  expect_gte(globale, phys)
})

# =============================================================================
# BLOC 3 - mariage_precoce()
# =============================================================================

test_that("mariage_precoce() : retourne saf_genre", {
  d   <- .make_femmes_genre()
  res <- suppressMessages(
    mariage_precoce(d, "marie_18", poids="poids"))
  expect_s3_class(res, "saf_genre")
})

test_that("mariage_precoce() : taux entre 0 et 1", {
  d   <- .make_femmes_genre()
  res <- suppressMessages(mariage_precoce(d, "marie_18"))
  expect_gte(res$taux, 0)
  expect_lte(res$taux, 1)
})

test_that("mariage_precoce() : avec cohortes", {
  d   <- .make_femmes_genre()
  res <- suppressMessages(
    mariage_precoce(d, "marie_18", var_cohorte="cohorte", poids="poids"))
  expect_false(is.null(res$cohortes))
  expect_equal(nrow(res$cohortes), 4L)
})

test_that("mariage_precoce() : variable introuvable => erreur", {
  d <- .make_femmes_genre()
  expect_error(mariage_precoce(d, "xxx"), regexp="introuvable")
})

test_that("mariage_precoce() : avec desagregation milieu", {
  d   <- .make_femmes_genre()
  res <- suppressMessages(
    mariage_precoce(d, "marie_18", poids="poids",
                     sous_groupes="milieu"))
  expect_equal(nrow(res$decomposition), 2L)
})

# =============================================================================
# BLOC 4 - parite_education()
# =============================================================================

test_that("parite_education() : retourne saf_genre", {
  d   <- .make_femmes_genre()
  res <- suppressMessages(
    parite_education(d, "scolarise", "sexe", poids="poids"))
  expect_s3_class(res, "saf_genre")
})

test_that("parite_education() : ISP positif", {
  d   <- .make_femmes_genre()
  res <- suppressMessages(parite_education(d, "scolarise", "sexe"))
  expect_gt(res$isp, 0)
})

test_that("parite_education() : ISP egal pop equale", {
  set.seed(42)
  n <- 400
  d <- data.frame(
    scol  = rep(1L, n),  # tous scolarises
    sexe  = rep(c("H","F"), n/2)
  )
  res <- suppressMessages(parite_education(d, "scol", "sexe"))
  expect_equal(res$isp, 1.0, tolerance=0.01)
})

test_that("parite_education() : avec niveaux", {
  d   <- .make_femmes_genre()
  res <- suppressMessages(
    parite_education(d, "scolarise", "sexe",
                     poids="poids", var_niveau="niveau"))
  expect_false(is.null(res$isp_par_niveau))
  expect_equal(nrow(res$isp_par_niveau), 2L)
})

test_that("parite_education() : variable introuvable => erreur", {
  d <- .make_femmes_genre()
  expect_error(parite_education(d, "xxx", "sexe"), regexp="introuvable")
})

# =============================================================================
# BLOC 5 - handicap_prevalence()
# =============================================================================

test_that("handicap_prevalence() : retourne tibble", {
  d   <- .make_femmes_genre()
  res <- suppressMessages(
    handicap_prevalence(d,
      vars_handicap=c(Visuel="hand_vis",Moteur="hand_mot"),
      poids="poids"))
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 3L)
})

test_that("handicap_prevalence() : ligne 'au moins un' presente", {
  d   <- .make_femmes_genre()
  res <- suppressMessages(
    handicap_prevalence(d,
      vars_handicap=c(Visuel="hand_vis",Moteur="hand_mot")))
  expect_true(any(grepl("Au moins", res$type_handicap)))
})

test_that("handicap_prevalence() : vecteur non nomme => erreur", {
  d <- .make_femmes_genre()
  expect_error(
    handicap_prevalence(d, vars_handicap=c("hand_vis")),
    regexp="nomme")
})

test_that("handicap_prevalence() : variable introuvable => erreur", {
  d <- .make_femmes_genre()
  expect_error(
    handicap_prevalence(d, vars_handicap=c(Test="xxx")),
    regexp="introuvable")
})

# =============================================================================
# BLOC 6 - tableau_genre()
# =============================================================================

test_that("tableau_genre() : retourne tibble", {
  d  <- .make_femmes_genre()
  rm <- suppressMessages(mariage_precoce(d, "marie_18", poids="poids"))
  res <- suppressMessages(
    tableau_genre(list(mariage=rm), pays="RCA", annee=2026L))
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 1L)
})

test_that("tableau_genre() : colonnes attendues", {
  d  <- .make_femmes_genre()
  rm <- suppressMessages(mariage_precoce(d, "marie_18"))
  res <- suppressMessages(
    tableau_genre(list(mariage=rm), pays="RCA"))
  expect_true(all(c("indicateur","code_ref","valeur","pays","annee")
                  %in% names(res)))
})

test_that("tableau_genre() : liste vide => erreur", {
  expect_error(tableau_genre(list()), regexp="non vide")
})

test_that("tableau_genre() : avec violence_basee_genre", {
  d    <- .make_femmes_genre()
  rvbg <- violence_basee_genre(d, var_violence_physique="vbg_phys")
  res  <- suppressMessages(
    tableau_genre(list(vbg=rvbg), pays="RCA"))
  expect_equal(nrow(res), 1L)
})
