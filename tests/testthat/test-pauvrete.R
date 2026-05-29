# =============================================================================
# statAfrikR — Tests module Pauvreté (FGT)
# testthat edition 3 — Couverture cible : > 95%
# =============================================================================

# Données de test réutilisables (reproductibles)
menages_test <- local({
  set.seed(2024)
  n <- 200
  data.frame(
    id_menage  = 1:n,
    depense_pc = c(
      rexp(140, rate = 1 / 150000),   # 70% pauvres potentiels
      rexp(60,  rate = 1 / 450000)    # 30% non pauvres
    ),
    poids      = runif(n, 0.7, 1.4),
    region     = sample(c("Bangui", "Ombella", "Lobaye", "Sangha"), n, TRUE),
    milieu     = sample(c("urbain", "rural"), n, TRUE, prob = c(0.35, 0.65)),
    sexe_cm    = sample(c("homme", "femme"), n, TRUE, prob = c(0.72, 0.28))
  )
})

SEUIL_TEST <- 200000  # Seuil de pauvreté en FCFA

# =============================================================================
# BLOC 1 — calcul_fgt() : résultats de base
# =============================================================================

test_that("calcul_fgt() retourne un objet saf_fgt valide", {
  fgt <- calcul_fgt(menages_test, "depense_pc", SEUIL_TEST)
  expect_s3_class(fgt, "saf_fgt")
  expect_true(is.list(fgt))
  expect_named(fgt, c("national", "sous_groupes", "n_total", "n_pauvres",
                       "seuil", "var_depense", "na_count", "alpha", "appel"))
})

test_that("calcul_fgt() : indices dans [0, 1]", {
  fgt <- calcul_fgt(menages_test, "depense_pc", SEUIL_TEST)
  nat <- fgt$national
  for (col in c("fgt0", "fgt1", "fgt2")) {
    if (col %in% names(nat)) {
      expect_gte(nat[[col]], 0, label = paste(col, ">= 0"))
      expect_lte(nat[[col]], 1, label = paste(col, "<= 1"))
    }
  }
})

test_that("calcul_fgt() : FGT0 >= FGT1 >= FGT2 (propriété mathématique)", {
  fgt <- calcul_fgt(menages_test, "depense_pc", SEUIL_TEST)
  nat <- fgt$national
  if (all(c("fgt0", "fgt1", "fgt2") %in% names(nat))) {
    expect_gte(nat$fgt0, nat$fgt1 - 1e-9)
    expect_gte(nat$fgt1, nat$fgt2 - 1e-9)
  }
})

test_that("calcul_fgt() : seuil = 0 => FGT0 = 0 (personne pauvre)", {
  fgt <- calcul_fgt(menages_test, "depense_pc", seuil_pauvrete = 1)
  expect_equal(fgt$national$fgt0, 0, tolerance = 1e-6)
})

test_that("calcul_fgt() : seuil > max(depense) => FGT0 = 1 (tous pauvres)", {
  seuil_max <- max(menages_test$depense_pc) * 2
  fgt <- calcul_fgt(menages_test, "depense_pc", seuil_max)
  expect_equal(fgt$national$fgt0, 1, tolerance = 1e-6)
})

test_that("calcul_fgt() : FGT0 cohérent avec calcul manuel", {
  taux_ref <- mean(menages_test$depense_pc < SEUIL_TEST)
  fgt <- calcul_fgt(menages_test, "depense_pc", SEUIL_TEST)
  expect_equal(fgt$national$fgt0, taux_ref, tolerance = 1e-6)
})

test_that("calcul_fgt() : n_total et n_pauvres cohérents", {
  fgt <- calcul_fgt(menages_test, "depense_pc", SEUIL_TEST)
  expect_equal(fgt$n_total, nrow(menages_test))
  expect_lte(fgt$n_pauvres, fgt$n_total)
  expect_gte(fgt$n_pauvres, 0L)
})

test_that("calcul_fgt() : intervalles de confiance cohérents (ic = TRUE)", {
  fgt <- calcul_fgt(menages_test, "depense_pc", SEUIL_TEST, ic = TRUE)
  nat <- fgt$national
  if (all(c("fgt0", "fgt0_ic_bas", "fgt0_ic_haut") %in% names(nat))) {
    expect_lte(nat$fgt0_ic_bas,  nat$fgt0 + 1e-9)
    expect_gte(nat$fgt0_ic_haut, nat$fgt0 - 1e-9)
    expect_gte(nat$fgt0_ic_bas,  0)
  }
})

test_that("calcul_fgt() : sans IC (ic = FALSE)", {
  fgt <- calcul_fgt(menages_test, "depense_pc", SEUIL_TEST, ic = FALSE)
  expect_false("fgt0_ic_bas" %in% names(fgt$national))
})

