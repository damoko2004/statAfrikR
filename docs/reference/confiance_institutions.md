# Calculer la confiance dans les institutions

Proportion de la population faisant confiance aux institutions publiques
(gouvernement, justice, police, parlement). Indicateur de gouvernance
percu. Methodologie Afrobarometer.

## Utilisation

``` r
confiance_institutions(
  donnees,
  vars_institutions,
  codes_confiance = NULL,
  poids = NULL,
  sous_groupes = NULL
)
```

## Arguments

- donnees:

  data.frame – Donnees individuelles

- vars_institutions:

  named character – Vecteur nomme : institution -\> variable 0/1 (ou
  codes_confiance si categorielle). Ex : c(Gouvernement="conf_gouv",
  Justice="conf_just")

- codes_confiance:

  numeric ou NULL – Codes indiquant confiance. Defaut : NULL (variables
  deja binaires)

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de desagregation. Defaut : NULL

## Valeur de retour

Un tibble avec taux de confiance par institution

## Exemples

``` r
set.seed(42)
n <- 500
individus <- data.frame(
  conf_gouv  = rbinom(n, 1, 0.35),
  conf_just  = rbinom(n, 1, 0.42),
  conf_pol   = rbinom(n, 1, 0.38),
  milieu     = sample(c("urbain","rural"), n, TRUE),
  poids      = runif(n, 0.8, 1.3)
)
confiance_institutions(individus,
  vars_institutions = c(Gouvernement="conf_gouv",
                         Justice="conf_just",
                         Police="conf_pol"),
  poids="poids", sous_groupes="milieu")
#> === Confiance dans les institutions (Afrobarometer) ===
#>   Gouvernement : 33.18%
#>   Justice : 39.11%
#>   Police : 36.87%
#> # A tibble: 3 × 5
#>   institution  confiance_pct ic_bas ic_haut n_obs
#>   <chr>                <dbl>  <dbl>   <dbl> <int>
#> 1 Gouvernement          33.2   29.2    37.4   500
#> 2 Justice               39.1   34.9    43.5   500
#> 3 Police                36.9   32.8    41.2   500
```
