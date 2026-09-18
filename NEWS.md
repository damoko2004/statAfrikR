# statAfrikR News

## statAfrikR 0.2.0 (2026-09-18)

### 17 nouveaux modules — 644+ tests — 0 erreurs CRAN

#### Nouveau — Module Pauvrete monetaire FGT
* `calcul_fgt()` — FGT0/FGT1/FGT2 avec IC 95%, plan complexe, sous-groupes
* `decomposer_fgt()` — Decomposition par region, milieu, quintile
* `graphique_fgt()` — Graphique institutionnel FGT
* `tableau_fgt()` — Tableau Word/Excel format INS
* Nouveau : avertissements precision INS (n<30, CV>33%) dans les sous-groupes

#### Nouveau — Module IPM (Alkire-Foster 2011)
* `calcul_ipm()` — H, A, IPM, contributions, 10 indicateurs, 3 dimensions
* `calcul_ipm_national()` — Agregat national
* `decomposer_ipm()` — Decomposition par groupe/region
* `comparer_ipm()` — Comparaison entre annees ou pays
* `graphique_ipm()` — Graphique contributions par dimension
* `tableau_ipm()` — Tableau institutionnel

#### Nouveau — Module Inegalites
* `calcul_gini()` — Coefficient de Gini + IC bootstrap
* `courbe_lorenz()` — Courbe de Lorenz pondéree
* `indice_atkinson()` — Indice d Atkinson (parametre epsilon)
* `decomposer_theil()` — Theil T intra/inter groupes
* `indice_palma()` — Ratio Palma top10/bottom40
* `part_quintile()` — Parts de consommation par quintile

#### Nouveau — Module Sante et Nutrition (OMS/DHS/MICS)
* `retard_croissance()` — Stunting HAZ < -2SD (ODD 2.2.1)
* `emaciation()` — Wasting WHZ < -2SD
* `insuffisance_ponderale()` — Underweight WAZ < -2SD
* `anemie()` — Prevalence anemie
* `vaccination()` — Couverture vaccinale par antigene
* `mortalite_5ans()` — Mortalite < 5 ans (ODD 3.2.1)
* `accouchements_assistes()` — Accouchements assistes (ODD 3.1.2)
* `tableau_sante()` — Tableau institutionnel sante

#### Nouveau — Module Emploi et Travail decent (OIT 2013)
* `taux_activite()` — Taux d activite BIT
* `taux_emploi()` — Taux d emploi (ODD 8.5)
* `emploi_informel()` — Emploi informel OIT 2013
* `sous_emploi_temps()` — Sous-emploi en temps (OIT LU2)
* `taux_sous_utilisation()` — Composite LU3 (OIT)
* `pauvrete_travail()` — Pauvrete au travail (ODD 8.1.1)
* `emploi_vulnerable()` — Emploi vulnerable (ODD 8.3.1)
* `protection_sociale()` — Couverture protection sociale (ODD 1.3.1)
* `travail_enfants()` — Travail des enfants (ODD 8.7.1)
* `tableau_marche_travail()` — Tableau de bord emploi OIT/ILOSTAT

#### Nouveau — Module Genre et Inclusion (ODD 5)
* `autonomisation_femmes()` — Indice composite 3 dimensions DHS/MICS
* `violence_basee_genre()` — VBG physique/sexuelle/psychologique (ODD 5.2.1)
* `mariage_precoce()` — Mariage avant 18 ans + cohortes (ODD 5.3.1)
* `parite_education()` — ISP filles/garcons (ODD 4.5.1)
* `handicap_prevalence()` — Prevalence handicap (Washington Group)
* `tableau_genre()` — Tableau de bord genre

#### Nouveau — Module PIB et Comptes nationaux (SCN 2008)
* `comparer_pib()` — INS vs UNSD/BM/FMI, diagnostic ecarts
* `suivre_revisions_pib()` — Preliminaire/Provisoire/Definitif
* `calculer_deflateur()` — Conversion prix courants vers constants
* `taux_croissance()` — Taux reel/nominal + contributions sectorielles
* `tableau_bord_pib()` — Dashboard PIB institutionnel

#### Nouveau — Module Bien-etre subjectif (Afrobarometer/OCDE/Gallup)
* `satisfaction_vie()` — Score Cantril 0-10 + distribution
* `bonheur_declare()` — Proportion se declarant heureuse
* `perception_economique()` — Perception situation economique
* `privations_ressenties()` — Nourriture/eau/medicaments/argent
* `sante_mentale()` — Stress/anxiete/isolement
* `confiance_institutions()` — Gouvernement/justice/police
* `sentiment_securite()` — Securite percue
* `tableau_bien_etre_subjectif()` — Tableau institutionnel

#### Nouveau — Module Plans de sondage complexes
* `creer_design()` — svydesign strates/grappes/poids/FPC (EHCVM/DHS/MICS)
* `valider_poids()` — CV, outliers Z-score, ecart population cible
* `calcul_deff()` — DEFF = Var_complexe/Var_SRS, taille effective
* `calibrer_poids()` — Raking iteratif, post-stratification
* `analyser_non_reponse()` — Taux + biais de non-reponse
* `rapport_qualite_sondage()` — Rapport qualite IHSN

#### Nouveau — Module Qualite demographique (ONU/IUSSP)
* `whipple()` — Indice de Whipple (attraction 0 et 5)
* `myers()` — Indice de Myers (attraction tous chiffres)
* `ratio_masculinite()` — Rapport H/F par groupe quinquennal
* `pyramide_age()` — Pyramide des ages institutionnelle ggplot2
* `coherence_demo()` — Detection anomalies demographiques
* `rapport_qualite_demo()` — Rapport qualite ONU

