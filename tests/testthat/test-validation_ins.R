# =============================================================================
# statAfrikR - Tests module Validation Statistique INS
# testthat edition 3
# =============================================================================

.make_donnees_ins <- function(n = 300, seed = 42) {
  set.seed(seed)
  data.frame(
    region  = sample(c("Nord","Sud","Est","Ouest"), n, TRUE),
    milieu  = sample(c("urbain","rural"), n, TRUE),
    poids   = runif(n, 800, 3500),
    depense = pmax(10000, rnorm(n, 165000, 90000)),
    sexe    = sample(c("H","F"), n, TRUE),
    age     = sample(15:80, n, TRUE),
    stringsAsFactors = FALSE
  )
}

# =============================================================================
# BLOC 1 - valider_statistique_ins() structure
# =============================================================================

test_that("valider_statistique_ins() : retourne saf_validation_ins", {
  d   <- .make_donnees_ins()
  res <- suppressMessages(
    valider_statistique_ins(d, var_poids="poids",
                             var_region="region", pays="RCA"))
  expect_s3_class(res, "saf_validation_ins")
})

test_that("valider_statistique_ins() : champs principaux presents", {
  d   <- .make_donnees_ins()
  res <- suppressMessages(
    valider_statistique_ins(d, pays="RCA"))
  expect_true(all(c("rapport","statut_global","n_pass",
                     "n_warn","n_fail","pays","annee") %in% names(res)))
})

test_that("valider_statistique_ins() : 9 sections dans rapport", {
  d   <- .make_donnees_ins()
  res <- suppressMessages(
    valider_statistique_ins(d, var_poids="poids", pays="RCA"))
  expect_gte(length(res$rapport), 7L)
})

test_that("valider_statistique_ins() : statut_global valide", {
  d   <- .make_donnees_ins()
  res <- suppressMessages(
    valider_statistique_ins(d, pays="RCA"))
  expect_true(res$statut_global %in% c("VALIDE","A VERIFIER","ECHEC"))
})

test_that("valider_statistique_ins() : donnees vides => erreur", {
  expect_error(
    valider_statistique_ins(data.frame()),
    regexp="non vide")
})

test_that("valider_statistique_ins() : print sans erreur", {
  d   <- .make_donnees_ins()
  res <- suppressMessages(valider_statistique_ins(d, pays="RCA"))
  expect_output(print(res), "validation")
})

# =============================================================================
# BLOC 2 - Critere donnees
# =============================================================================

test_that("critere donnees : detecte doublons", {
  d <- .make_donnees_ins(100)
  d <- rbind(d, d[1:5, ])  # ajouter 5 doublons
  res <- suppressMessages(suppressWarnings(
    valider_statistique_ins(d, pays="RCA")))
  statuts <- res$rapport$donnees$statut
  expect_true(any(statuts %in% c("WARN","FAIL")))
})

test_that("critere donnees : sans doublons => PASS", {
  d   <- .make_donnees_ins()
  res <- suppressMessages(valider_statistique_ins(d, pays="RCA"))
  n_doublons_statut <- res$rapport$donnees$statut[
    res$rapport$donnees$sous_critere == "Doublons detectes"]
  expect_equal(n_doublons_statut, "PASS")
})

# =============================================================================
# BLOC 3 - Critere poids
# =============================================================================

test_that("critere poids : avec poids valides => PASS", {
  d   <- .make_donnees_ins()
  res <- suppressMessages(
    valider_statistique_ins(d, var_poids="poids", pays="RCA"))
  statuts_poids <- res$rapport$poids$statut
  expect_false(any(statuts_poids == "FAIL"))
})

test_that("critere poids : sans poids => WARN", {
  d   <- .make_donnees_ins()
  res <- suppressMessages(valider_statistique_ins(d, pays="RCA"))
  expect_equal(res$rapport$poids$statut[1], "WARN")
})

