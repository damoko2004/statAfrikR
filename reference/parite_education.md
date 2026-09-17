# Calculer l'indice de parite filles/garcons en education

Calcule l'Indice de Parite entre les Sexes (ISP) pour les taux de
scolarisation bruts et nets. ODD 4.5.1. ISP = valeur filles / valeur
garcons. ISP = 1 = parite parfaite.

## Usage

``` r
parite_education(
  donnees,
  var_scolarise,
  var_sexe,
  poids = NULL,
  var_niveau = NULL
)
```

## Arguments

- donnees:

  data.frame – Donnees menages ou enfants

- var_scolarise:

  character – Variable 0/1 : enfant scolarise

- var_sexe:

  character – Variable sexe (H/F, M/F, 1/2, homme/femme)

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- var_niveau:

  character ou NULL – Niveau scolaire pour ISP par niveau. Defaut : NULL

## Value

Un objet de classe `saf_genre`

## Examples

``` r
set.seed(42)
n <- 600
enfants <- data.frame(
  scolarise = rbinom(n, 1, 0.72),
  sexe      = sample(c("H","F"), n, TRUE),
  niveau    = sample(c("primaire","secondaire"), n, TRUE),
  poids     = runif(n, 0.8, 1.3)
)
parite_education(enfants, "scolarise", "sexe",
                  poids="poids", var_niveau="niveau")
#> === Indice de Parite (ODD 4.5.1) ===
#>   ISP global : 0.995  (Parite atteinte)
#>   primaire : ISP = 1.008
#>   secondaire : ISP = 0.988
#> 
#> === Indice de Parite Filles/Garcons (ISP) ( ODD 4.5.1 ) ===
#>   ISP : 0.995  (Parite atteinte)
```
