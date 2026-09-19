# statAfrikR v0.2.0 — INS Readiness Document

**Package :** statAfrikR v0.2.0  
**Auteur :** Dikers Amoko <diamoko@gmail.com>  
**Contributeur :** Josue Honore Dasse <josue.h.dasse@gmail.com>  
**Licence :** GPL-3 | **Site :** https://statafrikr.org/  
**Date :** Septembre 2026

---

## 1. POSITIONNEMENT INSTITUTIONNEL

statAfrikR est une boite a outils statistique R conçue specifiquement pour les
Instituts Nationaux de Statistique (INS) d'Afrique subsaharienne. Il couvre
le cycle complet de production statistique (GSBPM phases 4-7) avec des
methodologies conformes aux standards internationaux.

**Cible principale :** Agents statisticiens des INS africains  
**Niveau requis :** R debutant a intermediaire  
**Langues :** Français (documentation, messages)  
**Environnement :** Fonctionne hors ligne (terrains, bureaux sans internet)

---

## 2. CONFORMITE AUX STANDARDS INTERNATIONAUX

| Standard | Couverture | Indicateurs |
|----------|-----------|------------|
| GSBPM 5.1-5.3 | Analyse et diffusion | Tous les 17 modules |
| UN NQAF | Qualite des donnees | valider_statistique_ins() |
| SCN 2008 | Comptes nationaux | Module PIB |
| OIT/BIT Resolution 2013 | Emploi | Module Emploi |
| OMS Standards 2006 | Anthropometrie | Module Sante |
| Alkire-Foster (2011) | IPM | Module IPM |
| Foster-Greer-Thorbecke (1984) | FGT | Module Pauvrete |
| IHSN/PARIS21 | Metadonnees/Dissemination | Modules Diffusion/Geo |
| SDMX 2.1 | Echange donnees | exporter_sdmx() |
| DDI Codebook 2.5 | Metadonnees | generer_metadonnees_ddi() |

---

## 3. INDICATEURS ODD COUVERTS

| ODD | Indicateur | Fonction |
|-----|-----------|---------|
| 1.1.1 | Pauvrete extreme ($2.15/j PPA) | calcul_fgt() |
| 1.2.1 | Pauvrete nationale | calcul_fgt() |
| 1.2.2 | IPM | calcul_ipm() |
| 1.3.1 | Protection sociale | protection_sociale() |
| 2.2.1 | Stunting | retard_croissance() |
| 2.2.2 | Wasting | emaciation() |
| 3.1.2 | Accouchements assistes | accouchements_assistes() |
| 3.2.1 | Mortalite < 5 ans | mortalite_5ans() |
| 4.5.1 | Parite education | parite_education() |
| 5.2.1 | Violences basees genre | violence_basee_genre() |
| 5.3.1 | Mariage precoce | mariage_precoce() |
| 8.1.1 | Croissance PIB | taux_croissance() |
| 8.3.1 | Emploi vulnerable | emploi_vulnerable() |
| 8.5.2 | Chomage | taux_activite() |
| 8.6.1 | NEET | taux_activite() |
| 8.7.1 | Travail enfants | travail_enfants() |
| 10.1 | Inegalites Gini | calcul_gini() |

---

## 4. INS VALIDATION SUITE

La fonction `valider_statistique_ins()` produit un rapport de validation
couvrant 10 criteres institutionnels :

```r
rapport <- valider_statistique_ins(
  donnees        = mon_enquete,
  var_poids      = "poids_sondage",
  var_region     = "region",
  var_depense    = "conso_par_tete",
  seuil_pauvrete = 171486,
  pays           = "Centrafrique",
  annee          = 2024L
)
# Statut : VALIDE / A VERIFIER / ECHEC
```

**Criteres evalues :**
1. Qualite donnees (completude, doublons)
2. Poids de sondage (CV, outliers, valeurs negatives)
3. Valeurs manquantes (par variable, seuil configurable)
4. Geographie (couverture, regions avec n<30)
5. Precision statistique (DEFF, methode IC recommandee)
6. Confidentialite (cellules < seuil, defaut=5)
7. Metadonnees (taux de documentation)
8. Reproductibilite (version, date, pays)
9. Indicateurs cles (FGT0 + CV si disponible)
10. Statut global : VALIDE / A VERIFIER / ECHEC

