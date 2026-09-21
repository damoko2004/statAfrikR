# Calculer la couverture de protection sociale

Calcule la proportion de la population couverte par au moins un regime
de protection sociale (retraite, assurance maladie, allocations). ODD
1.3.1.

## Utilisation

``` r
protection_sociale(donnees, vars_protection, poids = NULL, sous_groupes = NULL)
```

## Arguments

- donnees:

  data.frame – Donnees menages ou individus

- vars_protection:

  named character – Vecteur nomme : type de protection -\> variable 0/1.
  Ex: c(Retraite="retraite", Assurance_maladie="assur_maladie")

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de desagregation. Defaut : NULL

## Valeur de retour

Un tibble avec couverture par type de protection

## Exemples

``` r
set.seed(42)
n <- 400
individus <- data.frame(
  retraite      = rbinom(n, 1, 0.18),
  assur_maladie = rbinom(n, 1, 0.22),
  allocations   = rbinom(n, 1, 0.12),
  poids         = runif(n, 0.8, 1.3)
)
protection_sociale(individus,
  vars_protection = c(Retraite="retraite",
                      Assurance_maladie="assur_maladie",
                      Allocations="allocations"),
  poids = "poids")
#> === Protection sociale (ODD 1.3.1) ===
#>   Retraite : 18.72%
#>   Assurance_maladie : 20.5%
#>   Allocations : 12.46%
#>   Au moins un regime : 41.8%
#> # A tibble: 4 × 3
#>   type_protection    couverture_pct n_obs
#>   <chr>                       <dbl> <int>
#> 1 Retraite                     18.7   400
#> 2 Assurance_maladie            20.5   400
#> 3 Allocations                  12.5   400
#> 4 Au moins un regime           41.8   400
```
