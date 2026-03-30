# Calculer l'Indice de Pauvreté Multidimensionnelle (IPM)

Calcule l'IPM selon la méthodologie OPHI/PNUD (Alkire-Foster). Supporte
les dimensions standard (santé, éducation, niveau de vie) et des
dimensions personnalisées.

## Usage

``` r
calcul_ipm(
  data,
  indicateurs,
  poids_dimensions = NULL,
  seuil_pauvrete = 1/3,
  var_poids = NULL
)
```

## Arguments

- data:

  data.frame ou tibble — Données individuelles ou ménages

- indicateurs:

  list — Liste nommée des indicateurs par dimension. Chaque élément est
  un vecteur de noms de variables (0/1 : 1 = privation). Ex:
  `list(sante = c("malnutrition", "mortalite_enfant"), ...)`

- poids_dimensions:

  numeric ou NULL — Poids de chaque dimension (doit sommer à 1). Si
  NULL, poids égaux. Défaut : NULL.

- seuil_pauvrete:

  numeric — Seuil de privation pour être considéré
  multidimensionnellement pauvre (entre 0 et 1). Défaut : 1/3.

- var_poids:

  character ou NULL — Variable de pondération. Défaut : NULL.

## Value

Une liste avec : `ipm`, `H` (incidence), `A` (intensité),
`contributions` par dimension, `donnees_enrichies`.

## References

Alkire, S. & Foster, J. (2011). Counting and multidimensional poverty
measurement. Journal of Public Economics, 95(7-8), 476-487.

## Examples

``` r
# \donttest{
  donnees <- data.frame(
    malnutrition         = sample(0:1, 50, replace = TRUE),
    mortalite_enfant     = sample(0:1, 50, replace = TRUE),
    annees_scolarisation = sample(0:1, 50, replace = TRUE),
    enfants_scolarises   = sample(0:1, 50, replace = TRUE),
    electricite          = sample(0:1, 50, replace = TRUE),
    eau_potable          = sample(0:1, 50, replace = TRUE)
  )
  indicateurs <- list(
    sante      = c("malnutrition", "mortalite_enfant"),
    education  = c("annees_scolarisation", "enfants_scolarises"),
    niveau_vie = c("electricite", "eau_potable")
  )
  calcul_ipm(donnees, indicateurs)
#> === Résultats IPM ===
#> IPM   : 0.5033
#> H (incidence) : 90.0%
#> A (intensité) : 55.9%
#> Contributions par dimension :
#>   sante : 29.14%
#>   education : 36.42%
#>   niveau_vie : 34.44%
#> $ipm
#> [1] 0.5033
#> 
#> $H
#> [1] 0.9
#> 
#> $A
#> [1] 0.5593
#> 
#> $contributions
#>      sante  education niveau_vie 
#>      29.14      36.42      34.44 
#> 
#> $seuil_pauvrete
#> [1] 0.3333333
#> 
#> $n_pauvres
#> [1] 45
#> 
#> $n_total
#> [1] 50
#> 
#> $donnees_enrichies
#>    malnutrition mortalite_enfant annees_scolarisation enfants_scolarises
#> 1             0                1                    1                  1
#> 2             0                0                    0                  1
#> 3             1                1                    0                  1
#> 4             0                0                    1                  1
#> 5             0                0                    1                  0
#> 6             1                0                    1                  1
#> 7             1                0                    0                  1
#> 8             1                1                    0                  0
#> 9             1                1                    1                  1
#> 10            1                0                    1                  1
#> 11            0                0                    1                  0
#> 12            0                0                    0                  1
#> 13            0                0                    1                  1
#> 14            0                1                    1                  1
#> 15            0                0                    1                  0
#> 16            1                0                    1                  0
#> 17            0                1                    1                  1
#> 18            0                1                    1                  1
#> 19            1                0                    1                  0
#> 20            1                1                    1                  1
#> 21            1                1                    0                  0
#> 22            1                0                    0                  0
#> 23            0                1                    0                  0
#> 24            1                1                    1                  1
#> 25            0                0                    1                  1
#> 26            1                1                    1                  1
#> 27            0                1                    1                  0
#> 28            1                0                    0                  0
#> 29            0                0                    0                  0
#> 30            0                1                    1                  1
#> 31            0                0                    1                  1
#> 32            0                0                    1                  0
#> 33            0                1                    0                  0
#> 34            0                1                    1                  0
#> 35            0                1                    0                  0
#> 36            1                0                    1                  1
#> 37            0                0                    0                  0
#> 38            0                1                    0                  1
#> 39            0                0                    0                  1
#> 40            1                0                    1                  1
#> 41            1                0                    1                  0
#> 42            1                1                    1                  1
#> 43            0                0                    1                  0
#> 44            1                0                    0                  0
#> 45            1                0                    0                  1
#> 46            1                0                    1                  1
#> 47            0                1                    0                  0
#> 48            1                1                    1                  0
#> 49            0                0                    0                  0
#> 50            1                0                    0                  1
#>    electricite eau_potable .score_privation .est_pauvre_multi
#> 1            0           0           0.5000              TRUE
#> 2            0           1           0.3333              TRUE
#> 3            1           0           0.6667              TRUE
#> 4            1           0           0.5000              TRUE
#> 5            1           0           0.3333              TRUE
#> 6            1           0           0.6667              TRUE
#> 7            0           0           0.3333              TRUE
#> 8            0           1           0.5000              TRUE
#> 9            1           0           0.8333              TRUE
#> 10           1           0           0.6667              TRUE
#> 11           0           0           0.1667             FALSE
#> 12           0           0           0.1667             FALSE
#> 13           0           0           0.3333              TRUE
#> 14           1           1           0.8333              TRUE
#> 15           1           0           0.3333              TRUE
#> 16           0           0           0.3333              TRUE
#> 17           1           1           0.8333              TRUE
#> 18           1           0           0.6667              TRUE
#> 19           1           0           0.5000              TRUE
#> 20           0           1           0.8333              TRUE
#> 21           1           1           0.6667              TRUE
#> 22           1           1           0.5000              TRUE
#> 23           1           1           0.5000              TRUE
#> 24           1           0           0.8333              TRUE
#> 25           1           1           0.6667              TRUE
#> 26           1           1           1.0000              TRUE
#> 27           1           0           0.5000              TRUE
#> 28           0           1           0.3333              TRUE
#> 29           0           0           0.0000             FALSE
#> 30           0           0           0.5000              TRUE
#> 31           0           1           0.5000              TRUE
#> 32           1           0           0.3333              TRUE
#> 33           1           0           0.3333              TRUE
#> 34           1           1           0.6667              TRUE
#> 35           0           1           0.3333              TRUE
#> 36           0           0           0.5000              TRUE
#> 37           0           1           0.1667             FALSE
#> 38           0           1           0.5000              TRUE
#> 39           0           1           0.3333              TRUE
#> 40           1           0           0.6667              TRUE
#> 41           1           0           0.5000              TRUE
#> 42           1           1           1.0000              TRUE
#> 43           1           0           0.3333              TRUE
#> 44           0           1           0.3333              TRUE
#> 45           0           1           0.5000              TRUE
#> 46           1           1           0.8333              TRUE
#> 47           1           1           0.5000              TRUE
#> 48           1           1           0.8333              TRUE
#> 49           1           0           0.1667             FALSE
#> 50           1           1           0.6667              TRUE
#> 
# }
```
