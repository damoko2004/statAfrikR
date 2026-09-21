# Calculer le score de satisfaction dans la vie

Calcule le score moyen de satisfaction dans la vie sur une echelle de 0
a 10 (echelle de Cantril). Indicateur de bien-etre subjectif global
conforme a la methodologie OCDE / Gallup World Poll.

## Utilisation

``` r
satisfaction_vie(donnees, var_satisfaction, poids = NULL, sous_groupes = NULL)
```

## Arguments

- donnees:

  data.frame – Donnees individuelles

- var_satisfaction:

  character – Variable de satisfaction (0-10)

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de desagregation. Defaut : NULL

## Valeur de retour

Un objet de classe `saf_subjectif`

## Exemples

``` r
set.seed(42)
n <- 500
individus <- data.frame(
  satisfaction = pmin(10, pmax(0, round(rnorm(n, 5.8, 2.1)))),
  milieu       = sample(c("urbain","rural"), n, TRUE),
  quintile     = sample(paste0("Q", 1:5), n, TRUE),
  poids        = runif(n, 0.8, 1.3)
)
satisfaction_vie(individus, "satisfaction", poids="poids",
                 sous_groupes=c("milieu","quintile"))
#> === Satisfaction dans la vie (echelle Cantril 0-10) ===
#>   Score moyen : 5.74 / 10
#> 
#> === Satisfaction dans la vie (echelle Cantril 0-10) ( OCDE / Gallup ) ===
#>   Score moyen : 5.74
#>   N obs : 500
#> 
#> Distribution :
#>   Bas (0-3)            : 13.8%
#>   Moyen (4-5)          : 31.8%
#>   Eleve (6-7)          : 35%
#>   Tres eleve (8-10)    : 19.4%
#> 
#> Desagregation :
#>   rural                : 5.814  (n=249)
#>   urbain               : 5.666  (n=251)
#>   Q1                   : 5.484  (n=96)
#>   Q2                   : 5.813  (n=98)
#>   Q3                   : 5.732  (n=103)
#>   Q4                   : 6.038  (n=105)
#>   Q5                   : 5.599  (n=98)
```
