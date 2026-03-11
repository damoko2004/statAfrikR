# statAfrikR

<!-- badges: start -->
[![R-CMD-check](https://github.com/VOTRE_USERNAME/statAfrikR/actions/workflows/R-CMD-check.yml/badge.svg)](https://github.com/VOTRE_USERNAME/statAfrikR/actions)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![codecov](https://codecov.io/gh/VOTRE_USERNAME/statAfrikR/branch/main/graph/badge.svg)](https://codecov.io/gh/VOTRE_USERNAME/statAfrikR)
<!-- badges: end -->

> Package R open source pour les Instituts Nationaux de Statistique (INS) africains

## Objectif

**statAfrikR** couvre l'ensemble du cycle de la donnée statistique : collecte, traitement, analyse, visualisation et diffusion — en tenant compte des réalités africaines (connectivité limitée, formats locaux, multilinguisme, ressources IT contraintes).

## Installation

```r
# Version de développement depuis GitHub
# install.packages("remotes")
remotes::install_github("VOTRE_USERNAME/statAfrikR")
```

## Modules

| Module | Fonctions clés | Statut |
|--------|---------------|--------|
| 📥 **Collecte** | `import_cspro()`, `import_kobo()`, `import_excel()`, `valider_dictionnaire()` | 🔧 En développement |
| 🔧 **Traitement** | `appliquer_ponderations()`, `imputer_valeurs()`, `harmoniser_regions()` | 🔧 En développement |
| 📊 **Analyse** | `tab_croisee()`, `calcul_idh()`, `calcul_ipm()`, `stat_descr()` | 🔧 En développement |
| 🗺️ **Visualisation** | `carte_thematique()`, `pyramide_ages()`, `theme_ins()` | 🔧 En développement |
| 📄 **Diffusion** | `generer_rapport()`, `anonymiser_donnees()`, `exporter_sdmx()` | 🔧 En développement |

## Exemple rapide

```r
library(statAfrikR)

# Importer des données Excel
donnees <- import_excel("mon_enquete.xlsx")

# Vérifier la qualité
check_na(donnees)

# Créer le plan de sondage
plan <- appliquer_ponderations(donnees, var_poids = "poids_final",
                                var_strate = "strate", var_grappe = "grappe")

# Tableau croisé pondéré
tab_croisee(plan, var_ligne = "region", var_col = "sexe")

# Générer un rapport automatisé
generer_rapport(template = "bulletin_mensuel", donnees = list(data = donnees),
                format = "pdf", langue = "fr")
```

## Contexte africain

Ce package tient compte de :
- 🌐 **Connectivité limitée** → fonctionne 100% offline après installation
- 📋 **Formats locaux** → CSPro (RGPH), KoboToolbox, ODK
- 🌍 **Multilinguisme** → Français, Anglais, Portugais
- 💻 **Windows-first** → testé et optimisé pour Windows (majoritaire dans les INS)
- 🔒 **Souveraineté des données** → aucune dépendance cloud obligatoire

## Documentation

- 📖 [Document de cadrage](docs/cadrage/document_cadrage.md)
- 📐 [Spécifications techniques](docs/specifications/specifications_techniques.md)
- 🌐 Site de documentation (disponible après déploiement pkgdown)

## Contribuer

Consultez [CONTRIBUTING.md](CONTRIBUTING.md). Les contributions des INS africains sont particulièrement bienvenues.

## Licence

GPL-3.0 © Institut National de la Statistique
