# =============================================================================
# statAfrikR - Tests module Tableaux
# testthat edition 3 - Couverture cible : > 90%
# =============================================================================

# Donnees de test
donnees_test <- local({
  set.seed(2024)
  n <- 300
  data.frame(
    id     = 1:n,
    age    = sample(18:70, n, replace = TRUE),
    revenu = pmax(10000, rnorm(n, 250000, 80000)),
    poids  = runif(n, 0.7, 1.4),
    region = sample(c("Nord", "Sud", "Est", "Ouest"), n, TRUE),
    milieu = sample(c("urbain", "rural"), n, TRUE, prob = c(0.4, 0.6)),
    sexe   = sample(c("H", "F"), n, TRUE, prob = c(0.52, 0.48))
  )
})

# =============================================================================
# BLOC 1 - tableau_descriptif() : format tibble
# =============================================================================

test_that("tableau_descriptif() : retourne un tibble valide", {
  res <- tableau_descriptif(donnees_test, vars = c("age", "revenu"))
  expect_s3_class(res, "data.frame")
  expect_gt(nrow(res), 0)
  expect_true("variable" %in% names(res))
  expect_true("n" %in% names(res))
})

test_that("tableau_descriptif() : toutes les stats demandees presentes", {
  res <- tableau_descriptif(donnees_test, vars = "age",
                             stats = c("n","moyenne","mediane",
                                       "ecart_type","min","max","ic"))
  noms <- names(res)
  for (s in c("n","moyenne","mediane","ecart_type","min","max",
              "ic_bas","ic_haut")) {
    expect_true(s %in% noms, label = paste("stat manquante:", s))
  }
})

test_that("tableau_descriptif() : subset de stats fonctionne", {
  res <- tableau_descriptif(donnees_test, vars = "age",
                             stats = c("n","moyenne"))
  expect_true("moyenne" %in% names(res))
  expect_false("mediane" %in% names(res))
})

test_that("tableau_descriptif() : n correct", {
  res <- tableau_descriptif(donnees_test, vars = "age")
  n_age <- res$n[res$variable == "age"]
  expect_equal(n_age, sum(!is.na(donnees_test$age)))
})

test_that("tableau_descriptif() : moyenne coherente", {
  res <- tableau_descriptif(donnees_test, vars = "age",
                             stats = c("n","moyenne"))
  moy_ref <- mean(donnees_test$age, na.rm = TRUE)
  expect_equal(res$moyenne, round(moy_ref, 3), tolerance = 1e-3)
})

test_that("tableau_descriptif() : IC coherents (bas <= moy <= haut)", {
  res <- tableau_descriptif(donnees_test, vars = "age",
                             stats = c("n","moyenne","ic"))
  expect_lte(res$ic_bas,  res$moyenne + 1e-6)
  expect_gte(res$ic_haut, res$moyenne - 1e-6)
  expect_gte(res$ic_bas,  0)
})

test_that("tableau_descriptif() : ventilation par groupe fonctionne", {
  res <- tableau_descriptif(donnees_test, vars = "age", par = "milieu",
                             stats = c("n","moyenne"))
  expect_true("milieu" %in% names(res))
  expect_setequal(res$milieu,
                  as.character(sort(unique(donnees_test$milieu))))
})

test_that("tableau_descriptif() : avec poids - resultat different", {
  res_np <- tableau_descriptif(donnees_test, vars = "revenu",
                                stats = c("n","moyenne"))
  res_p  <- tableau_descriptif(donnees_test, vars = "revenu",
                                poids = "poids", stats = c("n","moyenne"))
  expect_false(isTRUE(all.equal(res_np$moyenne, res_p$moyenne)))
})

test_that("tableau_descriptif() : variable inexistante => erreur", {
  expect_error(
    tableau_descriptif(donnees_test, vars = "xxx"),
    regexp = "introuvable"
  )
})

test_that("tableau_descriptif() : variable non numerique => warning", {
  expect_warning(
    tableau_descriptif(donnees_test, vars = c("age", "region")),
    regexp = "non numerique"
  )
})

# =============================================================================
# BLOC 2 - tableau_descriptif() : exports
# =============================================================================

test_that("tableau_descriptif() : format flextable", {
  skip_if_not_installed("flextable")
  res <- tableau_descriptif(donnees_test, vars = "age",
                             format = "flextable")
  expect_s3_class(res, "flextable")
})

test_that("tableau_descriptif() : format excel dans tempdir", {
  skip_if_not_installed("openxlsx2")
  chemin <- file.path(tempdir(), "test_desc.xlsx")
  res <- tableau_descriptif(donnees_test, vars = c("age","revenu"),
                             format = "excel", chemin = chemin)
  expect_true(file.exists(chemin))
  withr::defer(unlink(chemin))
})

test_that("tableau_descriptif() : excel avec titre et source", {
  skip_if_not_installed("openxlsx2")
  chemin <- file.path(tempdir(), "test_desc2.xlsx")
  expect_no_error(
    tableau_descriptif(donnees_test, vars = "age",
                       format = "excel", chemin = chemin,
                       titre = "Statistiques age",
                       source = "Enquete menages 2026")
  )
  withr::defer(unlink(chemin))
})

