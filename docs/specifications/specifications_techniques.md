# Spécifications techniques — statAfrikR
### Analyse & Amélioration des spécifications (8 étapes)

---

## 📌 Étape 1/8 — Audit critique du document existant

### 1.1 Tableau d'audit critique

| Dimension | Constat | Recommandation |
|-----------|---------|----------------|
| **Vision & Objectifs** | Vision claire et pertinente. Objectifs bien alignés avec les besoins réels des INS. | Ajouter des critères de succès mesurables (indicateurs SMART). |
| **Cohérence des modules** | Le module "Documentation" listé en Section 3 n'a pas de fichier `.R` correspondant. | Retirer "Documentation" comme module fonctionnel — c'est une activité transversale. |
| **Signatures de fonctions** | Fonctions nommées mais aucune signature définie (paramètres, types, retours). | Définir toutes les signatures avec paramètres typés dès la Phase 1. |
| **Gestion des erreurs** | Aucune mention de gestion d'erreurs ni de validation des entrées. | Intégrer `tryCatch()`, `rlang::abort()`, messages pédagogiques en français. |
| **Calendrier vs complexité** | 7 mois optimistes pour un package de cette envergure. | Redistribuer sur 10–12 mois réalistes. |
| **Dépendances** | `tidyverse` entier (~30 packages) alourdit l'installation — critique en contexte de connectivité limitée. | Remplacer par composants stricts : `dplyr`, `tidyr`, `readr`, `stringr`, `purrr`, `tibble`. |
| **CSPro absent** | CSPro est le logiciel de saisie le plus utilisé dans les RGPH africains. | Ajouter `import_cspro()` comme fonction prioritaire Must. |
| **Interface Shiny** | Mentionnée sans spécification ni estimation de charge. Peut doubler la charge de développement. | Déplacer Shiny en phase "Could" (MoSCoW) — non prioritaire pour la v1.0. |
| **Tests** | Absents du document de cadrage. | Définir une stratégie complète avec `testthat` dès la conception. |
| **Anonymisation** | Citée sans spécification des algorithmes. | Spécifier les méthodes : k-anonymat, suppression, pseudonymisation. |
| **Multilinguisme** | Cité mais non implémenté dans l'architecture. | Prévoir un système de messages localisés avec `gettext` ou fichiers `.po`. |
| **CRAN compliance** | Aucune mention des contraintes CRAN. | Intégrer les exigences CRAN dès la conception. |
| **Gouvernance** | Aucun modèle de gouvernance open source défini. | Définir un modèle avec rôles explicites. |
| **Jeux de données fictifs** | Mentionnés comme livrables mais non spécifiés. | Spécifier 3 jeux : RGPH simulé, EDS simulée, EMOP simulée. |

### 1.2 Risques critiques

| Risque | Probabilité | Impact | Mitigation |
|--------|-------------|--------|------------|
| Dépendance `tidyverse` entier → installation échoue sur connexion lente | Élevée | Élevé | Dépendances minimales, bundle offline |
| CSPro non supporté → rejet par les INS RGPH | Élevée | Élevé | Ajouter `import_cspro()` en priorité Must |
| Pas de tests → régression silencieuse | Moyenne | Élevé | CI/CD dès la Phase 2 |
| Shiny sous-estimé → retard global | Élevée | Moyen | Reporter Shiny à la v1.1 |
| Turnover des développeurs → perte de connaissance | Moyenne | Élevé | Documentation obligatoire + CONTRIBUTING.md |
| Rejet CRAN au premier dépôt | Moyenne | Moyen | `R CMD check --as-cran` dès le début |

---

## 📌 Étape 2/8 — Enrichissement des spécifications fonctionnelles

### Module Collecte — Fonctions nouvelles à haute valeur ajoutée

| Fonction | Justification | Description |
|----------|--------------|-------------|
| `import_cspro()` | Standard RGPH africain, absent du document | Lecture des fichiers `.csdb` et `.dat` avec métadonnées |
| `lire_questionnaire_xls()` | XLSForm contient le dictionnaire des variables | Extraction automatique du dictionnaire depuis la conception du questionnaire |
| `telecharger_donnees_ins()` | API des portails open data INS | Connecteur générique vers portails SDMX/API REST |
| `valider_completude()` | Contrôle qualité avant traitement | Taux de complétion par module, par agent, par zone géographique |

### Module Traitement — Fonctions nouvelles

