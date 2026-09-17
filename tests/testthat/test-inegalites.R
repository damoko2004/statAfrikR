# =============================================================================
# statAfrikR - Tests module Inegalites
# testthat edition 3
# =============================================================================

.make_df <- function(n = 300, seed = 42) {
  set.seed(seed)
  data.frame(
    depense = c(rexp(round(n*0.7), 1/150000),
                rexp(round(n*0.3), 1/500000)),
    milieu  = sample(c("urbain","rural"), n, TRUE),
    region  = sample(paste0("R", 1:5), n, TRUE),
    poids   = runif(n, 0.8, 1.3),
    stringsAsFactors = FALSE
  )
}

# =============================================================================
# BLOC 1 - calcul_gini()
# =============================================================================

test_that("calcul_gini() : retourne saf_gini", {
  d <- .make_df()
  res <- calcul_gini(d, "depense", poids="poids")
  expect_s3_class(res, "saf_gini")
})

test_that("calcul_gini() : Gini entre 0 et 1", {
  d <- .make_df()
  res <- calcul_gini(d, "depense", poids="poids")
  expect_gte(res$gini, 0)
  expect_lte(res$gini, 1)
})

test_that("calcul_gini() : distribution egale => Gini proche de 0", {
  d <- data.frame(depense=rep(100000, 100), poids=rep(1,100))
  res <- calcul_gini(d, "depense")
  expect_lte(res$gini, 0.01)
})

test_that("calcul_gini() : variable introuvable => erreur", {
  d <- .make_df()
  expect_error(calcul_gini(d, "xxx"), regexp="introuvable")
})

test_that("calcul_gini() : donnees vides => erreur", {
  expect_error(calcul_gini(data.frame(), "x"), regexp="non vide")
})

test_that("calcul_gini() : poids introuvable => erreur", {
  d <- .make_df()
  expect_error(calcul_gini(d, "depense", poids="xxx"), regexp="introuvable")
})

test_that("calcul_gini() : avec IC bootstrap", {
  d <- .make_df(100)
  res <- calcul_gini(d, "depense", poids="poids",
                     ic=TRUE, n_bootstrap=50L)
  expect_false(is.null(res$ic))
  expect_length(res$ic, 2L)
  expect_lte(res$ic[1], res$ic[2])
})

test_that("calcul_gini() : avec sous_groupes", {
  d <- .make_df()
  res <- calcul_gini(d, "depense", poids="poids",
                     sous_groupes="milieu")
  expect_false(is.null(res$decomposition))
  expect_equal(nrow(res$decomposition), 2L)
})

test_that("calcul_gini() : print sans erreur", {
  d <- .make_df()
  res <- calcul_gini(d, "depense")
  expect_output(print(res), "Gini")
})

test_that("calcul_gini() : sans poids fonctionne", {
  d <- .make_df(100)
  res <- calcul_gini(d, "depense")
  expect_s3_class(res, "saf_gini")
})

test_that("calcul_gini() : interpretation presente", {
  d <- .make_df()
  res <- calcul_gini(d, "depense", poids="poids")
  expect_true(nchar(res$interpretation) > 0)
})

test_that("calcul_gini() : inegalite plus forte => Gini plus eleve", {
  set.seed(42)
  d1 <- data.frame(depense=rnorm(200,200000,20000),  poids=rep(1,200))
  d2 <- data.frame(depense=c(rexp(150,1/100000),rexp(50,1/800000)),
                   poids=rep(1,200))
  r1 <- calcul_gini(d1, "depense")
  r2 <- calcul_gini(d2, "depense")
  expect_lt(r1$gini, r2$gini)
})

# =============================================================================
# BLOC 2 - courbe_lorenz()
# =============================================================================

test_that("courbe_lorenz() : retourne ggplot", {
  d <- .make_df()
  g <- courbe_lorenz(d, "depense", poids="poids")
  expect_s3_class(g, "ggplot")
})

test_that("courbe_lorenz() : avec groupe", {
  d <- .make_df()
  g <- courbe_lorenz(d, "depense", poids="poids", var_groupe="milieu")
  expect_s3_class(g, "ggplot")
})

test_that("courbe_lorenz() : variable introuvable => erreur", {
  d <- .make_df()
  expect_error(courbe_lorenz(d, "xxx"), regexp="introuvable")
})

test_that("courbe_lorenz() : avec titre et source", {
  d <- .make_df(100)
  g <- courbe_lorenz(d, "depense", titre="Test", source="INS")
  expect_s3_class(g, "ggplot")
})

# =============================================================================
# BLOC 3 - part_quintile()
# =============================================================================

test_that("part_quintile() : 5 quintiles par defaut", {
  d <- .make_df()
  res <- suppressMessages(part_quintile(d, "depense", poids="poids"))
  expect_equal(nrow(res), 5L)
})

test_that("part_quintile() : 10 deciles", {
  d <- .make_df()
  res <- suppressMessages(part_quintile(d, "depense", poids="poids",
                                         n_groupes=10L))
  expect_equal(nrow(res), 10L)
})

test_that("part_quintile() : somme parts = 100%", {
  d <- .make_df()
  res <- suppressMessages(part_quintile(d, "depense", poids="poids"))
  expect_equal(sum(res$part_revenu), 100, tolerance=0.5)
})

