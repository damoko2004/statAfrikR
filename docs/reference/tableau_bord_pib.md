# Tableau de bord des comptes nationaux

Produit un tableau de bord institutionnel du PIB combinant croissance,
deflateur, comparaison de sources et revisions. Format comparable aux
publications des INS africains.

## Utilisation

``` r
tableau_bord_pib(
  donnees,
  var_pib_courant,
  var_pib_constant = NULL,
  var_annee = "annee",
  vars_secteurs = NULL,
  pays = "Pays",
  unite = "Mds FCFA"
)
```

## Arguments

- donnees:

  data.frame – Donnees de comptes nationaux

- var_pib_courant:

  character – PIB en prix courants

- var_pib_constant:

  character ou NULL – PIB en prix constants. Defaut : NULL

- var_annee:

  character – Variable annee. Defaut : "annee"

- vars_secteurs:

  named character ou NULL – Secteurs economiques. Defaut : NULL

- pays:

  character – Nom du pays. Defaut : "Pays"

- unite:

  character – Unite. Defaut : "Mds FCFA"

## Valeur de retour

Un tibble du tableau de bord PIB

## Exemples

``` r
comptes <- data.frame(
  annee       = 2018:2022,
  pib_courant = c(2100,2180,2250,2195,2380),
  pib_cst     = c(2000,2060,2110,2060,2210)
)
tableau_bord_pib(comptes, "pib_courant",
                  var_pib_constant="pib_cst",
                  pays="Cameroun", unite="Mds FCFA")
#> Tableau de bord PIB : Cameroun (2018-2022)
#>   N periodes : 5
#>   Croissance reelle moy : 2.58%/an
#> # A tibble: 5 × 8
#>   annee pib_courant croissance_nom pib_constant croissance_reel deflateur pays  
#>   <int>       <dbl>          <dbl>        <dbl>           <dbl>     <dbl> <chr> 
#> 1  2018        2100          NA            2000           NA         105  Camer…
#> 2  2019        2180           3.81         2060            3         106. Camer…
#> 3  2020        2250           3.21         2110            2.43      107. Camer…
#> 4  2021        2195          -2.44         2060           -2.37      107. Camer…
#> 5  2022        2380           8.43         2210            7.28      108. Camer…
#> # ℹ 1 more variable: unite <chr>
```
