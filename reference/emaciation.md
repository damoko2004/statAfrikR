# Calculer le taux d'emaciation (wasting)

Prevalence de l'emaciation : poids-pour-taille \< -2 ecarts-types
(standards OMS 2006). Indicateur de malnutrition aigue.

## Usage

``` r
emaciation(
  donnees,
  var_poids_taille_z,
  poids = NULL,
  sous_groupes = NULL,
  seuil = -2
)
```

## Arguments

- donnees:

  data.frame – Donnees enfants \< 5 ans

- var_poids_taille_z:

  character – Score Z poids-pour-taille (WHZ)

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
  whz  = rnorm(n, -0.8, 1.1),
  poids = runif(n, 0.8, 1.3)
)
emaciation(enfants, var_poids_taille_z = "whz", poids = "poids")
#> === Emaciation (wasting) ===
#>   Taux : 13.2%  (Preoccupant (10-20%))
#>   N    : 400 enfants
#> 
#> === Emaciation (wasting) ( ODD 2.2.2 ) ===
#>   Taux  : 13.2%  [IC 95% : 10.2% - 16.8%]
#>   N obs : 400 enfants  |  N cas : 53
#>   Seuil OMS : score Z < -2
#>   Categorie : Preoccupant (10-20%)
```
