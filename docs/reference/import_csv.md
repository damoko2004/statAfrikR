# Importer un fichier CSV

Importe un fichier CSV avec détection automatique de l'encodage, du
séparateur et du séparateur décimal. Gère les formats courants des INS
africains (séparateurs point-virgule, virgule, tabulation).

## Utilisation

``` r
import_csv(
  chemin,
  separateur = NULL,
  encodage = "UTF-8",
  decimal = ".",
  na = c("", "NA", "N/A", "n/a", ".", " "),
  verbose = TRUE
)
```

## Arguments

- chemin:

  character — Chemin vers le fichier CSV

- separateur:

  character ou NULL — Séparateur de colonnes. Si NULL, détection
  automatique. Défaut : NULL.

- encodage:

  character — Encodage du fichier. Défaut : "UTF-8" (essaie aussi
  "latin1" si UTF-8 échoue).

- decimal:

  character — Séparateur décimal ("." ou ","). Défaut : ".".

- na:

  character — Valeurs à interpréter comme NA. Défaut : c("", "NA",
  "N/A", "n/a", ".", " ").

- verbose:

  logical — Afficher les messages. Défaut : TRUE.

## Valeur de retour

Un tibble.

## Exemples

``` r
if (FALSE) { # \dontrun{
  donnees <- import_csv("data/prix_marches.csv")
  donnees_fr <- import_csv("data/donnees_fr.csv", decimal = ",")
} # }
```
