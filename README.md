# statAfrikR

<!-- badges: start -->
[![R CMD Check](https://github.com/damoko2004/statAfrikR/actions/workflows/R-CMD-check.yml/badge.svg)](https://github.com/damoko2004/statAfrikR/actions/workflows/R-CMD-check.yml)
[![Codecov](https://app.codecov.io/gh/damoko2004/statAfrikR/branch/main/graph/badge.svg)](https://app.codecov.io/gh/damoko2004/statAfrikR)
<!-- badges: end -->

Package R open source pour les Instituts Nationaux de Statistique (INS) africains.

## Objectif

**statAfrikR** couvre l'ensemble du cycle de la donnée statistique : collecte,
traitement, analyse, visualisation et diffusion — en tenant compte des réalités
africaines (connectivité limitée, formats locaux, multilinguisme, ressources IT
contraintes).

## Installation

```r
# Version stable depuis le CRAN
install.packages("statAfrikR")

# Version de développement depuis GitHub
# install.packages("remotes")
remotes::install_github("damoko2004/statAfrikR")
```

## Modules

| Module | Fonctions clés | Statut |
|--------|---------------|--------|
| 📥 Collecte | `import_cspro()`, `import_kobo()`, `import_excel()`, `valider_dictionnaire()` | 🔧 En développement |
| 🔧 Traitement | `appliquer_ponderations()`, `imputer_valeurs()`, `harmoniser_regions()` | 🔧 En développement |
| 📊 Analyse | `tab_croisee()`, `calcul_idh()`, `calcul_ipm()`, `stat_descr()` | 🔧 En développement |
| 🗺️ Visualisation | `carte_thematique()`, `pyramide_ages()`, `theme_ins()` | 🔧 En développement |
| 📄 Diffusion | `generer_rapport()`, `anonymiser_donnees()`, `exporter_sdmx()` | 🔧 En développement |

## Exemple rapide

```r
library(statAfrikR)

# Vérifier la qualité des données
check_na(donnees)

# Créer le plan de sondage
plan <- appliquer_ponderations(donnees,
  var_poids  = "poids_final",
  var_strate = "strate",
  var_grappe = "grappe"
)

# Tableau croisé pondéré
tab_croisee(plan, var_ligne = "region", var_col = "sexe")
```

## Contexte africain

Ce package tient compte de :

- 🌐 **Connectivité limitée** — fonctionne 100% offline après installation
- 📋 **Formats locaux** — CSPro (RGPH), KoboToolbox, ODK
- 🌍 **Multilinguisme** — Français, Anglais, Portugais
- 💻 **Windows-first** — testé et optimisé pour Windows (majoritaire dans les INS)
- 🔒 **Souveraineté des données** — aucune dépendance cloud obligatoire

## Documentation

- 🌐 [Site de documentation](https://damoko2004.github.io/statAfrikR/)
- 📖 [Vignette : Démarrage rapide](https://damoko2004.github.io/statAfrikR/articles/01-demarrage-rapide.html)
- 📊 [Vignette : Enquête pondérée](https://damoko2004.github.io/statAfrikR/articles/02-enquete-ponderee.html)
- 📐 [Vignette : Indicateurs ODD](https://damoko2004.github.io/statAfrikR/articles/03-indicateurs-odd.html)

## Contribuer

Les contributions des INS africains sont particulièrement bienvenues.
Consultez les [issues GitHub](https://github.com/damoko2004/statAfrikR/issues).

## Licence

GPL-3.0 © Dikers Amoko

## 💬 Communauté

[![Discord](https://img.shields.io/discord/1482000033158135920?color=00C853&label=Discord&logo=discord&logoColor=white)](https://discord.gg/x9u5sXQB2V)

Rejoins la communauté officielle **statAfrikR** sur Discord !

- 🌍 Statisticiens et analystes des INS africains
- 💻 Développeurs R contributeurs
- 📊 Support technique et entraide
- 🎓 Formations et ressources

👉 [Rejoindre le serveur Discord](https://discord.gg/x9u5sXQB2V)
