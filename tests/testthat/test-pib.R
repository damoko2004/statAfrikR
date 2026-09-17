# =============================================================================
# statAfrikR - Tests module PIB & Comptes nationaux
# testthat edition 3
# =============================================================================

.make_comptes <- function() {
  data.frame(
    annee       = 2015:2022,
    pib_courant = c(2100,2180,2250,2310,2195,2280,2380,2450),
    pib_cst     = c(2000,2055,2108,2155,2080,2140,2210,2265),
    deflateur   = c(100,103.2,106.8,110.5,109.2,113.5,118.2,122.8),
    agri        = c(420,438,452,464,440,456,474,490),
    indus       = c(630,655,678,695,660,684,714,735),
    services    = c(1050,1062,1118,1151,1095,1140,1192,1225),
    stringsAsFactors = FALSE
  )
}

.make_revisions <- function() {
  data.frame(
    annee   = rep(2019:2022, each=3),
    version = rep(c("preliminaire","provisoire","definitif"), 4),
    valeur  = c(2210,2225,2240, 2320,2335,2348,
                2415,2430,NA,   2510,NA,NA),
    stringsAsFactors = FALSE
  )
}

# =============================================================================
# BLOC 1 - comparer_pib()
# =============================================================================

test_that("comparer_pib() : retourne saf_pib", {
  res <- suppressWarnings(suppressMessages(
    comparer_pib(2450.5, c(UNSD=2380.2, BM=2412.8),
                 pays="Cameroun", annee=2023L)))
  expect_s3_class(res, "saf_pib")
})

test_that("comparer_pib() : ecarts calcules correctement", {
  res <- suppressWarnings(suppressMessages(
    comparer_pib(2450.5, c(UNSD=2380.2),
                 pays="Cameroun", annee=2023L)))
  ecart_attendu <- (2450.5 - 2380.2) / 2380.2 * 100
  expect_equal(unname(res$comparaisons$ecart_pct[1]),
               round(ecart_attendu, 2))
})

test_that("comparer_pib() : pib_ins negatif => erreur", {
  expect_error(comparer_pib(-100, c(UNSD=200)), regexp="positif")
})

test_that("comparer_pib() : pib_intl non nomme => erreur", {
  expect_error(comparer_pib(2000, c(200, 210)), regexp="nomme")
})

test_that("comparer_pib() : n_alertes compte les gros ecarts", {
  res <- suppressWarnings(suppressMessages(
    comparer_pib(2000, c(UNSD=1800, BM=1950),
                 seuil_alerte=5.0)))
  expect_equal(res$n_alertes, 1L)
})

test_that("comparer_pib() : print sans erreur", {
  res <- suppressWarnings(suppressMessages(
    comparer_pib(2000, c(UNSD=1980), pays="RCA")))
  expect_output(print(res), "PIB")
})

test_that("comparer_pib() : colonnes comparaisons correctes", {
  res <- suppressWarnings(suppressMessages(
    comparer_pib(2000, c(UNSD=1980, BM=2010), pays="RCA")))
  expect_true(all(c("source_intl","ecart_pct","alerte","cause_probable")
                  %in% names(res$comparaisons)))
  expect_equal(nrow(res$comparaisons), 2L)
})

# =============================================================================
# BLOC 2 - suivre_revisions_pib()
# =============================================================================

test_that("suivre_revisions_pib() : retourne saf_revision_pib", {
  d   <- .make_revisions()
  res <- suppressMessages(suivre_revisions_pib(d, pays="Cameroun"))
  expect_s3_class(res, "saf_revision_pib")
})

test_that("suivre_revisions_pib() : revisions contient 4 annees", {
  d   <- .make_revisions()
  res <- suppressMessages(suivre_revisions_pib(d))
  expect_equal(nrow(res$revisions), 4L)
})

test_that("suivre_revisions_pib() : graphique produit", {
  d   <- .make_revisions()
  res <- suppressMessages(suivre_revisions_pib(d))
  expect_s3_class(res$graphique, "ggplot")
})

test_that("suivre_revisions_pib() : variable manquante => erreur", {
  d <- .make_revisions()
  expect_error(suivre_revisions_pib(d, var_valeur="xxx"),
               regexp="introuvable")
})

test_that("suivre_revisions_pib() : revisions definitives NA pour annees recentes", {
  d   <- .make_revisions()
  res <- suppressMessages(suivre_revisions_pib(d))
  expect_true(is.na(res$revisions$definitif[3]))
})

# =============================================================================
# BLOC 3 - calculer_deflateur()
# =============================================================================

