# =============================================================================
# statAfrikR - Tests module Controles qualite demographique
# testthat edition 3
# =============================================================================

.make_pop <- function(n = 2000, seed = 42, attraction = 0.15) {
  set.seed(seed)
  ages_base <- sample(10:79, n, TRUE)
  ages <- ifelse(runif(n) < attraction,
                 ages_base - ages_base %% 5, ages_base)
  data.frame(
    age        = pmax(0, pmin(100, ages)),
    sexe       = sample(c("H","F"), n, TRUE, prob=c(0.49,0.51)),
    age_mere   = sample(20:55, n, TRUE),
    age_enfant = sample(0:25,  n, TRUE),
    poids      = runif(n, 0.8, 1.3),
    stringsAsFactors = FALSE
  )
}

# =============================================================================
# BLOC 1 - whipple()
# =============================================================================

test_that("whipple() : retourne saf_qualite_demo", {
  d   <- .make_pop()
  res <- suppressMessages(suppressWarnings(whipple(d, "age")))
  expect_s3_class(res, "saf_qualite_demo")
})

test_that("whipple() : indice positif", {
  d   <- .make_pop()
  res <- suppressMessages(suppressWarnings(whipple(d, "age")))
  expect_gt(res$indice, 0)
})

test_that("whipple() : forte attraction => indice eleve", {
  set.seed(42)
  n <- 1000
  ages_base <- sample(23:62, n, TRUE)
  ages_fort <- ages_base - (ages_base %% 5)
  d1 <- data.frame(age = ages_base)
  d2 <- data.frame(age = ages_fort)
  r1 <- suppressMessages(suppressWarnings(whipple(d1, "age")))
  r2 <- suppressMessages(suppressWarnings(whipple(d2, "age")))
  expect_lt(r1$indice, r2$indice)
})

test_that("whipple() : variable introuvable => erreur", {
  d <- .make_pop()
  expect_error(whipple(d, "xxx"), regexp="introuvable")
})

test_that("whipple() : donnees vides => erreur", {
  expect_error(whipple(data.frame(), "age"), regexp="non vide")
})

test_that("whipple() : poids introuvable => erreur", {
  d <- .make_pop()
  expect_error(whipple(d, "age", poids="xxx"), regexp="introuvable")
})

test_that("whipple() : avec poids fonctionne", {
  d   <- .make_pop()
  res <- suppressMessages(suppressWarnings(
    whipple(d, "age", poids="poids")))
  expect_s3_class(res, "saf_qualite_demo")
})

test_that("whipple() : interpretation presente", {
  d   <- .make_pop()
  res <- suppressMessages(suppressWarnings(whipple(d, "age")))
  expect_true(nchar(res$interpretation) > 0)
})

test_that("whipple() : print sans erreur", {
  d   <- .make_pop()
  res <- suppressMessages(suppressWarnings(whipple(d, "age")))
  expect_output(print(res), "Whipple")
})

# =============================================================================
# BLOC 2 - myers()
# =============================================================================

test_that("myers() : retourne saf_qualite_demo", {
  d   <- .make_pop()
  res <- suppressMessages(myers(d, "age"))
  expect_s3_class(res, "saf_qualite_demo")
})

test_that("myers() : indice entre 0 et 90", {
  d   <- .make_pop()
  res <- suppressMessages(myers(d, "age"))
  expect_gte(res$indice, 0)
  expect_lte(res$indice, 90)
})

test_that("myers() : distribution 10 chiffres", {
  d   <- .make_pop()
  res <- suppressMessages(myers(d, "age"))
  expect_equal(nrow(res$distribution), 10L)
})

test_that("myers() : variable introuvable => erreur", {
  d <- .make_pop()
  expect_error(myers(d, "xxx"), regexp="introuvable")
})

test_that("myers() : forte attraction => indice eleve", {
  set.seed(42)
  n <- 1000
  ages_uniform <- sample(10:89, n, TRUE)
  ages_biaise  <- ages_uniform - (ages_uniform %% 10)
  d1 <- data.frame(age=ages_uniform)
  d2 <- data.frame(age=ages_biaise)
  r1 <- suppressMessages(myers(d1, "age"))
  r2 <- suppressMessages(myers(d2, "age"))
  expect_lt(r1$indice, r2$indice)
})

test_that("myers() : print sans erreur", {
  d   <- .make_pop()
  res <- suppressMessages(myers(d, "age"))
  expect_output(print(res), "Myers")
})

# =============================================================================
# BLOC 3 - ratio_masculinite()
# =============================================================================

test_that("ratio_masculinite() : retourne tibble", {
  d   <- .make_pop()
  res <- suppressMessages(
    ratio_masculinite(d, "age", "sexe", poids="poids"))
  expect_s3_class(res, "data.frame")
})