---

## 5. AVERTISSEMENTS DE PRECISION STATISTIQUE

statAfrikR emet automatiquement des avertissements quand :

- **n < 30** dans un sous-groupe desagrege
- **CV > 33%** pour une estimation FGT
- **Cellules < 5** dans un tableau de contingence

Ces seuils sont configurables et bases sur les recommandations ONU/OCDE.

---

## 6. METHODES DE VARIANCE IMPLEMENTEES

| Methode | Contexte | Fonctions |
|---------|---------|----------|
| Wilson (IC exact) | Proportions simples | Emploi, Sante, Genre, Bien-etre |
| Bootstrap | Gini, Atkinson | calcul_gini(), indice_atkinson() |
| Taylor (plan complexe) | FGT via survey::svydesign | calcul_fgt() + creer_design() |
| Delta method | IPM | calcul_ipm() |

**Recommandation pour publications officielles :**
```r
# Utiliser la variance de Taylor pour le FGT avec plan complexe
design <- creer_design(donnees, "poids_sond",
                        var_strate="strate", var_grappe="grappe")
# Les IC seront bases sur la linearisation de Taylor
```

---

## 7. GESTION DES PLANS DE SONDAGE COMPLEXES

```r
# 1. Creer le design
design <- creer_design(donnees, "poids_sond",
                        var_strate="strate", var_grappe="grappe")

# 2. Valider les poids
valider_poids(design, population_cible=4500000)

# 3. Calculer le DEFF
calcul_deff(design, variables=c("pauvre","stunting"))

# 4. Calibrer si necessaire
design_cal <- calibrer_poids(design,
  marges=list(sexe=c(H=2200000, F=2300000)))

# 5. Rapport qualite
rapport_qualite_sondage(design_cal, variables="pauvre",
                         pays="Centrafrique", annee=2024L)
```

---

## 8. DASHBOARD POUR LES AGENTS INS

```r
# Lancement zero-code pour l'agent INS
lancer_dashboard(
  donnees    = mon_enquete_ehcvm,
  var_poids  = "poids_sondage",
  var_region = "prefecture",
  var_milieu = "milieu",
  pays       = "Centrafrique",
  titre      = "Tableau de bord EHCVM 2024",
  sous_titre = "INS - Resultats preliminaires"
)

# Ou exporter le code pour personnalisation
exporter_code_dashboard(
  chemin     = "mon_dashboard.R",
  pays       = "Centrafrique",
  var_poids  = "poids_sondage"
)
# Le fichier genere contient 7 sections commentees
# L'agent modifie uniquement la Section 1 (chargement donnees)
```

---

## 9. CATALOGUE DES INDICATEURS

```r
# Lister tous les indicateurs disponibles
catalogue_indicateurs()

# Fiche methodologique complete
catalogue_indicateurs("FGT0", format="complet")
# -> Definition, formule, standard, ODD, variance, seuils

# Filtrer par domaine
catalogue_indicateurs(domaine="Emploi")
catalogue_indicateurs(domaine="Sante")
```

---

## 10. FEUILLE DE ROUTE POST-v0.2.0

| Version | Calendrier | Contenu principal |
|---------|-----------|-------------------|
| v0.2.1 | Oct. 2026 | Variance design-based generalisee |
| v0.2.2 | Dec. 2026 | Audit trail complet + hash |
| v0.2.3 | Mar. 2027 | Profils pays + geographies versionnees |
| v1.0.0 | Jun. 2027 | Production-ready NSO toolkit |

---

## 11. SUPPORT ET COMMUNAUTE

- **Documentation :** https://statafrikr.org/
- **GitHub :** https://github.com/damoko2004/statAfrikR
- **Discord :** https://discord.gg/kcfA27Yz
- **Email :** diamoko@gmail.com
- **StatsTalk Africa :** Webinaires mensuels INS

---

*statAfrikR v0.2.0 — GPL-3 — https://statafrikr.org/*  
*Dikers Amoko | Josue Honore Dasse*
