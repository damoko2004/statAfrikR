# Calculer le taux de pauvrete au travail (working poor)

Proportion des actifs occupes vivant sous le seuil de pauvrete national.
Indicateur ODD 8.1.1 et lien emploi-pauvrete.

## Utilisation

``` r
pauvrete_travail(
  donnees,
  var_employe,
  var_revenu,
  seuil,
  poids = NULL,
  sous_groupes = NULL
)
```

## Arguments

- donnees:

  data.frame – Donnees individuelles (actifs occupes)

- var_employe:

  character – Variable 0/1 : a un emploi

- var_revenu:

  character – Variable de revenu ou consommation par tete du menage

- seuil:

  numeric – Seuil de pauvrete national

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de desagregation. Defaut : NULL

## Valeur de retour

Un objet de classe `saf_emploi`

## Exemples

``` r
set.seed(42)
n <- 500
individus <- data.frame(
  employe = rbinom(n, 1, 0.60),
  revenu  = pmax(10000, rnorm(n, 180000, 90000)),
  milieu  = sample(c("urbain","rural"), n, TRUE),
  poids   = runif(n, 0.8, 1.3)
)
pauvrete_travail(individus, "employe", "revenu",
                  seuil = 144800, poids = "poids")
#> === Pauvrete au travail (ODD 8.1.1) ===
#>   Taux : 36.3% des actifs occupes
#>   N    : 313 actifs occupes
#> 
#> === Pauvrete au travail (working poor) ( ODD 8.1.1 ) ===
#>   Taux  : 36.4%  [IC 95% : 31.2% - 41.8%]
#>   N obs : 313
```
