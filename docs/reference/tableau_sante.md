# Tableau de bord des indicateurs de sante

Synthetise tous les indicateurs de sante disponibles en un seul tableau
institutionnel. Produit un rapport comparable aux tableaux de bord
DHS/MICS.

## Utilisation

``` r
tableau_sante(
  indicateurs,
  pays = "Pays",
  annee = as.integer(format(Sys.Date(), "%Y")),
  source = NULL
)
```

## Arguments

- indicateurs:

  list – Liste nommee d'objets saf_anthropo ou saf_mortalite, ou tibbles
  de vaccination/accouchements

- pays:

  character – Nom du pays. Defaut : "Pays"

- annee:

  integer – Annee. Defaut : annee courante

- source:

  character ou NULL – Source des donnees. Defaut : NULL

## Valeur de retour

Un tibble institutionnel

## Exemples

``` r
set.seed(42)
n <- 400
enfants <- data.frame(
  haz  = rnorm(n,-1.2,1.3), waz = rnorm(n,-1.0,1.2),
  poids = runif(n,0.8,1.3)
)
r1 <- suppressMessages(
  retard_croissance(enfants, var_taille_age_z="haz", poids="poids"))
r2 <- suppressMessages(
  insuffisance_ponderale(enfants, var_poids_age_z="waz", poids="poids"))
tableau_sante(list(stunting=r1, underweight=r2),
              pays="Centrafrique", annee=2026L)
#> Tableau de bord sante : Centrafrique - 2026 (2 indicateurs)
#> # A tibble: 2 × 9
#>   indicateur      code_odd valeur_pct ic_bas ic_haut n_obs categorie pays  annee
#>   <chr>           <chr>         <dbl>  <dbl>   <dbl> <int> <chr>     <chr> <int>
#> 1 Retard de croi… ODD 2.2…       25.0   21.0    29.4   400 Eleve (2… Cent…  2026
#> 2 Insuffisance p… ODD 2.2…       21.7   18.0    26.0   400 Eleve (2… Cent…  2026
```
