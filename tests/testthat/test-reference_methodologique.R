# =============================================================================
# statAfrikR - Tests de reference methodologique
# Validation des methodes sur des datasets avec valeurs attendues connues
#
# Sources de reference :
#   - FGT  : Foster, Greer & Thorbecke (1984) Econometrica 52(3)
#   - Gini : Formule analytique sur distributions connues
#   - IPM  : PNUD/OPHI - Alkire & Foster (2011) doi:10.1093/oep/gpr051
#   - Whipple : ONU DESA (2002) Methods for Estimating...
#   - Myers : Myers (1940) JASA 35(211)
# =============================================================================

# =============================================================================
# BLOC 1 - FGT : valeurs de reference analytiques
# =============================================================================

# Jeu de donnees simple avec valeur FGT connue
# Population : 10 individus, seuil z = 5
# Revenus : 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
# FGT0 = 4/10 = 0.4 (individus 1,2,3,4 sous le seuil)
# FGT1 = [(5-1)/5 + (5-2)/5 + (5-3)/5 + (5-4)/5] / 10
#       = [0.8 + 0.6 + 0.4 + 0.2] / 10 = 2.0/10 = 0.2
# FGT2 = [(4/5)^2 + (3/5)^2 + (2/5)^2 + (1/5)^2] / 10
#       = [0.64 + 0.36 + 0.16 + 0.04] / 10 = 1.2/10 = 0.12

.ref_fgt <- data.frame(
  revenu = 1:10,
  poids  = rep(1, 10),
  stringsAsFactors = FALSE
)

test_that("[REF-FGT] FGT0 = 0.4 (reference analytique)", {
  res <- suppressMessages(
    calcul_fgt(.ref_fgt, "revenu", seuil_pauvrete=5, poids="poids"))
  expect_equal(res$national$fgt0, 0.4, tolerance=1e-6)
})

test_that("[REF-FGT] FGT1 = 0.2 (reference analytique)", {
  res <- suppressMessages(
    calcul_fgt(.ref_fgt, "revenu", seuil_pauvrete=5, poids="poids"))
  expect_equal(res$national$fgt1, 0.2, tolerance=1e-6)
})

test_that("[REF-FGT] FGT2 = 0.12 (reference analytique)", {
  res <- suppressMessages(
    calcul_fgt(.ref_fgt, "revenu", seuil_pauvrete=5, poids="poids"))
  expect_equal(res$national$fgt2, 0.12, tolerance=1e-6)
})

test_that("[REF-FGT] FGT0 = 0 si tout le monde au-dessus du seuil", {
  d   <- data.frame(revenu=6:10, poids=rep(1,5))
  res <- suppressMessages(calcul_fgt(d, "revenu", seuil_pauvrete=5))
  expect_equal(res$national$fgt0, 0)
})

test_that("[REF-FGT] FGT0 = 1 si tout le monde sous le seuil", {
  d   <- data.frame(revenu=1:4, poids=rep(1,4))
  res <- suppressMessages(calcul_fgt(d, "revenu", seuil_pauvrete=5))
  expect_equal(res$national$fgt0, 1)
})

test_that("[REF-FGT] FGT0 >= FGT1 >= FGT2 toujours", {
  set.seed(42)
  d   <- data.frame(revenu=runif(200, 0, 10), poids=rep(1,200))
  res <- suppressMessages(calcul_fgt(d, "revenu", seuil_pauvrete=5))
  expect_gte(res$national$fgt0, res$national$fgt1)
  expect_gte(res$national$fgt1, res$national$fgt2)
})

test_that("[REF-FGT] Decomposition FGT est additive (somme = national)", {
  set.seed(42)
  d <- data.frame(
    revenu = runif(200, 0, 10),
    groupe = rep(c("A","B"), 100),
    poids  = rep(1, 200)
  )
  res <- suppressMessages(
    calcul_fgt(d, "revenu", seuil_pauvrete=5,
               poids="poids", sous_groupes="groupe"))
  # FGT0 national = moyenne ponderee des FGT0 par groupe
  fgt0_A <- res$sous_groupes$groupe$fgt0[res$sous_groupes$groupe$.modalite=="A"]
  fgt0_B <- res$sous_groupes$groupe$fgt0[res$sous_groupes$groupe$.modalite=="B"]
  fgt0_agg <- (fgt0_A * 100 + fgt0_B * 100) / 200
  expect_equal(res$national$fgt0, fgt0_agg, tolerance=0.01)
})

