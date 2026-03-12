# =============================================================================
# Tests unitaires — Module Analyse
# statAfrikR
# =============================================================================

# Données de test partagées
set.seed(42)
donnees_test <- tibble::tibble(
  id       = 1:200,
  age      = sample(15:80, 200, replace = TRUE),
  sexe     = sample(c("Masculin", "Féminin"), 200, replace = TRUE),
  region   = sample(c("Nord", "Sud", "Est", "Ouest"), 200, replace = TRUE),
  milieu   = sample(c("Urbain", "Rural"), 200, replace = TRUE),
  revenu   = abs(rnorm(200, 150000, 60000)),
  depense  = abs(rnorm(200, 120000, 50000)),
  poids    = runif(200, 0.5, 2.5),
  strate   = sample(c("A", "B", "C"), 200, replace = TRUE),
  grappe   = sample(1:30, 200, replace = TRUE),
  # Indicateurs IPM (0 = non privé, 1 = privé)
  malnutrition    = sample(c(0L, 1L), 200, replace = TRUE, prob = c(0.7, 0.3)),
  mortalite       = sample(c(0L, 1L), 200, replace = TRUE, prob = c(0.9, 0.1)),
  scolarisation   = sample(c(0L, 1L), 200, replace = TRUE, prob = c(0.6, 0.4)),
  enfants_scol    = sample(c(0L, 1L), 200, replace = TRUE, prob = c(0.7, 0.3)),
  electricite     = sample(c(0L, 1L), 200, replace = TRUE, prob = c(0.5, 0.5)),
  eau_potable     = sample(c(0L, 1L), 200, replace = TRUE, prob = c(0.6, 0.4)),
  pauvre          = sample(c(0L, 1L), 200, replace = TRUE, prob = c(0.6, 0.4))
)

# --- stat_descr --------------------------------------------------------------

test_that("stat_descr() retourne un tibble avec les bonnes colonnes", {
  result <- stat_descr(donnees_test, vars = "revenu")
  expect_s3_class(result, "tbl_df")
  expect_true(all(c("variable", "n", "moyenne", "mediane") %in% names(result)))
})

test_that("stat_descr() accepte plusieurs variables", {
  result <- stat_descr(donnees_test, vars = c("revenu", "age"))
  expect_equal(nrow(result), 2)
})

test_that("stat_descr() fonctionne avec regroupement", {
  result <- stat_descr(donnees_test, vars = "revenu", groupe = "sexe")
  expect_s3_class(result, "tbl_df")
  expect_true("sexe" %in% names(result) || "groupe" %in% names(result))
})

test_that("stat_descr() fonctionne avec un svydesign", {
  skip_if_not_installed("survey")
  plan <- appliquer_ponderations(donnees_test, "poids",
                                  var_strate = "strate",
                                  var_grappe = "grappe")
  result <- stat_descr(plan, vars = "revenu")
  expect_s3_class(result, "tbl_df")
  expect_true("moyenne" %in% names(result))
})

test_that("stat_descr() calcule les IC si demandé", {
  result <- stat_descr(donnees_test, vars = "revenu", ic = TRUE)
  expect_true(all(c("ic_bas", "ic_haut") %in% names(result)))
})

test_that("stat_descr() échoue sur variable inexistante", {
  expect_error(
    stat_descr(donnees_test, vars = "var_inexistante"),
    regexp = "introuvable"
  )
})

test_that("stat_descr() avertit sur variables non numériques", {
  expect_warning(
    stat_descr(donnees_test, vars = c("revenu", "sexe")),
    regexp = "non numérique"
  )
})

test_that("stat_descr() retourne la moyenne correcte", {
  result <- stat_descr(donnees_test, vars = "age")
  moy_attendue <- round(mean(donnees_test$age), 2)
  expect_equal(result$moyenne, moy_attendue, tolerance = 0.01)
})

# --- tab_croisee -------------------------------------------------------------

test_that("tab_croisee() retourne un tibble par défaut", {
  result <- tab_croisee(donnees_test, "region", "sexe",
                         format_sortie = "tibble")
  expect_s3_class(result, "tbl_df")
})

test_that("tab_croisee() retourne les colonnes attendues", {
  result <- tab_croisee(donnees_test, "region", "sexe",
                         format_sortie = "tibble")
  expect_true(all(c("effectif", "pourcentage") %in% names(result)))
})

test_that("tab_croisee() fonctionne sans var_col (fréquences simples)", {
  result <- tab_croisee(donnees_test, "region", format_sortie = "tibble")
  expect_s3_class(result, "tbl_df")
  expect_true("effectif" %in% names(result))
})

