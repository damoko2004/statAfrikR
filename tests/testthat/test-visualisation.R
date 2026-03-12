# =============================================================================
# Tests unitaires — Module Visualisation
# statAfrikR
# =============================================================================

set.seed(99)
donnees_test <- tibble::tibble(
  id      = 1:300,
  age     = sample(1:85, 300, replace = TRUE),
  sexe    = sample(c("Masculin", "Féminin"), 300, replace = TRUE),
  region  = sample(c("Nord", "Sud", "Est", "Ouest", "Centre"), 300, replace = TRUE),
  milieu  = sample(c("Urbain", "Rural"), 300, replace = TRUE),
  annee   = sample(2015:2023, 300, replace = TRUE),
  valeur  = abs(rnorm(300, 50, 15)),
  poids   = runif(300, 0.5, 2.5),
  indice1 = abs(rnorm(300, 30, 10)),
  indice2 = abs(rnorm(300, 60, 20))
)

# Données agrégées pour barres
donnees_agg <- tibble::tibble(
  region      = c("Nord", "Sud", "Est", "Ouest", "Centre"),
  pourcentage = c(22.3, 18.7, 15.2, 28.1, 15.7),
  ic_bas      = c(19.1, 15.9, 12.5, 24.8, 12.3),
  ic_haut     = c(25.5, 21.5, 17.9, 31.4, 19.1)
)

# Données temporelles
donnees_temps <- tibble::tibble(
  annee   = 2015:2023,
  pib     = c(3.2, 3.8, 4.1, 3.9, 4.5, 4.2, 2.1, 5.1, 5.8),
  inflation = c(2.1, 2.8, 3.2, 2.9, 3.5, 4.1, 5.2, 4.8, 3.9)
)

# --- theme_ins ---------------------------------------------------------------

test_that("theme_ins() retourne un objet theme ggplot2", {
  skip_if_not_installed("ggplot2")
  result <- theme_ins()
  expect_s3_class(result, "theme")
})

test_that("theme_ins() accepte différentes tailles de base", {
  skip_if_not_installed("ggplot2")
  expect_s3_class(theme_ins(base_size = 14), "theme")
  expect_s3_class(theme_ins(base_size = 9),  "theme")
})

test_that("theme_ins() fonctionne sans grille", {
  skip_if_not_installed("ggplot2")
  result <- theme_ins(grille = FALSE)
  expect_s3_class(result, "theme")
})

test_that("theme_ins() s'applique à un ggplot sans erreur", {
  skip_if_not_installed("ggplot2")
  p <- ggplot2::ggplot(donnees_test, ggplot2::aes(age, valeur)) +
    ggplot2::geom_point() +
    theme_ins()
  expect_s3_class(p, "ggplot")
})

# --- palette_ins -------------------------------------------------------------

test_that("palette_ins() retourne n couleurs", {
  result <- palette_ins(4)
  expect_length(result, 4)
})

test_that("palette_ins() retourne des codes hexadécimaux valides", {
  result <- palette_ins(6)
  expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", result)))
})

test_that("palette_ins() fonctionne pour les 3 types", {
  for (type in c("categoriel", "sequentiel", "divergent")) {
    result <- palette_ins(4, type = type)
    expect_length(result, 4)
  }
})

test_that("palette_ins() avertit si n > disponible", {
  expect_warning(palette_ins(20, type = "categoriel"), regexp = "disponible")
})

# --- pyramide_ages -----------------------------------------------------------

test_that("pyramide_ages() retourne un ggplot", {
  skip_if_not_installed("ggplot2")
  p <- pyramide_ages(donnees_test, "age", "sexe")
  expect_s3_class(p, "ggplot")
})

test_that("pyramide_ages() fonctionne avec pondération", {
  skip_if_not_installed("ggplot2")
  p <- pyramide_ages(donnees_test, "age", "sexe", var_poids = "poids")
  expect_s3_class(p, "ggplot")
})

test_that("pyramide_ages() fonctionne en effectifs", {
  skip_if_not_installed("ggplot2")
  p <- pyramide_ages(donnees_test, "age", "sexe", pourcentage = FALSE)
  expect_s3_class(p, "ggplot")
})

test_that("pyramide_ages() accepte un titre", {
  skip_if_not_installed("ggplot2")
  p <- pyramide_ages(donnees_test, "age", "sexe",
                      titre = "Pyramide test")
  expect_equal(p$labels$title, "Pyramide test")
})

test_that("pyramide_ages() échoue sur variables inexistantes", {
  skip_if_not_installed("ggplot2")
  expect_error(
    pyramide_ages(donnees_test, "age_inexistant", "sexe"),
    regexp = "introuvable"
  )
})

test_that("pyramide_ages() accepte des couleurs personnalisées", {
  skip_if_not_installed("ggplot2")
  p <- pyramide_ages(donnees_test, "age", "sexe",
                      couleur_homme = "#003087",
                      couleur_femme = "#C8102E")
  expect_s3_class(p, "ggplot")
})

test_that("pyramide_ages() fonctionne avec largeur_classe = 10", {
  skip_if_not_installed("ggplot2")
  p <- pyramide_ages(donnees_test, "age", "sexe", largeur_classe = 10L)
  expect_s3_class(p, "ggplot")
})

# --- graphique_barres --------------------------------------------------------

test_that("graphique_barres() retourne un ggplot", {
  skip_if_not_installed("ggplot2")
  p <- graphique_barres(donnees_agg, "region", "pourcentage")
  expect_s3_class(p, "ggplot")
})

test_that("graphique_barres() affiche les IC si fournis", {
  skip_if_not_installed("ggplot2")
  p <- graphique_barres(
    donnees_agg, "region", "pourcentage",
    var_ic_bas = "ic_bas", var_ic_haut = "ic_haut"
  )
  expect_s3_class(p, "ggplot")
})

