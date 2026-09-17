# Calculer le taux d'emploi vulnerable

Part des actifs occupes en situation d'emploi vulnerable : travailleurs
familiaux non remuneres et travailleurs independants precaires. ODD
8.3.1.

## Usage

``` r
emploi_vulnerable(donnees, var_vulnerable, poids = NULL, sous_groupes = NULL)
```

## Arguments

- donnees:

  data.frame – Donnees actifs occupes

- var_vulnerable:

  character – Variable 0/1 : emploi vulnerable

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de desagregation. Defaut : NULL

## Value

Un objet de classe `saf_emploi`

## Examples

``` r
set.seed(42)
n <- 400
employes <- data.frame(
  vulnerable = rbinom(n, 1, 0.55),
  sexe       = sample(c("H","F"), n, TRUE),
  poids      = runif(n, 0.8, 1.3)
)
emploi_vulnerable(employes, "vulnerable", poids="poids",
                   sous_groupes="sexe")
#> === Emploi vulnerable (ODD 8.3.1) ===
#>   Taux : 56.8%
#>   N    : 400
#> 
#> === Emploi vulnerable ( ODD 8.3.1 ) ===
#>   Taux  : 56.8%  [IC 95% : 51.9% - 61.6%]
#>   N obs : 400
#> 
#> Desagregation :
#>   F                    : 52.42%  (n=202)
#>   H                    : 61.31%  (n=198)
```
