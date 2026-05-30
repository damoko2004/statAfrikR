# Charger un fond de carte africain integre

Charge un fond de carte geographique directement integre dans
statAfrikR. Aucun package supplementaire requis.

## Usage

``` r
carte_zones(
  zone = c("afrique", "cemac", "cedeao", "eau", "sadc", "rca", "subdivisions"),
  pays = NULL
)
```

## Arguments

- zone:

  character – Zone geographique : `"afrique"` (54 pays), `"cemac"` (6
  pays), `"cedeao"` (15 pays), `"eau"` (Afrique de l'Est), `"sadc"`
  (Afrique Australe), `"rca"` (17 prefectures RCA). Defaut : "afrique"

- pays:

  character ou NULL – Filtrer par noms de pays (colonne `pays`) ou codes
  ISO3 (colonne `iso3`). Defaut : NULL

## Value

Un objet `sf` pret a l'emploi

## Examples

``` r
# Tous les pays africains
afrique <- carte_zones("afrique")

# Zone CEMAC uniquement
cemac <- carte_zones("cemac")

# Prefectures de la RCA
rca <- carte_zones("rca")

# Filtrer : Cameroun + Centrafrique uniquement
sous_zone <- carte_zones("afrique", pays = c("CMR", "CAF"))
```
