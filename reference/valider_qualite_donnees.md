# Valider la qualité globale d'un jeu de données

Calcule un score de qualité composite (0-100) en évaluant la complétude,
la cohérence, l'unicité et la plausibilité des données.

## Usage

``` r
valider_qualite_donnees(data, seuil_na = 0.1, vars_cles = NULL)
```

## Arguments

- data:

  data.frame ou tibble — Données à évaluer

- seuil_na:

  numeric — Seuil acceptable de valeurs manquantes. Défaut : 0.1.

- vars_cles:

  character ou NULL — Variables clés pour le test d'unicité. Défaut :
  NULL.

## Value

Une liste avec `score_global` et le détail par dimension.

## Examples

``` r
if (FALSE) { # \dontrun{
  qualite <- valider_qualite_donnees(donnees_enquete, vars_cles = "id_menage")
  cat("Score de qualité :", qualite$score_global, "/100")
} # }
```
