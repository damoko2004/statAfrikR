# Calculer la part de population se declarant heureuse

Proportion d'individus se declarant tres heureux ou heureux. Variable
categorielle recodee en indicateur 0/1.

## Usage

``` r
bonheur_declare(
  donnees,
  var_bonheur,
  codes_heureux = c(1, 2),
  poids = NULL,
  sous_groupes = NULL
)
```

## Arguments

- donnees:

  data.frame – Donnees individuelles

- var_bonheur:

  character – Variable de bonheur. Valeurs attendues : 1="Tres heureux",
  2="Heureux", 3="Pas tres heureux", 4="Pas du tout heureux" OU variable
  0/1 deja binaire.

- codes_heureux:

  numeric ou character – Codes consideres comme "heureux" (les autres =
  "pas heureux"). Defaut : c(1, 2)

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de desagregation. Defaut : NULL

## Value

Un objet de classe `saf_subjectif`

## Examples

``` r
set.seed(42)
n <- 500
individus <- data.frame(
  bonheur  = sample(1:4, n, TRUE, prob=c(0.20,0.45,0.25,0.10)),
  milieu   = sample(c("urbain","rural"), n, TRUE),
  poids    = runif(n, 0.8, 1.3)
)
bonheur_declare(individus, "bonheur", codes_heureux=c(1,2),
                 poids="poids", sous_groupes="milieu")
#> === Bonheur declare (proportion se declarant heureuse) ===
#>   Taux : 64.8%
#> 
#> === Bonheur declare (proportion se declarant heureuse) ( Afrobarometer / World Values Survey ) ===
#>   Taux : 64.8%  [IC 95% : 60.5% - 68.9%]
#>   N obs : 500
#> 
#> Desagregation :
#>   rural                : 65.01  (n=242)
#>   urbain               : 64.61  (n=258)
```