| Fonction | Justification | Description |
|----------|--------------|-------------|
| `imputer_valeurs()` | Critique pour les enquêtes à taux de non-réponse élevé | Imputation par moyenne, médiane, hot-deck ou modèle |
| `creer_indicateur_composite()` | IDH, IPM, indices de richesse | Construction d'indices avec pondération personnalisable |
| `standardiser_ages()` | Heap effect fréquent dans les enquêtes | Détection et correction des concentrations sur âges ronds |
| `tracer_flux_traitement()` | Auditabilité du pipeline | Journal horodaté des transformations appliquées |

### Module Analyse — Fonctions nouvelles

| Fonction | Justification | Description |
|----------|--------------|-------------|
| `calcul_idh()` | Indicateur phare de tout rapport INS | Calcul IDH selon méthodologie PNUD post-2010 |
| `calcul_ipm()` | Standard OPHI/PNUD | Calcul IPM avec dimensions et seuils paramétrables |
| `analyse_survie()` | Mortalité infantile dans les EDS | Kaplan-Meier, modèle de Cox adapté aux enquêtes |
| `projection_demographique()` | Besoin récurrent post-RGPH | Projections par composantes (fécondité, mortalité, migration) |

### Module Visualisation — Fonctions nouvelles

| Fonction | Justification | Description |
|----------|--------------|-------------|
| `theme_ins()` | Harmonisation visuelle des publications | Thème ggplot2 aux couleurs et polices standards INS |
| `pyramide_ages()` | Graphique incontournable post-RGPH | Pyramide des âges avec comparaison optionnelle |
| `exporter_graphique()` | Publication officielle | Export PNG/SVG/PDF à résolution paramétrable (300 dpi) |

### Module Diffusion — Fonctions nouvelles

| Fonction | Justification | Description |
|----------|--------------|-------------|
| `exporter_sdmx()` | Standard international | Export données et métadonnées au format SDMX-ML |
| `generer_metadonnees_ddi()` | Standard DDI obligatoire | Génération fichier DDI à partir des attributs du dataset |
| `compresser_package_diffusion()` | Partage en faible connectivité | Bundling rapport + données + graphiques en archive ZIP |

---

## 📌 Étape 3/8 — Spécification technique approfondie

### Fonction `import_kobo()`

```r
#' @title Importer des données depuis KoboToolbox
#' @description Importe un formulaire KoboToolbox via fichier local (XLS/JSON)
#'   ou via l'API REST. Retourne un tibble annoté avec les métadonnées.
#' @param source character — Chemin vers fichier XLS/JSON ou URL API
#' @param uid character — Identifiant unique du formulaire (requis si API)
#' @param token character — Jeton d'authentification API
#' @param format character — "xls" ou "json". Défaut : "xls"
#' @param langue character — Code langue pour labels multilingues. Défaut : "French (fr)"
#' @param verbose logical — Afficher les messages de progression. Défaut : TRUE
#' @return tibble avec attribut `metadonnees_kobo` contenant le dictionnaire
#' @examples
#' \dontrun{
#'   donnees <- import_kobo(source = "data/enquete_2024.xls", format = "xls")
#' }
#' @export
import_kobo <- function(source, uid = NULL, token = Sys.getenv("KOBO_TOKEN"),
                        format = c("xls", "json"), langue = "French (fr)",
                        verbose = TRUE) { }
```

### Fonction `import_cspro()`

```r
#' @title Importer des données CSPro
#' @description Lit les fichiers CSPro (.dat + .dcf). Prioritaire pour les RGPH.
#' @param fichier_dat character — Chemin vers le fichier .dat
#' @param fichier_dcf character — Chemin vers le dictionnaire .dcf (auto-détecté si NULL)
#' @param niveau character — Niveau d'enregistrement ("MENAGE", "INDIVIDU"). Défaut : NULL
#' @param encoding character — Encodage. Défaut : "UTF-8"
#' @return tibble avec labels issus du dictionnaire CSPro
#' @examples
#' \dontrun{
#'   menages <- import_cspro("data/rgph_2024.dat", niveau = "MENAGE")
#' }
#' @export
import_cspro <- function(fichier_dat, fichier_dcf = NULL,
                         niveau = NULL, encoding = "UTF-8") { }
```

### Fonction `appliquer_ponderations()`

```r
#' @title Appliquer les pondérations d'enquête
#' @description Crée un objet svydesign avec validation complète des poids.
#' @param data data.frame ou tibble — Données de l'enquête
#' @param var_poids character — Variable de pondération finale
#' @param var_strate character ou NULL — Variable de stratification
#' @param var_grappe character ou NULL — Unité primaire de sondage
#' @param normaliser logical — Normaliser les poids. Défaut : FALSE
#' @return Objet `svydesign` prêt pour l'analyse pondérée
#' @examples
#' plan <- appliquer_ponderations(donnees, "poids_final", "strate", "grappe_id")
#' @export
appliquer_ponderations <- function(data, var_poids, var_strate = NULL,
                                   var_grappe = NULL, normaliser = FALSE) { }
```

