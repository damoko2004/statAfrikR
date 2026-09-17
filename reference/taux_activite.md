# Calculer le taux d'activite

Calcule le taux d'activite selon la definition du Bureau International
du Travail (BIT) : proportion de la population en age de travailler qui
est active (employes + chomeurs). ODD 8.

## Usage

``` r
taux_activite(
  donnees,
  var_actif,
  var_age = NULL,
  age_min = 15L,
  age_max = 64L,
  poids = NULL,
  sous_groupes = NULL
)
```

## Arguments

- donnees:

  data.frame – Donnees individuelles ou menages

- var_actif:

  character – Variable 0/1 : actif (employe ou chomeur)

- var_age:

  character ou NULL – Variable age pour filtrer la population en age de
  travailler. Defaut : NULL

- age_min:

  integer – Age minimum. Defaut : 15L

- age_max:

  integer – Age maximum. Defaut : 64L

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de desagregation (sexe, milieu, region).
  Defaut : NULL

## Value

Un objet de classe `saf_emploi`

## Examples

``` r
set.seed(42)
n <- 500
individus <- data.frame(
  actif  = rbinom(n, 1, 0.65),
  age    = sample(15:64, n, TRUE),
  sexe   = sample(c("H","F"), n, TRUE),
  milieu = sample(c("urbain","rural"), n, TRUE),
  poids  = runif(n, 0.8, 1.3)
)
taux_activite(individus, "actif", var_age="age", poids="poids",
              sous_groupes=c("sexe","milieu"))
#> === Taux d'activite (BIT/OIT) ===
#>   Taux : 66.2%
#>   N    : 500
#> 
#> === Taux d'activite ( BIT/OIT ) ===
#>   Taux  : 66.2%  [IC 95% : 62.0% - 70.2%]
#>   N obs : 500
#> 
#> Desagregation :
#>   F                    : 66.7%  (n=255)
#>   H                    : 65.69%  (n=245)
#>   rural                : 68.1%  (n=221)
#>   urbain               : 64.7%  (n=279)
```
