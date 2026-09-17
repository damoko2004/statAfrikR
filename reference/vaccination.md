# Calculer la couverture vaccinale

Calcule la couverture vaccinale par antigene selon la methodologie
DHS/MICS. Indicateurs ODD 3.b.1.

## Usage

``` r
vaccination(
  donnees,
  vars_vaccins,
  poids = NULL,
  var_carte_sante = NULL,
  sous_groupes = NULL
)
```

## Arguments

- donnees:

  data.frame – Donnees enfants

- vars_vaccins:

  named character – Vecteur nomme : nom du vaccin -\> nom de la variable
  (0/1). Ex: c(DTC3="dtc3", Rougeole="rougeole")

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- var_carte_sante:

  character ou NULL – Variable indiquant si l'enfant a une carte de
  sante (pour ajustement). Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de desagregation. Defaut : NULL

## Value

Un tibble avec couverture par antigene

## Examples

``` r
set.seed(42)
n <- 500
enfants <- data.frame(
  dtc3      = rbinom(n, 1, 0.72),
  rougeole  = rbinom(n, 1, 0.68),
  polio3    = rbinom(n, 1, 0.75),
  bcg       = rbinom(n, 1, 0.90),
  poids     = runif(n, 0.8, 1.3),
  milieu    = sample(c("urbain","rural"), n, TRUE)
)
vaccination(enfants,
  vars_vaccins = c(DTC3="dtc3", Rougeole="rougeole",
                   Polio3="polio3", BCG="bcg"),
  poids = "poids")
#> === Couverture vaccinale ===
#>   DTC3 : 71.74% [Ecart : -23.3%]
#>   Rougeole : 68.69% [Ecart : -26.3%]
#>   Polio3 : 76.54% [Ecart : -18.5%]
#>   BCG : 88.05% [Ecart : -6.9%]
#> # A tibble: 4 × 7
#>   antigene couverture_pct ic_bas ic_haut n_obs objectif_oms ecart_objectif
#>   <chr>             <dbl>  <dbl>   <dbl> <int>        <dbl>          <dbl>
#> 1 DTC3               71.7   67.6    75.5   500           95           23.3
#> 2 Rougeole           68.7   64.5    72.6   500           95           26.3
#> 3 Polio3             76.5   72.6    80.0   500           95           18.5
#> 4 BCG                88.0   84.9    90.6   500           95            6.9
```