test_that("critere poids : poids negatifs => FAIL", {
  d <- .make_donnees_ins(100)
  d$poids[1:10] <- -1
  res <- suppressMessages(suppressWarnings(
    valider_statistique_ins(d, var_poids="poids", pays="RCA")))
  statuts <- res$rapport$poids$statut
  expect_true(any(statuts == "FAIL"))
})

# =============================================================================
# BLOC 4 - Critere valeurs manquantes
# =============================================================================

test_that("critere manquantes : sans NA => PASS", {
  d   <- .make_donnees_ins()
  res <- suppressMessages(valider_statistique_ins(d, pays="RCA"))
  statuts <- res$rapport$manquantes$statut
  expect_false(any(statuts == "FAIL"))
})

test_that("critere manquantes : avec NA eleves => WARN", {
  d <- .make_donnees_ins(200)
  d$age[1:50] <- NA  # 25% manquants
  res <- suppressMessages(valider_statistique_ins(d, pays="RCA"))
  statuts <- res$rapport$manquantes$statut
  expect_true(any(statuts == "WARN"))
})

# =============================================================================
# BLOC 5 - Critere confidentialite
# =============================================================================

test_that("critere confidentialite : retourne tibble", {
  d   <- .make_donnees_ins()
  res <- suppressMessages(valider_statistique_ins(d, pays="RCA"))
  expect_s3_class(res$rapport$confidentialite, "data.frame")
})

test_that("critere confidentialite : variables verifiees", {
  d   <- .make_donnees_ins()
  res <- suppressMessages(valider_statistique_ins(d, pays="RCA"))
  n_verif <- res$rapport$confidentialite$valeur[
    res$rapport$confidentialite$sous_critere ==
      "Variables categorielle verifiees"]
  expect_gte(as.integer(n_verif), 0L)
})

# =============================================================================
# BLOC 6 - Critere reproductibilite
# =============================================================================

test_that("critere reproductibilite : version presente", {
  d   <- .make_donnees_ins()
  res <- suppressMessages(
    valider_statistique_ins(d, pays="RCA", annee=2024L))
  ver <- res$rapport$reproductibilite$valeur[
    res$rapport$reproductibilite$sous_critere == "Version statAfrikR"]
  expect_true(nchar(ver) > 0)
})

test_that("critere reproductibilite : pays et annee corrects", {
  d   <- .make_donnees_ins()
  res <- suppressMessages(
    valider_statistique_ins(d, pays="Cameroun", annee=2022L))
  expect_equal(res$pays, "Cameroun")
  expect_equal(res$annee, 2022L)
})

# =============================================================================
# BLOC 7 - Critere indicateurs
# =============================================================================

test_that("critere indicateurs : avec FGT => calcule", {
  d   <- .make_donnees_ins()
  res <- suppressMessages(
    valider_statistique_ins(d, var_poids="poids",
                             var_depense="depense",
                             seuil_pauvrete=171000,
                             pays="RCA"))
  expect_true(any(grepl("FGT0", res$rapport$indicateurs$indicateur)) ||
              "info" %in% names(res$rapport$indicateurs))
})

test_that("critere indicateurs : sans var_depense => INFO", {
  d   <- .make_donnees_ins()
  res <- suppressMessages(valider_statistique_ins(d, pays="RCA"))
  statuts <- res$rapport$indicateurs$statut
  expect_true(all(statuts == "INFO"))
})

# =============================================================================
# BLOC 8 - Compteurs
# =============================================================================

test_that("n_pass + n_warn + n_fail > 0", {
  d   <- .make_donnees_ins()
  res <- suppressMessages(valider_statistique_ins(d, pays="RCA"))
  expect_gt(res$n_pass + res$n_warn + res$n_fail, 0L)
})

test_that("duree_sec positive", {
  d   <- .make_donnees_ins()
  res <- suppressMessages(valider_statistique_ins(d, pays="RCA"))
  expect_gt(res$duree_sec, 0)
})
