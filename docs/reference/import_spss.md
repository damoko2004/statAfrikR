# Importer un fichier SPSS

Importe un fichier SPSS (.sav ou .zsav) avec préservation des labels de
variables et de valeurs SPSS.

## Utilisation

``` r
import_spss(
  chemin,
  garder_labels = TRUE,
  convertir_labels = FALSE,
  encoding = NULL,
  verbose = TRUE
)
```

## Arguments

- chemin:

  character — Chemin vers le fichier .sav ou .zsav

- garder_labels:

  logical — Conserver les labels. Défaut : TRUE.

- convertir_labels:

  logical — Convertir en facteurs. Défaut : FALSE.

- encoding:

  character ou NULL — Encodage. Si NULL, détection auto. Défaut : NULL.

- verbose:

  logical — Afficher les messages. Défaut : TRUE.

## Valeur de retour

Un tibble.

## Exemples

``` r
if (FALSE) { # \dontrun{
  mics <- import_spss("data/mics6_enfants.sav")
} # }
```
