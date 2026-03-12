## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  warning  = FALSE,
  message  = FALSE
)

## ----charger------------------------------------------------------------------
library(statAfrikR)

## ----import-excel, eval=FALSE-------------------------------------------------
# donnees <- import_excel(
#   chemin    = "enquete_menages_2023.xlsx",
#   feuille   = "Données",
#   na_values = c("", "NA", "N/A", "9999", ".")
# )

## ----import-stata, eval=FALSE-------------------------------------------------
# donnees <- import_stata(
#   chemin           = "emop_2023.dta",
#   convertir_labels = TRUE
# )

## ----import-kobo, eval=FALSE--------------------------------------------------
# donnees <- import_kobo(
#   chemin = "enquete_kobo_export.xlsx"
# )

## ----validation, eval=FALSE---------------------------------------------------
# # Vérifier les valeurs manquantes
# rapport_na <- check_na(donnees, seuil = 0.1)
# print(rapport_na)
# 
# # Valider par rapport à un dictionnaire
# dict <- readr::read_csv("dictionnaire_variables.csv")
# score <- valider_dictionnaire(donnees, dict)
# cat("Score de qualité :", score$score_qualite, "/100\n")

## ----nettoyage, eval=FALSE----------------------------------------------------
# # Nettoyage des libellés textuels
# donnees <- nettoyer_libelles(
#   donnees,
#   vars  = c("region", "commune"),
#   casse = "titre"
# )
# 
# # Suppression des doublons
# resultat <- supprimer_doublons(donnees, cles = "id_menage")
# donnees  <- resultat$donnees
# cat("Doublons supprimés :", nrow(resultat$rapport), "\n")
# 
# # Imputation des valeurs manquantes
# donnees <- imputer_valeurs(
#   donnees,
#   vars    = c("revenu_mensuel", "depense_alimentaire"),
#   methode = "mediane",
#   rapport = FALSE
# )

## ----ponderation, eval=FALSE--------------------------------------------------
# plan <- appliquer_ponderations(
#   data       = donnees,
#   var_poids  = "poids_final",
#   var_strate = "strate",
#   var_grappe = "grappe_id"
# )

## ----analyse, eval=FALSE------------------------------------------------------
# # Statistiques descriptives pondérées
# stats <- stat_descr(
#   plan,
#   vars   = c("revenu_mensuel", "depense_alimentaire"),
#   ic     = TRUE
# )
# print(stats)
# 
# # Tableau croisé
# tableau <- tab_croisee(
#   plan,
#   var_ligne   = "quintile_vie",
#   var_col     = "milieu",
#   pourcentage = "colonne"
# )
# print(tableau)

## ----visualisation, eval=FALSE------------------------------------------------
# library(ggplot2)
# 
# # Pyramide des âges
# p <- pyramide_ages(
#   donnees,
#   var_age   = "age",
#   var_sexe  = "sexe",
#   var_poids = "poids_final",
#   titre     = "Pyramide des âges — Enquête 2023"
# )
# print(p)
# 
# # Exporter
# exporter_graphique(p, "outputs/pyramide_ages_2023.png", dpi = 300L)

## ----diffusion, eval=FALSE----------------------------------------------------
# # Anonymiser avant diffusion
# donnees_anon <- anonymiser_donnees(
#   donnees,
#   vars_supprimer   = c("nom", "prenom", "telephone", "adresse"),
#   vars_masquer     = c("id_menage", "id_individu"),
#   vars_generaliser = list(age = 5),
#   rapport          = FALSE
# )
# 
# # Créer le package de diffusion
# compresser_package_diffusion(
#   donnees           = donnees_anon,
#   repertoire_sortie = "diffusion/",
#   nom_package       = "EMOP_BEN_2023_v1",
#   metadonnees       = list(
#     titre       = "EMOP Bénin 2023",
#     institution = "INSAE",
#     version     = "1.0"
#   )
# )

