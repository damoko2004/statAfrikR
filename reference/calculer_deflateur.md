# Calculer et appliquer le deflateur du PIB

Convertit les valeurs en prix courants en prix constants (volume) en
utilisant le deflateur implicite du PIB ou un indice de prix fourni.
Base annee referencee configurable.

## Usage

``` r
calculer_deflateur(
  donnees,
  var_pib_courant,
  var_deflateur = NULL,
  var_ipc = NULL,
  annee_base = 2015L,
  var_annee = "annee"
)
```

## Arguments

- donnees:

  data.frame – Donnees avec PIB courant et deflateur

- var_pib_courant:

  character – Variable PIB en prix courants

- var_deflateur:

  character ou NULL – Variable deflateur (base 100). Si NULL, calcule
  depuis var_ipc. Defaut : NULL

- var_ipc:

  character ou NULL – Indice des prix a la consommation (si deflateur
  non fourni). Defaut : NULL

- annee_base:

  integer – Annee de base du deflateur. Defaut : 2015L

- var_annee:

  character – Variable annee. Defaut : "annee"

## Value

Un tibble avec PIB courant, deflateur et PIB constant

## Examples

``` r
comptes <- data.frame(
  annee        = 2015:2022,
  pib_courant  = c(2100,2180,2250,2310,2195,2280,2380,2450),
  deflateur    = c(100,103.2,106.8,110.5,109.2,113.5,118.2,122.8)
)
calculer_deflateur(comptes, "pib_courant",
                   var_deflateur="deflateur",
                   annee_base=2015L)
#> === Deflateur PIB (base 2015) ===
#>   Periodes : 8
#>   Croissance reelle moy : -0.72% par an
#> # A tibble: 8 × 6
#>   annee pib_courant deflateur pib_constant annee_base croissance_reelle_pct
#>   <int>       <dbl>     <dbl>        <dbl>      <int>                 <dbl>
#> 1  2015        2100      100         2100        2015                 NA   
#> 2  2016        2180      103.        2112.       2015                  0.59
#> 3  2017        2250      107.        2107.       2015                 -0.27
#> 4  2018        2310      110.        2090.       2015                 -0.77
#> 5  2019        2195      109.        2010.       2015                 -3.85
#> 6  2020        2280      114.        2009.       2015                 -0.06
#> 7  2021        2380      118.        2014.       2015                  0.24
#> 8  2022        2450      123.        1995.       2015                 -0.92
```
