# Calculer le taux de mariage precoce

Proportion de femmes/hommes maries avant 18 ans (ODD 5.3.1) avec
desagregation et analyse des tendances par cohorte d'age.

## Utilisation

``` r
mariage_precoce(
  donnees,
  var_marie_avant_18,
  var_cohorte = NULL,
  poids = NULL,
  sous_groupes = NULL
)
```

## Arguments

- donnees:

  data.frame – Donnees femmes (15-49 ans)

- var_marie_avant_18:

  character – Variable 0/1 : marie(e) avant 18 ans

- var_cohorte:

  character ou NULL – Variable de cohorte ou groupe d'age pour analyser
  les tendances. Defaut : NULL

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de desagregation. Defaut : NULL

## Valeur de retour

Un objet de classe `saf_genre`

## Exemples

``` r
set.seed(42)
n <- 500
femmes <- data.frame(
  marie_18  = rbinom(n, 1, 0.42),
  cohorte   = sample(c("15-19","20-24","25-29","30-34","35-49"),
                      n, TRUE),
  milieu    = sample(c("urbain","rural"), n, TRUE),
  poids     = runif(n, 0.8, 1.3)
)
mariage_precoce(femmes, "marie_18",
                 var_cohorte = "cohorte",
                 poids = "poids", sous_groupes = "milieu")
#> === Mariage precoce (ODD 5.3.1) ===
#>   Taux global : 39%
#>   Tendances par cohorte :
#>     15-19 : 42.46%
#>     20-24 : 33.55%
#>     25-29 : 44.12%
#>     30-34 : 39.54%
#>     35-49 : 35.33%
#> 
#> === Mariage precoce (avant 18 ans) ( ODD 5.3.1 ) ===
#>   Taux : 39.0%  [IC 95% : 34.8% - 43.3%]
#> 
#> Desagregation :
#>   rural                : 36.07  (n=238)
#>   urbain               : 41.63  (n=262)
```
