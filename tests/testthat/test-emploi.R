# =============================================================================
# statAfrikR - Tests module Emploi etendu & Travail decent
# testthat edition 3
# =============================================================================

.make_individus <- function(n = 500, seed = 42) {
  set.seed(seed)
  data.frame(
    actif          = rbinom(n, 1, 0.65),
    employe        = rbinom(n, 1, 0.55),
    chomeur        = rbinom(n, 1, 0.14),
    informel       = rbinom(n, 1, 0.72),
    vulnerable     = rbinom(n, 1, 0.55),
    sous_emp_t     = rbinom(n, 1, 0.08),
    actif_pot      = rbinom(n, 1, 0.05),
    heures_trav    = pmax(0, rnorm(n, 38, 15)),
    revenu         = pmax(10000, rnorm(n, 180000, 90000)),
    retraite       = rbinom(n, 1, 0.18),
    assur_maladie  = rbinom(n, 1, 0.22),
    travail_enf    = rbinom(n, 1, 0.22),
    age            = sample(15:64, n, TRUE),
    age_enf        = sample(5:17,  n, TRUE),
    sexe           = sample(c("H","F"), n, TRUE),
    milieu         = sample(c("urbain","rural"), n, TRUE),
    poids          = runif(n, 0.8, 1.3),
    stringsAsFactors = FALSE
  )
}

# =============================================================================
# BLOC 1 - taux_activite()
# =============================================================================

test_that("taux_activite() : retourne saf_emploi", {
  d   <- .make_individus()
  res <- suppressMessages(
    taux_activite(d, "actif", poids="poids"))
  expect_s3_class(res, "saf_emploi")
})

test_that("taux_activite() : taux entre 0 et 1", {
  d   <- .make_individus()
  res <- suppressMessages(taux_activite(d, "actif"))
  expect_gte(res$taux, 0)
  expect_lte(res$taux, 1)
})

test_that("taux_activite() : avec filtre age", {
  d   <- .make_individus()
  res <- suppressMessages(
    taux_activite(d, "actif", var_age="age", age_min=15L, age_max=64L))
  expect_s3_class(res, "saf_emploi")
})

test_that("taux_activite() : variable introuvable => erreur", {
  d <- .make_individus()
  expect_error(taux_activite(d, "xxx"), regexp="introuvable")
})

test_that("taux_activite() : donnees vides => erreur", {
  expect_error(taux_activite(data.frame(), "actif"), regexp="non vide")
})

test_that("taux_activite() : avec sous_groupes", {
  d   <- .make_individus()
  res <- suppressMessages(
    taux_activite(d, "actif", poids="poids", sous_groupes="sexe"))
  expect_false(is.null(res$decomposition))
  expect_equal(nrow(res$decomposition), 2L)
})

test_that("taux_activite() : print sans erreur", {
  d   <- .make_individus()
  res <- suppressMessages(taux_activite(d, "actif"))
  expect_output(print(res), "Taux")
})

# =============================================================================
# BLOC 2 - taux_emploi()
# =============================================================================

test_that("taux_emploi() : retourne saf_emploi", {
  d   <- .make_individus()
  res <- suppressMessages(taux_emploi(d, "employe", poids="poids"))
  expect_s3_class(res, "saf_emploi")
})

test_that("taux_emploi() : IC coherent", {
  d   <- .make_individus()
  res <- suppressMessages(taux_emploi(d, "employe"))
  expect_lte(res$ic_bas,  res$taux_pct)
  expect_gte(res$ic_haut, res$taux_pct)
})

test_that("taux_emploi() : poids introuvable => erreur", {
  d <- .make_individus()
  expect_error(taux_emploi(d, "employe", poids="xxx"), regexp="introuvable")
})

# =============================================================================
# BLOC 3 - emploi_informel()
# =============================================================================

test_that("emploi_informel() : retourne saf_emploi", {
  d   <- .make_individus()
  res <- suppressMessages(emploi_informel(d, "informel", poids="poids"))
  expect_s3_class(res, "saf_emploi")
})

