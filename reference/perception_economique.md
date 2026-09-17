# Calculer la perception de la situation economique

Proportion de menages pouvant joindre les deux bouts ou percevant leur
situation economique comme bonne ou tres bonne.

## Usage

``` r
perception_economique(
  donnees,
  var_perception,
  codes_positifs = NULL,
  poids = NULL,
  sous_groupes = NULL
)
```

## Arguments

- donnees:

  data.frame – Donnees menages

- var_perception:

  character – Variable de perception economique. 0/1 (1=situation
  positive) OU categorielle avec codes_positifs.

- codes_positifs:

  numeric ou NULL – Codes positifs si variable categorielle. Defaut :
  NULL (variable deja binaire)

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de desagregation. Defaut : NULL

## Value

Un objet de classe `saf_subjectif`

## Examples

``` r
set.seed(42)
n <- 400
menages <- data.frame(
  econ_ok = rbinom(n, 1, 0.38),
  quintile = sample(paste0("Q", 1:5), n, TRUE),
  poids   = runif(n, 0.8, 1.3)
)
perception_economique(menages, "econ_ok", poids="poids",
                       sous_groupes="quintile")
#> === Perception positive de la situation economique ===
#>   Taux : 36.5%
#> 
#> === Perception positive de la situation economique ( Afrobarometer / MICS ) ===
#>   Taux : 36.5%  [IC 95% : 32.0% - 41.4%]
#>   N obs : 400
#> 
#> Desagregation :
#>   Q1                   : 35.49  (n=74)
#>   Q2                   : 30.36  (n=93)
#>   Q3                   : 45.55  (n=85)
#>   Q4                   : 34.93  (n=74)
#>   Q5                   : 36.69  (n=74)
```
