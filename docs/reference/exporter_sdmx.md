# Exporter des données au format SDMX

Génère un fichier SDMX-CSV ou SDMX-ML (Structure Data Message) conforme
aux standards SDMX 2.1 pour l'échange de données statistiques avec les
organisations internationales (FMI, BM, OCDE, etc.).

## Utilisation

``` r
exporter_sdmx(
  data,
  flux_donnees,
  agence = "INS",
  vars_dimensions,
  vars_mesures,
  vars_attributs = NULL,
  fichier_sortie,
  version = "2.1"
)
```

## Arguments

- data:

  data.frame ou tibble — Données à exporter

- flux_donnees:

  character — Identifiant du flux de données (DataFlow). Ex:
  "BEN_EMOP_2023"

- agence:

  character — Identifiant de l'agence productrice. Ex: "INSAE", "INSD".
  Défaut : "INS".

- vars_dimensions:

  character — Variables identifiant les dimensions (axes d'analyse). Ex:
  c("PAYS", "ANNEE", "REGION").

- vars_mesures:

  character — Variables contenant les valeurs mesurées.

- vars_attributs:

  character ou NULL — Variables d'attributs (métadonnées). Défaut :
  NULL.

- fichier_sortie:

  character — Chemin du fichier de sortie (.csv).

- version:

  character — Version SDMX. Défaut : "2.1".

## Valeur de retour

Chemin du fichier exporté (invisible).

## Exemples

``` r
if (FALSE) { # \dontrun{
  exporter_sdmx(
    data            = indicateurs_regionaux,
    flux_donnees    = "BEN_IDH_2023",
    agence          = "INSAE",
    vars_dimensions = c("region", "annee"),
    vars_mesures    = c("idh", "taux_pauvrete"),
    fichier_sortie  = "outputs/indicateurs_sdmx.csv"
  )
} # }
```
