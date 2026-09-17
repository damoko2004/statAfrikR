# =============================================================================
# statAfrikR - Tests module Harmonisation referentiels geographiques
# testthat edition 3
# =============================================================================

.make_zones_rca <- function() {
  data.frame(
    nom_zone  = c("Bangui","Ombella-M'Poko","Bamingui-Bangoran",
                   "Mbomou","Haute-Kotto","Kemo","Nana-Gribizi"),
    code_ins  = c("01","02","03","04","05","06","07"),
    code_iso  = c("CF-BGF","CF-MP","CF-BB","CF-MB","CF-HK","CF-KG","CF-NG"),
    niveau    = rep(1L, 7),
    pays      = rep("CAF", 7),
    stringsAsFactors = FALSE
  )
}

.make_concordance <- function() {
  suppressMessages(
    table_concordance(.make_zones_rca(), "nom_zone",
                       var_code_ins="code_ins", var_code_iso="code_iso",
                       var_niveau="niveau", var_pays="pays"))
}

.make_donnees <- function() {
  data.frame(
    region = c("Bangui","Ombella-Mpoko","KEMO","Zone inconnue","Mbomou"),
    valeur = c(100, 200, 150, 80, 120),
    stringsAsFactors = FALSE
  )
}

# =============================================================================
# BLOC 1 - table_concordance()
# =============================================================================

test_that("table_concordance() : retourne saf_concordance", {
  res <- .make_concordance()
  expect_s3_class(res, "saf_concordance")
})

test_that("table_concordance() : n_zones correct", {
  res <- .make_concordance()
  expect_equal(res$n_zones, 7L)
})

test_that("table_concordance() : colonnes nom_local et code_ins", {
  res <- .make_concordance()
  expect_true("nom_local"     %in% names(res$concordance))
  expect_true("code_ins"      %in% names(res$concordance))
  expect_true("nom_normalise" %in% names(res$concordance))
})

test_that("table_concordance() : variable introuvable => erreur", {
  d <- .make_zones_rca()
  expect_error(table_concordance(d, "xxx"), regexp="introuvable")
})

test_that("table_concordance() : donnees vides => erreur", {
  expect_error(table_concordance(data.frame(), "x"), regexp="non vide")
})

test_that("table_concordance() : print sans erreur", {
  res <- .make_concordance()
  expect_output(print(res), "concordance")
})

# =============================================================================
# BLOC 2 - harmoniser_zones()
# =============================================================================

test_that("harmoniser_zones() : retourne data.frame enrichi", {
  d   <- .make_donnees()
  res <- suppressMessages(harmoniser_zones(d, "region"))
  expect_true("region_normalise" %in% names(res))
  expect_equal(nrow(res), nrow(d))
})

test_that("harmoniser_zones() : normalise en minuscules", {
  d   <- .make_donnees()
  res <- suppressMessages(harmoniser_zones(d, "region"))
  expect_true(all(res$region_normalise == tolower(
    gsub("[^a-zA-Z0-9 -]", "", res$region_normalise))))
})

test_that("harmoniser_zones() : avec reference", {
  d    <- .make_donnees()
  conc <- .make_concordance()
  res  <- suppressMessages(
    harmoniser_zones(d, "region", reference=conc))
  expect_true("region_ref" %in% names(res))
})

test_that("harmoniser_zones() : variable introuvable => erreur", {
  d <- .make_donnees()
  expect_error(harmoniser_zones(d, "xxx"), regexp="introuvable")
})

test_that("harmoniser_zones() : donnees vides => erreur", {
  expect_error(harmoniser_zones(data.frame(), "x"), regexp="non vide")
})

# =============================================================================
# BLOC 3 - detecter_ecarts_geo()
# =============================================================================

test_that("detecter_ecarts_geo() : retourne liste", {
  d    <- .make_donnees()
  ref  <- .make_zones_rca()
  res  <- suppressMessages(
    detecter_ecarts_geo(d, "region", ref, "nom_zone"))
  expect_true(is.list(res))
  expect_true(all(c("appariees","non_appariees","suggestions",
                     "taux_appariement") %in% names(res)))
})

test_that("detecter_ecarts_geo() : detecte zones non appariees", {
  d    <- .make_donnees()
  ref  <- .make_zones_rca()
  res  <- suppressMessages(
    detecter_ecarts_geo(d, "region", ref, "nom_zone"))
  expect_gt(length(res$non_appariees), 0L)
})

test_that("detecter_ecarts_geo() : taux entre 0 et 100", {
  d    <- .make_donnees()
  ref  <- .make_zones_rca()
  res  <- suppressMessages(
    detecter_ecarts_geo(d, "region", ref, "nom_zone"))
  expect_gte(res$taux_appariement, 0)
  expect_lte(res$taux_appariement, 100)
})

