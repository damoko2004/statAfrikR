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
# \donttest{
  donnees <- data.frame(
    id_menage = 1:50,
    age       = c(sample(20:70, 45, replace = TRUE), rep(NA, 5)),
    revenu    = c(rnorm(48, 200000, 50000), NA, NA)
  )
  valider_qualite_donnees(donnees, vars_cles="id_menage")
#> === Score de qualité des données ===
#> Complétude   : 13.3/25
#> Unicité      : 25/25
#> Cohérence    : 25/25
#> Plausibilité : 25/25
#> SCORE GLOBAL : 88.3/100
#> $score_global
#> [1] 88.3
#> 
#> $completude
#> [1] 13.3
#> 
#> $unicite
#> [1] 25
#> 
#> $coherence
#> [1] 25
#> 
#> $plausibilite
#> [1] 25
#> 
#> $n_lignes
#> [1] 50
#> 
#> $n_colonnes
#> [1] 3
#> 
#> $taux_na
#> [1] 0.0467
#> 
# }
```