test_that("emploi_informel() : taux positif", {
  d   <- .make_individus()
  res <- suppressMessages(emploi_informel(d, "informel"))
  expect_gt(res$taux, 0)
})

test_that("emploi_informel() : avec desagregation milieu", {
  d   <- .make_individus()
  res <- suppressMessages(
    emploi_informel(d, "informel", poids="poids", sous_groupes="milieu"))
  expect_equal(nrow(res$decomposition), 2L)
})

# =============================================================================
# BLOC 4 - sous_emploi_temps()
# =============================================================================

test_that("sous_emploi_temps() : retourne saf_emploi", {
  d   <- .make_individus()
  res <- suppressMessages(
    sous_emploi_temps(d, "heures_trav", seuil_heures=35L))
  expect_s3_class(res, "saf_emploi")
})

test_that("sous_emploi_temps() : seuil 0h => taux=0", {
  d   <- .make_individus()
  res <- suppressMessages(
    sous_emploi_temps(d, "heures_trav", seuil_heures=0L))
  expect_equal(res$taux, 0)
})

test_that("sous_emploi_temps() : seuil plus eleve => plus de sous-emploi", {
  d  <- .make_individus()
  r1 <- suppressMessages(sous_emploi_temps(d,"heures_trav",seuil_heures=20L))
  r2 <- suppressMessages(sous_emploi_temps(d,"heures_trav",seuil_heures=40L))
  expect_lte(r1$taux, r2$taux)
})

test_that("sous_emploi_temps() : variable introuvable => erreur", {
  d <- .make_individus()
  expect_error(sous_emploi_temps(d, "xxx"), regexp="introuvable")
})

# =============================================================================
# BLOC 5 - taux_sous_utilisation()
# =============================================================================

test_that("taux_sous_utilisation() : retourne tibble", {
  d   <- .make_individus()
  res <- suppressMessages(
    taux_sous_utilisation(d, "chomeur",
                           var_sous_emploi_t="sous_emp_t",
                           var_actif_potentiel="actif_pot",
                           poids="poids"))
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 5L)
})

test_that("taux_sous_utilisation() : LU3 >= chomage", {
  d   <- .make_individus()
  res <- suppressMessages(
    taux_sous_utilisation(d, "chomeur",
                           var_sous_emploi_t="sous_emp_t",
                           var_actif_potentiel="actif_pot"))
  chomage <- res$taux_pct[1]
  lu3     <- res$taux_pct[5]
  expect_gte(lu3, chomage)
})

test_that("taux_sous_utilisation() : sans composantes optionnelles", {
  d   <- .make_individus()
  res <- suppressMessages(taux_sous_utilisation(d, "chomeur"))
  expect_s3_class(res, "data.frame")
})

test_that("taux_sous_utilisation() : var chomeur introuvable => erreur", {
  d <- .make_individus()
  expect_error(taux_sous_utilisation(d, "xxx"), regexp="introuvable")
})

# =============================================================================
# BLOC 6 - pauvrete_travail()
# =============================================================================

test_that("pauvrete_travail() : retourne saf_emploi", {
  d   <- .make_individus()
  res <- suppressMessages(
    pauvrete_travail(d, "employe", "revenu",
                     seuil=144800, poids="poids"))
  expect_s3_class(res, "saf_emploi")
})

test_that("pauvrete_travail() : seuil plus eleve => plus de pauvres", {
  d  <- .make_individus()
  r1 <- suppressMessages(
    pauvrete_travail(d,"employe","revenu",seuil=100000))
  r2 <- suppressMessages(
    pauvrete_travail(d,"employe","revenu",seuil=250000))
  expect_lte(r1$taux, r2$taux)
})

test_that("pauvrete_travail() : variable manquante => erreur", {
  d <- .make_individus()
  expect_error(pauvrete_travail(d,"employe","xxx",seuil=144800),
               regexp="introuvable")
})

test_that("pauvrete_travail() : avec desagregation", {
  d   <- .make_individus()
  res <- suppressMessages(
    pauvrete_travail(d, "employe", "revenu", seuil=144800,
                     poids="poids", sous_groupes="milieu"))
  expect_false(is.null(res$decomposition))
})

