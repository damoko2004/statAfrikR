# Calculer la prevalence du travail des enfants

Prevalence du travail des enfants (5-17 ans) selon la definition
OIT/MICS. ODD 8.7.1.

## Utilisation

``` r
travail_enfants(
  donnees,
  var_travail_enfant,
  var_age = NULL,
  poids = NULL,
  sous_groupes = NULL
)
```

## Arguments

- donnees:

  data.frame – Donnees enfants 5-17 ans

- var_travail_enfant:

  character – Variable 0/1 : enfant au travail

- var_age:

  character ou NULL – Variable age pour filtrer 5-17 ans. Defaut : NULL

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de desagregation. Defaut : NULL

## Valeur de retour

Un objet de classe `saf_emploi`

## Exemples

``` r
set.seed(42)
n <- 600
enfants <- data.frame(
  travail = rbinom(n, 1, 0.22),
  age     = sample(5:17, n, TRUE),
  sexe    = sample(c("H","F"), n, TRUE),
  milieu  = sample(c("urbain","rural"), n, TRUE),
  poids   = runif(n, 0.8, 1.3)
)
travail_enfants(enfants, "travail", var_age="age",
                 poids="poids", sous_groupes=c("sexe","milieu"))
#> === Travail des enfants (ODD 8.7.1) ===
#>   Taux : 21.4%
#>   N    : 600
#> 
#> === Travail des enfants ( ODD 8.7.1 ) ===
#>   Taux  : 21.4%  [IC 95% : 18.3% - 24.9%]
#>   N obs : 600
#> 
#> Desagregation :
#>   F                    : 19.17%  (n=288)
#>   H                    : 23.54%  (n=312)
#>   rural                : 22.27%  (n=282)
#>   urbain               : 20.68%  (n=318)
```
