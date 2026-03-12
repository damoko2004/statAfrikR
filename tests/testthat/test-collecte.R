# =============================================================================
# Tests unitaires — Module Collecte
# statAfrikR
# =============================================================================

# Données de test partagées
donnees_test <- tibble::tibble(
  id      = 1:50,
  age     = c(sample(15:80, 45), rep(NA, 5)),
  sexe    = sample(c("Masculin", "Féminin"), 50, replace = TRUE),
  region  = sample(c("Nord", "Sud", "Est", "Ouest", "Centre"), 50, replace = TRUE),
  revenu  = c(abs(rnorm(40, 150000, 80000)), rep(NA, 10))
)

# --- import_excel -----------------------------------------------------------

test_that("import_excel() échoue proprement sur fichier inexistant", {
  expect_error(
    import_excel("fichier_inexistant.xlsx"),
    regexp = "introuvable"
  )
})

test_that("import_excel() échoue sur mauvaise extension", {
  tmp <- tempfile(fileext = ".csv")
  writeLines("a,b\n1,2", tmp)
  expect_error(import_excel(tmp), regexp = "Extension non reconnue")
  unlink(tmp)
})

test_that("import_excel() retourne un tibble sur fichier valide", {
  skip_if_not_installed("readxl")
  skip_if_not_installed("openxlsx2")

  tmp <- tempfile(fileext = ".xlsx")
  openxlsx2::write_xlsx(donnees_test, tmp)

  resultat <- import_excel(tmp, verbose = FALSE)
  expect_s3_class(resultat, "tbl_df")
  expect_equal(nrow(resultat), 50)
  unlink(tmp)
})

test_that("import_excel() retourne une liste pour feuille = NULL", {
  skip_if_not_installed("readxl")
  skip_if_not_installed("openxlsx2")

  tmp <- tempfile(fileext = ".xlsx")
  wb <- openxlsx2::wb_workbook()
  wb <- openxlsx2::wb_add_worksheet(wb, "Feuille1")
  wb <- openxlsx2::wb_add_worksheet(wb, "Feuille2")
  wb <- openxlsx2::wb_add_data(wb, "Feuille1", donnees_test)
  wb <- openxlsx2::wb_add_data(wb, "Feuille2", donnees_test[1:10,])
  openxlsx2::wb_save(wb, tmp)

  resultat <- import_excel(tmp, feuille = NULL, verbose = FALSE)
  expect_type(resultat, "list")
  expect_equal(length(resultat), 2)
  unlink(tmp)
})

# --- import_csv -------------------------------------------------------------

test_that("import_csv() échoue proprement sur fichier inexistant", {
  expect_error(
    import_csv("fichier_inexistant.csv"),
    regexp = "introuvable"
  )
})

test_that("import_csv() importe correctement un CSV virgule", {
  tmp <- tempfile(fileext = ".csv")
  readr::write_csv(donnees_test, tmp)

  resultat <- import_csv(tmp, verbose = FALSE)
  expect_s3_class(resultat, "tbl_df")
  expect_equal(nrow(resultat), 50)
  unlink(tmp)
})

test_that("import_csv() détecte le séparateur point-virgule", {
  tmp <- tempfile(fileext = ".csv")
  readr::write_csv2(donnees_test, tmp)

  resultat <- import_csv(tmp, verbose = FALSE)
  expect_s3_class(resultat, "tbl_df")
  expect_equal(nrow(resultat), 50)
  unlink(tmp)
})

test_that("import_csv() gère les accents français", {
  tmp <- tempfile(fileext = ".csv")
  df_accents <- tibble::tibble(
    region = c("Île-de-France", "Côte d'Ivoire", "Sénégal")
  )
  readr::write_csv(df_accents, tmp)

  resultat <- import_csv(tmp, verbose = FALSE)
  expect_equal(nrow(resultat), 3)
  expect_true(any(grepl("Sénégal", resultat$region)))
  unlink(tmp)
})

# --- import_stata -----------------------------------------------------------

test_that("import_stata() échoue proprement sur fichier inexistant", {
  expect_error(
    import_stata("fichier_inexistant.dta"),
    regexp = "introuvable"
  )
})

test_that("import_stata() importe un fichier .dta valide", {
  skip_if_not_installed("haven")

  tmp <- tempfile(fileext = ".dta")
  haven::write_dta(donnees_test, tmp)

  resultat <- import_stata(tmp, verbose = FALSE)
  expect_s3_class(resultat, "tbl_df")
  expect_equal(nrow(resultat), 50)
  unlink(tmp)
})

# --- import_spss ------------------------------------------------------------

test_that("import_spss() échoue proprement sur fichier inexistant", {
  expect_error(
    import_spss("fichier_inexistant.sav"),
    regexp = "introuvable"
  )
})

test_that("import_spss() importe un fichier .sav valide", {
  skip_if_not_installed("haven")

  tmp <- tempfile(fileext = ".sav")
  haven::write_sav(donnees_test, tmp)

  resultat <- import_spss(tmp, verbose = FALSE)
  expect_s3_class(resultat, "tbl_df")
  expect_equal(nrow(resultat), 50)
  unlink(tmp)
})

