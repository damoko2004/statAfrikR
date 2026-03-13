# Importer un fichier Excel

Importe un fichier Excel (.xlsx, .xls) avec détection automatique des
feuilles, gestion des en-têtes multiples et conversion intelligente des
types de colonnes. Optimisé pour les formats courants des INS africains.

## Utilisation

``` r
import_excel(
  chemin,
  feuille = 1,
  skip = 0,
  col_types = NULL,
  na = c("", "NA", "N/A", "n/a", ".", " "),
  verbose = TRUE
)
```

## Arguments

- chemin:

  character — Chemin vers le fichier Excel (.xlsx ou .xls)

- feuille:

  character ou integer ou NULL — Nom ou numéro de la feuille à importer.
  Si NULL, importe toutes les feuilles sous forme de liste. Défaut : 1
  (première feuille).

- skip:

  integer — Nombre de lignes à ignorer avant l'en-tête. Défaut : 0.

- col_types:

  character ou NULL — Types des colonnes (voir readxl). Si NULL,
  détection automatique. Défaut : NULL.

- na:

  character — Valeurs à interpréter comme NA. Défaut : c("", "NA",
  "N/A", "n/a", ".", " ").

- verbose:

  logical — Afficher les messages de progression. Défaut : TRUE.

## Valeur de retour

Un tibble si une seule feuille, une liste de tibbles si
`feuille = NULL`.

## Voir également

[`import_csv`](https://damoko2004.github.io/statAfrikR/reference/import_csv.md),
[`valider_dictionnaire`](https://damoko2004.github.io/statAfrikR/reference/valider_dictionnaire.md)

## Exemples

``` r
if (FALSE) { # \dontrun{
  # Import de la première feuille
  donnees <- import_excel("data/enquete_menage.xlsx")

  # Import d'une feuille spécifique
  menages <- import_excel("data/emop_2024.xlsx", feuille = "Menages")

  # Import de toutes les feuilles
  toutes <- import_excel("data/rapport.xlsx", feuille = NULL)
} # }
```
