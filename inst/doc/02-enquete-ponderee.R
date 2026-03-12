## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  warning  = FALSE,
  message  = FALSE,
  fig.width  = 7,
  fig.height = 5
)

## ----charger------------------------------------------------------------------
library(statAfrikR)
library(dplyr)

## ----donnees-simulees---------------------------------------------------------
set.seed(2024)
n <- 5000

donnees_eds <- tibble::tibble(
  id_menage      = paste0("MEN_", stringr::str_pad(1:n, 5, pad = "0")),
  strate         = sample(c("Urbain_Nord", "Urbain_Sud", "Rural_Nord",
                             "Rural_Sud"), n, replace = TRUE),
  grappe         = sample(1:250, n, replace = TRUE),
  poids_final    = runif(n, 0.4, 3.2),
  region         = sample(c("Alibori", "Atacora", "Atlantique",
                             "Borgou", "Collines", "Couffo",
                             "Donga", "Littoral"), n, replace = TRUE),
  milieu         = sample(c("Urbain", "Rural"), n, replace = TRUE,
                           prob = c(0.4, 0.6)),
  age_chef       = sample(25:75, n, replace = TRUE),
  sexe_chef      = sample(c("Masculin", "Féminin"), n, replace = TRUE,
                           prob = c(0.75, 0.25)),
  taille_menage  = sample(1:12, n, replace = TRUE,
                           prob = c(0.05, 0.1, 0.15, 0.2, 0.18,
                                    0.12, 0.08, 0.05, 0.03,
                                    0.02, 0.01, 0.01)),
  depense_totale = abs(rnorm(n, 850000, 420000)),
  acces_eau      = sample(c(0L, 1L), n, replace = TRUE, prob = c(0.35, 0.65)),
  electricite    = sample(c(0L, 1L), n, replace = TRUE, prob = c(0.45, 0.55)),
  scolarisation  = sample(c(0L, 1L), n, replace = TRUE, prob = c(0.28, 0.72))
)

cat("Ménages :", nrow(donnees_eds), "\n")
cat("Régions :", length(unique(donnees_eds$region)), "\n")

## ----validation---------------------------------------------------------------
qualite <- valider_qualite_donnees(
  donnees_eds,
  vars_cles = "id_menage",
  seuil_na  = 0.05
)

## ----nettoyage----------------------------------------------------------------
# Harmonisation des régions
donnees_eds <- harmoniser_regions(
  donnees_eds,
  var_region = "region",
  pays       = "BJ",
  var_sortie = "region_std",
  signaler_non_trouves = FALSE
)

# Journal de traitement
etape <- tracer_flux_traitement(
  donnees_eds,
  "Harmonisation des régions"
)

## ----plan-sondage-------------------------------------------------------------
plan <- appliquer_ponderations(
  data       = donnees_eds,
  var_poids  = "poids_final",
  var_strate = "strate",
  var_grappe = "grappe"
)

## ----stats-descriptives-------------------------------------------------------
stats <- stat_descr(
  plan,
  vars = c("depense_totale", "taille_menage", "age_chef"),
  ic   = TRUE
)
knitr::kable(stats, caption = "Statistiques descriptives pondérées")

## ----tableau-croise-----------------------------------------------------------
tab <- tab_croisee(
  plan,
  var_ligne   = "milieu",
  var_col     = "region_std",
  pourcentage = "colonne",
  format_sortie = "tibble"
)
knitr::kable(
  head(tab, 16),
  caption = "Répartition par milieu et région (%)"
)

## ----ipm----------------------------------------------------------------------
indicateurs_ipm <- list(
  sante      = c("acces_eau"),
  education  = c("scolarisation"),
  niveau_vie = c("electricite")
)

resultat_ipm <- calcul_ipm(
  donnees_eds,
  indicateurs_ipm,
  seuil_pauvrete = 1/3,
  var_poids      = "poids_final"
)

## ----inegalite----------------------------------------------------------------
inegalites <- decomposer_inegalite(
  donnees_eds,
  var_revenu = "depense_totale",
  var_groupe = "milieu",
  var_poids  = "poids_final"
)

cat("Indice de Gini :", inegalites$gini, "\n")
knitr::kable(
  inegalites$decomposition,
  caption = "Décomposition des inégalités par milieu"
)

## ----pyramide, fig.cap="Pyramide des âges des chefs de ménage"----------------
library(ggplot2)
pyramide_ages(
  donnees_eds,
  var_age   = "age_chef",
  var_sexe  = "sexe_chef",
  var_poids = "poids_final",
  titre     = "Pyramide des âges — Chefs de ménage",
  largeur_classe = 10L
)

## ----barres, fig.cap="Dépense moyenne par région"-----------------------------
stats_region <- stat_descr(
  donnees_eds,
  vars   = "depense_totale",
  groupe = "region_std",
  ic     = TRUE
)

graphique_barres(
  stats_region,
  var_x       = "region_std",
  var_y       = "moyenne",
  var_ic_bas  = "ic_bas",
  var_ic_haut = "ic_haut",
  titre       = "Dépense moyenne par région (FCFA)",
  label_y     = "Dépense moyenne (FCFA)",
  trier       = TRUE
) + ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1))

## ----regression---------------------------------------------------------------
# Déterminants de la dépense
modele <- analyse_regression(
  log(depense_totale) ~ age_chef + taille_menage + electricite + acces_eau,
  data          = donnees_eds,
  type          = "lineaire",
  format_sortie = "tibble"
)

knitr::kable(
  modele[, c("terme", "estimateur", "ic_bas", "ic_haut",
             "p_valeur", "significatif")],
  caption = "Déterminants de la dépense des ménages"
)

## ----diffusion, eval=FALSE----------------------------------------------------
# # Anonymisation
# donnees_anon <- anonymiser_donnees(
#   donnees_eds,
#   vars_supprimer   = c("id_menage"),
#   vars_generaliser = list(age_chef = 10, depense_totale = 100000),
#   rapport          = FALSE
# )
# 
# # Métadonnées DDI
# generer_metadonnees_ddi(
#   data           = donnees_anon,
#   titre          = "Enquête Démographique et de Santé — 2024",
#   pays           = "Bénin",
#   annee          = 2024,
#   institution    = "INSAE",
#   fichier_sortie = "outputs/eds_2024_ddi.xml"
# )
# 
# # Package de diffusion
# compresser_package_diffusion(
#   donnees           = donnees_anon,
#   repertoire_sortie = "diffusion/",
#   nom_package       = "EDS_BEN_2024_v1"
# )

