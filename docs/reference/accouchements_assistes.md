# Calculer le taux d'accouchements assistes

Proportion des naissances assistees par un personnel de sante qualifie
(medecin, sage-femme, infirmier). ODD 3.1.2.

## Utilisation

``` r
accouchements_assistes(donnees, var_assiste, poids = NULL, sous_groupes = NULL)
```

## Arguments

- donnees:

  data.frame – Donnees naissances recentes

- var_assiste:

  character – Variable 0/1 indiquant un accouchement assiste par
  personnel qualifie

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de desagregation. Defaut : NULL

## Valeur de retour

Un tibble avec taux global et par sous-groupe

## Exemples

``` r
set.seed(42)
n <- 400
naissances <- data.frame(
  assiste = rbinom(n, 1, 0.65),
  milieu  = sample(c("urbain","rural"), n, TRUE),
  region  = sample(paste0("R", 1:5), n, TRUE),
  poids   = runif(n, 0.8, 1.3)
)
accouchements_assistes(naissances, "assiste",
                        poids = "poids",
                        sous_groupes = c("milieu","region"))
#> === Accouchements assistes (ODD 3.1.2) ===
#>   Taux global : 65.6%
#>   milieu - rural : 62.5%
#>   milieu - urbain : 68.6%
#>   region - R1 : 61.3%
#>   region - R2 : 61.5%
#>   region - R3 : 71.6%
#>   region - R4 : 68.8%
#>   region - R5 : 64.3%
#> # A tibble: 8 × 5
#>   groupe          taux_pct ic_bas ic_haut n_obs
#>   <chr>              <dbl>  <dbl>   <dbl> <int>
#> 1 Total               65.6   60.8    70.0   400
#> 2 milieu : rural      62.5   55.7    68.9   202
#> 3 milieu : urbain     68.6   61.9    74.7   198
#> 4 region : R1         61.3   50.8    70.8    87
#> 5 region : R2         61.5   50.9    71.2    85
#> 6 region : R3         71.6   61.5    79.9    90
#> 7 region : R4         68.8   57.4    78.3    72
#> 8 region : R5         64.3   52.3    74.8    66
```
