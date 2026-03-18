# statAfrikR News

## statAfrikR 0.1.0 (2026-03-12)

### Première version officielle

#### Nouveau — Module Collecte (11 fonctions)
* `import_excel()` — Import fichiers Excel (.xlsx/.xls), multi-feuilles
* `import_csv()` — Import CSV avec détection automatique du séparateur
* `import_stata()` — Import Stata .dta toutes versions, avec labels
* `import_spss()` — Import SPSS .sav/.zsav avec labels
* `import_sas()` — Import SAS .sas7bdat
* `import_cspro()` — Import CSPro .dat + .dcf, multi-niveaux
* `import_kobo()` — Import KoboToolbox fichier XLS/JSON ou API REST
* `import_odk()` — Import ODK Central fichier ZIP/CSV ou API REST
* `check_na()` — Rapport des valeurs manquantes par variable
* `check_types()` — Détection des incohérences de types
* `valider_dictionnaire()` — Validation complète + score qualité

#### Nouveau — Module Traitement (9 fonctions)
* `nettoyer_libelles()` — Normalisation des chaînes, casse, accents
* `harmoniser_regions()` — Référentiels BJ, BF, SN, CI intégrés
* `appliquer_ponderations()` — Plan de sondage complexe (svydesign)
* `imputer_valeurs()` — Imputation : médiane, moyenne, mode, hot-deck, régression
* `supprimer_doublons()` — Détection et suppression intelligente
* `recoder_variable()` — Recodage par table de correspondance
* `standardiser_ages()` — Indices Whipple et Myers, correction heap effect
* `fusion_datasets()` — Fusion verticale et horizontale (4 types)
* `tracer_flux_traitement()` — Journal horodaté des transformations

#### Nouveau — Module Analyse (8 fonctions)
* `stat_descr()` — Statistiques descriptives pondérées + IC95
* `tab_croisee()` — Tableaux croisés avec pourcentages ligne/colonne/total
* `analyse_regression()` — Régression linéaire, logistique, Poisson + OR/RR
* `analyse_spatiale()` — Jointure shapefile + agrégation par zone
* `calcul_idh()` — IDH PNUD post-2010 avec catégorie
* `calcul_ipm()` — IPM Alkire-Foster avec décomposition par dimension
* `decomposer_inegalite()` — Gini, Theil, Atkinson + décomposition
* `valider_qualite_donnees()` — Score qualité 0-100 (4 dimensions)

#### Nouveau — Module Visualisation (6 fonctions)
* `theme_ins()` — Thème ggplot2 officiel INS
* `palette_ins()` — Palette couleurs compatible daltonisme
* `pyramide_ages()` — Pyramide pondérée, classes paramétrables
* `graphique_barres()` — Barres groupées/empilées + IC95
* `graphique_tendance()` — Séries temporelles format large/long
* `carte_thematique()` — Carte choroplèthe (sf + ggplot2)
* `exporter_graphique()` — Export PNG/PDF/SVG haute résolution

#### Nouveau — Module Diffusion (5 fonctions)
* `generer_rapport()` — Rapport Word/PDF depuis template Rmd
* `anonymiser_donnees()` — Suppression, masquage, perturbation, généralisation
* `exporter_sdmx()` — Export SDMX-CSV 2.1 pour FMI/BM/OCDE
* `generer_metadonnees_ddi()` — Fiche DDI Codebook 2.5 pour IHSN/NADA
* `compresser_package_diffusion()` — Archive ZIP structurée + README auto

#### Tests
* 257 tests unitaires — FAIL 0 | WARN 0 | SKIP 0
* Couverture cible : ≥ 85%

#### Documentation
* 3 vignettes : démarrage rapide, enquête pondérée, indicateurs ODD
* Documentation roxygen2 complète pour toutes les fonctions exportées

