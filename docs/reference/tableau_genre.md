# Tableau de bord des indicateurs de genre et d'inclusion

Synthetise tous les indicateurs genre en un tableau institutionnel
comparable aux rapports ODD 5 et DHS.

## Utilisation

``` r
tableau_genre(
  indicateurs,
  pays = "Pays",
  annee = as.integer(format(Sys.Date(), "%Y")),
  source = NULL
)
```

## Arguments

- indicateurs:

  list – Liste nommee d'objets saf_genre ou tibbles

- pays:

  character – Nom du pays. Defaut : "Pays"

- annee:

  integer – Annee. Defaut : annee courante

- source:

  character ou NULL – Source. Defaut : NULL

## Valeur de retour

Un tibble institutionnel

## Exemples

``` r
set.seed(42)
n <- 400
femmes <- data.frame(
  marie_18 = rbinom(n, 1, 0.42),
  vbg_phys = rbinom(n, 1, 0.28),
  poids    = runif(n, 0.8, 1.3)
)
rm <- suppressMessages(
  mariage_precoce(femmes, "marie_18", poids="poids"))
rvbg <- violence_basee_genre(femmes,
  var_violence_physique="vbg_phys", poids="poids")
#> === Violences basees sur le genre (ODD 5.2.1) ===
#>   Physique : 26.35%
#>   Au moins une forme : 26.35%
tableau_genre(list(mariage=rm, vbg=rvbg), pays="RCA", annee=2026L)
#> Tableau de bord genre : RCA - 2026 (2 indicateurs)
#> # A tibble: 2 × 6
#>   indicateur                     code_ref  valeur n_obs pays  annee
#>   <chr>                          <chr>      <dbl> <int> <chr> <int>
#> 1 Mariage precoce (avant 18 ans) ODD 5.3.1   39.8   400 RCA    2026
#> 2 vbg                            ODD 5       26.4   400 RCA    2026
```
