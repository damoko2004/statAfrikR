# Calculer la prevalence de l'anemie

Calcule la prevalence de l'anemie selon les seuils OMS (hemoglobine en
g/dL). Distingue les niveaux legere, moderee, severe.

## Utilisation

``` r
anemie(
  donnees,
  var_hemoglobine,
  var_groupe_cible = NULL,
  poids = NULL,
  sous_groupes = NULL
)
```

## Arguments

- donnees:

  data.frame – Donnees menages ou individus

- var_hemoglobine:

  character – Taux d'hemoglobine en g/dL

- var_groupe_cible:

  character ou NULL – Groupe cible : "femmes_15_49", "enfants_6_59",
  "enceintes", "tous". Defaut : NULL (tous)

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de desagregation. Defaut : NULL

## Valeur de retour

Un tibble avec prevalence par niveau d'anemie

## Exemples

``` r
set.seed(42)
n <- 400
femmes <- data.frame(
  hemoglobine = rnorm(n, 11.5, 2.1),
  milieu      = sample(c("urbain","rural"), n, TRUE),
  poids       = runif(n, 0.8, 1.3)
)
anemie(femmes, var_hemoglobine = "hemoglobine", poids = "poids")
#> === Prevalence de l'anemie (seuils OMS) ===
#>   Severe (< 8 g/dL) : 3.35%
#>   Moderee (8-11 g/dL) : 36.85%
#>   Legere (11-12 g/dL) : 21.59%
#>   Total anemie (< 12 g/dL) : 61.79%
#> # A tibble: 5 × 3
#>   niveau                   prevalence_pct n_obs
#>   <chr>                             <dbl> <int>
#> 1 Severe (< 8 g/dL)                  3.35   400
#> 2 Moderee (8-11 g/dL)               36.8    400
#> 3 Legere (11-12 g/dL)               21.6    400
#> 4 Total anemie (< 12 g/dL)          61.8    400
#> 5 Normale (>= 12 g/dL)              38.2    400
```