# =============================================================================
# BLOC 2 — calcul_fgt() : pondération
# =============================================================================

test_that("calcul_fgt() avec poids : résultat différent du non pondéré", {
  fgt_np <- calcul_fgt(menages_test, "depense_pc", SEUIL_TEST)
  fgt_p  <- calcul_fgt(menages_test, "depense_pc", SEUIL_TEST,
                        poids = "poids")
  # Avec des poids variables, le résultat doit différer (légèrement)
  expect_false(isTRUE(all.equal(fgt_np$national$fgt0,
                                 fgt_p$national$fgt0)))
})

test_that("calcul_fgt() avec poids uniformes == sans poids", {
  menages_up <- menages_test
  menages_up$poids_uni <- 1
  fgt_np <- calcul_fgt(menages_test, "depense_pc", SEUIL_TEST)
  fgt_p  <- calcul_fgt(menages_up, "depense_pc", SEUIL_TEST,
                        poids = "poids_uni")
  expect_equal(fgt_np$national$fgt0, fgt_p$national$fgt0, tolerance = 1e-6)
})

# =============================================================================
# BLOC 3 — calcul_fgt() : sous-groupes
# =============================================================================

test_that("calcul_fgt() avec sous_groupes : structure valide", {
  fgt <- calcul_fgt(menages_test, "depense_pc", SEUIL_TEST,
                    poids = "poids",
                    sous_groupes = c("milieu", "sexe_cm"))
  expect_false(is.null(fgt$sous_groupes))
  expect_named(fgt$sous_groupes, c("milieu", "sexe_cm"))
})

test_that("calcul_fgt() : FGT0 sous-groupes dans [0, 1]", {
  fgt <- calcul_fgt(menages_test, "depense_pc", SEUIL_TEST,
                    sous_groupes = "milieu")
  sg <- fgt$sous_groupes$milieu
  expect_true(all(sg$fgt0 >= 0 & sg$fgt0 <= 1))
})

test_that("calcul_fgt() : modalités sous-groupe = modalités réelles", {
  fgt <- calcul_fgt(menages_test, "depense_pc", SEUIL_TEST,
                    sous_groupes = "milieu")
  expect_setequal(
    fgt$sous_groupes$milieu$.modalite,
    as.character(sort(unique(menages_test$milieu)))
  )
})

# =============================================================================
# BLOC 4 — calcul_fgt() : gestion des NA
# =============================================================================

test_that("calcul_fgt() : na.rm = TRUE fonctionne silencieusement (< 5% NA)", {
  menages_na <- menages_test
  menages_na$depense_pc[1:5] <- NA  # 2.5% NA — sous le seuil d'alerte
  expect_no_error(calcul_fgt(menages_na, "depense_pc", SEUIL_TEST,
                              na.rm = TRUE))
})

test_that("calcul_fgt() : na.rm = TRUE avec > 5% NA émet un warning", {
  menages_na <- menages_test
  menages_na$depense_pc[1:20] <- NA  # 10% NA
  expect_warning(
    calcul_fgt(menages_na, "depense_pc", SEUIL_TEST, na.rm = TRUE),
    regexp = "valeurs manquantes"
  )
})

test_that("calcul_fgt() : na.rm = FALSE avec NA génère une erreur", {
  menages_na <- menages_test
  menages_na$depense_pc[1] <- NA
  expect_error(
    calcul_fgt(menages_na, "depense_pc", SEUIL_TEST, na.rm = FALSE),
    regexp = "manquantes"
  )
})

test_that("calcul_fgt() : na_count correct", {
  menages_na <- menages_test
  menages_na$depense_pc[1:8] <- NA
  fgt <- suppressWarnings(
    calcul_fgt(menages_na, "depense_pc", SEUIL_TEST)
  )
  expect_equal(fgt$na_count, 8L)
})

# =============================================================================
# BLOC 5 — calcul_fgt() : validations d'erreurs
# =============================================================================

test_that("calcul_fgt() : variable inexistante => erreur claire", {
  expect_error(
    calcul_fgt(menages_test, "var_inexistante", SEUIL_TEST),
    regexp = "introuvable"
  )
})

test_that("calcul_fgt() : variable non numérique => erreur", {
  expect_error(
    calcul_fgt(menages_test, "region", SEUIL_TEST),
    regexp = "numerique"
  )
})

test_that("calcul_fgt() : seuil négatif => erreur", {
  expect_error(
    calcul_fgt(menages_test, "depense_pc", -1000),
    regexp = "positif"
  )
})

test_that("calcul_fgt() : alpha invalide => erreur", {
  expect_error(
    calcul_fgt(menages_test, "depense_pc", SEUIL_TEST, alpha = 3),
    regexp = "0, 1"
  )
})

