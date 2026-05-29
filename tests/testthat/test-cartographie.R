# =============================================================================
# statAfrikR - Tests module Cartographie
# testthat edition 3 - sf en Suggests
# =============================================================================

# Creer un objet sf minimal pour les tests
make_sf_test <- function(n = 5) {
  skip_if_not_installed("sf")
  polys <- lapply(seq_len(n), function(i) {
    x0 <- (i - 1) * 2
    sf::st_polygon(list(matrix(
      c(x0, 0, x0+2, 0, x0+2, 2, x0, 2, x0, 0),
      ncol = 2, byrow = TRUE
    )))
  })
  sf::st_sf(
    region     = paste0("Region_", LETTERS[seq_len(n)]),
    code       = paste0("R0", seq_len(n)),
    population = c(250000L, 180000L, 320000L, 90000L, 410000L)[seq_len(n)],
    geometry   = sf::st_sfc(polys, crs = 4326)
  )
}

make_stats_test <- function(n = 5) {
  set.seed(42)
  data.frame(
    region_code = paste0("R0", seq_len(n)),
    taux_pauvrete  = c(0.42, 0.31, 0.58, 0.25, 0.67)[seq_len(n)],
    taux_electricite = c(0.55, 0.72, 0.38, 0.80, 0.29)[seq_len(n)],
    stringsAsFactors = FALSE
  )
}

# =============================================================================
# BLOC 1 - carte_import() -- tests avec fichier reel
# =============================================================================

test_that("carte_import() : fichier inexistant => erreur", {
  skip_if_not_installed("sf")
  expect_error(
    carte_import("/tmp/fichier_inexistant.shp"),
    regexp = "introuvable"
  )
})

test_that("carte_import() : chemin vide => erreur", {
  skip_if_not_installed("sf")
  expect_error(
    carte_import("/tmp/fichier_inexistant.shp"),
    regexp = "introuvable"
  )
})

# =============================================================================
# BLOC 2 - carte_joindre()
# =============================================================================

test_that("carte_joindre() : jointure basique fonctionne", {
  skip_if_not_installed("sf")
  sf_test    <- make_sf_test()
  stats_test <- make_stats_test()
  result     <- suppressWarnings(
    carte_joindre(sf_test, stats_test,
                  cle_geo = "code", cle_data = "region_code")
  )
  expect_s3_class(result, "sf")
})

test_that("carte_joindre() : retourne un objet sf", {
  skip_if_not_installed("sf")
  sf_test    <- make_sf_test()
  stats_test <- make_stats_test()
  result     <- suppressMessages(suppressWarnings(
    carte_joindre(sf_test, stats_test,
                  cle_geo = "code", cle_data = "region_code")
  ))
  expect_true(inherits(result, "sf"))
})

test_that("carte_joindre() : variables statistiques presentes", {
  skip_if_not_installed("sf")
  sf_test    <- make_sf_test()
  stats_test <- make_stats_test()
  result     <- suppressMessages(suppressWarnings(
    carte_joindre(sf_test, stats_test,
                  cle_geo = "code", cle_data = "region_code")
  ))
  expect_true("taux_pauvrete" %in% names(result))
  expect_true("taux_electricite" %in% names(result))
})

test_that("carte_joindre() : jointure gauche conserve toutes les zones", {
  skip_if_not_installed("sf")
  sf_test    <- make_sf_test(5)
  stats_part <- make_stats_test(3)  # Seulement 3 zones sur 5
  result     <- suppressMessages(suppressWarnings(
    carte_joindre(sf_test, stats_part,
                  cle_geo = "code", cle_data = "region_code",
                  type = "gauche")
  ))
  expect_equal(nrow(result), 5L)
})

test_that("carte_joindre() : jointure interne ne conserve que les apparies", {
  skip_if_not_installed("sf")
  sf_test    <- make_sf_test(5)
  stats_part <- make_stats_test(3)
  result     <- suppressMessages(suppressWarnings(
    carte_joindre(sf_test, stats_part,
                  cle_geo = "code", cle_data = "region_code",
                  type = "interne")
  ))
  expect_lte(nrow(result), 5L)
})

test_that("carte_joindre() : cle_geo absente => erreur", {
  skip_if_not_installed("sf")
  sf_test <- make_sf_test()
  expect_error(
    carte_joindre(sf_test, data.frame(x = 1), cle_geo = "xxx"),
    regexp = "absente"
  )
})

test_that("carte_joindre() : non-sf => erreur", {
  skip_if_not_installed("sf")
  expect_error(
    carte_joindre(data.frame(x = 1), data.frame(x = 1), cle_geo = "x"),
    regexp = "sf"
  )
})

# =============================================================================
# BLOC 3 - carte_choroplethe()
# =============================================================================

test_that("carte_choroplethe() : retourne un ggplot", {
  skip_if_not_installed("sf")
  sf_test    <- make_sf_test()
  stats_test <- make_stats_test()
  sf_enr     <- suppressMessages(suppressWarnings(
    carte_joindre(sf_test, stats_test,
                  cle_geo = "code", cle_data = "region_code")
  ))
  g <- suppressWarnings(
    carte_choroplethe(sf_enr, var = "taux_pauvrete")
  )
  expect_s3_class(g, "ggplot")
})

