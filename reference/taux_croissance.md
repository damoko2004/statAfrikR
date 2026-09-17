# Calculer les taux de croissance du PIB et contributions

Calcule les taux de croissance reels et nominaux du PIB et la
contribution de chaque secteur a la croissance. Conforme aux methodes
SCN 2008.

## Usage

``` r
taux_croissance(
  donnees,
  var_pib,
  vars_secteurs = NULL,
  var_annee = "annee",
  var_trimestre = NULL
)
```

## Arguments

- donnees:

  data.frame – Donnees de comptes nationaux avec secteurs

- var_pib:

  character – Variable PIB total (prix constants)

- vars_secteurs:

  named character ou NULL – Vecteur nomme des variables sectorielles. Ex
  : c(Agriculture="agri", Industrie="indus")

- var_annee:

  character – Variable annee. Defaut : "annee"

- var_trimestre:

  character ou NULL – Variable trimestre (si donnees trimestrielles).
  Defaut : NULL

## Value

Un tibble avec taux de croissance et contributions sectorielles

## Examples

``` r
comptes <- data.frame(
  annee = 2018:2022,
  pib   = c(2100, 2180, 2250, 2195, 2380),
  agri  = c(420,  440,  460,  445,  490),
  indus = c(630,  660,  680,  660,  715),
  serv  = c(1050, 1080, 1110, 1090, 1175)
)
taux_croissance(comptes, "pib",
  vars_secteurs = c(Agriculture="agri",
                    Industrie="indus",
                    Services="serv"),
  var_annee = "annee")
#> === Croissance du PIB ===
#>   2019 : +3.81%
#>   2020 : +3.21%
#>   2021 : -2.44%
#>   2022 : +8.43%
#> # A tibble: 5 × 6
#>   annee   pib croissance_pct contrib_Agriculture contrib_Industrie
#>   <int> <dbl>          <dbl>               <dbl>             <dbl>
#> 1  2018  2100          NA                  NA                NA   
#> 2  2019  2180           3.81                0.95              1.43
#> 3  2020  2250           3.21                0.92              0.92
#> 4  2021  2195          -2.44               -0.67             -0.89
#> 5  2022  2380           8.43                2.05              2.51
#> # ℹ 1 more variable: contrib_Services <dbl>
```
