# Tableau de bord du marche du travail

Synthetise tous les indicateurs du marche du travail en un tableau
institutionnel unique, comparable aux publications OIT/ILOSTAT et aux
rapports nationaux sur l'emploi.

## Usage

``` r
tableau_marche_travail(
  indicateurs,
  pays = "Pays",
  annee = as.integer(format(Sys.Date(), "%Y")),
  source = NULL
)
```

## Arguments

- indicateurs:

  list – Liste nommee d'objets saf_emploi ou tibbles
  (protection_sociale, taux_sous_utilisation)

- pays:

  character – Nom du pays. Defaut : "Pays"

- annee:

  integer – Annee. Defaut : annee courante

- source:

  character ou NULL – Source. Defaut : NULL

## Value

Un tibble institutionnel

## Examples

``` r
set.seed(42)
n <- 500
ind <- data.frame(
  actif      = rbinom(n, 1, 0.65),
  employe    = rbinom(n, 1, 0.55),
  informel   = rbinom(n, 1, 0.72),
  poids      = runif(n, 0.8, 1.3),
  stringsAsFactors = FALSE
)
r1 <- suppressMessages(taux_activite(ind, "actif", poids="poids"))
r2 <- suppressMessages(taux_emploi(ind, "employe", poids="poids"))
r3 <- suppressMessages(emploi_informel(ind, "informel", poids="poids"))
tableau_marche_travail(list(activite=r1, emploi=r2, informel=r3),
                        pays="Centrafrique", annee=2026L)
#> Tableau de bord marche du travail : Centrafrique - 2026 (3 indicateurs)
#> # A tibble: 3 × 8
#>   indicateur             code_ref valeur_pct ic_bas ic_haut n_obs pays     annee
#>   <chr>                  <chr>         <dbl>  <dbl>   <dbl> <int> <chr>    <int>
#> 1 Taux d'activite        BIT/OIT        67.0   62.8    71.0   500 Centraf…  2026
#> 2 Taux d'emploi          ODD 8.5        58.2   53.8    62.4   500 Centraf…  2026
#> 3 Taux d'emploi informel OIT 2013       73.4   69.3    77.0   500 Centraf…  2026
```
