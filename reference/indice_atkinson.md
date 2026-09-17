# Calculer l'indice d'Atkinson

L'indice d'Atkinson est une mesure d'inegalite parametrique dont le
parametre epsilon reflete l aversion a l'inegalite de la societe.
Epsilon = 0 : indifference ; Epsilon = 1 : forte aversion.

## Usage

``` r
indice_atkinson(donnees, var_revenu, poids = NULL, epsilon = 1)

atkinson(donnees, var_revenu, poids = NULL, epsilon = 1)
```

## Arguments

- donnees:

  data.frame – Donnees menages

- var_revenu:

  character – Variable de revenu

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- epsilon:

  numeric – Parametre d'aversion a l'inegalite (\>0). Defaut : 1.0

## Value

Un scalaire numerique (indice d'Atkinson)

## Examples

``` r
set.seed(42)
menages <- data.frame(
  depense = c(rexp(200, 1/150000), rexp(100, 1/500000)),
  poids   = runif(300, 0.8, 1.3)
)
indice_atkinson(menages, "depense", poids = "poids", epsilon = 1)
#> Atkinson (epsilon=1) = 0.5095
```
