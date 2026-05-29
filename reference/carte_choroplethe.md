# Carte choroplethe institutionnelle

Produit une carte choroplethe a partir d'un objet sf, avec choix de la
methode de discretisation et de la palette. Retourne un objet ggplot2
pret a l'emploi.

## Usage

``` r
carte_choroplethe(
  sf_obj,
  var,
  titre = NULL,
  sous_titre = NULL,
  legende = NULL,
  palette = "Blues",
  n_classes = 5L,
  methode = c("quantile", "jenks", "egal", "sd"),
  inverser = FALSE,
  fond = "#EEF4F8",
  na_couleur = "#D9E4EC",
  source = NULL
)
```

## Arguments

- sf_obj:

  sf – Objet geographique enrichi (resultat de
  [`carte_joindre()`](https://damoko2004.github.io/statAfrikR/reference/carte_joindre.md)
  ou tout objet sf avec attributs statistiques)

- var:

  character – Nom de la variable numerique a cartographier

- titre:

  character ou NULL – Titre de la carte. Defaut : NULL

- sous_titre:

  character ou NULL – Sous-titre. Defaut : NULL

- legende:

  character ou NULL – Titre de la legende. Defaut : NULL

- palette:

  character – Palette de couleur ColorBrewer : `"Blues"`, `"Reds"`,
  `"YlOrRd"`, `"YlGnBu"`, `"RdYlGn"` (divergente). Defaut : "Blues"

- n_classes:

  integer – Nombre de classes (3 a 9). Defaut : 5L

- methode:

  character – Methode de discretisation : `"quantile"`, `"jenks"`,
  `"egal"`, `"sd"`. Defaut : "quantile"

- inverser:

  logical – Inverser la palette. Defaut : FALSE

- fond:

  character – Couleur de fond de la carte. Defaut : `"#EEF4F8"`

- na_couleur:

  character – Couleur des zones sans donnees. Defaut : `"#D9E4EC"`

- source:

  character ou NULL – Note de source. Defaut : NULL

## Value

Un objet `ggplot2`

## Examples

``` r
if (FALSE) { # \dontrun{
  sf_enrichi <- carte_joindre(regions_sf, stats_pauvrete,
                              cle_geo = "NOM_REGION",
                              cle_data = "region")
  carte_choroplethe(sf_enrichi, var = "taux_pauvrete",
                    titre = "Taux de pauvrete par region",
                    methode = "quantile")
} # }
```
