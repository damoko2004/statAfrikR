# Verifier la coherence demographique des donnees

Detecte les incoherences courantes dans les donnees demographiques : age
mere \< age enfant, dates d'evenements incoherentes, ages impossibles,
sex-ratio aberrants, etc.

## Usage

``` r
coherence_demo(
  donnees,
  var_age = NULL,
  var_age_mere = NULL,
  var_age_enfant = NULL,
  var_age_deces = NULL,
  var_sexe = NULL,
  age_max_plausible = 120L
)
```

## Arguments

- donnees:

  data.frame – Donnees individuelles ou menages

- var_age:

  character ou NULL – Variable age. Defaut : NULL

- var_age_mere:

  character ou NULL – Variable age de la mere. Defaut : NULL

- var_age_enfant:

  character ou NULL – Variable age de l'enfant. Defaut : NULL

- var_age_deces:

  character ou NULL – Variable age au deces. Defaut : NULL

- var_sexe:

  character ou NULL – Variable sexe. Defaut : NULL

- age_max_plausible:

  integer – Age maximum plausible. Defaut : 120L

## Value

Un tibble des anomalies detectees avec leur nombre

## Examples

``` r
set.seed(42)
n <- 500
menages <- data.frame(
  age         = c(sample(0:100, n-5, TRUE), rep(-1, 3), rep(130, 2)),
  age_mere    = sample(15:60, n, TRUE),
  age_enfant  = sample(0:30,  n, TRUE),
  age_deces   = c(sample(1:90, n-10, TRUE), rep(NA, 10)),
  sexe        = sample(c("H","F","X"), n, TRUE, prob=c(0.49,0.49,0.02))
)
coherence_demo(menages,
  var_age="age", var_age_mere="age_mere",
  var_age_enfant="age_enfant",
  var_sexe="sexe")
#> === Coherence demographique ===
#>   Anomalies detectees : 4 type(s)
#>   [Critique] Age negatif (< 0) : n=3 (0.6%)
#>   [Critique] Age > 120 ans : n=2 (0.4%)
#>   [Important] Age mere - age enfant < 12 ans : n=114 (22.8%)
#>   [Important] Code sexe invalide : n=8 (1.6%)
#> # A tibble: 4 × 4
#>   type_anomalie                  n_anomalies   pct gravite  
#>   <chr>                                <int> <dbl> <chr>    
#> 1 Age negatif (< 0)                        3   0.6 Critique 
#> 2 Age > 120 ans                            2   0.4 Critique 
#> 3 Age mere - age enfant < 12 ans         114  22.8 Important
#> 4 Code sexe invalide                       8   1.6 Important
```