test_that("detecter_ecarts_geo() : avec saf_concordance", {
  d    <- .make_donnees()
  conc <- .make_concordance()
  res  <- suppressMessages(
    detecter_ecarts_geo(d, "region", conc))
  expect_true(is.list(res))
})

test_that("detecter_ecarts_geo() : variable introuvable => erreur", {
  d   <- .make_donnees()
  ref <- .make_zones_rca()
  expect_error(detecter_ecarts_geo(d,"xxx",ref,"nom_zone"),regexp="introuvable")
})

# =============================================================================
# BLOC 4 - migrer_nomenclature()
# =============================================================================

test_that("migrer_nomenclature() : retourne data.frame", {
  d    <- .make_donnees()
  conc <- .make_concordance()
  res  <- suppressMessages(
    migrer_nomenclature(d, "region", conc,
                         var_source="nom_local", var_cible="code_iso"))
  expect_s3_class(res, "data.frame")
  expect_true("zone_harmonisee" %in% names(res))
})

test_that("migrer_nomenclature() : zones appariees converties", {
  d    <- data.frame(zone=c("Bangui","Mbomou"), stringsAsFactors=FALSE)
  conc <- .make_concordance()
  res  <- suppressMessages(
    migrer_nomenclature(d, "zone", conc,
                         var_source="nom_local", var_cible="code_iso"))
  expect_equal(res$zone_harmonisee[1], "CF-BGF")
})

test_that("migrer_nomenclature() : variable introuvable => erreur", {
  d    <- .make_donnees()
  conc <- .make_concordance()
  expect_error(
    migrer_nomenclature(d,"xxx",conc),
    regexp="introuvable")
})

test_that("migrer_nomenclature() : sans conserver non-apparies", {
  d    <- .make_donnees()
  conc <- .make_concordance()
  res  <- suppressMessages(
    migrer_nomenclature(d, "region", conc,
                         var_source="nom_local", var_cible="code_iso",
                         conserver_non_apparies=FALSE))
  expect_lt(nrow(res), nrow(d))
})

# =============================================================================
# BLOC 5 - valider_coherence_geo()
# =============================================================================

test_that("valider_coherence_geo() : retourne tibble", {
  d    <- .make_donnees()
  ref  <- .make_zones_rca()
  res  <- suppressMessages(
    valider_coherence_geo(d, "region", ref, "nom_zone"))
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 5L)
})

test_that("valider_coherence_geo() : detecte zones manquantes", {
  d    <- data.frame(region=c("Bangui"), stringsAsFactors=FALSE)
  ref  <- .make_zones_rca()
  res  <- suppressMessages(
    valider_coherence_geo(d, "region", ref, "nom_zone"))
  manquantes <- res$valeur[res$critere == "Zones manquantes dans les donnees"]
  expect_gt(manquantes, 0L)
})

test_that("valider_coherence_geo() : variable introuvable => erreur", {
  d   <- .make_donnees()
  ref <- .make_zones_rca()
  expect_error(
    valider_coherence_geo(d,"xxx",ref,"nom_zone"),
    regexp="introuvable")
})

# =============================================================================
# BLOC 6 - rapport_harmonisation()
# =============================================================================

test_that("rapport_harmonisation() : retourne tibble", {
  d    <- .make_donnees()
  ref  <- .make_zones_rca()
  res  <- suppressMessages(
    rapport_harmonisation(d, "region", ref, var_ref="nom_zone", pays="RCA", annee=2026L))
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 4L)
})

test_that("rapport_harmonisation() : colonnes attendues", {
  d    <- .make_donnees()
  ref  <- .make_zones_rca()
  res  <- suppressMessages(
    rapport_harmonisation(d, "region", ref, var_ref="nom_zone", pays="RCA"))
  expect_true(all(c("indicateur","valeur","statut","pays","annee")
                  %in% names(res)))
})

test_that("rapport_harmonisation() : variable introuvable => erreur", {
  d    <- .make_donnees()
  ref  <- .make_zones_rca()
  expect_error(rapport_harmonisation(d,"xxx",ref), regexp="introuvable")
})

test_that("rapport_harmonisation() : taux appariement present", {
  d    <- .make_donnees()
  ref  <- .make_zones_rca()
  res  <- suppressMessages(rapport_harmonisation(d,"region",ref,var_ref="nom_zone",pays="RCA"))
  taux <- res$valeur[grepl("Taux", res$indicateur)]
  expect_gte(taux, 0)
  expect_lte(taux, 100)
})
