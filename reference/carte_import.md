# Importer un fichier geographique

Importe un fichier geographique externe (shapefile, GeoJSON, GeoPackage)
fourni par l'utilisateur ou l'INS.

## Usage

``` r
carte_import(chemin, crs = 4326L, couche = NULL, simplifier = FALSE)
```

## Arguments

- chemin:

  character – Chemin vers le fichier (.shp, .geojson, .gpkg)

- crs:

  integer – Code EPSG cible. Defaut : 4326 (WGS 84)

- couche:

  character ou NULL – Couche GeoPackage. Defaut : NULL

- simplifier:

  logical – Simplifier la geometrie. Defaut : FALSE

## Value

Un objet `sf`

## Examples

``` r
if (FALSE) { # \dontrun{
  regions <- carte_import("data/regions_enquete.shp")
} # }
```
