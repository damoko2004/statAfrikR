# =============================================================================
# statAfrikR - Tests module ODD
# testthat edition 3
# =============================================================================

# Donnees de test
menages_odd <- local({
  set.seed(2024)
  n <- 300
  data.frame(
    depense_pc   = c(rexp(180, 1/150000), rexp(120, 1/450000)),
    poids        = runif(n, 0.7, 1.4),
    electricite  = sample(c(0L, 1L), n, TRUE, c(0.42, 0.58)),
    eau_potable  = sample(c(0L, 1L), n, TRUE, c(0.38, 0.62)),
    internet     = sample(c(0L, 1L), n, TRUE, c(0.72, 0.28)),
    chomeur      = sample(c(0L, 1L), n, TRUE, c(0.85, 0.15)),
    neet         = sample(c(0L, 1L), n, TRUE, c(0.78, 0.22)),
    eau_sec      = sample(c(0L, 1L), n, TRUE, c(0.55, 0.45)),
    taudis       = sample(c(0L, 1L), n, TRUE, c(0.68, 0.32)),
    identite_jur = sample(c(0L, 1L), n, TRUE, c(0.25, 0.75)),
    inclusion    = sample(c(0L, 1L), n, TRUE, c(0.35, 0.65)),
    femme_dir    = sample(c(0L, 1L), n, TRUE, c(0.72, 0.28)),
    age_mariage  = sample(c(14:25, NA), n, TRUE),
    age_actuel   = sample(18:55, n, TRUE),
    taille_cm    = rnorm(n, 85, 15),
    age_mois     = sample(6:59, n, TRUE),
    deces_enf    = sample(c(0L, 1L), n, TRUE, c(0.94, 0.06)),
    annee        = sample(c(2020L, 2023L), n, TRUE)
  )
})

SEUIL_NATIONAL <- 200000

# =============================================================================
# BLOC 1 - odd_catalogue()
# =============================================================================

test_that("odd_catalogue() : retourne un tibble non vide", {
  res <- odd_catalogue()
  expect_s3_class(res, "data.frame")
  expect_gt(nrow(res), 0)
})

test_that("odd_catalogue() : contient les colonnes attendues", {
  res <- odd_catalogue()
  cols <- c("code_odd", "objectif", "titre_court",
            "source_donnee", "unite", "disponibilite", "statut")
  expect_true(all(cols %in% names(res)))
})

test_that("odd_catalogue() : 20 indicateurs au total", {
  res <- odd_catalogue()
  expect_equal(nrow(res), 20L)
})

test_that("odd_catalogue() : filtre par objectif fonctionne", {
  res <- odd_catalogue(objectif = 1)
  expect_true(all(res$objectif == 1L))
  expect_gt(nrow(res), 0)
})

test_that("odd_catalogue() : filtre par disponibilite fonctionne", {
  res <- odd_catalogue(disponibilite = "haute")
  expect_true(all(res$disponibilite == "haute"))
})

test_that("odd_catalogue() : filtre par statut fonctionne", {
  res <- odd_catalogue(statut = "implementee")
  expect_true(all(res$statut == "implementee"))
})

test_that("odd_catalogue() : filtres combines fonctionnent", {
  res <- odd_catalogue(objectif = 1, statut = "implementee")
  expect_true(all(res$objectif == 1L))
  expect_true(all(res$statut == "implementee"))
})

test_that("odd_catalogue() : objectif hors plage => erreur", {
  expect_error(odd_catalogue(objectif = 18), regexp = "1 et 17")
})

test_that("odd_catalogue() : disponibilite invalide => erreur", {
  expect_error(odd_catalogue(disponibilite = "tres_haute"),
               regexp = "haute")
})

test_that("odd_catalogue() : format flextable", {
  skip_if_not_installed("flextable")
  res <- odd_catalogue(format = "flextable")
  expect_s3_class(res, "flextable")
})

# =============================================================================
# BLOC 2 - odd_indicateur() : indicateurs binaires
# =============================================================================

test_that("odd_indicateur() : 7.1.1 electricite retourne saf_odd", {
  res <- odd_indicateur(menages_odd, "7.1.1",
                        var_indicateur = "electricite")
  expect_s3_class(res, "saf_odd")
})