### Fonction `calcul_idh()`

```r
#' @title Calculer l'Indice de Développement Humain (IDH)
#' @description Calcule l'IDH selon la méthodologie officielle PNUD (post-2010).
#' @param esperance_vie numeric — Espérance de vie à la naissance (années)
#' @param annees_scol_moy numeric — Durée moyenne de scolarisation (années)
#' @param annees_scol_att numeric — Durée attendue de scolarisation (années)
#' @param rnb_habitant numeric — RNB par habitant en PPA (USD 2017)
#' @param annee integer ou NULL — Année de référence
#' @return Liste : `$idh`, `$indice_sante`, `$indice_education`,
#'   `$indice_revenu`, `$categorie`
#' @examples
#' idh <- calcul_idh(61.2, 5.4, 9.8, 2350, annee = 2023)
#' cat("IDH :", idh$idh, "-", idh$categorie)
#' @export
calcul_idh <- function(esperance_vie, annees_scol_moy, annees_scol_att,
                       rnb_habitant, niveau = c("national","infranational"),
                       annee = NULL) { }
```

### Fonction `anonymiser_donnees()`

```r
#' @title Anonymiser un jeu de données
#' @description K-anonymisation et suppression des identifiants selon ONU-STAT.
#' @param data data.frame ou tibble — Données à anonymiser
#' @param vars_directes character — Variables identifiantes directes à supprimer
#' @param vars_quasi character ou NULL — Variables quasi-identifiantes à généraliser
#' @param k integer — Niveau de k-anonymat souhaité. Défaut : 5
#' @param methode_bruit character — "arrondi", "aucune", "perturbation". Défaut : "arrondi"
#' @param rapport logical — Produire un rapport d'anonymisation. Défaut : TRUE
#' @return Liste : `$donnees` (tibble anonymisé) + `$rapport`
#' @examples
#' res <- anonymiser_donnees(enquete, vars_directes = c("nom", "telephone"), k = 5)
#' @export
anonymiser_donnees <- function(data, vars_directes, vars_quasi = NULL,
                               k = 5L, methode_bruit = c("arrondi","aucune","perturbation"),
                               rapport = TRUE) { }
```

---

## 📌 Étape 4/8 — Architecture & Gouvernance

### Arborescence CRAN-compliant

```
statAfrikR/
├── R/
│   ├── collecte.R
│   ├── traitement.R
│   ├── analyse.R
│   ├── visualisation.R
│   ├── diffusion.R
│   ├── utils.R
│   ├── utils-messages.R
│   └── statAfrikR-package.R
├── data/
│   ├── rgph_fictif.rda
│   ├── eds_fictif.rda
│   └── emop_fictif.rda
├── data-raw/
├── inst/
│   ├── extdata/
│   │   ├── shapefiles/
│   │   └── templates/
│   │       ├── bulletin_mensuel.Rmd
│   │       ├── rapport_annuel.Rmd
│   │       └── fiche_pays.Rmd
│   ├── i18n/
│   │   ├── fr.yml
│   │   ├── en.yml
│   │   └── pt.yml
│   └── dict/
│       ├── regions_afristat.csv
│       └── indicateurs_onu.csv
├── man/
├── vignettes/
│   ├── 01-demarrage-rapide.Rmd
│   ├── 02-enquete-ponderee.Rmd
│   └── 03-extension-developpeur.Rmd
├── tests/testthat/
│   ├── helper-donnees.R
│   ├── test-collecte.R
│   ├── test-traitement.R
│   ├── test-analyse.R
│   ├── test-visualisation.R
│   └── test-diffusion.R
├── .github/
│   ├── workflows/
│   │   ├── R-CMD-check.yml
│   │   ├── pkgdown.yml
│   │   └── test-coverage.yml
│   └── ISSUE_TEMPLATE/
├── DESCRIPTION
├── NAMESPACE
├── NEWS.md
├── README.md
├── LICENSE
├── CONTRIBUTING.md
└── .Rbuildignore
```

### Stratégie de dépendances