# =============================================================================
# BLOC 2 - GINI : valeurs de reference
# =============================================================================

# Distribution parfaitement egale => Gini = 0
test_that("[REF-GINI] Gini = 0 pour distribution uniforme", {
  d   <- data.frame(revenu=rep(1000, 100), poids=rep(1,100))
  res <- suppressMessages(calcul_gini(d, "revenu"))
  expect_equal(res$gini, 0, tolerance=1e-4)
})

# Distribution maximalement inegale (1 personne a tout) => Gini proche de 1
test_that("[REF-GINI] Gini proche de 1 pour inegalite maximale", {
  d   <- data.frame(
    revenu = c(rep(0, 99), 1000000),
    poids  = rep(1, 100)
  )
  res <- suppressMessages(calcul_gini(d, "revenu"))
  expect_gt(res$gini, 0.95)
})

# Gini entre 0 et 1
test_that("[REF-GINI] Gini dans [0, 1] pour distribution quelconque", {
  set.seed(42)
  d   <- data.frame(revenu=rlnorm(500, 12, 0.8), poids=runif(500,0.8,1.3))
  res <- suppressMessages(calcul_gini(d, "revenu", poids="poids"))
  expect_gte(res$gini, 0)
  expect_lte(res$gini, 1)
})

test_that("[REF-GINI] Gini invariant a l'ordre des observations", {
  d1 <- data.frame(revenu=c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20), poids=rep(1,20))
  d2 <- data.frame(revenu=c(20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1), poids=rep(1,20))
  r1 <- suppressMessages(calcul_gini(d1, "revenu"))
  r2 <- suppressMessages(calcul_gini(d2, "revenu"))
  r1 <- suppressMessages(calcul_gini(d1, "revenu"))
  r2 <- suppressMessages(calcul_gini(d2, "revenu"))
  expect_equal(r1$gini, r2$gini, tolerance=1e-6)
})

# =============================================================================
# BLOC 3 - IPM : coherence interne
# =============================================================================

test_that("[REF-IPM] IPM = H x A", {
  set.seed(42)
  n <- 500
  d <- data.frame(
    nutr    = rbinom(n,1,0.4),
    mort    = rbinom(n,1,0.1),
    scol_ad = rbinom(n,1,0.3),
    scol_en = rbinom(n,1,0.5),
    elec    = rbinom(n,1,0.6),
    eau     = rbinom(n,1,0.4),
    assain  = rbinom(n,1,0.5),
    combust = rbinom(n,1,0.7),
    logem   = rbinom(n,1,0.4),
    actifs  = rbinom(n,1,0.3)
  )
  res <- suppressMessages(calcul_ipm(d,
    var_nutrition="nutr", var_mortalite_inf="mort",
    var_annees_scol="scol_ad", var_scolarisation="scol_en",
    var_electricite="elec", var_eau="eau",
    var_assainissement="assain", var_combustible="combust",
    var_logement="logem", var_actifs="actifs"))
  expect_equal(res$IPM, round(res$H * res$A, 4), tolerance=1e-3)
})

test_that("[REF-IPM] H dans [0,1] et A dans [0,1]", {
  set.seed(42)
  n <- 300
  d <- data.frame(
    nutr=rbinom(n,1,0.4), mort=rbinom(n,1,0.1),
    scol_ad=rbinom(n,1,0.3), scol_en=rbinom(n,1,0.5),
    elec=rbinom(n,1,0.6), eau=rbinom(n,1,0.4),
    assain=rbinom(n,1,0.5), combust=rbinom(n,1,0.7),
    logem=rbinom(n,1,0.4), actifs=rbinom(n,1,0.3)
  )
  res <- suppressMessages(calcul_ipm(d,
    var_nutrition="nutr", var_mortalite_inf="mort",
    var_annees_scol="scol_ad", var_scolarisation="scol_en",
    var_electricite="elec", var_eau="eau",
    var_assainissement="assain", var_combustible="combust",
    var_logement="logem", var_actifs="actifs"))
  expect_gte(res$H, 0); expect_lte(res$H, 1)
  expect_gte(res$A, 0); expect_lte(res$A, 1)
})

