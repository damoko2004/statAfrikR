# Générer une fiche de métadonnées DDI

Produit une fiche de métadonnées au format DDI (Data Documentation
Initiative) Codebook 2.5, standard international pour l'archivage des
enquêtes statistiques (IHSN, NADA, NESSTAR).

## Utilisation

``` r
generer_metadonnees_ddi(
  data,
  titre = NULL,
  pays = NULL,
  annee = NULL,
  institution = NULL,
  auteurs = NULL,
  description = NULL,
  fichier_sortie = NULL,
  langue = "fr"
)
```

## Arguments

- data:

  data.frame ou tibble — Données de l'enquête

- titre:

  character — Titre de l'enquête

- pays:

  character — Pays concerné

- annee:

  integer ou character — Année de l'enquête

- institution:

  character — Institution productrice

- auteurs:

  character ou NULL — Auteurs. Défaut : NULL.

- description:

  character ou NULL — Description de l'enquête. Défaut : NULL.

- fichier_sortie:

  character — Chemin du fichier XML de sortie

- langue:

  character — Langue principale. Défaut : "fr".

## Valeur de retour

Chemin du fichier généré (invisible).

## Exemples

``` r
if (FALSE) { # \dontrun{
  generer_metadonnees_ddi(
    data        = donnees_emop,
    titre       = "Enquête Modulaire sur les Conditions de Vie — 2023",
    pays        = "Bénin",
    annee       = 2023,
    institution = "INSAE",
    fichier_sortie = "outputs/emop_2023_ddi.xml"
  )
} # }
```
