# Carte thématique choroplèthe

Génère une carte choroplèthe à partir d'un objet sf enrichi ou de la
jointure d'un shapefile avec des données statistiques.

## Usage

``` r
carte_thematique(
  data_sf = NULL,
  shapefile = NULL,
  data = NULL,
  var_geo_shape = NULL,
  var_geo_data = NULL,
  var_couleur,
  titre = NULL,
  sous_titre = NULL,
  source = NULL,
  palette = c("sequentiel", "divergent"),
  n_classes = 5L,
  na_couleur = "#cccccc"
)
```

## Arguments

- data_sf:

  sf ou NULL — Objet sf avec données. Si NULL, utilise `shapefile` +
  `data`. Défaut : NULL.

- shapefile:

  sf ou character ou NULL — Shapefile si `data_sf` est NULL. Défaut :
  NULL.

- data:

  data.frame ou NULL — Données à joindre si `data_sf` est NULL. Défaut :
  NULL.

- var_geo_shape:

  character ou NULL — Variable clé dans le shapefile. Défaut : NULL.

- var_geo_data:

  character ou NULL — Variable clé dans les données. Défaut : NULL.

- var_couleur:

  character — Variable à représenter par la couleur

- titre:

  character ou NULL — Titre de la carte. Défaut : NULL.

- sous_titre:

  character ou NULL — Sous-titre. Défaut : NULL.

- source:

  character ou NULL — Source des données. Défaut : NULL.

- palette:

  character — Palette de couleurs : `"sequentiel"`, `"divergent"`.
  Défaut : "sequentiel".

- n_classes:

  integer — Nombre de classes. Défaut : 5.

- na_couleur:

  character — Couleur pour les NA. Défaut : "#cccccc".

## Value

Un objet `ggplot`.

## Examples

``` r
if (FALSE) { # \dontrun{
  carte_thematique(
    data_sf      = regions_sf_enrichi,
    var_couleur  = "taux_pauvrete_moyenne",
    titre        = "Taux de pauvreté par région"
  )
} # }
```
