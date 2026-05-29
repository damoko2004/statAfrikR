# Importer un fichier geographique

Importe un fichier geographique (shapefile, GeoJSON, GeoPackage) et
retourne un objet `sf` normalise avec validation du CRS et rapport des
entites chargees.

## Usage

``` r
carte_import(chemin, crs = 4326L, couche = NULL, simplifier = FALSE)
```

## Arguments

- chemin:

  character – Chemin vers le fichier geographique (.shp, .geojson,
  .gpkg, .json)

- crs:

  integer – Code EPSG du systeme de coordonnees cible. Defaut : 4326
  (WGS 84)

- couche:

  character ou NULL – Nom de la couche (GeoPackage multi-couches).
  Defaut : NULL (premiere couche)

- simplifier:

  logical – Simplifier la geometrie pour reduire le temps de rendu
  (tolerance = 0.001 degres). Defaut : FALSE

## Value

Un objet `sf` normalise

## Examples

``` r
if (FALSE) { # \dontrun{
  regions <- carte_import("data/regions.shp")
  communes <- carte_import("data/communes.geojson", crs = 32632)
} # }
```
