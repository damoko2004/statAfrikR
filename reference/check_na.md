# Détecter les valeurs manquantes

Calcule le taux de valeurs manquantes par variable et produit un rapport
de complétude. Alerte sur les variables dépassant le seuil.

## Usage

``` r
check_na(data, seuil = 0.1, vars = NULL, alerter = TRUE)
```

## Arguments

- data:

  data.frame ou tibble — Données à analyser

- seuil:

  numeric — Taux de NA à partir duquel une alerte est émise (entre 0 et
  1). Défaut : 0.1 (10%).

- vars:

  character ou NULL — Variables à analyser. Si NULL, toutes les
  variables. Défaut : NULL.

- alerter:

  logical — Émettre des avertissements pour les variables dépassant le
  seuil. Défaut : TRUE.

## Value

Un tibble avec les colonnes : `variable`, `n_total`, `n_manquant`,
`taux_na`, `statut`.

## Examples

``` r
if (FALSE) { # \dontrun{
  rapport_na <- check_na(donnees_enquete)
  rapport_na <- check_na(donnees_enquete, seuil = 0.05, vars = c("age", "revenu"))
} # }
```
