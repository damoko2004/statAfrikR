# Calculer le score de privations ressenties

Calcule la proportion de menages ayant declare souffrir de privations
subjectives (manque de nourriture, eau, medicaments, argent) au cours
des 12 derniers mois. Complement a l'IPM.

## Usage

``` r
privations_ressenties(
  donnees,
  vars_privations,
  poids = NULL,
  sous_groupes = NULL
)
```

## Arguments

- donnees:

  data.frame – Donnees menages

- vars_privations:

  named character – Vecteur nomme : type de privation -\> variable 0/1.
  Ex : c(Nourriture="manque_nour", Eau="manque_eau",
  Medicaments="manque_med")

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de desagregation. Defaut : NULL

## Value

Un tibble avec prevalence par type de privation

## Examples

``` r
set.seed(42)
n <- 400
menages <- data.frame(
  manque_nour = rbinom(n, 1, 0.48),
  manque_eau  = rbinom(n, 1, 0.35),
  manque_med  = rbinom(n, 1, 0.58),
  manque_arg  = rbinom(n, 1, 0.62),
  milieu      = sample(c("urbain","rural"), n, TRUE),
  poids       = runif(n, 0.8, 1.3)
)
privations_ressenties(menages,
  vars_privations = c(Nourriture="manque_nour",
                      Eau="manque_eau",
                      Medicaments="manque_med",
                      Argent="manque_arg"),
  poids="poids", sous_groupes="milieu")
#> === Privations ressenties ===
#>   Score composite moyen : 51.3%
#>   Nourriture : 46.91%
#>   Eau : 33.5%
#>   Medicaments : 61.81%
#>   Argent : 63.12%
#>   Au moins une privation : 94.56%
#> # A tibble: 5 × 5
#>   type_privation         prevalence_pct ic_bas ic_haut n_obs
#>   <chr>                           <dbl>  <dbl>   <dbl> <int>
#> 1 Nourriture                       46.9   42.1    51.8   400
#> 2 Eau                              33.5   29.0    38.3   400
#> 3 Medicaments                      61.8   57.0    66.4   400
#> 4 Argent                           63.1   58.3    67.7   400
#> 5 Au moins une privation           94.6   91.9    96.4   400
```
