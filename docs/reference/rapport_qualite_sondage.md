# Produire un rapport de qualite du plan de sondage

Genere un rapport de synthese sur la qualite du plan de sondage : taux
de reponse, effets de plan, CV, validite des poids. Format
institutionnel IHSN/DHS.

## Utilisation

``` r
rapport_qualite_sondage(
  saf_design,
  variables = NULL,
  var_reponse = NULL,
  pays = "Pays",
  annee = as.integer(format(Sys.Date(), "%Y"))
)
```

## Arguments

- saf_design:

  saf_design – Objet design

- variables:

  character ou NULL – Variables pour le calcul du DEFF. Defaut : NULL

- var_reponse:

  character ou NULL – Variable de non-reponse. Defaut : NULL

- pays:

  character – Nom du pays. Defaut : "Pays"

- annee:

  integer – Annee. Defaut : annee courante

## Valeur de retour

Un tibble de rapport qualite

## Exemples

``` r
set.seed(42)
n <- 300
donnees <- data.frame(
  poids_sond = runif(n, 1800, 3500),
  strate     = sample(c("Urbain","Rural"), n, TRUE),
  grappe     = sample(1:20, n, TRUE),
  repondu    = rbinom(n, 1, 0.88),
  pauvre     = rbinom(n, 1, 0.45)
)
design <- suppressMessages(
  creer_design(donnees,"poids_sond",var_strate="strate",var_grappe="grappe"))
rapport_qualite_sondage(design, variables="pauvre",
                         var_reponse="repondu",
                         pays="RCA", annee=2026L)
#> Rapport qualite sondage : RCA - 2026
#> # A tibble: 7 × 5
#>   indicateur                     valeur statut     pays  annee
#>   <chr>                           <dbl> <chr>      <chr> <int>
#> 1 Taille de l'echantillon        300    Info       RCA    2026
#> 2 Nombre de strates                2    Info       RCA    2026
#> 3 Nombre de grappes (UPS)         20    Info       RCA    2026
#> 4 CV des poids de sondage (%)     18.8  OK         RCA    2026
#> 5 Somme des poids             792485    Info       RCA    2026
#> 6 Taux de reponse global (%)      89.7  Acceptable RCA    2026
#> 7 DEFF moyen                       1.16 Acceptable RCA    2026
```