test_that("odd_indicateur() : 7.1.1 valeur dans [0, 100]", {
  res <- odd_indicateur(menages_odd, "7.1.1",
                        var_indicateur = "electricite")
  expect_gte(res$valeur, 0)
  expect_lte(res$valeur, 100)
})

test_that("odd_indicateur() : 7.1.1 valeur coherente avec calcul manuel", {
  ref <- mean(menages_odd$electricite, na.rm = TRUE) * 100
  res <- odd_indicateur(menages_odd, "7.1.1",
                        var_indicateur = "electricite")
  expect_equal(res$valeur, round(ref, 3), tolerance = 0.01)
})

test_that("odd_indicateur() : 7.1.1 avec poids different du non pondere", {
  res_np <- odd_indicateur(menages_odd, "7.1.1",
                            var_indicateur = "electricite")
  res_p  <- odd_indicateur(menages_odd, "7.1.1",
                            var_indicateur = "electricite",
                            poids = "poids")
  expect_false(isTRUE(all.equal(res_np$valeur, res_p$valeur)))
})

test_that("odd_indicateur() : 6.1.1 eau potable fonctionne", {
  res <- odd_indicateur(menages_odd, "6.1.1",
                        var_indicateur = "eau_potable")
  expect_s3_class(res, "saf_odd")
  expect_gte(res$valeur, 0)
})

test_that("odd_indicateur() : 17.8.1 internet fonctionne", {
  res <- odd_indicateur(menages_odd, "17.8.1",
                        var_indicateur = "internet")
  expect_s3_class(res, "saf_odd")
})

test_that("odd_indicateur() : 8.5.2 chomage fonctionne", {
  res <- odd_indicateur(menages_odd, "8.5.2",
                        var_indicateur = "chomeur")
  expect_s3_class(res, "saf_odd")
})

test_that("odd_indicateur() : 8.6.1 NEET fonctionne", {
  res <- odd_indicateur(menages_odd, "8.6.1",
                        var_indicateur = "neet")
  expect_s3_class(res, "saf_odd")
})

test_that("odd_indicateur() : 16.9.1 identite juridique fonctionne", {
  res <- odd_indicateur(menages_odd, "16.9.1",
                        var_indicateur = "identite_jur")
  expect_s3_class(res, "saf_odd")
  expect_equal(res$unite, "%")
})

# =============================================================================
# BLOC 3 - odd_indicateur() : indicateurs pauvrete
# =============================================================================

test_that("odd_indicateur() : 1.2.1 pauvrete nationale fonctionne", {
  res <- odd_indicateur(menages_odd, "1.2.1",
                        var_depense = "depense_pc",
                        seuil = SEUIL_NATIONAL)
  expect_s3_class(res, "saf_odd")
  expect_gte(res$valeur, 0)
  expect_lte(res$valeur, 100)
})

test_that("odd_indicateur() : 1.2.1 coherent avec calcul_fgt() FGT0", {
  fgt <- calcul_fgt(menages_odd, "depense_pc", SEUIL_NATIONAL)
  odd <- odd_indicateur(menages_odd, "1.2.1",
                        var_depense = "depense_pc",
                        seuil = SEUIL_NATIONAL)
  # FGT0 * 100 doit egal valeur ODD
  expect_equal(fgt$national$fgt0 * 100, odd$valeur, tolerance = 0.01)
})

test_that("odd_indicateur() : 1.2.1 sans seuil => erreur", {
  expect_error(
    odd_indicateur(menages_odd, "1.2.1", var_depense = "depense_pc"),
    regexp = "seuil"
  )
})

test_that("odd_indicateur() : 1.1.1 fonctionne", {
  res <- odd_indicateur(menages_odd, "1.1.1",
                        var_depense = "depense_pc",
                        seuil = 150000)
  expect_s3_class(res, "saf_odd")
})

# =============================================================================
# BLOC 4 - odd_indicateur() : autres indicateurs
# =============================================================================

test_that("odd_indicateur() : 2.2.1 retard croissance fonctionne", {
  res <- odd_indicateur(menages_odd, "2.2.1",
                        var_taille    = "taille_cm",
                        var_age_mois  = "age_mois")
  expect_s3_class(res, "saf_odd")
  expect_gte(res$valeur, 0)
  expect_lte(res$valeur, 100)
})

