# Calculer la prevalence du handicap

Prevalence du handicap par type (visuel, auditif, moteur, cognitif)
selon la methodologie Washington Group / recensement.

## Usage

``` r
handicap_prevalence(donnees, vars_handicap, poids = NULL, sous_groupes = NULL)
```

## Arguments

- donnees:

  data.frame – Donnees individuelles

- vars_handicap:

  named character – Vecteur nomme : type de handicap -\> variable 0/1.
  Ex: c(Visuel="hand_vis", Moteur="hand_mot")

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de desagregation. Defaut : NULL

## Value

Un tibble avec prevalence par type de handicap

## Examples

``` r
set.seed(42)
n <- 500
individus <- data.frame(
  hand_vis = rbinom(n, 1, 0.04),
  hand_aud = rbinom(n, 1, 0.03),
  hand_mot = rbinom(n, 1, 0.05),
  sexe     = sample(c("H","F"), n, TRUE),
  poids    = runif(n, 0.8, 1.3)
)
handicap_prevalence(individus,
  vars_handicap = c(Visuel="hand_vis", Auditif="hand_aud",
                    Moteur="hand_mot"),
  poids = "poids")
#> === Prevalence du handicap (Washington Group) ===
#>   Visuel : 3.92%
#>   Auditif : 2.04%
#>   Moteur : 3.47%
#>   Au moins un type : 8.79%
#> # A tibble: 4 × 5
#>   type_handicap    prevalence_pct ic_bas ic_haut n_obs
#>   <chr>                     <dbl>  <dbl>   <dbl> <int>
#> 1 Visuel                     3.92   2.54    6      500
#> 2 Auditif                    2.04   1.12    3.69   500
#> 3 Moteur                     3.47   2.18    5.46   500
#> 4 Au moins un type           8.79   6.61   11.6    500
```
