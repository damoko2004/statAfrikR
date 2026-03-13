# Importer un fichier SAS

Importe un fichier SAS (.sas7bdat) ou un fichier de formats SAS
(.sas7bcat) avec préservation des labels.

## Utilisation

``` r
import_sas(chemin, chemin_formats = NULL, encoding = "UTF-8", verbose = TRUE)
```

## Arguments

- chemin:

  character — Chemin vers le fichier .sas7bdat

- chemin_formats:

  character ou NULL — Chemin vers le fichier de formats .sas7bcat
  (optionnel). Défaut : NULL.

- encoding:

  character — Encodage. Défaut : "UTF-8".

- verbose:

  logical — Afficher les messages. Défaut : TRUE.

## Valeur de retour

Un tibble.

## Exemples

``` r
if (FALSE) { # \dontrun{
  donnees <- import_sas("data/enquete_emploi.sas7bdat")
} # }
```
