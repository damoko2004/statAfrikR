# Importer un fichier Stata

Importe un fichier Stata (.dta) avec préservation des labels de
variables et de valeurs. Compatible avec toutes les versions Stata
(Stata 8 à Stata 18).

## Usage

``` r
import_stata(
  chemin,
  encoding = "UTF-8",
  garder_labels = TRUE,
  convertir_labels = FALSE,
  verbose = TRUE
)
```

## Arguments

- chemin:

  character — Chemin vers le fichier .dta

- encoding:

  character — Encodage pour les labels. Défaut : "UTF-8".

- garder_labels:

  logical — Conserver les labels comme attributs. Défaut : TRUE.

- convertir_labels:

  logical — Convertir les variables labellisées en facteurs. Défaut :
  FALSE.

- verbose:

  logical — Afficher les messages. Défaut : TRUE.

## Value

Un tibble avec attributs de labels si `garder_labels = TRUE`.

## Examples

``` r
if (FALSE) { # \dontrun{
  eds <- import_stata("data/eds_2021.dta")
  eds_facteurs <- import_stata("data/eds_2021.dta", convertir_labels = TRUE)
} # }
```
