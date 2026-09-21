# Tableau de bord du bien-etre subjectif

Synthetise tous les indicateurs de bien-etre subjectif en un tableau
institutionnel unique. Format adapte aux rapports nationaux sur le
bien-etre et la qualite de vie.

## Utilisation

``` r
tableau_bien_etre_subjectif(
  indicateurs,
  pays = "Pays",
  annee = as.integer(format(Sys.Date(), "%Y")),
  source = NULL
)
```

## Arguments

- indicateurs:

  list – Liste nommee d'objets saf_subjectif ou tibbles

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
individus <- data.frame(
  satisf   = pmin(10,pmax(0,round(rnorm(n,5.8,2.1)))),
  bonheur  = rbinom(n,1,0.62),
  securise = rbinom(n,1,0.52),
  poids    = runif(n,0.8,1.3)
)
r1 <- suppressMessages(
  satisfaction_vie(individus,"satisf",poids="poids"))
r2 <- suppressMessages(
  sentiment_securite(individus,"securise",poids="poids"))
tableau_bien_etre_subjectif(list(satisfaction=r1, securite=r2),
                             pays="RCA", annee=2026L)
#> Tableau bien-etre subjectif : RCA - 2026 (2 indicateurs)
#> # A tibble: 2 × 7
#>   indicateur                             code_ref valeur unite n_obs pays  annee
#>   <chr>                                  <chr>     <dbl> <chr> <int> <chr> <int>
#> 1 Satisfaction dans la vie (echelle Can… OCDE / …   5.80 /10     400 RCA    2026
#> 2 Sentiment de securite percue           Afrobar…  52.7  %       400 RCA    2026
```
