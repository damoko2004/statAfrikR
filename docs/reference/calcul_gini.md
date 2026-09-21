# Calculer le coefficient de Gini

Calcule le coefficient de Gini avec intervalle de confiance par
bootstrap. Le Gini mesure l'inegalite de distribution d'une variable de
revenu ou de consommation (0 = egalite parfaite, 1 = inegalite
maximale).

## Utilisation

``` r
calcul_gini(
  donnees,
  var_revenu,
  poids = NULL,
  ic = FALSE,
  n_bootstrap = 200L,
  sous_groupes = NULL
)
```

## Arguments

- donnees:

  data.frame – Donnees menages

- var_revenu:

  character – Variable de revenu ou de consommation (valeurs strictement
  positives)

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- ic:

  logical – Calculer l'IC 95% par bootstrap. Defaut : FALSE

- n_bootstrap:

  integer – Replications bootstrap. Defaut : 200L

- sous_groupes:

  character ou NULL – Variables de sous-groupe pour decomposition.
  Defaut : NULL

## Valeur de retour

Un objet de classe `saf_gini`

## Exemples

``` r
set.seed(42)
n <- 300
menages <- data.frame(
  depense = c(rexp(200, 1/150000), rexp(100, 1/500000)),
  milieu  = sample(c("urbain","rural"), n, TRUE),
  poids   = runif(n, 0.8, 1.3)
)
res <- calcul_gini(menages, "depense", poids = "poids")
print(res)
#> 
#> === Coefficient de Gini ===
#>   Gini = 0.5667  (Inegalite extreme)
#>   N   = 300 observations
```
