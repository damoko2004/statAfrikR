# Compresser un package de diffusion

Crée une archive ZIP structurée prête à diffuser, incluant les données,
la documentation, les métadonnées et les scripts de traitement. Conforme
aux standards IHSN de documentation des enquêtes.

## Usage

``` r
compresser_package_diffusion(
  donnees,
  repertoire_sortie,
  nom_package,
  inclure_csv = TRUE,
  inclure_rds = TRUE,
  fichiers_supplementaires = NULL,
  metadonnees = NULL
)
```

## Arguments

- donnees:

  data.frame ou tibble — Données à archiver

- repertoire_sortie:

  character — Répertoire de destination de l'archive

- nom_package:

  character — Nom de base de l'archive (sans extension)

- inclure_csv:

  logical — Inclure les données en CSV. Défaut : TRUE.

- inclure_rds:

  logical — Inclure les données en RDS. Défaut : TRUE.

- fichiers_supplementaires:

  character ou NULL — Chemins vers des fichiers additionnels à inclure
  (rapports, scripts, etc.). Défaut : NULL.

- metadonnees:

  list ou NULL — Métadonnées à inclure dans un fichier README
  automatique. Défaut : NULL.

## Value

Chemin de l'archive ZIP (invisible).

## Examples

``` r
if (FALSE) { # \dontrun{
  compresser_package_diffusion(
    donnees              = donnees_emop_anon,
    repertoire_sortie    = "diffusion/",
    nom_package          = "EMOP_BEN_2023_v1",
    fichiers_supplementaires = c("outputs/rapport.docx",
                                  "outputs/emop_ddi.xml"),
    metadonnees = list(
      titre       = "EMOP Bénin 2023",
      institution = "INSAE",
      version     = "1.0"
    )
  )
} # }
```
