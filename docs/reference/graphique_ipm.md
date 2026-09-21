# Graphique des contributions IPM

Produit un graphique en barres des contributions de chaque indicateur et
chaque dimension a l'IPM. Retourne un objet ggplot2.

## Utilisation

``` r
graphique_ipm(
  res_ipm,
  type = c("indicateurs", "dimensions"),
  titre = NULL,
  source = NULL
)
```

## Arguments

- res_ipm:

  saf_ipm – Resultat de
  [`calcul_ipm()`](https://damoko2004.github.io/statAfrikR/reference/calcul_ipm.md)
  ou
  [`calcul_ipm_national()`](https://damoko2004.github.io/statAfrikR/reference/calcul_ipm_national.md)

- type:

  character – `"indicateurs"` ou `"dimensions"`. Defaut : "indicateurs"

- titre:

  character ou NULL – Titre du graphique. Defaut : NULL

- source:

  character ou NULL – Note de source. Defaut : NULL

## Valeur de retour

Un objet `ggplot2`

## Exemples

``` r
set.seed(42)
n <- 200
menages <- data.frame(
  nutrition   = rbinom(n,1,0.35), electricite = rbinom(n,1,0.60),
  eau         = rbinom(n,1,0.40), scolarisation = rbinom(n,1,0.30),
  poids       = runif(n,0.8,1.3)
)
res <- calcul_ipm(menages, var_nutrition="nutrition",
  var_electricite="electricite", var_eau="eau",
  var_scolarisation="scolarisation", poids="poids")
graphique_ipm(res)

```
