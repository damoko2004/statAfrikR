# Tracer la courbe de Lorenz

Produit la courbe de Lorenz institutionnelle montrant la distribution
cumulee des revenus. L'aire entre la diagonale et la courbe est egale a
Gini/2.

## Utilisation

``` r
courbe_lorenz(
  donnees,
  var_revenu,
  poids = NULL,
  var_groupe = NULL,
  titre = NULL,
  source = NULL
)
```

## Arguments

- donnees:

  data.frame – Donnees menages

- var_revenu:

  character – Variable de revenu

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- var_groupe:

  character ou NULL – Variable de groupe pour comparaison. Defaut : NULL

- titre:

  character ou NULL – Titre. Defaut : NULL

- source:

  character ou NULL – Source. Defaut : NULL

## Valeur de retour

Un objet `ggplot2`

## Exemples

``` r
set.seed(42)
menages <- data.frame(
  depense = c(rexp(150, 1/150000), rexp(50, 1/500000)),
  milieu  = sample(c("urbain","rural"), 200, TRUE),
  poids   = runif(200, 0.8, 1.3)
)
courbe_lorenz(menages, "depense", poids = "poids")

```
