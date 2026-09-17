# Detecter les zones non appariees entre deux sources

Identifie les zones presentes dans les donnees mais absentes de la
reference geographique. Propose des suggestions d'appariement par score
de similarite (Jaro-Winkler). Essentiel avant toute jointure
cartographique.

## Usage

``` r
detecter_ecarts_geo(
  donnees,
  var_zone,
  reference,
  var_ref = "nom_local",
  n_suggestions = 3L
)
```

## Arguments

- donnees:

  data.frame – Donnees avec zones a verifier

- var_zone:

  character – Variable zone dans les donnees

- reference:

  data.frame ou saf_concordance – Reference geographique

- var_ref:

  character – Variable zone dans la reference. Defaut : "nom_local"

- n_suggestions:

  integer – Nombre de suggestions par zone. Defaut : 3L

## Value

Un tibble avec zones non appariees et suggestions

## Examples

``` r
donnees <- data.frame(
  region = c("Bangui","Ombella-Mpoko","Kemo","Zone inconnue"),
  valeur = c(100, 200, 150, 80),
  stringsAsFactors = FALSE
)
reference <- data.frame(
  nom_local = c("Bangui","Ombella-M'Poko","Kemo",
                 "Bamingui-Bangoran","Mbomou"),
  stringsAsFactors = FALSE
)
detecter_ecarts_geo(donnees, "region", reference, "nom_local")
#> === Detection des ecarts geographiques ===
#>   Zones dans les donnees    : 4
#>   Zones appariees           : 3 (75%)
#>   Zones non appariees       : 1
#>   Zones non appariees :
#>     - Zone inconnue
#> $appariees
#> [1] "Bangui"        "Ombella-Mpoko" "Kemo"         
#> 
#> $non_appariees
#> [1] "Zone inconnue"
#> 
#> $suggestions
#> # A tibble: 1 × 7
#>   zone_source   suggestion_1 score_1 suggestion_2   score_2 suggestion_3 score_3
#>   <chr>         <chr>          <dbl> <chr>            <dbl> <chr>          <dbl>
#> 1 Zone inconnue Bangui         0.316 Bamingui-Bang…   0.267 Kemo           0.235
#> 
#> $taux_appariement
#> [1] 75
#> 
```