test_that("calcul_fgt() : sous-groupe inexistant => erreur", {
  expect_error(
    calcul_fgt(menages_test, "depense_pc", SEUIL_TEST,
               sous_groupes = "var_inexistante"),
    regexp = "introuvable"
  )
})

# =============================================================================
# BLOC 6 — decomposer_fgt()
# =============================================================================

test_that("decomposer_fgt() : structure valide", {
  fgt <- calcul_fgt(menages_test, "depense_pc", SEUIL_TEST,
                    poids = "poids", sous_groupes = "milieu")
  decomp <- decomposer_fgt(fgt, "milieu", alpha_cible = 0)
  expect_true(is.data.frame(decomp))
  expect_true(all(c("modalite", "fgt_local", "n",
                     "part_population", "contribution_abs",
                     "contribution_rel") %in% names(decomp)))
})

test_that("decomposer_fgt() : somme des contributions ≈ 100%", {
  fgt <- calcul_fgt(menages_test, "depense_pc", SEUIL_TEST,
                    sous_groupes = "milieu")
  decomp <- decomposer_fgt(fgt, "milieu", alpha_cible = 0)
  expect_equal(sum(decomp$contribution_rel), 100, tolerance = 0.5)
})

test_that("decomposer_fgt() : parts de population somment à 1", {
  fgt <- calcul_fgt(menages_test, "depense_pc", SEUIL_TEST,
                    sous_groupes = "milieu")
  decomp <- decomposer_fgt(fgt, "milieu")
  expect_equal(sum(decomp$part_population), 1, tolerance = 1e-6)
})

test_that("decomposer_fgt() : erreur si sous-groupe absent", {
  fgt <- calcul_fgt(menages_test, "depense_pc", SEUIL_TEST)
  expect_error(decomposer_fgt(fgt, "milieu"), regexp = "Relancez")
})

test_that("decomposer_fgt() : erreur si objet non saf_fgt", {
  expect_error(decomposer_fgt(list(), "milieu"), regexp = "saf_fgt")
})

# =============================================================================
# BLOC 7 — tableau_fgt()
# =============================================================================

test_that("tableau_fgt() : format tibble", {
  fgt <- calcul_fgt(menages_test, "depense_pc", SEUIL_TEST)
  tab <- tableau_fgt(fgt, format = "tibble")
  expect_true(is.data.frame(tab))
  expect_gt(nrow(tab), 0)
})

test_that("tableau_fgt() : format excel dans tempdir()", {
  skip_if_not_installed("openxlsx2")
  fgt <- calcul_fgt(menages_test, "depense_pc", SEUIL_TEST)
  chemin <- file.path(tempdir(), "test_fgt.xlsx")
  res <- tableau_fgt(fgt, format = "excel", chemin = chemin)
  expect_true(file.exists(chemin))
  # Nettoyage
  withr::defer(unlink(chemin))
})

test_that("tableau_fgt() : erreur si objet non saf_fgt", {
  expect_error(tableau_fgt(list()), regexp = "saf_fgt")
})

# =============================================================================
# BLOC 8 — graphique_fgt()
# =============================================================================

test_that("graphique_fgt() type 'indices' : objet ggplot2", {
  fgt <- calcul_fgt(menages_test, "depense_pc", SEUIL_TEST)
  g   <- graphique_fgt(fgt, type = "indices")
  expect_s3_class(g, "ggplot")
})

test_that("graphique_fgt() type 'barres' avec sous-groupe : objet ggplot2", {
  fgt <- calcul_fgt(menages_test, "depense_pc", SEUIL_TEST,
                    sous_groupes = "milieu")
  g   <- graphique_fgt(fgt, type = "barres", variable = "milieu")
  expect_s3_class(g, "ggplot")
})

test_that("graphique_fgt() : erreur sans sous-groupe pour type 'barres'", {
  fgt <- calcul_fgt(menages_test, "depense_pc", SEUIL_TEST)
  expect_error(graphique_fgt(fgt, type = "barres"), regexp = "sous-groupe")
})

# =============================================================================
# BLOC 9 — print.saf_fgt() et as.data.frame.saf_fgt()
# =============================================================================

test_that("print.saf_fgt() ne génère pas d'erreur", {
  fgt <- calcul_fgt(menages_test, "depense_pc", SEUIL_TEST)
  expect_output(print(fgt), regexp = "FGT")
})

test_that("as.data.frame.saf_fgt() fonctionne", {
  fgt <- calcul_fgt(menages_test, "depense_pc", SEUIL_TEST)
  df  <- as.data.frame(fgt)
  expect_true(is.data.frame(df))
})
