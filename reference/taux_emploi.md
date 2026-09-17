# Calculer le taux d'emploi

Proportion de la population en age de travailler ayant un emploi
(salarie ou independant). Indicateur cle ODD 8.5.

## Usage

``` r
taux_emploi(
  donnees,
  var_employe,
  var_age = NULL,
  age_min = 15L,
  age_max = 64L,
  poids = NULL,
  sous_groupes = NULL
)
```

## Arguments

- donnees:

  data.frame – Donnees individuelles

- var_employe:

  character – Variable 0/1 : a un emploi

- var_age:

  character ou NULL – Variable age. Defaut : NULL

- age_min:

  integer – Age minimum. Defaut : 15L

- age_max:

  integer – Age maximum. Defaut : 64L

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de desagregation. Defaut : NULL

## Value

Un objet de classe `saf_emploi`

## Examples

``` r
set.seed(42)
individus <- data.frame(
  employe = rbinom(500, 1, 0.55),
  age     = sample(15:64, 500, TRUE),
  sexe    = sample(c("H","F"), 500, TRUE),
  poids   = runif(500, 0.8, 1.3)
)
taux_emploi(individus, "employe", var_age="age",
            poids="poids", sous_groupes="sexe")
#> === Taux d'emploi (ODD 8.5) ===
#>   Taux : 58%
#>   N    : 500
#> 
#> === Taux d'emploi ( ODD 8.5 ) ===
#>   Taux  : 58.0%  [IC 95% : 53.6% - 62.3%]
#>   N obs : 500
#> 
#> Desagregation :
#>   F                    : 58.18%  (n=255)
#>   H                    : 57.87%  (n=245)
```
