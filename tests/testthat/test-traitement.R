# =============================================================================
# Tests unitaires — Module Traitement
# statAfrikR
# =============================================================================

# Données de test partagées
set.seed(123)
donnees_test <- tibble::tibble(
  id      = 1:100,
  age     = c(sample(c(10,15,20,25,30,35,40,45,50,55,60), 80, replace = TRUE),
              rep(NA, 20)),
  sexe    = sample(c("Masculin", "Féminin"), 100, replace = TRUE),
  region  = sample(c("Nord", "Sud", "Est", "Ouest", "Centre"), 100, replace = TRUE),
  revenu  = c(abs(rnorm(85, 150000, 80000)), rep(NA, 15)),
  poids   = runif(100, 0.5, 2.5),
  strate  = sample(c("Urbain", "Rural"), 100, replace = TRUE),
  grappe  = sample(1:20, 100, replace = TRUE)
)

# --- nettoyer_libelles -------------------------------------------------------

test_that("nettoyer_libelles() retourne un tibble de même dimension", {
  result <- nettoyer_libelles(donnees_test, vars = "region")
  expect_s3_class(result, "tbl_df")
  expect_equal(dim(result), dim(donnees_test))
})

test_that("nettoyer_libelles() supprime les espaces superflus", {
  df <- tibble::tibble(region = c("  Nord  ", " Sud", "Est   "))
  result <- nettoyer_libelles(df, vars = "region", casse = "aucune")
  expect_equal(result$region, c("Nord", "Sud", "Est"))
})

test_that("nettoyer_libelles() applique la casse majuscule", {
  df <- tibble::tibble(region = c("nord", "sud", "est"))
  result <- nettoyer_libelles(df, vars = "region", casse = "majuscule")
  expect_equal(result$region, c("NORD", "SUD", "EST"))
})

test_that("nettoyer_libelles() applique la casse minuscule", {
  df <- tibble::tibble(region = c("NORD", "SUD"))
  result <- nettoyer_libelles(df, vars = "region", casse = "minuscule")
  expect_equal(result$region, c("nord", "sud"))
})

test_that("nettoyer_libelles() préserve les accents", {
  df <- tibble::tibble(region = c("  SÉNÉGAL  ", "côte d'ivoire"))
  result <- nettoyer_libelles(df, vars = "region", casse = "titre")
  expect_true(any(grepl("Sénégal", result$region)))
})

test_that("nettoyer_libelles() traite toutes les vars character si vars = NULL", {
  result <- nettoyer_libelles(donnees_test)
  expect_s3_class(result, "tbl_df")
})

test_that("nettoyer_libelles() échoue sur variable inexistante", {
  expect_error(
    nettoyer_libelles(donnees_test, vars = "variable_inexistante"),
    regexp = "introuvable"
  )
})

test_that("nettoyer_libelles() échoue si data n'est pas un data.frame", {
  expect_error(nettoyer_libelles("pas_un_df"), regexp = "data.frame")
})

# --- harmoniser_regions ------------------------------------------------------

test_that("harmoniser_regions() ajoute une colonne region_std", {
  result <- harmoniser_regions(donnees_test, "region")
  expect_true("region_std" %in% names(result))
})

test_that("harmoniser_regions() utilise le référentiel pays BJ", {
  df <- tibble::tibble(region = c("alibori", "Atacora", "ATLANTIQUE"))
  result <- harmoniser_regions(df, "region", pays = "BJ",
                                signaler_non_trouves = FALSE)
  expect_true("region_std" %in% names(result))
})

test_that("harmoniser_regions() utilise une table de correspondance manuelle", {
  table_corr <- data.frame(
    original    = c("nord", "sud", "est", "ouest", "centre"),
    standardise = c("Nord", "Sud", "Est", "Ouest", "Centre")
  )
  df <- tibble::tibble(region = c("nord", "sud", "est"))
  result <- harmoniser_regions(df, "region",
                                table_correspondance = table_corr,
                                signaler_non_trouves = FALSE)
  expect_equal(result$region_std, c("Nord", "Sud", "Est"))
})

test_that("harmoniser_regions() échoue sur variable inexistante", {
  expect_error(
    harmoniser_regions(donnees_test, "var_inexistante"),
    regexp = "introuvable"
  )
})

test_that("harmoniser_regions() utilise var_sortie personnalisée", {
  result <- harmoniser_regions(donnees_test, "region",
                                var_sortie = "ma_region_std")
  expect_true("ma_region_std" %in% names(result))
})

# --- appliquer_ponderations --------------------------------------------------

test_that("appliquer_ponderations() retourne un objet svydesign", {
  skip_if_not_installed("survey")
  result <- appliquer_ponderations(donnees_test, "poids")
  expect_s3_class(result, "survey.design")
})