# =============================================================================
# BLOC 3 - tableau_croise_ins()
# =============================================================================

test_that("tableau_croise_ins() : retourne un data.frame", {
  res <- tableau_croise_ins(donnees_test, "region", "milieu")
  expect_s3_class(res, "data.frame")
  expect_gt(nrow(res), 0)
})

test_that("tableau_croise_ins() : colonne region presente", {
  res <- tableau_croise_ins(donnees_test, "region", "milieu")
  expect_true("region" %in% names(res))
})

test_that("tableau_croise_ins() : pourcentages entre 0 et 100", {
  res <- tableau_croise_ins(donnees_test, "region", "milieu")
  cols_pct <- setdiff(names(res), c("region", "N"))
  pcts <- unlist(res[res$region != "Total", cols_pct])
  pcts <- pcts[!is.na(pcts)]
  expect_true(all(pcts >= 0 & pcts <= 100))
})

test_that("tableau_croise_ins() : somme colonnes = 100% (type colonne)", {
  res <- tableau_croise_ins(donnees_test, "region", "milieu",
                             type_pct = "colonne", marges = FALSE)
  cols_pct <- setdiff(names(res), c("region", "N"))
  for (col in cols_pct) {
    tot <- sum(res[[col]], na.rm = TRUE)
    expect_equal(tot, 100, tolerance = 1.0, label = paste("col:", col))
  }
})

test_that("tableau_croise_ins() : marges = TRUE ajoute ligne Total", {
  res <- tableau_croise_ins(donnees_test, "region", "milieu",
                             marges = TRUE)
  expect_true("Total" %in% res$region)
})

test_that("tableau_croise_ins() : chi2 calcule", {
  res <- tableau_croise_ins(donnees_test, "region", "sexe", chi2 = TRUE)
  chi2_res <- attr(res, "chi2")
  expect_false(is.null(chi2_res))
  expect_true("statistic" %in% names(chi2_res))
  expect_true("p.value" %in% names(chi2_res))
})

test_that("tableau_croise_ins() : chi2 = FALSE => pas de test", {
  res <- tableau_croise_ins(donnees_test, "region", "milieu",
                             chi2 = FALSE)
  expect_null(attr(res, "chi2"))
})

test_that("tableau_croise_ins() : variable inexistante => erreur", {
  expect_error(
    tableau_croise_ins(donnees_test, "xxx", "milieu"),
    regexp = "introuvable"
  )
})

test_that("tableau_croise_ins() : format flextable", {
  skip_if_not_installed("flextable")
  res <- tableau_croise_ins(donnees_test, "region", "milieu",
                             format = "flextable")
  expect_s3_class(res, "flextable")
})

test_that("tableau_croise_ins() : format excel", {
  skip_if_not_installed("openxlsx2")
  chemin <- file.path(tempdir(), "test_croise.xlsx")
  res <- tableau_croise_ins(donnees_test, "region", "milieu",
                             format = "excel", chemin = chemin)
  expect_true(file.exists(chemin))
  withr::defer(unlink(chemin))
})

# =============================================================================
# BLOC 4 - exporter_excel_ins()
# =============================================================================

test_that("exporter_excel_ins() : cree le fichier", {
  skip_if_not_installed("openxlsx2")
  tabs <- list(
    "Age"    = data.frame(variable="age", n=300L, moyenne=38.2),
    "Revenu" = data.frame(variable="revenu", n=300L, moyenne=245000)
  )
  chemin <- file.path(tempdir(), "test_multi.xlsx")
  res    <- exporter_excel_ins(tabs, chemin)
  expect_true(file.exists(chemin))
  expect_equal(res, chemin)
  withr::defer(unlink(chemin))
})

test_that("exporter_excel_ins() : avec meta pays/annee", {
  skip_if_not_installed("openxlsx2")
  tabs   <- list("T1" = data.frame(x = 1:3))
  chemin <- file.path(tempdir(), "test_meta.xlsx")
  expect_no_error(
    exporter_excel_ins(tabs, chemin,
                       titre_classeur = "Enquete 2026",
                       pays = "Centrafrique", annee = 2026L)
  )
  withr::defer(unlink(chemin))
})

test_that("exporter_excel_ins() : tableaux vides => erreur", {
  skip_if_not_installed("openxlsx2")
  expect_error(
    exporter_excel_ins(list(), file.path(tempdir(), "x.xlsx")),
    regexp = "non vide"
  )
})

test_that("exporter_excel_ins() : repertoire inexistant => erreur", {
  skip_if_not_installed("openxlsx2")
  expect_error(
    exporter_excel_ins(
      list("T1" = data.frame(x = 1)),
      "/chemin/inexistant/stats.xlsx"
    ),
    regexp = "inexistant"
  )
})

test_that("exporter_excel_ins() : noms automatiques si liste non nommee", {
  skip_if_not_installed("openxlsx2")
  tabs   <- list(data.frame(x = 1:3), data.frame(y = 4:6))
  chemin <- file.path(tempdir(), "test_nonoms.xlsx")
  expect_no_error(exporter_excel_ins(tabs, chemin))
  withr::defer(unlink(chemin))
})