test_that("part_quintile() : Q1 < Q5 (croissance)", {
  d <- .make_df()
  res <- suppressMessages(part_quintile(d, "depense"))
  expect_lt(res$part_revenu[1], res$part_revenu[5])
})

test_that("part_quintile() : ratios Palma presents", {
  d <- .make_df()
  res <- suppressMessages(part_quintile(d, "depense", poids="poids"))
  r   <- attr(res, "ratios")
  expect_false(is.null(r))
  expect_true("Palma" %in% names(r))
  expect_true("Q5_Q1" %in% names(r))
})

test_that("part_quintile() : n_groupes invalide => erreur", {
  d <- .make_df()
  expect_error(suppressMessages(
    part_quintile(d, "depense", n_groupes=7L)), regexp="5.*10")
})

# =============================================================================
# BLOC 4 - indice_palma()
# =============================================================================

test_that("indice_palma() : retourne numerique positif", {
  d <- .make_df()
  res <- suppressMessages(indice_palma(d, "depense", poids="poids"))
  expect_true(is.numeric(res))
  expect_gt(res, 0)
})

test_that("palma() alias fonctionne", {
  d <- .make_df(100)
  res <- suppressMessages(palma(d, "depense"))
  expect_true(is.numeric(res))
})

# =============================================================================
# BLOC 5 - decomposer_theil()
# =============================================================================

test_that("decomposer_theil() : retourne saf_theil", {
  d <- .make_df()
  res <- suppressMessages(
    decomposer_theil(d, "depense", "milieu", poids="poids"))
  expect_s3_class(res, "saf_theil")
})

test_that("decomposer_theil() : inter + intra = total", {
  d <- .make_df()
  res <- suppressMessages(
    decomposer_theil(d, "depense", "milieu", poids="poids"))
  expect_equal(res$theil_inter + res$theil_intra, res$theil_total,
               tolerance=1e-6)
})

test_that("decomposer_theil() : 2 groupes milieu", {
  d <- .make_df()
  res <- suppressMessages(
    decomposer_theil(d, "depense", "milieu", poids="poids"))
  expect_equal(nrow(res$par_groupe), 2L)
})

test_that("decomposer_theil() : print sans erreur", {
  d <- .make_df()
  res <- suppressMessages(
    decomposer_theil(d, "depense", "milieu", poids="poids"))
  expect_output(print(res), "Theil")
})

test_that("decomposer_theil() : variable manquante => erreur", {
  d <- .make_df()
  expect_error(decomposer_theil(d, "xxx", "milieu"), regexp="revenu")
  expect_error(decomposer_theil(d, "depense", "xxx"), regexp="groupe")
})

test_that("theil() alias fonctionne", {
  d <- .make_df(150)
  res <- suppressMessages(theil(d, "depense", "milieu"))
  expect_s3_class(res, "saf_theil")
})

# =============================================================================
# BLOC 6 - indice_atkinson()
# =============================================================================

test_that("indice_atkinson() : entre 0 et 1", {
  d <- .make_df()
  res <- suppressMessages(indice_atkinson(d, "depense", poids="poids"))
  expect_gte(res, 0)
  expect_lte(res, 1)
})

test_that("indice_atkinson() : distribution egale => proche de 0", {
  d <- data.frame(depense=rep(200000,100), poids=rep(1,100))
  res <- suppressMessages(indice_atkinson(d, "depense", epsilon=1))
  expect_lte(res, 0.01)
})

test_that("indice_atkinson() : epsilon invalide => erreur", {
  d <- .make_df(50)
  expect_error(indice_atkinson(d, "depense", epsilon=-1),
               regexp="positif")
})

test_that("atkinson() alias fonctionne", {
  d <- .make_df(100)
  res <- suppressMessages(atkinson(d, "depense"))
  expect_true(is.numeric(res))
})

test_that("indice_atkinson() : epsilon plus grand => Atkinson plus grand", {
  d <- .make_df(200)
  r1 <- suppressMessages(indice_atkinson(d, "depense", epsilon=0.5))
  r2 <- suppressMessages(indice_atkinson(d, "depense", epsilon=2.0))
  expect_lte(r1, r2)
})

# =============================================================================
# BLOC 7 - tableau_inegalites()
# =============================================================================

test_that("tableau_inegalites() : retourne tibble", {
  d <- .make_df()
  res <- suppressMessages(
    tableau_inegalites(d, "depense", poids="poids",
                       pays="RCA", annee=2026L))
  expect_s3_class(res, "data.frame")
})

test_that("tableau_inegalites() : 7 indicateurs", {
  d <- .make_df()
  res <- suppressMessages(
    tableau_inegalites(d, "depense", poids="poids"))
  expect_equal(nrow(res), 7L)
})

test_that("tableau_inegalites() : colonnes attendues", {
  d <- .make_df()
  res <- suppressMessages(
    tableau_inegalites(d, "depense", poids="poids"))
  expect_true(all(c("indicateur","valeur","interpretation") %in% names(res)))
})

test_that("tableau_inegalites() : sans poids fonctionne", {
  d <- .make_df(100)
  res <- suppressMessages(tableau_inegalites(d, "depense"))
  expect_equal(nrow(res), 7L)
})
