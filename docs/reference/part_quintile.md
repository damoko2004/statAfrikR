# Calculer les parts de revenu par quintile ou decile

Calcule la part de revenu ou de consommation detenue par chaque quintile
(ou decile) de la population. Inclut les ratios Palma et Q5/Q1.

## Utilisation

``` r
part_quintile(donnees, var_revenu, poids = NULL, n_groupes = 5L)
```

## Arguments

- donnees:

  data.frame – Donnees menages

- var_revenu:

  character – Variable de revenu

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- n_groupes:

  integer – 5 (quintiles) ou 10 (deciles). Defaut : 5L

## Valeur de retour

Un tibble avec parts par groupe + ratios Palma et Q5/Q1

## Exemples

``` r
set.seed(42)
menages <- data.frame(
  depense = c(rexp(200, 1/150000), rexp(100, 1/500000)),
  poids   = runif(300, 0.8, 1.3)
)
part_quintile(menages, "depense", poids = "poids")
#> Ratios : Q5/Q1 = 35.56 | Palma = 8.55 (top 10% / bottom 40%)
#> # A tibble: 5 × 4
#>   groupe     revenu_moyen part_revenu n_obs
#>   <chr>             <dbl>       <dbl> <int>
#> 1 Quintile 1        25799        1.7     60
#> 2 Quintile 2        83121        5.37    60
#> 3 Quintile 3       171495       11.5     60
#> 4 Quintile 4       324807       21.0     60
#> 5 Quintile 5       912826       60.4     60
```
