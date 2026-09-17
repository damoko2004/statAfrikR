# Valider les poids de sondage

Verifie la coherence des poids de sondage : somme par strate, detection
des poids aberrants (outliers), DEFF eleves, comparaison avec la
population cible. Etape indispensable avant toute analyse.

## Usage

``` r
valider_poids(saf_design, population_cible = NULL, seuil_outlier = 3)
```

## Arguments

- saf_design:

  saf_design – Objet cree par
  [`creer_design()`](https://damoko2004.github.io/statAfrikR/reference/creer_design.md)

- population_cible:

  numeric ou NULL – Population totale cible (pour verifier que
  sum(poids) est coherent). Defaut : NULL

- seuil_outlier:

  numeric – Seuil de detection des outliers en ecarts-types (score Z).
  Defaut : 3.0

## Value

Un tibble avec les statistiques de validation par strate

## Examples

``` r
set.seed(42)
n <- 300
donnees <- data.frame(
  poids_sond = runif(n, 1800, 3500),
  strate     = sample(c("Urbain","Rural"), n, TRUE),
  grappe     = sample(1:20, n, TRUE)
)
design <- suppressMessages(
  creer_design(donnees,"poids_sond",var_strate="strate",var_grappe="grappe"))
valider_poids(design)
#> === Validation des poids de sondage ===
#>   Somme totale poids : 792 485
#>   CV des poids       : 18.8%
#>   Poids outliers     : 0 (Z > 3)
#> # A tibble: 2 × 7
#>   strate n_obs somme_poids poids_moyen cv_poids_pct n_outliers alerte
#>   <chr>  <int>       <dbl>       <dbl>        <dbl>      <int> <lgl> 
#> 1 Rural    148      391251       2644.         18.7          0 FALSE 
#> 2 Urbain   152      401234       2640.         19.0          0 FALSE 
```