test_that("ratio_masculinite() : colonnes attendues", {
  d   <- .make_pop()
  res <- suppressMessages(
    ratio_masculinite(d, "age", "sexe"))
  expect_true(all(c("groupe_age","H","F","ratio","alerte")
                  %in% names(res)))
})

test_that("ratio_masculinite() : ratios positifs", {
  d   <- .make_pop()
  res <- suppressMessages(
    ratio_masculinite(d, "age", "sexe"))
  expect_true(all(res$ratio[!is.na(res$ratio)] > 0))
})

test_that("ratio_masculinite() : variable introuvable => erreur", {
  d <- .make_pop()
  expect_error(ratio_masculinite(d,"xxx","sexe"), regexp="introuvable")
  expect_error(ratio_masculinite(d,"age","xxx"),  regexp="introuvable")
})

# =============================================================================
# BLOC 4 - pyramide_age()
# =============================================================================

test_that("pyramide_age() : retourne ggplot", {
  d   <- .make_pop()
  g   <- pyramide_age(d, "age", "sexe", poids="poids")
  expect_s3_class(g, "ggplot")
})

test_that("pyramide_age() : avec titre et source", {
  d   <- .make_pop(500)
  g   <- pyramide_age(d, "age", "sexe",
                       titre="Test", source="INS")
  expect_s3_class(g, "ggplot")
})

test_that("pyramide_age() : variable introuvable => erreur", {
  d <- .make_pop()
  expect_error(pyramide_age(d,"xxx","sexe"), regexp="introuvable")
})

# =============================================================================
# BLOC 5 - coherence_demo()
# =============================================================================

test_that("coherence_demo() : aucune anomalie => tibble OK", {
  d   <- .make_pop()
  res <- suppressMessages(coherence_demo(d, var_age="age"))
  expect_s3_class(res, "data.frame")
})

test_that("coherence_demo() : detecte ages negatifs", {
  d <- .make_pop(100)
  d$age[1:5] <- -1L
  res <- suppressMessages(coherence_demo(d, var_age="age"))
  expect_true(any(grepl("negatif", res$type_anomalie, ignore.case=TRUE)))
})

test_that("coherence_demo() : detecte ages impossibles", {
  d <- .make_pop(100)
  d$age[1:3] <- 130L
  res <- suppressMessages(coherence_demo(d, var_age="age"))
  expect_true(any(grepl("120", res$type_anomalie)))
})

test_that("coherence_demo() : detecte incoh mere-enfant", {
  d <- .make_pop(200)
  d$age_mere[1:10]   <- 20L
  d$age_enfant[1:10] <- 15L
  res <- suppressMessages(
    coherence_demo(d, var_age_mere="age_mere",
                    var_age_enfant="age_enfant"))
  expect_true(any(grepl("mere|enfant", res$type_anomalie,
                         ignore.case=TRUE)))
})

test_that("coherence_demo() : detecte sexe invalide", {
  d <- .make_pop(100)
  d$sexe[1:5] <- "X"
  res <- suppressMessages(
    coherence_demo(d, var_sexe="sexe"))
  expect_true(any(grepl("sexe", res$type_anomalie, ignore.case=TRUE)))
})

test_that("coherence_demo() : donnees vides => erreur", {
  expect_error(coherence_demo(data.frame()), regexp="non vide")
})

# =============================================================================
# BLOC 6 - rapport_qualite_demo()
# =============================================================================

test_that("rapport_qualite_demo() : retourne tibble", {
  d   <- .make_pop()
  res <- suppressMessages(
    rapport_qualite_demo(d, "age", pays="RCA", annee=2024L))
  expect_s3_class(res, "data.frame")
})

test_that("rapport_qualite_demo() : avec sexe => 3 indicateurs", {
  d   <- .make_pop()
  res <- suppressMessages(
    rapport_qualite_demo(d, "age", var_sexe="sexe", pays="RCA"))
  expect_equal(nrow(res), 3L)
})

test_that("rapport_qualite_demo() : sans sexe => 2 indicateurs", {
  d   <- .make_pop()
  res <- suppressMessages(
    rapport_qualite_demo(d, "age", pays="RCA"))
  expect_equal(nrow(res), 2L)
})

test_that("rapport_qualite_demo() : colonnes statut et valeur", {
  d   <- .make_pop()
  res <- suppressMessages(
    rapport_qualite_demo(d, "age", pays="RCA"))
  expect_true(all(c("indicateur","valeur","statut","pays","annee")
                  %in% names(res)))
})

test_that("rapport_qualite_demo() : variable introuvable => erreur", {
  d <- .make_pop()
  expect_error(rapport_qualite_demo(d, "xxx"), regexp="introuvable")
})