test_that("[REF-IPM] IPM = 0 si aucune privation", {
  n <- 200
  d <- data.frame(matrix(0L, nrow=n, ncol=10))
  names(d) <- c("nutr","mort","scol_ad","scol_en","elec",
                 "eau","assain","combust","logem","actifs")
  res <- suppressMessages(calcul_ipm(d,
    var_nutrition="nutr", var_mortalite_inf="mort",
    var_annees_scol="scol_ad", var_scolarisation="scol_en",
    var_electricite="elec", var_eau="eau",
    var_assainissement="assain", var_combustible="combust",
    var_logement="logem", var_actifs="actifs"))
  expect_equal(res$IPM, 0, tolerance=1e-6)
})

# =============================================================================
# BLOC 4 - WHIPPLE : valeur de reference
# =============================================================================

# Ages uniformement distribues => Whipple proche de 100
test_that("[REF-WHIPPLE] Whipple ~ 100 pour distribution uniforme", {
  d   <- data.frame(age = rep(23:62, 100))
  res <- suppressMessages(suppressWarnings(whipple(d, "age")))
  expect_equal(res$indice, 100, tolerance=5)
})

# Tous ages multiples de 5 => Whipple tres eleve
test_that("[REF-WHIPPLE] Whipple eleve si tous ages multiples de 5", {
  d   <- data.frame(age = rep(c(25,30,35,40,45,50,55,60), 50))
  res <- suppressMessages(suppressWarnings(whipple(d, "age")))
  expect_gt(res$indice, 400)
})

# =============================================================================
# BLOC 5 - MYERS : coherence
# =============================================================================

# Distribution uniforme => Myers proche de 0
test_that("[REF-MYERS] Myers ~ 0 pour distribution uniforme", {
  d   <- data.frame(age = rep(10:89, 10))
  res <- suppressMessages(myers(d, "age"))
  expect_lt(res$indice, 5)
})

# Myers dans [0, 90]
test_that("[REF-MYERS] Myers dans [0, 90]", {
  set.seed(42)
  d   <- data.frame(age = sample(10:89, 500, TRUE))
  res <- suppressMessages(myers(d, "age"))
  expect_gte(res$indice, 0)
  expect_lte(res$indice, 90)
})

# =============================================================================
# BLOC 6 - GINI vs LORENZ coherence
# =============================================================================

test_that("[REF-LORENZ] Somme parts quintile = 100%", {
  set.seed(42)
  d   <- data.frame(revenu=rlnorm(500, 12, 0.8), poids=rep(1,500))
  res <- suppressMessages(part_quintile(d, "revenu"))
  expect_equal(sum(res$part_revenu, na.rm=TRUE), 100, tolerance=1)
})


test_that("[REF-LORENZ] Part Q5 > Part Q1 pour toute distribution inegale", {
  set.seed(42)
  d   <- data.frame(revenu=c(seq(1000,1400,100), seq(9000,10000,100)))
  res <- suppressMessages(part_quintile(d, "revenu"))
  col_pct <- "part_revenu"
  q1 <- res$part_revenu[res$groupe == "Quintile 1"]
  q5 <- res$part_revenu[res$groupe == "Quintile 5"]
  expect_gt(q5, q1)
})
# BLOC 7 - VALIDER_STATISTIQUE_INS coherence
# =============================================================================

test_that("[REF-VALIDATION] Statut VALIDE si donnees propres", {
  set.seed(42)
  d <- data.frame(
    region = sample(c("N","S","E","O"), 200, TRUE),
    poids  = runif(200, 800, 3500),
    revenu = pmax(1000, rnorm(200, 165000, 50000))
  )
  res <- suppressMessages(
    valider_statistique_ins(d, var_poids="poids", pays="Test"))
  expect_true(res$statut_global %in% c("VALIDE","A VERIFIER"))
})

test_that("[REF-VALIDATION] n_fail = 0 si donnees parfaites", {
  d <- data.frame(
    x = 1:100, y = rnorm(100),
    poids = rep(1000, 100)
  )
  res <- suppressMessages(
    valider_statistique_ins(d, var_poids="poids", pays="Test"))
  expect_equal(res$n_fail, 0L)
})