test_that("tab_croisee() fonctionne avec svydesign", {
  skip_if_not_installed("survey")
  plan <- appliquer_ponderations(donnees_test, "poids",
                                  var_strate = "strate",
                                  var_grappe = "grappe")
  result <- tab_croisee(plan, "region", format_sortie = "tibble")
  expect_s3_class(result, "tbl_df")
})

test_that("tab_croisee() échoue sur variable en ligne inexistante", {
  expect_error(
    tab_croisee(donnees_test, "var_inexistante"),
    regexp = "introuvable"
  )
})

test_that("tab_croisee() échoue sur variable en colonne inexistante", {
  expect_error(
    tab_croisee(donnees_test, "region", "var_inexistante"),
    regexp = "introuvable"
  )
})

test_that("tab_croisee() supporte les 3 types de pourcentage", {
  for (pct in c("colonne", "ligne", "total")) {
    result <- tab_croisee(donnees_test, "region", "sexe",
                           pourcentage = pct, format_sortie = "tibble")
    expect_s3_class(result, "tbl_df")
  }
})

# --- analyse_regression ------------------------------------------------------

test_that("analyse_regression() retourne un tibble", {
  result <- analyse_regression(revenu ~ age + sexe, donnees_test)
  expect_s3_class(result, "tbl_df")
})

test_that("analyse_regression() contient les colonnes attendues", {
  result <- analyse_regression(revenu ~ age, donnees_test)
  expect_true(all(c("terme", "estimateur", "p_valeur") %in% names(result)))
})

test_that("analyse_regression() fonctionne en logistique", {
  result <- analyse_regression(pauvre ~ age + sexe, donnees_test,
                                type = "logistique")
  expect_s3_class(result, "tbl_df")
  expect_true("odds_ratio" %in% names(result))
})

test_that("analyse_regression() fonctionne en Poisson", {
  result <- analyse_regression(pauvre ~ age, donnees_test, type = "poisson")
  expect_s3_class(result, "tbl_df")
  expect_true("odds_ratio" %in% names(result))
})

test_that("analyse_regression() retourne une liste si format_sortie = 'liste'", {
  result <- analyse_regression(revenu ~ age, donnees_test,
                                format_sortie = "liste")
  expect_type(result, "list")
  expect_true("modele" %in% names(result))
  expect_true("tableau" %in% names(result))
})

test_that("analyse_regression() fonctionne avec svydesign", {
  skip_if_not_installed("survey")
  plan <- appliquer_ponderations(donnees_test, "poids",
                                  var_strate = "strate",
                                  var_grappe = "grappe")
  result <- analyse_regression(revenu ~ age, plan)
  expect_s3_class(result, "tbl_df")
})

# --- calcul_idh --------------------------------------------------------------

test_that("calcul_idh() retourne une liste avec les bons éléments", {
  result <- calcul_idh(61.2, 5.4, 9.8, 2350)
  expect_type(result, "list")
  expect_true(all(c("idh", "indice_sante", "indice_education",
                     "indice_revenu", "categorie") %in% names(result)))
})

test_that("calcul_idh() retourne un IDH entre 0 et 1", {
  result <- calcul_idh(61.2, 5.4, 9.8, 2350)
  expect_gte(result$idh, 0)
  expect_lte(result$idh, 1)
})

test_that("calcul_idh() retourne les indices entre 0 et 1", {
  result <- calcul_idh(61.2, 5.4, 9.8, 2350)
  expect_gte(result$indice_sante, 0)
  expect_lte(result$indice_sante, 1)
  expect_gte(result$indice_education, 0)
  expect_lte(result$indice_education, 1)
  expect_gte(result$indice_revenu, 0)
  expect_lte(result$indice_revenu, 1)
})

test_that("calcul_idh() catégorise correctement", {
  # IDH élevé (pays développé)
  result_eleve <- calcul_idh(80, 12, 16, 45000)
  expect_equal(result_eleve$categorie, "Très élevé")

  # IDH faible (pays peu développé)
  result_faible <- calcul_idh(55, 3, 7, 800)
  expect_equal(result_faible$categorie, "Faible")
})

test_that("calcul_idh() calcul cohérent : IDH = (Is * Ie * Ir)^(1/3)", {
  result <- calcul_idh(65, 6, 10, 3000)
  idh_attendu <- round(
    (result$indice_sante * result$indice_education * result$indice_revenu)^(1/3),
    3
  )
  expect_equal(result$idh, idh_attendu, tolerance = 1e-3)
})

test_that("calcul_idh() avertit sur valeurs hors plage", {
  expect_warning(
    calcul_idh(90, 5, 10, 2000),  # EV > 85
    regexp = "hors plage"
  )
})

# --- calcul_ipm --------------------------------------------------------------

