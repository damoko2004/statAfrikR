# statAfrikR

> Package R open source pour les Instituts Nationaux de Statistique
> (INS) africains

## Objectif

**statAfrikR** couvre l’ensemble du cycle de la donnée statistique :
collecte, traitement, analyse, visualisation et diffusion — en tenant
compte des réalités africaines (connectivité limitée, formats locaux,
multilinguisme, ressources IT contraintes).

## Installation

``` r
# Version de développement depuis GitHub
# install.packages("remotes")
remotes::install_github("VOTRE_USERNAME/statAfrikR")
```

## Modules

| Module               | Fonctions clés                                                                                                                                                                                                                                                                                                                                                           | Statut              |
|----------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------|
| 📥 **Collecte**      | [`import_cspro()`](https://damoko2004.github.io/statAfrikR/reference/import_cspro.md), [`import_kobo()`](https://damoko2004.github.io/statAfrikR/reference/import_kobo.md), [`import_excel()`](https://damoko2004.github.io/statAfrikR/reference/import_excel.md), [`valider_dictionnaire()`](https://damoko2004.github.io/statAfrikR/reference/valider_dictionnaire.md) | 🔧 En développement |
| 🔧 **Traitement**    | [`appliquer_ponderations()`](https://damoko2004.github.io/statAfrikR/reference/appliquer_ponderations.md), [`imputer_valeurs()`](https://damoko2004.github.io/statAfrikR/reference/imputer_valeurs.md), [`harmoniser_regions()`](https://damoko2004.github.io/statAfrikR/reference/harmoniser_regions.md)                                                                | 🔧 En développement |
| 📊 **Analyse**       | [`tab_croisee()`](https://damoko2004.github.io/statAfrikR/reference/tab_croisee.md), [`calcul_idh()`](https://damoko2004.github.io/statAfrikR/reference/calcul_idh.md), [`calcul_ipm()`](https://damoko2004.github.io/statAfrikR/reference/calcul_ipm.md), [`stat_descr()`](https://damoko2004.github.io/statAfrikR/reference/stat_descr.md)                             | 🔧 En développement |
| 🗺️ **Visualisation** | [`carte_thematique()`](https://damoko2004.github.io/statAfrikR/reference/carte_thematique.md), [`pyramide_ages()`](https://damoko2004.github.io/statAfrikR/reference/pyramide_ages.md), [`theme_ins()`](https://damoko2004.github.io/statAfrikR/reference/theme_ins.md)                                                                                                  | 🔧 En développement |
| 📄 **Diffusion**     | [`generer_rapport()`](https://damoko2004.github.io/statAfrikR/reference/generer_rapport.md), [`anonymiser_donnees()`](https://damoko2004.github.io/statAfrikR/reference/anonymiser_donnees.md), [`exporter_sdmx()`](https://damoko2004.github.io/statAfrikR/reference/exporter_sdmx.md)                                                                                  | 🔧 En développement |

## Exemple rapide

``` r
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

Ce package tient compte de : - 🌐 **Connectivité limitée** → fonctionne
100% offline après installation - 📋 **Formats locaux** → CSPro (RGPH),
KoboToolbox, ODK - 🌍 **Multilinguisme** → Français, Anglais,
Portugais - 💻 **Windows-first** → testé et optimisé pour Windows
(majoritaire dans les INS) - 🔒 **Souveraineté des données** → aucune
dépendance cloud obligatoire

## Documentation

- 📖 [Document de
  cadrage](https://damoko2004.github.io/statAfrikR/docs/cadrage/document_cadrage.md)
- 📐 [Spécifications
  techniques](https://damoko2004.github.io/statAfrikR/docs/specifications/specifications_techniques.md)
- 🌐 Site de documentation (disponible après déploiement pkgdown)

## Contribuer

Consultez
[CONTRIBUTING.md](https://damoko2004.github.io/statAfrikR/CONTRIBUTING.md).
Les contributions des INS africains sont particulièrement bienvenues.

## Licence

GPL-3.0 © Institut National de la Statistique