# =============================================================================
# BLOC 7 - emploi_vulnerable()
# =============================================================================

test_that("emploi_vulnerable() : retourne saf_emploi", {
  d   <- .make_individus()
  res <- suppressMessages(
    emploi_vulnerable(d, "vulnerable", poids="poids"))
  expect_s3_class(res, "saf_emploi")
})

test_that("emploi_vulnerable() : taux entre 0 et 1", {
  d   <- .make_individus()
  res <- suppressMessages(emploi_vulnerable(d, "vulnerable"))
  expect_gte(res$taux, 0)
  expect_lte(res$taux, 1)
})

# =============================================================================
# BLOC 8 - protection_sociale()
# =============================================================================

test_that("protection_sociale() : retourne tibble", {
  d   <- .make_individus()
  res <- suppressMessages(
    protection_sociale(d,
      vars_protection=c(Retraite="retraite",Maladie="assur_maladie"),
      poids="poids"))
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 3L)
})

test_that("protection_sociale() : vecteur non nomme => erreur", {
  d <- .make_individus()
  expect_error(
    protection_sociale(d, vars_protection=c("retraite")),
    regexp="nomme")
})

test_that("protection_sociale() : variable introuvable => erreur", {
  d <- .make_individus()
  expect_error(
    protection_sociale(d, vars_protection=c(Test="xxx")),
    regexp="introuvable")
})

test_that("protection_sociale() : ligne 'au moins un' presente", {
  d   <- .make_individus()
  res <- suppressMessages(
    protection_sociale(d,
      vars_protection=c(Retraite="retraite",Maladie="assur_maladie")))
  expect_true(any(grepl("Au moins", res$type_protection)))
})

# =============================================================================
# BLOC 9 - travail_enfants()
# =============================================================================

test_that("travail_enfants() : retourne saf_emploi", {
  d   <- .make_individus()
  res <- suppressMessages(
    travail_enfants(d, "travail_enf", var_age="age_enf",
                     poids="poids"))
  expect_s3_class(res, "saf_emploi")
})

test_that("travail_enfants() : taux entre 0 et 1", {
  d   <- .make_individus()
  res <- suppressMessages(travail_enfants(d, "travail_enf"))
  expect_gte(res$taux, 0)
  expect_lte(res$taux, 1)
})

test_that("travail_enfants() : avec sous_groupes", {
  d   <- .make_individus()
  res <- suppressMessages(
    travail_enfants(d, "travail_enf", poids="poids",
                     sous_groupes=c("sexe","milieu")))
  expect_false(is.null(res$decomposition))
})

# =============================================================================
# BLOC 10 - tableau_marche_travail()
# =============================================================================

test_that("tableau_marche_travail() : retourne tibble", {
  d  <- .make_individus()
  r1 <- suppressMessages(taux_activite(d,"actif",poids="poids"))
  r2 <- suppressMessages(taux_emploi(d,"employe",poids="poids"))
  res <- suppressMessages(
    tableau_marche_travail(list(activite=r1,emploi=r2),
                            pays="RCA", annee=2026L))
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 2L)
})

test_that("tableau_marche_travail() : colonnes attendues", {
  d  <- .make_individus()
  r1 <- suppressMessages(taux_activite(d, "actif"))
  res <- suppressMessages(
    tableau_marche_travail(list(activite=r1), pays="RCA"))
  expect_true(all(c("indicateur","code_ref","valeur_pct","pays","annee")
                  %in% names(res)))
})

test_that("tableau_marche_travail() : liste vide => erreur", {
  expect_error(tableau_marche_travail(list()), regexp="non vide")
})

test_that("tableau_marche_travail() : avec pauvrete_travail", {
  d  <- .make_individus()
  rp <- suppressMessages(
    pauvrete_travail(d,"employe","revenu",seuil=144800,poids="poids"))
  res <- suppressMessages(
    tableau_marche_travail(list(working_poor=rp), pays="RCA"))
  expect_equal(nrow(res), 1L)
})