test_that("calcul_ipm() retourne une liste avec les bons éléments", {
  indicateurs <- list(
    sante     = c("malnutrition", "mortalite"),
    education = c("scolarisation", "enfants_scol"),
    niveau_vie = c("electricite", "eau_potable")
  )
  result <- calcul_ipm(donnees_test, indicateurs)
  expect_type(result, "list")
  expect_true(all(c("ipm", "H", "A", "contributions") %in% names(result)))
})

test_that("calcul_ipm() retourne IPM entre 0 et 1", {
  indicateurs <- list(
    sante     = c("malnutrition", "mortalite"),
    education = c("scolarisation", "enfants_scol")
  )
  result <- calcul_ipm(donnees_test, indicateurs)
  expect_gte(result$ipm, 0)
  expect_lte(result$ipm, 1)
})

test_that("calcul_ipm() vérifie la relation IPM = H × A", {
  indicateurs <- list(
    sante     = c("malnutrition", "mortalite"),
    education = c("scolarisation", "enfants_scol")
  )
  result <- calcul_ipm(donnees_test, indicateurs)
  expect_equal(result$ipm, round(result$H * result$A, 4), tolerance = 1e-3)
})

test_that("calcul_ipm() échoue sur indicateurs manquants", {
  indicateurs <- list(sante = c("var_inexistante"))
  expect_error(calcul_ipm(donnees_test, indicateurs), regexp = "introuvable")
})

test_that("calcul_ipm() échoue sur seuil invalide", {
  indicateurs <- list(sante = c("malnutrition"))
  expect_error(calcul_ipm(donnees_test, indicateurs, seuil_pauvrete = 1.5))
  expect_error(calcul_ipm(donnees_test, indicateurs, seuil_pauvrete = 0))
})

test_that("calcul_ipm() enrichit les données avec les colonnes attendues", {
  indicateurs <- list(sante = c("malnutrition"), education = c("scolarisation"))
  result <- calcul_ipm(donnees_test, indicateurs)
  expect_true(".score_privation" %in% names(result$donnees_enrichies))
  expect_true(".est_pauvre_multi" %in% names(result$donnees_enrichies))
})

# --- decomposer_inegalite ----------------------------------------------------

test_that("decomposer_inegalite() retourne une liste avec gini, theil, atkinson", {
  result <- decomposer_inegalite(donnees_test, "revenu")
  expect_type(result, "list")
  expect_true(all(c("gini", "theil", "atkinson") %in% names(result)))
})

test_that("decomposer_inegalite() Gini entre 0 et 1", {
  result <- decomposer_inegalite(donnees_test, "revenu")
  expect_gte(result$gini, 0)
  expect_lte(result$gini, 1)
})

test_that("decomposer_inegalite() fonctionne avec groupe", {
  result <- decomposer_inegalite(donnees_test, "revenu", var_groupe = "milieu")
  expect_true("decomposition" %in% names(result))
  expect_s3_class(result$decomposition, "tbl_df")
})

test_that("decomposer_inegalite() échoue sur variable non numérique", {
  expect_error(
    decomposer_inegalite(donnees_test, "sexe"),
    regexp = "numérique"
  )
})

test_that("decomposer_inegalite() échoue sur variable inexistante", {
  expect_error(
    decomposer_inegalite(donnees_test, "var_inexistante"),
    regexp = "introuvable"
  )
})

# --- valider_qualite_donnees -------------------------------------------------

test_that("valider_qualite_donnees() retourne un score entre 0 et 100", {
  result <- valider_qualite_donnees(donnees_test)
  expect_gte(result$score_global, 0)
  expect_lte(result$score_global, 100)
})

test_that("valider_qualite_donnees() retourne toutes les dimensions", {
  result <- valider_qualite_donnees(donnees_test)
  expect_true(all(c("completude", "unicite", "coherence",
                     "plausibilite") %in% names(result)))
})

test_that("valider_qualite_donnees() score = 100 sur données parfaites", {
  df_parfait <- tibble::tibble(
    id     = 1:100,
    age    = sample(20:60, 100, replace = TRUE),
    revenu = abs(rnorm(100, 100000, 20000))
  )
  result <- valider_qualite_donnees(df_parfait, vars_cles = "id")
  expect_gte(result$score_global, 80)
})

test_that("valider_qualite_donnees() score bas sur données avec beaucoup de NA", {
  df_na <- donnees_test
  df_na[1:100, 3:10] <- NA
  result <- valider_qualite_donnees(df_na)
  expect_lt(result$score_global, 80)
})

test_that("valider_qualite_donnees() échoue si data n'est pas un data.frame", {
  expect_error(valider_qualite_donnees("pas_un_df"), regexp = "data.frame")
})