| Package | Rôle | Statut |
|---------|------|--------|
| `dplyr`, `tidyr`, `readr`, `stringr`, `purrr`, `tibble` | Manipulation données | **Imports** |
| `haven` | Fichiers SPSS/Stata | **Imports** |
| `survey`, `srvyr` | Pondérations | **Imports** |
| `sf` | Données spatiales | **Imports** |
| `ggplot2` | Visualisation | **Imports** |
| `flextable`, `officer` | Rapports Word | **Imports** |
| `rmarkdown` | Génération rapports | **Imports** |
| `rlang`, `cli` | Messages d'erreur | **Imports** |
| `tmap`, `leaflet` | Cartes interactives | **Suggests** |
| `httr2`, `jsonlite` | Connecteurs API | **Suggests** |
| `shiny` | Interface graphique (v1.1) | **Suggests** |
| `testthat`, `knitr`, `covr` | Développement uniquement | **Suggests** |

### Versionnement sémantique

```
0.1.0 → Premier jalon : noyau Collecte + Traitement
0.2.0 → Module Analyse complet
0.3.0 → Visualisation + Diffusion
0.9.0 → Release candidate (tests INS pilote)
1.0.0 → Publication CRAN officielle
```

---

## 📌 Étape 5/8 — Plan de tests et qualité

### Tests prioritaires par module

```r
# test-collecte.R
test_that("import_excel() retourne un tibble", { ... })
test_that("import_excel() gère les fichiers multi-feuilles", { ... })
test_that("import_excel() échoue proprement sur fichier inexistant", { ... })
test_that("valider_dictionnaire() détecte les variables manquantes", { ... })
test_that("check_na() calcule correctement les taux", { ... })

# test-traitement.R
test_that("appliquer_ponderations() retourne un svydesign", { ... })
test_that("appliquer_ponderations() échoue sur poids négatifs", { ... })
test_that("imputer_valeurs() réduit le nombre de NA", { ... })
test_that("nettoyer_libelles() préserve les accents français", { ... })

# test-analyse.R
test_that("calcul_idh() retourne une valeur entre 0 et 1", { ... })
test_that("tab_croisee() fonctionne sans pondération", { ... })
test_that("tab_croisee() fonctionne avec un objet svydesign", { ... })

# test-diffusion.R
test_that("anonymiser_donnees() supprime les variables directes", { ... })
test_that("anonymiser_donnees() respecte le niveau k", { ... })
```

### Seuils de qualité cibles

| Métrique | Minimum | Cible |
|----------|---------|-------|
| Couverture de tests (`covr`) | 70% | 85% |
| `R CMD check` warnings | 0 | 0 |
| `R CMD check` notes (CRAN) | 0 | 0 |
| Fonctions exportées sans docs | 0 | 0 |

### Pipeline CI/CD (GitHub Actions)

```yaml
# R-CMD-check.yml — Tests sur Windows (prioritaire INS) + Ubuntu
strategy:
  matrix:
    config:
      - {os: windows-latest, r: 'release'}
      - {os: windows-latest, r: 'oldrel-1'}
      - {os: ubuntu-latest,  r: 'release'}
      - {os: ubuntu-latest,  r: 'devel'}
```

---

## 📌 Étape 6/8 — Stratégie de documentation

### Trois vignettes prioritaires

| Vignette | Public | Contenu |
|----------|--------|---------|
| `01-demarrage-rapide.Rmd` | Débutant (R < 1 an) | Installation offline, premier import Excel, tableau simple, graphique, export |
| `02-enquete-ponderee.Rmd` | Intermédiaire (tidyverse) | EDS fictive, plan de sondage, indicateurs pondérés, pyramide des âges, rapport PDF |
| `03-extension-developpeur.Rmd` | Avancé (développeur) | Architecture interne, ajouter un connecteur, écrire des tests, contribuer via PR |

### Règle multilinguisme

```
v1.0 : Français uniquement
v1.1 : Traduction anglaise des vignettes prioritaires
v1.2 : Support portugais (Angola, Mozambique, Cap-Vert)
```

---

## 📌 Étape 7/8 — Roadmap révisée (12 mois)

### Priorisation MoSCoW

| Priorité | Fonctionnalités |
|----------|----------------|
| **Must** | `import_excel`, `import_stata`, `import_cspro`, `valider_dictionnaire`, `appliquer_ponderations`, `tab_croisee`, `anonymiser_donnees`, `generer_rapport` |
| **Should** | `import_kobo`, `import_odk`, `imputer_valeurs`, `calcul_idh`, `calcul_ipm`, `pyramide_ages`, `carte_thematique`, `theme_ins`, `exporter_sdmx` |
| **Could** | `projection_demographique`, `analyse_survie`, `decomposer_inegalite`, `creer_tableau_bord` |
| **Won't (v1.0)** | Interface Shiny, API cloud, modules sectoriels spécialisés |

### Calendrier mensuel

