# Analyser la non-reponse

Calcule les taux de non-reponse par strate et teste les biais de
non-reponse potentiels par comparaison des repondants et non-repondants
sur les variables disponibles.

## Utilisation

``` r
analyser_non_reponse(
  donnees,
  var_reponse,
  var_strate = NULL,
  vars_biais = NULL
)
```

## Arguments

- donnees:

  data.frame – Donnees avec variable reponse

- var_reponse:

  character – Variable 0/1 : a repondu (1) ou non-repondant (0)

- var_strate:

  character ou NULL – Variable de stratification. Defaut : NULL

- vars_biais:

  character ou NULL – Variables pour test de biais (disponibles pour
  tous : repondants + non-repondants). Defaut : NULL

## Valeur de retour

Un tibble avec taux de reponse et statistiques de biais

## Exemples

``` r
set.seed(42)
n <- 400
donnees <- data.frame(
  repondu = rbinom(n, 1, 0.88),
  strate  = sample(c("Urbain","Rural"), n, TRUE),
  age_cm  = sample(25:65, n, TRUE),
  taille_men = sample(3:10, n, TRUE)
)
analyser_non_reponse(donnees, "repondu",
                      var_strate = "strate",
                      vars_biais = c("age_cm","taille_men"))
#> === Analyse de la non-reponse ===
#>   Rural : 86.14%
#>   Urbain : 86.87%
#>   Biais de non-reponse :
#>     age_cm : ecart=0.4%
#>     taille_men : ecart=1.1%
#> $taux_reponse
#> # A tibble: 2 × 5
#>   strate n_total n_repondants taux_reponse alerte
#>   <chr>    <int>        <int>        <dbl> <lgl> 
#> 1 Rural      202          174         86.1 FALSE 
#> 2 Urbain     198          172         86.9 FALSE 
#> 
#> $biais
#> # A tibble: 2 × 5
#>   variable   moy_repondants moy_non_rep ecart_pct biais_potentiel
#>   <chr>               <dbl>       <dbl>     <dbl> <lgl>          
#> 1 age_cm              46.2        46.4        0.4 FALSE          
#> 2 taille_men           6.34        6.41       1.1 FALSE          
#> 
```
