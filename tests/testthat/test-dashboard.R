# =============================================================================
# statAfrikR - Tests module Dashboard Shiny
# testthat edition 3
# Note : les tests evitent de lancer Shiny (lancer=FALSE)
# =============================================================================

.make_demo_data <- function() {
  suppressMessages(.demo_data_dashboard(n=200L, seed=42L))
}

# =============================================================================
# BLOC 1 - .demo_data_dashboard()
# =============================================================================

test_that(".demo_data_dashboard() : retourne data.frame", {
  d <- suppressMessages(.demo_data_dashboard(200L))
  expect_s3_class(d, "data.frame")
})

test_that(".demo_data_dashboard() : contient les colonnes cles", {
  d <- suppressMessages(.demo_data_dashboard(100L))
  expect_true("poids"       %in% names(d))
  expect_true("region"      %in% names(d))
  expect_true("milieu"      %in% names(d))
  expect_true("conso_pc"    %in% names(d))
  expect_true("satisfaction" %in% names(d))
})

test_that(".demo_data_dashboard() : taille correcte", {
  d <- suppressMessages(.demo_data_dashboard(150L))
  expect_equal(nrow(d), 150L)
})

# =============================================================================
# BLOC 2 - .precalculer_indicateurs()
# =============================================================================

test_that(".precalculer_indicateurs() : retourne une liste", {
  d   <- .make_demo_data()
  res <- suppressMessages(suppressWarnings(
    .precalculer_indicateurs(d, "poids", "region", "milieu", "RCA")
  ))
  expect_true(is.list(res))
})

test_that(".precalculer_indicateurs() : contient .meta", {
  d   <- .make_demo_data()
  res <- suppressMessages(suppressWarnings(
    .precalculer_indicateurs(d, "poids", "region", "milieu", "RCA")
  ))
  expect_true(".meta" %in% names(res))
  expect_equal(res$.meta$pays, "RCA")
  expect_equal(res$.meta$n_obs, 200L)
})

test_that(".precalculer_indicateurs() : calcule fgt", {
  d   <- .make_demo_data()
  res <- suppressMessages(suppressWarnings(
    .precalculer_indicateurs(d, "poids", "region", "milieu", "RCA")
  ))
  expect_false(is.null(res$fgt))
})

test_that(".precalculer_indicateurs() : calcule ipm", {
  d   <- .make_demo_data()
  res <- suppressMessages(suppressWarnings(
    .precalculer_indicateurs(d, "poids", "region", "milieu", "RCA")
  ))
  expect_false(is.null(res$ipm))
})

test_that(".precalculer_indicateurs() : calcule gini", {
  d   <- .make_demo_data()
  res <- suppressMessages(suppressWarnings(
    .precalculer_indicateurs(d, "poids", "region", "milieu", "RCA")
  ))
  expect_false(is.null(res$gini))
})

test_that(".precalculer_indicateurs() : calcule satisfaction", {
  d   <- .make_demo_data()
  res <- suppressMessages(suppressWarnings(
    .precalculer_indicateurs(d, "poids", "region", "milieu", "RCA")
  ))
  expect_false(is.null(res$satisfaction))
})

# =============================================================================
# BLOC 3 - lancer_dashboard() validations
# =============================================================================

test_that("lancer_dashboard() : donnees non data.frame => erreur", {
  expect_error(
    suppressMessages(lancer_dashboard(donnees="pas un df", lancer=FALSE)),
    regexp="data.frame"
  )
})

test_that("lancer_dashboard() : donnees vides => erreur", {
  expect_error(
    suppressMessages(lancer_dashboard(donnees=data.frame(), lancer=FALSE)),
    regexp="non vide"
  )
})

test_that("lancer_dashboard() : shiny absent => message utile", {
  skip_if(requireNamespace("shiny", quietly=TRUE),
          "shiny est installe")
  expect_error(
    lancer_dashboard(lancer=FALSE),
    regexp="shiny"
  )
})

# =============================================================================
# BLOC 4 - lancer_dashboard() avec lancer=FALSE (retourne l'app)
# =============================================================================

test_that("lancer_dashboard() : lancer=FALSE retourne shinyApp", {
  skip_if_not_installed("shiny")
  d   <- .make_demo_data()
  res <- suppressMessages(suppressWarnings(
    lancer_dashboard(donnees=d, var_poids="poids",
                     var_region="region", var_milieu="milieu",
                     pays="RCA", lancer=FALSE)
  ))
  expect_true(inherits(res, "shiny.appobj"))
})

test_that("lancer_dashboard() : demo sans donnees => shinyApp", {
  skip_if_not_installed("shiny")
  res <- suppressMessages(suppressWarnings(
    lancer_dashboard(lancer=FALSE)
  ))
  expect_true(inherits(res, "shiny.appobj"))
})

# =============================================================================
# BLOC 5 - export HTML
# =============================================================================

test_that("lancer_dashboard() : export HTML fonctionne", {
  skip_if_not_installed("shiny")
  d      <- .make_demo_data()
  chemin <- file.path(tempdir(), "test_dashboard.html")
  suppressMessages(suppressWarnings(
    lancer_dashboard(donnees=d, var_poids="poids",
                     pays="RCA", export_html=chemin)
  ))
  expect_true(file.exists(chemin))
  html <- readLines(chemin)
  expect_true(any(grepl("statAfrikR", html)))
  withr::defer(unlink(chemin))
})

test_that("lancer_dashboard() : HTML contient les sections", {
  skip_if_not_installed("shiny")
  d      <- .make_demo_data()
  chemin <- file.path(tempdir(), "test_dash2.html")
  suppressMessages(suppressWarnings(
    lancer_dashboard(donnees=d, var_poids="poids",
                     pays="RCA", export_html=chemin)
  ))
  html <- paste(readLines(chemin), collapse=" ")
  expect_true(grepl("pauvrete", html, ignore.case=TRUE))
  expect_true(grepl("ipm|IPM", html))
  withr::defer(unlink(chemin))
})

# =============================================================================
# BLOC 6 - .build_ui()
# =============================================================================

test_that(".build_ui() : retourne shiny HTML", {
  skip_if_not_installed("shiny")
  d   <- .make_demo_data()
  ind <- suppressMessages(suppressWarnings(
    .precalculer_indicateurs(d, "poids", "region", "milieu", "RCA")
  ))
  ui  <- .build_ui("RCA", ind)
  expect_true(inherits(ui, "html") || is.character(ui))
})