test_that("odd_indicateur() : 3.2.1 mortalite infantile fonctionne", {
  res <- odd_indicateur(menages_odd, "3.2.1",
                        var_deces_enfant = "deces_enf")
  expect_s3_class(res, "saf_odd")
  expect_gte(res$valeur, 0)
})

test_that("odd_indicateur() : 5.3.1 mariage precoce fonctionne", {
  res <- odd_indicateur(menages_odd, "5.3.1",
                        var_age_mariage = "age_mariage",
                        var_age_actuel  = "age_actuel")
  expect_s3_class(res, "saf_odd")
  expect_gte(res$valeur, 0)
  expect_lte(res$valeur, 100)
})

test_that("odd_indicateur() : 10.1.1 croissance 40% fonctionne", {
  res <- odd_indicateur(menages_odd, "10.1.1",
                        var_depense = "depense_pc",
                        var_periode = "annee")
  expect_s3_class(res, "saf_odd")
})

# =============================================================================
# BLOC 5 - Validations d'erreurs
# =============================================================================

test_that("odd_indicateur() : code inconnu => erreur", {
  expect_error(
    odd_indicateur(menages_odd, "99.9.9", var_indicateur = "electricite"),
    regexp = "non disponible"
  )
})

test_that("odd_indicateur() : var_indicateur manquant => erreur", {
  expect_error(
    odd_indicateur(menages_odd, "7.1.1"),
    regexp = "var_indicateur"
  )
})

test_that("odd_indicateur() : variable inexistante => erreur", {
  expect_error(
    odd_indicateur(menages_odd, "7.1.1", var_indicateur = "xxx"),
    regexp = "introuvable"
  )
})

# =============================================================================
# BLOC 6 - print et as.data.frame
# =============================================================================

test_that("print.saf_odd() fonctionne sans erreur", {
  res <- odd_indicateur(menages_odd, "7.1.1",
                        var_indicateur = "electricite")
  expect_output(print(res), regexp = "ODD 7.1.1")
})

test_that("as.data.frame.saf_odd() retourne un data.frame", {
  res <- odd_indicateur(menages_odd, "7.1.1",
                        var_indicateur = "electricite")
  df  <- as.data.frame(res)
  expect_true(is.data.frame(df))
  expect_true("valeur" %in% names(df))
})

# =============================================================================
# BLOC 7 - tableau_odd()
# =============================================================================

test_that("tableau_odd() : retourne un tibble valide", {
  r1 <- odd_indicateur(menages_odd, "1.2.1",
                       var_depense = "depense_pc", seuil = SEUIL_NATIONAL)
  r2 <- odd_indicateur(menages_odd, "7.1.1",
                       var_indicateur = "electricite")
  res <- tableau_odd(list(r1, r2))
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 2L)
})

test_that("tableau_odd() : avec pays et annee", {
  r1 <- odd_indicateur(menages_odd, "7.1.1",
                       var_indicateur = "electricite")
  res <- tableau_odd(list(r1), pays = "Centrafrique", annee = 2026L)
  expect_true("pays" %in% names(res))
  expect_true("annee" %in% names(res))
  expect_equal(res$pays, "Centrafrique")
})

test_that("tableau_odd() : avec cibles", {
  r1 <- odd_indicateur(menages_odd, "7.1.1",
                       var_indicateur = "electricite")
  res <- tableau_odd(list(r1), cibles = list("7.1.1" = 80))
  expect_true("cible" %in% names(res))
  expect_equal(res$cible, 80)
  expect_true("ecart_cible" %in% names(res))
})

test_that("tableau_odd() : format excel", {
  skip_if_not_installed("openxlsx2")
  r1 <- odd_indicateur(menages_odd, "7.1.1",
                       var_indicateur = "electricite")
  chemin <- file.path(tempdir(), "test_odd.xlsx")
  res <- tableau_odd(list(r1), format = "excel", chemin = chemin)
  expect_true(file.exists(chemin))
  withr::defer(unlink(chemin))
})

test_that("tableau_odd() : liste vide => erreur", {
  expect_error(tableau_odd(list()), regexp = "non vide")
})

test_that("tableau_odd() : element non saf_odd => erreur", {
  expect_error(tableau_odd(list(data.frame(x = 1))),
               regexp = "saf_odd")
})
