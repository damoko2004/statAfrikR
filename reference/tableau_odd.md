# Tableau de suivi des indicateurs ODD

Calcule et presente plusieurs indicateurs ODD dans un tableau de suivi
formate selon les standards de reporting PARIS21/Nations Unies.

## Usage

``` r
tableau_odd(
  resultats,
  pays = NULL,
  annee = NULL,
  cibles = NULL,
  format = c("tibble", "flextable", "excel"),
  chemin = NULL
)
```

## Arguments

- resultats:

  list – Liste nommee d'objets `saf_odd` (resultats de
  [`odd_indicateur()`](https://damoko2004.github.io/statAfrikR/reference/odd_indicateur.md))

- pays:

  character ou NULL – Nom du pays. Defaut : NULL

- annee:

  integer ou NULL – Annee de reference. Defaut : NULL

- cibles:

  list ou NULL – Liste nommee des cibles nationales par code ODD. Ex :
  `list("1.2.1" = 25, "7.1.1" = 80)`. Defaut : NULL

- format:

  character – `"tibble"`, `"flextable"` ou `"excel"`. Defaut : "tibble"

- chemin:

  character ou NULL – Chemin Excel. Defaut : NULL

## Value

Tibble, flextable ou chemin Excel

## Examples

``` r
set.seed(42)
menages <- data.frame(
  depense_pc  = c(rexp(70, 1/150000), rexp(30, 1/500000)),
  poids       = runif(100, 0.8, 1.2),
  electricite = sample(c(0L, 1L), 100, TRUE, c(0.45, 0.55)),
  eau_potable = sample(c(0L, 1L), 100, TRUE, c(0.35, 0.65))
)
r1 <- odd_indicateur(menages, "1.2.1",
                     var_depense = "depense_pc", seuil = 200000)
r2 <- odd_indicateur(menages, "7.1.1",
                     var_indicateur = "electricite")
tableau_odd(list(r1, r2), pays = "Centrafrique", annee = 2026L)
#> # A tibble: 2 × 9
#>   code_odd indicateur         valeur unite cible ecart_cible n_obs pays    annee
#>   <chr>    <chr>               <dbl> <chr> <dbl>       <dbl> <int> <chr>   <int>
#> 1 1.2.1    Pauvrete nationale     60 %        NA          NA   100 Centra…  2026
#> 2 7.1.1    Electricite            65 %        NA          NA   100 Centra…  2026
```
