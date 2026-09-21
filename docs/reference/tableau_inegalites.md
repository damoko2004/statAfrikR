# Tableau de bord des inegalites

Calcule toutes les mesures d'inegalite en une seule fonction et les
presente dans un tableau institutionnel. Inclut Gini, Palma, Theil,
Atkinson et les parts par quintile.

## Utilisation

``` r
tableau_inegalites(
  donnees,
  var_revenu,
  poids = NULL,
  var_groupe = NULL,
  pays = "Pays",
  annee = as.integer(format(Sys.Date(), "%Y"))
)
```

## Arguments

- donnees:

  data.frame – Donnees menages

- var_revenu:

  character – Variable de revenu

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- var_groupe:

  character ou NULL – Variable de groupe pour decomposition. Defaut :
  NULL

- pays:

  character – Nom du pays. Defaut : "Pays"

- annee:

  integer – Annee. Defaut : annee courante

## Valeur de retour

Un tibble avec toutes les mesures d'inegalite

## Exemples

``` r
set.seed(42)
menages <- data.frame(
  depense = c(rexp(200, 1/150000), rexp(100, 1/500000)),
  milieu  = sample(c("urbain","rural"), 300, TRUE),
  poids   = runif(300, 0.8, 1.3)
)
tableau_inegalites(menages, "depense", poids="poids",
                   var_groupe="milieu", pays="Centrafrique",
                   annee=2026L)
#> Decomposition Theil par 'milieu' disponible via decomposer_theil()
#> # A tibble: 7 × 5
#>   indicateur                             valeur interpretation       pays  annee
#>   <chr>                                   <dbl> <chr>                <chr> <int>
#> 1 Coefficient de Gini                     0.567 Inegalite extreme    Cent…  2026
#> 2 Indice de Palma (top 10% / bottom 40%)  8.37  Inegalite elevee     Cent…  2026
#> 3 Part Q1 (20% les plus pauvres)          1.71  Part des revenus     Cent…  2026
#> 4 Part Q5 (20% les plus riches)          60.2   Part des revenus     Cent…  2026
#> 5 Ratio Q5/Q1                            35.2   Rapport de richesse  Cent…  2026
#> 6 Indice de Theil T                       0.552 Inegalite elevee     Cent…  2026
#> 7 Indice d'Atkinson (epsilon=1)           0.509 Perte de bien-etre … Cent…  2026
```
