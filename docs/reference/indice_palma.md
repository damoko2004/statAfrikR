# Calculer l'indice de Palma

L'indice de Palma est le rapport entre la part de revenu des 10% les
plus riches et celle des 40% les plus pauvres. Il est plus sensible aux
extremes que le coefficient de Gini.

## Utilisation

``` r
indice_palma(donnees, var_revenu, poids = NULL)

palma(donnees, var_revenu, poids = NULL)
```

## Arguments

- donnees:

  data.frame – Donnees menages

- var_revenu:

  character – Variable de revenu

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

## Valeur de retour

Un scalaire numerique (indice de Palma)

## Exemples

``` r
set.seed(42)
menages <- data.frame(
  depense = c(rexp(200, 1/150000), rexp(100, 1/500000)),
  poids   = runif(300, 0.8, 1.3)
)
indice_palma(menages, "depense", poids = "poids")
#> Ratios : Q5/Q1 = 35.56 | Palma = 8.55 (top 10% / bottom 40%)
#> Palma = 8.55 (top 10% = 60.45% | bottom 40% = 7.07%)
```