test_that("carte_choroplethe() : avec titre et source", {
  skip_if_not_installed("sf")
  sf_test <- make_sf_test()
  stats_test <- make_stats_test()
  sf_enr <- suppressMessages(suppressWarnings(
    carte_joindre(sf_test, stats_test,
                  cle_geo = "code", cle_data = "region_code")
  ))
  g <- suppressWarnings(
    carte_choroplethe(sf_enr, var = "taux_pauvrete",
                      titre = "Test", source = "INS 2026")
  )
  expect_s3_class(g, "ggplot")
})

test_that("carte_choroplethe() : methodes de discretisation", {
  skip_if_not_installed("sf")
  sf_test <- make_sf_test()
  stats_test <- make_stats_test()
  sf_enr <- suppressMessages(suppressWarnings(
    carte_joindre(sf_test, stats_test,
                  cle_geo = "code", cle_data = "region_code")
  ))
  for (m in c("quantile", "egal", "jenks")) {
    g <- suppressWarnings(
      carte_choroplethe(sf_enr, var = "taux_pauvrete", methode = m)
    )
    expect_s3_class(g, "ggplot")
  }
})

test_that("carte_choroplethe() : variable absente => erreur", {
  skip_if_not_installed("sf")
  sf_test <- make_sf_test()
  expect_error(
    carte_choroplethe(sf_test, var = "xxx"),
    regexp = "absente"
  )
})

test_that("carte_choroplethe() : non-sf => erreur", {
  skip_if_not_installed("sf")
  expect_error(
    carte_choroplethe(data.frame(x = 1), var = "x"),
    regexp = "sf"
  )
})

test_that("carte_choroplethe() : n_classes hors plage => erreur", {
  skip_if_not_installed("sf")
  sf_test <- make_sf_test()
  sf_test$val <- c(0.1, 0.3, 0.5, 0.7, 0.9)
  expect_error(
    carte_choroplethe(sf_test, var = "val", n_classes = 10L),
    regexp = "9"
  )
})

# =============================================================================
# BLOC 4 - carte_pauvrete()
# =============================================================================

test_that("carte_pauvrete() : retourne un ggplot", {
  skip_if_not_installed("sf")
  sf_test <- make_sf_test()
  sf_test$taux <- c(0.42, 0.31, 0.58, 0.25, 0.67)
  g <- suppressWarnings(
    carte_pauvrete(sf_test, var_fgt0 = "taux",
                   titre = "Test pauvrete")
  )
  expect_s3_class(g, "ggplot")
})

test_that("carte_pauvrete() : conversion % automatique", {
  skip_if_not_installed("sf")
  sf_test <- make_sf_test()
  sf_test$taux_pct <- c(42, 31, 58, 25, 67)
  g <- suppressWarnings(
    carte_pauvrete(sf_test, var_fgt0 = "taux_pct")
  )
  expect_s3_class(g, "ggplot")
})

test_that("carte_pauvrete() : variable absente => erreur", {
  skip_if_not_installed("sf")
  sf_test <- make_sf_test()
  expect_error(
    carte_pauvrete(sf_test, var_fgt0 = "xxx"),
    regexp = "absente"
  )
})

# =============================================================================
# BLOC 5 - carte_exporter()
# =============================================================================

test_that("carte_exporter() : export PNG dans tempdir", {
  skip_if_not_installed("sf")
  sf_test <- make_sf_test()
  sf_test$val <- c(0.42, 0.31, 0.58, 0.25, 0.67)
  g      <- suppressWarnings(
    carte_choroplethe(sf_test, var = "val")
  )
  chemin <- file.path(tempdir(), "test_carte.png")
  res    <- suppressMessages(carte_exporter(g, chemin))
  expect_true(file.exists(chemin))
  expect_equal(res, chemin)
  withr::defer(unlink(chemin))
})

test_that("carte_exporter() : non-ggplot => erreur", {
  skip_if_not_installed("sf")
  expect_error(
    carte_exporter(list(), file.path(tempdir(), "x.png")),
    regexp = "ggplot"
  )
})

test_that("carte_exporter() : format invalide => erreur", {
  skip_if_not_installed("sf")
  sf_test <- make_sf_test()
  sf_test$val <- c(0.1, 0.2, 0.3, 0.4, 0.5)
  g <- suppressWarnings(carte_choroplethe(sf_test, var = "val"))
  expect_error(
    carte_exporter(g, file.path(tempdir(), "carte.bmp")),
    regexp = "Format"
  )
})

test_that("carte_exporter() : repertoire inexistant => erreur", {
  skip_if_not_installed("sf")
  sf_test <- make_sf_test()
  sf_test$val <- c(0.1, 0.2, 0.3, 0.4, 0.5)
  g <- suppressWarnings(carte_choroplethe(sf_test, var = "val"))
  expect_error(
    carte_exporter(g, "/chemin/inexistant/carte.png"),
    regexp = "inexistant"
  )
})
