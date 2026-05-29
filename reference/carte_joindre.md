# Joindre des donnees statistiques a un objet sf

Effectue la jointure entre un objet sf et un data.frame statistique sur
une cle administrative commune. Signale les zones non appariees et
propose un diagnostic de correspondance.

## Usage

``` r
carte_joindre(
  sf_obj,
  data,
  cle_geo,
  cle_data = NULL,
  type = c("gauche", "interne"),
  normaliser = TRUE
)
```

## Arguments

- sf_obj:

  sf – Objet geographique (resultat de
  [`carte_import()`](https://damoko2004.github.io/statAfrikR/reference/carte_import.md)
  ou tout objet sf valide)

- data:

  data.frame ou tibble – Donnees statistiques a joindre

- cle_geo:

  character – Nom de la variable cle dans `sf_obj`

- cle_data:

  character – Nom de la variable cle dans `data`. Si NULL, utilise
  `cle_geo`. Defaut : NULL

- type:

  character – Type de jointure : `"gauche"` (toutes les zones geo
  conservees) ou `"interne"` (seulement les zones appariees). Defaut :
  "gauche"

- normaliser:

  logical – Normaliser les cles (majuscules, suppression accents et
  espaces) avant jointure. Defaut : TRUE

## Value

Un objet `sf` enrichi avec les donnees statistiques

## Examples

``` r
if (FALSE) { # \dontrun{
  regions_sf <- carte_import("data/regions.shp")
  stats      <- data.frame(region = c("Nord", "Sud"), taux = c(0.42, 0.31))
  enrichi    <- carte_joindre(regions_sf, stats,
                              cle_geo = "NOM_REGION", cle_data = "region")
} # }
```
