# Harmoniser les noms de régions/provinces

Standardise les noms de régions géographiques selon un référentiel
national ou africain. Corrige les variantes orthographiques, les
abréviations et les noms en langues locales.

## Utilisation

``` r
harmoniser_regions(
  data,
  var_region,
  pays = NULL,
  table_correspondance = NULL,
  var_sortie = "region_std",
  signaler_non_trouves = TRUE
)
```

## Arguments

- data:

  data.frame ou tibble — Données à harmoniser

- var_region:

  character — Nom de la variable contenant les régions

- pays:

  character ou NULL — Code pays ISO2 pour utiliser le référentiel
  intégré (ex: "BJ", "BF", "SN", "CI", "ML", "NE", "TG", "CM", "GN"). Si
  NULL, utilise `table_correspondance`. Défaut : NULL.

- table_correspondance:

  data.frame ou NULL — Table de correspondance avec colonnes `original`
  et `standardise`. Si NULL et `pays` est NULL, tente une correspondance
  floue automatique. Défaut : NULL.

- var_sortie:

  character — Nom de la nouvelle colonne standardisée. Défaut :
  "region_std".

- signaler_non_trouves:

  logical — Afficher les valeurs non reconnues. Défaut : TRUE.

## Valeur de retour

Le tibble avec une colonne `var_sortie` ajoutée contenant les régions
standardisées.

## Exemples

``` r
if (FALSE) { # \dontrun{
  donnees <- harmoniser_regions(
    data       = donnees_enquete,
    var_region = "region",
    pays       = "BJ"
  )
} # }
```
