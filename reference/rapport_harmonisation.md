# Produire un rapport d'harmonisation geographique

Genere un rapport complet sur l'harmonisation geographique : zones
appariees, non appariees, ambigues. Format institutionnel conforme aux
standards IHSN/PARIS21.

## Usage

``` r
rapport_harmonisation(
  donnees,
  var_zone,
  reference,
  var_ref = "nom_local",
  pays = "Pays",
  annee = as.integer(format(Sys.Date(), "%Y"))
)
```

## Arguments

- donnees:

  data.frame – Donnees source

- var_zone:

  character – Variable zone

- reference:

  data.frame ou saf_concordance – Reference geographique

- var_ref:

  character – Variable zone de reference. Defaut : "nom_local"

- pays:

  character – Nom du pays. Defaut : "Pays"

- annee:

  integer – Annee. Defaut : annee courante

## Value

Un tibble de rapport d'harmonisation

## Examples

``` r
donnees <- data.frame(
  region = c("Bangui","Ombella-Mpoko","Kemo","Zone inconnue"),
  stringsAsFactors = FALSE
)
ref <- data.frame(
  nom_local = c("Bangui","Ombella-M'Poko","Kemo","Bamingui-Bangoran"),
  stringsAsFactors = FALSE
)
rapport_harmonisation(donnees, "region", ref, pays="RCA", annee=2026L)
#> Suggestions d'appariement disponibles dans attr(res,'suggestions')
#> Rapport harmonisation : RCA - 2026
#>   Appariement : 75%
#> # A tibble: 4 × 5
#>   indicateur                          valeur statut pays  annee
#>   <chr>                                <dbl> <chr>  <chr> <int>
#> 1 Zones uniques dans les donnees           4 Info   RCA    2026
#> 2 Zones appariees avec le referentiel      3 OK     RCA    2026
#> 3 Zones non appariees                      1 Alerte RCA    2026
#> 4 Taux d'appariement (%)                  75 Alerte RCA    2026
```
