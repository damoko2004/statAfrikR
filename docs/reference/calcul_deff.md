# Calculer l'effet de plan (DEFF)

Calcule le Design Effect (DEFF) pour les variables d'interet. DEFF =
Variance estimee sous le plan complexe / Variance sous SRS. Permet de
calculer la taille effective de l'echantillon.

## Utilisation

``` r
calcul_deff(saf_design, variables, type = c("proportion", "moyenne"))
```

## Arguments

- saf_design:

  saf_design – Objet cree par
  [`creer_design()`](https://damoko2004.github.io/statAfrikR/reference/creer_design.md)

- variables:

  character – Variables pour lesquelles calculer le DEFF

- type:

  character – "proportion" ou "moyenne". Defaut : "proportion"

## Valeur de retour

Un tibble avec DEFF et taille effective par variable

## Exemples

``` r
set.seed(42)
n <- 300
donnees <- data.frame(
  poids_sond = runif(n, 1800, 3500),
  strate     = sample(c("Urbain","Rural"), n, TRUE),
  grappe     = sample(1:20, n, TRUE),
  pauvre     = rbinom(n, 1, 0.45),
  revenu     = pmax(0, rnorm(n, 180000, 90000))
)
design <- suppressMessages(
  creer_design(donnees,"poids_sond",var_strate="strate",var_grappe="grappe"))
calcul_deff(design, variables=c("pauvre","revenu"))
#> === Effets de plan (DEFF) ===
#>   pauvre : DEFF=0.988 | N effectif=304 | CV=6.24%
#>   revenu : DEFF=NA | N effectif=300 | CV=2.9%
#> # A tibble: 2 × 5
#>   variable deff[,1] n_obs n_effectif[,1] cv_pct[,1]
#>   <chr>       <dbl> <int>          <dbl>      <dbl>
#> 1 pauvre      0.988   300            304       6.24
#> 2 revenu     NA       300            300       2.9 
```