test_that("appliquer_ponderations() fonctionne avec strate et grappe", {
  skip_if_not_installed("survey")
  result <- appliquer_ponderations(
    donnees_test, "poids",
    var_strate = "strate",
    var_grappe = "grappe"
  )
  expect_s3_class(result, "survey.design")
})

test_that("appliquer_ponderations() échoue sur poids négatifs", {
  df_pb <- donnees_test
  df_pb$poids[1] <- -1
  expect_error(
    appliquer_ponderations(df_pb, "poids"),
    regexp = "négatif"
  )
})

test_that("appliquer_ponderations() échoue sur poids nuls", {
  df_pb <- donnees_test
  df_pb$poids[1] <- 0
  expect_error(
    appliquer_ponderations(df_pb, "poids"),
    regexp = "nul"
  )
})

test_that("appliquer_ponderations() avertit sur poids NA", {
  df_na <- donnees_test
  df_na$poids[1:5] <- NA
  expect_warning(
    appliquer_ponderations(df_na, "poids"),
    regexp = "manquante"
  )
})

test_that("appliquer_ponderations() échoue sur variable de poids inexistante", {
  expect_error(
    appliquer_ponderations(donnees_test, "poids_inexistant"),
    regexp = "introuvable"
  )
})

test_that("appliquer_ponderations() normalise les poids si demandé", {
  skip_if_not_installed("survey")
  result <- appliquer_ponderations(donnees_test, "poids", normaliser = TRUE)
  expect_s3_class(result, "survey.design")
})

# --- imputer_valeurs ---------------------------------------------------------

test_that("imputer_valeurs() réduit les NA avec méthode médiane", {
  result <- imputer_valeurs(donnees_test, vars = "age",
                             methode = "mediane", rapport = FALSE)
  expect_equal(sum(is.na(result$age)), 0)
})

test_that("imputer_valeurs() réduit les NA avec méthode moyenne", {
  result <- imputer_valeurs(donnees_test, vars = "revenu",
                             methode = "moyenne", rapport = FALSE)
  expect_equal(sum(is.na(result$revenu)), 0)
})

test_that("imputer_valeurs() réduit les NA avec méthode mode", {
  result <- imputer_valeurs(donnees_test, vars = "sexe",
                             methode = "mode", rapport = FALSE)
  expect_equal(sum(is.na(result$sexe)), 0)
})

test_that("imputer_valeurs() réduit les NA avec hot_deck", {
  result <- imputer_valeurs(donnees_test, vars = "age",
                             methode = "hot_deck", rapport = FALSE)
  expect_equal(sum(is.na(result$age)), 0)
})

test_that("imputer_valeurs() retourne une liste si rapport = TRUE", {
  result <- imputer_valeurs(donnees_test, vars = "age",
                             methode = "mediane", rapport = TRUE)
  expect_type(result, "list")
  expect_true("donnees" %in% names(result))
  expect_true("rapport" %in% names(result))
})

test_that("imputer_valeurs() retourne un tibble si rapport = FALSE", {
  result <- imputer_valeurs(donnees_test, vars = "age",
                             methode = "mediane", rapport = FALSE)
  expect_s3_class(result, "tbl_df")
})

test_that("imputer_valeurs() échoue sur regression sans vars_auxiliaires", {
  expect_error(
    imputer_valeurs(donnees_test, vars = "age", methode = "regression"),
    regexp = "auxiliaires"
  )
})

test_that("imputer_valeurs() fonctionne avec regression et vars_auxiliaires", {
  result <- imputer_valeurs(
    donnees_test, vars = "age",
    methode = "regression",
    vars_auxiliaires = c("revenu", "poids"),
    rapport = FALSE
  )
  expect_s3_class(result, "tbl_df")
})

test_that("imputer_valeurs() message si aucune valeur manquante", {
  df_complet <- donnees_test[, c("id", "sexe", "region")]
  expect_message(
    imputer_valeurs(df_complet, methode = "mediane"),
    regexp = "manquante"
  )
})

# --- supprimer_doublons ------------------------------------------------------

test_that("supprimer_doublons() supprime les doublons exacts", {
  df_doublons <- dplyr::bind_rows(donnees_test, donnees_test[1:10, ])
  result <- supprimer_doublons(df_doublons, cles = "id", rapport = FALSE)
  expect_equal(nrow(result), nrow(donnees_test))
})

test_that("supprimer_doublons() retourne une liste si rapport = TRUE", {
  df_doublons <- dplyr::bind_rows(donnees_test, donnees_test[1:5, ])
  result <- supprimer_doublons(df_doublons, cles = "id", rapport = TRUE)
  expect_type(result, "list")
  expect_true("donnees" %in% names(result))
  expect_true("rapport" %in% names(result))
})

test_that("supprimer_doublons() garde le premier par défaut", {
  df_doublons <- dplyr::bind_rows(donnees_test, donnees_test[1:3, ])
  result <- supprimer_doublons(df_doublons, cles = "id",
                                garder = "premier", rapport = FALSE)
  expect_equal(nrow(result), nrow(donnees_test))
})