# --- import_cspro -----------------------------------------------------------

test_that("import_cspro() échoue sur fichier .dat inexistant", {
  expect_error(
    import_cspro("fichier_inexistant.dat"),
    regexp = "introuvable"
  )
})

test_that("import_cspro() échoue si .dcf introuvable", {
  tmp_dat <- tempfile(fileext = ".dat")
  writeLines("ligne1ligne2", tmp_dat)

  expect_error(
    import_cspro(tmp_dat),
    regexp = "dictionnaire .dcf introuvable"
  )
  unlink(tmp_dat)
})

# --- check_na ---------------------------------------------------------------

test_that("check_na() retourne un tibble avec les bonnes colonnes", {
  resultat <- check_na(donnees_test, alerter = FALSE)
  expect_s3_class(resultat, "tbl_df")
  expect_true(all(c("variable", "n_total", "n_manquant",
                     "taux_na", "statut") %in% names(resultat)))
})

test_that("check_na() calcule correctement le taux de NA", {
  resultat <- check_na(donnees_test, alerter = FALSE)
  # age : 5 NA sur 50 = 0.1
  taux_age <- unname(resultat$taux_na[resultat$variable == "age"])
  expect_equal(taux_age, 0.1, tolerance = 1e-6)
  
  taux_revenu <- unname(resultat$taux_na[resultat$variable == "revenu"])
  expect_equal(taux_revenu, 0.2, tolerance = 1e-6)
})

test_that("check_na() filtre correctement sur vars", {
  resultat <- check_na(donnees_test, vars = c("age", "sexe"), alerter = FALSE)
  expect_equal(nrow(resultat), 2)
  expect_true(all(resultat$variable %in% c("age", "sexe")))
})

test_that("check_na() échoue sur variable inexistante", {
  expect_error(
    check_na(donnees_test, vars = "variable_inexistante"),
    regexp = "introuvable"
  )
})

test_that("check_na() échoue sur seuil invalide", {
  expect_error(check_na(donnees_test, seuil = 1.5), regexp = "entre 0 et 1")
  expect_error(check_na(donnees_test, seuil = -0.1), regexp = "entre 0 et 1")
})

test_that("check_na() émet un avertissement pour variables critiques", {
  expect_warning(
    check_na(donnees_test, seuil = 0.05, alerter = TRUE),
    regexp = "CRITIQUE|NA"
  )
})

# --- check_types ------------------------------------------------------------

test_that("check_types() retourne un tibble", {
  resultat <- check_types(donnees_test)
  expect_s3_class(resultat, "tbl_df")
})

test_that("check_types() détecte les nombres stockés en caractère", {
  df_pb <- tibble::tibble(age_texte = c("25", "30", "45", "18", "60"))
  resultat <- check_types(df_pb)
  expect_true(nrow(resultat) > 0)
  expect_true(any(grepl("numeric", resultat$type_attendu)))
})

test_that("check_types() ne signale rien sur données propres", {
  df_propre <- tibble::tibble(
    age   = c(25L, 30L, 45L),
    sexe  = c("M", "F", "M"),
    poids = c(1.2, 0.8, 1.5)
  )
  resultat <- check_types(df_propre)
  expect_equal(nrow(resultat), 0)
})

# --- valider_dictionnaire ---------------------------------------------------

test_that("valider_dictionnaire() détecte les variables manquantes", {
  dico <- data.frame(
    nom_variable = c("age", "variable_absente"),
    type         = c("numeric", "character"),
    obligatoire  = c(TRUE, TRUE)
  )
  resultat <- suppressWarnings(valider_dictionnaire(donnees_test, dico))
  expect_false(resultat$valide)
  expect_true("variable_absente" %in% resultat$rapport$variable)
})

test_that("valider_dictionnaire() retourne valide=TRUE sur dictionnaire correct", {
  dico <- data.frame(
    nom_variable = c("age", "sexe"),
    type         = c("numeric", "character"),
    obligatoire  = c(TRUE, TRUE)
  )
  resultat <- valider_dictionnaire(donnees_test, dico)
  expect_true(resultat$valide)
})

test_that("valider_dictionnaire() retourne un score entre 0 et 100", {
  dico <- data.frame(
    nom_variable = c("age", "sexe"),
    type         = c("numeric", "character")
  )
  resultat <- valider_dictionnaire(donnees_test, dico)
  expect_gte(resultat$score_qualite, 0)
  expect_lte(resultat$score_qualite, 100)
})

test_that("valider_dictionnaire() échoue si colonnes requises absentes", {
  dico_mal <- data.frame(variable = "age", classe = "numeric")
  expect_error(
    valider_dictionnaire(donnees_test, dico_mal),
    regexp = "Colonnes manquantes"
  )
})

test_that("valider_dictionnaire() arrête si stopper_si_critique = TRUE", {
  dico <- data.frame(
    nom_variable = c("variable_critique_absente"),
    type         = c("numeric"),
    obligatoire  = TRUE
  )
  expect_error(
    valider_dictionnaire(donnees_test, dico, stopper_si_critique = TRUE)
  )
})
