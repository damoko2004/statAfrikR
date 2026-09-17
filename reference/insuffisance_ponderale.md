# Calculer le taux d'insuffisance ponderale

Prevalence de l'insuffisance ponderale : poids-pour-age \< -2
ecarts-types chez les enfants de moins de 5 ans.

## Usage

``` r
insuffisance_ponderale(
  donnees,
  var_poids_age_z,
  poids = NULL,
  sous_groupes = NULL,
  seuil = -2
)
```

## Arguments

- donnees:

  data.frame – Donnees enfants \< 5 ans

- var_poids_age_z:

  character – Score Z poids-pour-age (WAZ)

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de desagregation. Defaut : NULL

- seuil:

  numeric – Seuil score Z. Defaut : -2

## Value

Un objet de classe `saf_anthropo`

## Examples

``` r
set.seed(42)
n <- 400
enfants <- data.frame(
  waz  = rnorm(n, -1.0, 1.2),
  poids = runif(n, 0.8, 1.3)
)
insuffisance_ponderale(enfants, var_poids_age_z = "waz", poids = "poids")
#> === Insuffisance ponderale (underweight) ===
#>   Taux : 19.3%  (Preoccupant (10-20%))
#>   N    : 400 enfants
#> 
#> === Insuffisance ponderale (underweight) ( ODD 2.2.2 ) ===
#>   Taux  : 19.3%  [IC 95% : 15.8% - 23.5%]
#>   N obs : 400 enfants  |  N cas : 77
#>   Seuil OMS : score Z < -2
#>   Categorie : Preoccupant (10-20%)
```