test_that("supprimer_doublons() message si aucun doublon", {
  expect_message(
    supprimer_doublons(donnees_test, cles = "id"),
    regexp = "doublon"
  )
})

test_that("supprimer_doublons() échoue sur clé inexistante", {
  expect_error(
    supprimer_doublons(donnees_test, cles = "cle_inexistante"),
    regexp = "introuvable"
  )
})

# --- recoder_variable --------------------------------------------------------

test_that("recoder_variable() recode correctement avec data.frame", {
  table_rec <- data.frame(
    avant = c("Masculin", "Féminin"),
    apres = c("M", "F")
  )
  result <- recoder_variable(donnees_test, "sexe", table_rec)
  expect_true(all(result$sexe %in% c("M", "F", NA)))
})

test_that("recoder_variable() fonctionne avec vecteur nommé", {
  result <- recoder_variable(
    donnees_test, "strate",
    table_recodage = c("Urbain" = "U", "Rural" = "R")
  )
  expect_true(all(result$strate %in% c("U", "R", NA)))
})

test_that("recoder_variable() crée une nouvelle colonne si var_sortie spécifié", {
  table_rec <- data.frame(avant = c("Masculin", "Féminin"),
                           apres = c("M", "F"))
  result <- recoder_variable(donnees_test, "sexe", table_rec,
                              var_sortie = "sexe_code")
  expect_true("sexe_code" %in% names(result))
  expect_true("sexe" %in% names(result))
})

test_that("recoder_variable() échoue sur variable inexistante", {
  table_rec <- data.frame(avant = "a", apres = "b")
  expect_error(
    recoder_variable(donnees_test, "var_inexistante", table_rec),
    regexp = "introuvable"
  )
})

# --- standardiser_ages -------------------------------------------------------

test_that("standardiser_ages() retourne une liste avec les indices", {
  result <- standardiser_ages(donnees_test, "age")
  expect_type(result, "list")
  expect_true("indice_whipple" %in% names(result))
  expect_true("indice_myers" %in% names(result))
  expect_true("diagnostic" %in% names(result))
})

test_that("standardiser_ages() retourne l'indice de Whipple entre 0 et 5", {
  result <- standardiser_ages(donnees_test, "age")
  if (!is.na(result$indice_whipple)) {
    expect_gte(result$indice_whipple, 0)
    expect_lte(result$indice_whipple, 5)
  }
})

test_that("standardiser_ages() échoue sur variable non numérique", {
  expect_error(
    standardiser_ages(donnees_test, "sexe"),
    regexp = "numérique"
  )
})

# --- fusion_datasets ---------------------------------------------------------

test_that("fusion_datasets() empile correctement (vertical)", {
  result <- fusion_datasets(
    list(a = donnees_test[1:50,], b = donnees_test[51:100,]),
    type = "vertical"
  )
  expect_equal(nrow(result), 100)
})

test_that("fusion_datasets() fusionne horizontalement (gauche)", {
  df1 <- donnees_test[, c("id", "age", "sexe")]
  df2 <- donnees_test[, c("id", "region", "revenu")]
  result <- fusion_datasets(
    list(df1 = df1, df2 = df2),
    type = "horizontal", cle = "id"
  )
  expect_equal(nrow(result), 100)
  expect_true(all(c("age", "region") %in% names(result)))
})

test_that("fusion_datasets() échoue si moins de 2 datasets", {
  expect_error(
    fusion_datasets(list(a = donnees_test)),
    regexp = "au moins 2"
  )
})

test_that("fusion_datasets() échoue si cle absente pour fusion horizontale", {
  expect_error(
    fusion_datasets(list(a = donnees_test, b = donnees_test),
                    type = "horizontal"),
    regexp = "clé"
  )
})

# --- tracer_flux_traitement --------------------------------------------------

test_that("tracer_flux_traitement() retourne une liste avec donnees et journal", {
  result <- tracer_flux_traitement(donnees_test, "Import initial")
  expect_type(result, "list")
  expect_true("donnees" %in% names(result))
  expect_true("journal" %in% names(result))
})

test_that("tracer_flux_traitement() cumule les entrées du journal", {
  etape1 <- tracer_flux_traitement(donnees_test, "Étape 1")
  etape2 <- tracer_flux_traitement(donnees_test, "Étape 2",
                                    journal = etape1$journal)
  expect_equal(nrow(etape2$journal), 2)
})

test_that("tracer_flux_traitement() contient les bonnes colonnes", {
  result <- tracer_flux_traitement(donnees_test, "Test")
  cols_attendues <- c("horodatage", "action", "n_lignes", "n_colonnes")
  expect_true(all(cols_attendues %in% names(result$journal)))
})

test_that("tracer_flux_traitement() échoue si action manquante", {
  expect_error(
    tracer_flux_traitement(donnees_test, ""),
    regexp = "obligatoire"
  )
})