test_that("graphique_barres() fonctionne avec regroupement", {
  skip_if_not_installed("ggplot2")
  df <- donnees_test |>
    dplyr::group_by(region, milieu) |>
    dplyr::summarise(valeur = mean(valeur), .groups = "drop")
  p <- graphique_barres(df, "region", "valeur", var_groupe = "milieu")
  expect_s3_class(p, "ggplot")
})

test_that("graphique_barres() fonctionne en mode empilé", {
  skip_if_not_installed("ggplot2")
  df <- donnees_test |>
    dplyr::group_by(region, milieu) |>
    dplyr::summarise(valeur = mean(valeur), .groups = "drop")
  p <- graphique_barres(df, "region", "valeur",
                         var_groupe = "milieu", position = "stack")
  expect_s3_class(p, "ggplot")
})

test_that("graphique_barres() formate l'axe Y en pourcentage", {
  skip_if_not_installed("ggplot2")
  p <- graphique_barres(donnees_agg, "region", "pourcentage",
                         pourcentage = TRUE)
  expect_s3_class(p, "ggplot")
})

test_that("graphique_barres() trie les barres si demandé", {
  skip_if_not_installed("ggplot2")
  p <- graphique_barres(donnees_agg, "region", "pourcentage", trier = TRUE)
  expect_s3_class(p, "ggplot")
})

test_that("graphique_barres() échoue sur variables inexistantes", {
  skip_if_not_installed("ggplot2")
  expect_error(
    graphique_barres(donnees_agg, "var_inexistante", "pourcentage"),
    regexp = "introuvable"
  )
})

# --- graphique_tendance ------------------------------------------------------

test_that("graphique_tendance() fonctionne en format large", {
  skip_if_not_installed("ggplot2")
  p <- graphique_tendance(
    donnees_temps,
    var_temps        = "annee",
    vars_indicateurs = c("pib", "inflation")
  )
  expect_s3_class(p, "ggplot")
})

test_that("graphique_tendance() fonctionne en format long", {
  skip_if_not_installed("ggplot2")
  df_long <- tidyr::pivot_longer(
    donnees_temps, c("pib", "inflation"),
    names_to = "indicateur", values_to = "valeur"
  )
  p <- graphique_tendance(
    df_long,
    var_temps      = "annee",
    var_valeur     = "valeur",
    var_indicateur = "indicateur"
  )
  expect_s3_class(p, "ggplot")
})

test_that("graphique_tendance() affiche les points", {
  skip_if_not_installed("ggplot2")
  p <- graphique_tendance(
    donnees_temps, "annee",
    vars_indicateurs = c("pib"),
    afficher_points  = TRUE
  )
  expect_s3_class(p, "ggplot")
})

test_that("graphique_tendance() affiche les valeurs annotées", {
  skip_if_not_installed("ggplot2")
  p <- graphique_tendance(
    donnees_temps, "annee",
    vars_indicateurs = c("pib"),
    afficher_valeurs = TRUE
  )
  expect_s3_class(p, "ggplot")
})

test_that("graphique_tendance() échoue si variable temporelle absente", {
  skip_if_not_installed("ggplot2")
  expect_error(
    graphique_tendance(donnees_temps, "annee_inexistante",
                        vars_indicateurs = c("pib")),
    regexp = "introuvable"
  )
})

test_that("graphique_tendance() échoue sans vars_indicateurs ni var_valeur", {
  skip_if_not_installed("ggplot2")
  expect_error(
    graphique_tendance(donnees_temps, "annee"),
    regexp = "Spécifiez"
  )
})

# --- exporter_graphique ------------------------------------------------------

test_that("exporter_graphique() crée un fichier PNG", {
  skip_if_not_installed("ggplot2")
  tmp <- tempfile(fileext = ".png")
  p <- ggplot2::ggplot(donnees_test, ggplot2::aes(age, valeur)) +
    ggplot2::geom_point() + theme_ins()
  exporter_graphique(p, tmp, largeur = 15, hauteur = 10, dpi = 72L)
  expect_true(file.exists(tmp))
  unlink(tmp)
})

test_that("exporter_graphique() crée un fichier PDF", {
  skip_if_not_installed("ggplot2")
  tmp <- tempfile(fileext = ".pdf")
  p <- ggplot2::ggplot(donnees_test, ggplot2::aes(age, valeur)) +
    ggplot2::geom_point()
  exporter_graphique(p, tmp, largeur = 15, hauteur = 10)
  expect_true(file.exists(tmp))
  unlink(tmp)
})

test_that("exporter_graphique() échoue sur format non supporté", {
  skip_if_not_installed("ggplot2")
  p <- ggplot2::ggplot(donnees_test, ggplot2::aes(age)) +
    ggplot2::geom_histogram()
  expect_error(
    exporter_graphique(p, "fichier.docx"),
    regexp = "non supporté"
  )
})

test_that("exporter_graphique() échoue si graphique non ggplot", {
  skip_if_not_installed("ggplot2")
  expect_error(
    exporter_graphique("pas_un_ggplot", "fichier.png"),
    regexp = "ggplot"
  )
})

test_that("exporter_graphique() retourne le chemin invisible", {
  skip_if_not_installed("ggplot2")
  tmp <- tempfile(fileext = ".png")
  p <- ggplot2::ggplot(donnees_test, ggplot2::aes(age)) +
    ggplot2::geom_histogram(bins = 10)
  result <- exporter_graphique(p, tmp, largeur = 10, hauteur = 8, dpi = 72L)
  expect_equal(result, tmp)
  unlink(tmp)
})