#### Nouveau — Module Harmonisation geographique (IHSN/PARIS21)
* `table_concordance()` — EHCVM vs ISO vs GADM vs codes INS
* `harmoniser_zones()` — Normalisation Jaro-Winkler
* `detecter_ecarts_geo()` — Zones non appariees + suggestions
* `migrer_nomenclature()` — Conversion entre nomenclatures
* `valider_coherence_geo()` — Manquantes/surplus/doublons
* `rapport_harmonisation()` — Rapport IHSN/PARIS21

#### Nouveau — Module Validation Statistique INS
* `valider_statistique_ins()` — INS Validation Suite : 10 criteres
  - Qualite donnees, poids, valeurs manquantes, geographie
  - Precision statistique, confidentialite, metadonnees
  - Reproductibilite, indicateurs cles, statut global
  - Statuts : VALIDE / A VERIFIER / ECHEC

#### Nouveau — Module Dashboard Shiny interactif
* `lancer_dashboard()` — Dashboard 8 sections, bandeau titre/sous-titre,
  sidebar fixe, filtres sticky, 10 modules pre-calcules automatiquement
* `exporter_code_dashboard()` — Fichier R autonome 7 sections commentees
  pour personnalisation par les agents INS

#### Ameliorations methodologiques (audit INS)
* Avertissements precision : n<30 et CV>33% dans `calcul_fgt()` sous-groupes
* Controle confidentialite : cellules < seuil dans `anonymiser_donnees()`
* Note methodologique IC Wilson vs IC Survey (linearisation Taylor)
* `valider_statistique_ins()` — Suite de validation institutionnelle INS

#### Geodonnees
* 888 subdivisions administratives, 53/54 pays africains integres
* Packages sf + ggrepel en Imports

#### Tests
* 666+ tests unitaires — FAIL 0 | WARN 0 | SKIP 2 (shiny, rmarkdown)
* 0 erreurs CRAN | 0 warnings | 0 notes

#### Documentation
* Note methodologique IC Wilson vs IC Survey dans statAfrikR-package.R
* URL https://statafrikr.org/ dans DESCRIPTION et package.R
* Josue Honore Dasse ajoute comme contributeur (ctb)

---

## statAfrikR 0.1.0 (2026-03-12)

### Premiere version officielle

#### Nouveau — Module Collecte (11 fonctions)
* `import_excel()` — Import fichiers Excel (.xlsx/.xls), multi-feuilles
* `import_csv()` — Import CSV avec detection automatique du separateur
* `import_stata()` — Import Stata .dta toutes versions, avec labels
* `import_spss()` — Import SPSS .sav/.zsav avec labels
* `import_sas()` — Import SAS .sas7bdat
* `import_cspro()` — Import CSPro .dat + .dcf, multi-niveaux
* `import_kobo()` — Import KoboToolbox fichier XLS/JSON ou API REST
* `import_odk()` — Import ODK Central fichier ZIP/CSV ou API REST
* `check_na()` — Rapport des valeurs manquantes par variable
* `check_types()` — Detection des incoherences de types
* `valider_dictionnaire()` — Validation complete + score qualite

#### Nouveau — Module Traitement (9 fonctions)
* `nettoyer_libelles()` — Normalisation des chaines, casse, accents
* `harmoniser_regions()` — Referentiels BJ, BF, SN, CI integres
* `appliquer_ponderations()` — Plan de sondage complexe (svydesign)
* `imputer_valeurs()` — Imputation : mediane, moyenne, mode, hot-deck, regression
* `supprimer_doublons()` — Detection et suppression intelligente
* `recoder_variable()` — Recodage par table de correspondance
* `standardiser_ages()` — Indices Whipple et Myers, correction heap effect
* `fusion_datasets()` — Fusion verticale et horizontale (4 types)
* `tracer_flux_traitement()` — Journal horodate des transformations

#### Nouveau — Module Analyse (8 fonctions)
* `stat_descr()` — Statistiques descriptives ponderees + IC95
* `tab_croisee()` — Tableaux croises avec pourcentages ligne/colonne/total
* `analyse_regression()` — Regression lineaire, logistique, Poisson + OR/RR
* `analyse_spatiale()` — Jointure shapefile + agregation par zone
* `calcul_idh()` — IDH PNUD post-2010 avec categorie
* `calcul_ipm()` — IPM Alkire-Foster avec decomposition par dimension
* `decomposer_inegalite()` — Gini, Theil, Atkinson + decomposition
* `valider_qualite_donnees()` — Score qualite 0-100 (4 dimensions)

#### Nouveau — Module Visualisation (7 fonctions)
* `theme_ins()` — Theme ggplot2 officiel INS
* `palette_ins()` — Palette couleurs compatible daltonisme
* `pyramide_ages()` — Pyramide ponderee, classes parametrables
* `graphique_barres()` — Barres groupees/empilees + IC95
* `graphique_tendance()` — Series temporelles format large/long
* `carte_thematique()` — Carte choroplethe (sf + ggplot2)
* `exporter_graphique()` — Export PNG/PDF/SVG haute resolution

#### Nouveau — Module Diffusion (5 fonctions)
* `generer_rapport()` — Rapport Word/PDF depuis template Rmd
* `anonymiser_donnees()` — Suppression, masquage, perturbation, generalisation
* `exporter_sdmx()` — Export SDMX-CSV 2.1 pour FMI/BM/OCDE
* `generer_metadonnees_ddi()` — Fiche DDI Codebook 2.5 pour IHSN/NADA
* `compresser_package_diffusion()` — Archive ZIP structuree + README auto

#### Tests
* 257 tests unitaires — FAIL 0 | WARN 0 | SKIP 0

#### Documentation
* 3 vignettes : demarrage rapide, enquete ponderee, indicateurs ODD
* Documentation roxygen2 complete pour toutes les fonctions exportees

