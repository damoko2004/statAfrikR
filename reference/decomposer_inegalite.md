# Décomposer les inégalités

Calcule les mesures d'inégalité (Gini, Theil, Atkinson) et leur
décomposition inter/intra-groupe pour une variable de revenu ou de
dépense.

## Usage

``` r
decomposer_inegalite(
  data,
  var_revenu,
  var_groupe = NULL,
  var_poids = NULL,
  mesures = c("all", "gini", "theil", "atkinson")
)
```

## Arguments

- data:

  data.frame ou tibble — Données

- var_revenu:

  character — Variable de revenu/dépense (strictement positive)

- var_groupe:

  character ou NULL — Variable de groupe pour la décomposition. Défaut :
  NULL.

- var_poids:

  character ou NULL — Variable de pondération. Défaut : NULL.

- mesures:

  character — Mesures à calculer : `"gini"`, `"theil"`, `"atkinson"`,
  `"all"`. Défaut : "all".

## Value

Une liste avec les mesures d'inégalité et leur décomposition.

## Examples

``` r
# \donttest{
  donnees <- data.frame(
    depense_totale = rnorm(100, 250000, 80000),
    milieu = sample(c("urbain", "rural"), 100, replace = TRUE)
  )
  decomposer_inegalite(donnees, var_revenu="depense_totale", var_groupe="milieu")
#> === Mesures d'inégalité ===
#> Gini     : 0.1769
#> Theil T  : 0.0572
#> Atkinson : 0.0717
#> $gini
#> [1] 0.1769
#> 
#> $theil
#> [1] 0.0572
#> 
#> $atkinson
#> [1] 0.0717
#> 
#> $decomposition
#> # A tibble: 2 × 6
#>   groupe     n moyenne gini_interne part_pop part_revenu
#>   <chr>  <int>   <dbl>        <dbl>    <dbl>       <dbl>
#> 1 urbain    49 230173.        0.168     0.49       0.470
#> 2 rural     51 249632.        0.181     0.51       0.530
#> 
# }
```
