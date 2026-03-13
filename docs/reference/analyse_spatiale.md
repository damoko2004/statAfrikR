# Analyse spatiale — jointure et indicateurs par zone

Joint un jeu de données statistiques avec un shapefile géographique et
calcule des indicateurs par aire géographique. Produit un objet sf
enrichi prêt pour la cartographie.

## Utilisation

``` r
analyse_spatiale(
  data,
  shapefile,
  var_geo_data,
  var_geo_shape,
  indicateurs = NULL,
  fonctions = list(moyenne = function(x) mean(x, na.rm = TRUE), n = function(x)
    sum(!is.na(x)))
)
```

## Arguments

- data:

  data.frame ou tibble — Données avec variable géographique

- shapefile:

  sf ou character — Objet sf ou chemin vers un fichier shapefile (.shp,
  .gpkg, .geojson)

- var_geo_data:

  character — Variable géographique dans `data`

- var_geo_shape:

  character — Variable géographique dans le shapefile

- indicateurs:

  character ou NULL — Variables à agréger par zone. Si NULL, toutes les
  variables numériques. Défaut : NULL.

- fonctions:

  list — Fonctions d'agrégation nommées. Défaut :
  `list(moyenne = mean, n = length)`.

## Valeur de retour

Un objet `sf` avec les indicateurs calculés par zone.

## Exemples

``` r
if (FALSE) { # \dontrun{
  carte <- analyse_spatiale(
    data          = donnees_enquete,
    shapefile     = "data/shapefiles/regions.shp",
    var_geo_data  = "region",
    var_geo_shape = "NOM_REGION",
    indicateurs   = c("taux_pauvrete", "revenu_moyen")
  )
} # }
```
