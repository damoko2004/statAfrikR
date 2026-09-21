# Calculer le taux d'emploi informel

Calcule la part de l'emploi informel selon la definition OIT 2013.
L'emploi informel comprend les travailleurs sans contrat ecrit, sans
protection sociale et sans conges payes.

## Utilisation

``` r
emploi_informel(
  donnees,
  var_informel,
  var_statut = NULL,
  poids = NULL,
  sous_groupes = NULL
)
```

## Arguments

- donnees:

  data.frame – Donnees employes

- var_informel:

  character – Variable 0/1 : emploi informel

- var_statut:

  character ou NULL – Variable de statut d'emploi (pour decomposition).
  Defaut : NULL

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de desagregation. Defaut : NULL

## Valeur de retour

Un objet de classe `saf_emploi`

## Exemples

``` r
set.seed(42)
n <- 400
employes <- data.frame(
  informel = rbinom(n, 1, 0.72),
  secteur  = sample(c("agriculture","services","industrie"), n, TRUE),
  sexe     = sample(c("H","F"), n, TRUE),
  poids    = runif(n, 0.8, 1.3)
)
emploi_informel(employes, "informel", poids="poids",
                 sous_groupes=c("secteur","sexe"))
#> === Taux d'emploi informel (OIT 2013) ===
#>   Taux : 70.4%
#>   N    : 400
#> 
#> === Taux d'emploi informel ( OIT 2013 ) ===
#>   Taux  : 70.3%  [IC 95% : 65.7% - 74.6%]
#>   N obs : 400
#> 
#> Desagregation :
#>   agriculture          : 74.38%  (n=125)
#>   industrie            : 71.45%  (n=133)
#>   services             : 65.76%  (n=142)
#>   F                    : 70.86%  (n=201)
#>   H                    : 69.85%  (n=199)
```