| Mois | Activités | Jalon |
|------|-----------|-------|
| M1 | Cadrage + spécifications + infrastructure GitHub/CI | ✅ Spécifications validées par INS pilote |
| M2 | Module Collecte (Must) + jeux de données fictifs | ✅ Import de 5 formats validé |
| M3 | Module Traitement (Must) | ✅ Pipeline import→traitement testé |
| M4 | Module Analyse Part.1 : tableaux, IDH, IPM, anonymisation | ✅ Tableau pauvreté multidimensionnelle auto-produit |
| M5 | Analyse Part.2 + Visualisation + import Kobo/ODK | ✅ Prototype livré à l'INS pilote |
| M6 | **Sprint validation INS pilote** (2 semaines terrain) | ✅ Rapport de tests validé |
| M7 | Corrections + Module Diffusion (rapports, templates) | ✅ Rapport complet produit en < 2h |
| M8 | Fonctions Should restantes (SDMX, DDI, logs) | ✅ Conformité SDMX vérifiée AFRISTAT |
| M9 | Documentation complète (vignettes, pkgdown, PDF) | ✅ Documentation revue par non-développeur |
| M10 | Tests finaux + préparation CRAN | ✅ Acceptation CRAN |
| M11 | Formation + lancement régional | ✅ 20 agents formés, 50 postes installés |
| M12 | Stabilisation + roadmap v1.1 | ✅ Version 1.0.x stable |

### Estimation des charges

| Module | Dév. | Tests | Docs | **Total** |
|--------|------|-------|------|-----------|
| Infrastructure | 5 j | 2 j | 1 j | **8 j** |
| Collecte | 12 j | 5 j | 3 j | **20 j** |
| Traitement | 10 j | 4 j | 3 j | **17 j** |
| Analyse | 20 j | 8 j | 6 j | **34 j** |
| Visualisation | 12 j | 4 j | 3 j | **19 j** |
| Diffusion | 10 j | 3 j | 4 j | **17 j** |
| Documentation | — | — | 10 j | **10 j** |
| CRAN + lancement | 8 j | 5 j | 5 j | **18 j** |
| **TOTAL** | **77 j** | **31 j** | **35 j** | **143 j** |

> Avec 2 développeurs R à temps plein ≈ 10 mois calendaires.

---

## 📌 Étape 8/8 — Plan de durabilité et adoption

### Modèle de gouvernance

```
COMITÉ DE PILOTAGE (trimestriel)
  └── INS pilote + AFRISTAT + PTF
        ↓ valide la roadmap
ÉQUIPE MAINTAINERS (3–5 personnes)
  └── Lead maintainer (1 développeur INS)
  └── Co-maintainers (2–4 développeurs actifs)
        ↓ reviews PR + releases
CONTRIBUTEURS COMMUNAUTÉ
  └── INS partenaires, chercheurs, étudiants
```

### KPIs de succès

| KPI | À 6 mois | À 12 mois |
|-----|----------|-----------|
| Téléchargements CRAN | > 500 | > 2 000 |
| Stars GitHub | > 100 | > 300 |
| INS utilisant le package | ≥ 3 | ≥ 8 |
| Agents INS formés | ≥ 30 | ≥ 80 |
| Rapports officiels produits | ≥ 5 | ≥ 20 |
| Contributeurs externes | ≥ 2 PR | ≥ 5 PR |

### Partenaires institutionnels prioritaires

| Partenaire | Rôle | Priorité |
|-----------|------|----------|
| **AFRISTAT** | Coordination régionale, normalisation | ⭐⭐⭐ Critique |
| **PARIS21** | Renforcement capacités, visibilité | ⭐⭐⭐ Critique |
| **CEA-ONU** | Standards SDMX/DDI | ⭐⭐⭐ Critique |
| **INS Bénin / INSAE** | INS pilote francophone | ⭐⭐⭐ Critique |
| **INSD Burkina Faso** | Expertise R déjà présente | ⭐⭐ Élevée |
| **ANSD Sénégal** | Capacité à co-développer | ⭐⭐ Élevée |
| **Banque Mondiale** | Financement, diffusion CRAN | ⭐⭐ Élevée |
| **r4africa Community** | Adoption grassroots | ⭐⭐ Élevée |

### Stratégie de formation

| Niveau | Format | Durée | Public |
|--------|--------|-------|--------|
| 1. Autoformation | Manuel PDF + fiches + vidéos offline | En continu | Tous |
| 2. Atelier fondamental | Présentiel (3 jours) | Par trimestre | 15 agents/session |
| 3. Formation de formateurs | Présentiel (2 jours sup.) | Annuel | Référents INS |