test_that("calculer_deflateur() : retourne tibble", {
  d   <- .make_comptes()
  res <- suppressMessages(
    calculer_deflateur(d, "pib_courant",
                        var_deflateur="deflateur",
                        annee_base=2015L))
  expect_s3_class(res, "data.frame")
})

test_that("calculer_deflateur() : pib_constant calcule", {
  d   <- .make_comptes()
  res <- suppressMessages(
    calculer_deflateur(d, "pib_courant",
                        var_deflateur="deflateur",
                        annee_base=2015L,
                        var_annee="annee"))
  expect_true("pib_constant" %in% names(res))
  expect_true("croissance_reelle_pct" %in% names(res))
})

test_that("calculer_deflateur() : annee_base deflateur = 100", {
  d   <- .make_comptes()
  res <- suppressMessages(
    calculer_deflateur(d, "pib_courant",
                        var_deflateur="deflateur",
                        annee_base=2015L, var_annee="annee"))
  defl_base <- res$deflateur[res$annee == 2015]
  expect_equal(defl_base, 100, tolerance=0.01)
})

test_that("calculer_deflateur() : variable introuvable => erreur", {
  d <- .make_comptes()
  expect_error(calculer_deflateur(d, "xxx", var_deflateur="deflateur"),
               regexp="introuvable")
})

test_that("calculer_deflateur() : ni deflateur ni ipc => erreur", {
  d <- .make_comptes()
  expect_error(calculer_deflateur(d, "pib_courant"),
               regexp="var_deflateur")
})

test_that("calculer_deflateur() : avec IPC au lieu de deflateur", {
  d   <- .make_comptes()
  res <- suppressMessages(
    calculer_deflateur(d, "pib_courant",
                        var_ipc="deflateur",
                        annee_base=2015L, var_annee="annee"))
  expect_true("pib_constant" %in% names(res))
})

# =============================================================================
# BLOC 4 - taux_croissance()
# =============================================================================

test_that("taux_croissance() : retourne tibble", {
  d   <- .make_comptes()
  res <- suppressMessages(taux_croissance(d, "pib_courant"))
  expect_s3_class(res, "data.frame")
})

test_that("taux_croissance() : premiere annee NA", {
  d   <- .make_comptes()
  res <- suppressMessages(taux_croissance(d, "pib_courant"))
  expect_true(is.na(res$croissance_pct[1]))
})

test_that("taux_croissance() : taux calcule correctement", {
  d   <- .make_comptes()
  res <- suppressMessages(taux_croissance(d, "pib_courant"))
  attendu <- (2180 - 2100) / 2100 * 100
  expect_equal(res$croissance_pct[2], round(attendu, 2))
})

test_that("taux_croissance() : avec contributions sectorielles", {
  d   <- .make_comptes()
  res <- suppressMessages(
    taux_croissance(d, "pib_courant",
                    vars_secteurs=c(Agriculture="agri",
                                    Industrie="indus"),
                    var_annee="annee"))
  expect_true("contrib_Agriculture" %in% names(res))
  expect_true("contrib_Industrie"   %in% names(res))
})

test_that("taux_croissance() : variable PIB introuvable => erreur", {
  d <- .make_comptes()
  expect_error(taux_croissance(d, "xxx"), regexp="introuvable")
})

# =============================================================================
# BLOC 5 - tableau_bord_pib()
# =============================================================================

test_that("tableau_bord_pib() : retourne tibble", {
  d   <- .make_comptes()
  res <- suppressMessages(
    tableau_bord_pib(d, "pib_courant", pays="Cameroun"))
  expect_s3_class(res, "data.frame")
})

test_that("tableau_bord_pib() : 8 periodes", {
  d   <- .make_comptes()
  res <- suppressMessages(
    tableau_bord_pib(d, "pib_courant"))
  expect_equal(nrow(res), 8L)
})

test_that("tableau_bord_pib() : avec pib constant", {
  d   <- .make_comptes()
  res <- suppressMessages(
    tableau_bord_pib(d, "pib_courant",
                     var_pib_constant="pib_cst"))
  expect_true("croissance_reel" %in% names(res))
  expect_true("deflateur"       %in% names(res))
})

test_that("tableau_bord_pib() : variable introuvable => erreur", {
  d <- .make_comptes()
  expect_error(tableau_bord_pib(d, "xxx"), regexp="introuvable")
})

test_that("tableau_bord_pib() : avec parts sectorielles", {
  d   <- .make_comptes()
  res <- suppressMessages(
    tableau_bord_pib(d, "pib_courant",
                     vars_secteurs=c(Agri="agri", Ind="indus")))
  expect_true("part_Agri_pct" %in% names(res))
})
