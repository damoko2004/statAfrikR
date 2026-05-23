# Exporter un graphique en haute résolution

Exporte un objet ggplot en PNG, PDF ou SVG avec les paramètres optimaux
pour publication officielle.

## Usage

``` r
exporter_graphique(
  graphique,
  chemin,
  largeur = 20,
  hauteur = 14,
  dpi = 300L,
  fond = "white"
)
```

## Arguments

- graphique:

  ggplot — Objet graphique à exporter

- chemin:

  character — Chemin de sortie avec extension (.png, .pdf, .svg)

- largeur:

  numeric — Largeur en cm. Défaut : 20.

- hauteur:

  numeric — Hauteur en cm. Défaut : 14.

- dpi:

  integer — Résolution pour PNG (ignoré pour PDF/SVG). Défaut : 300.

- fond:

  character — Couleur de fond. Défaut : "white".

## Value

Chemin du fichier exporté (invisible).

## Examples

``` r
# \donttest{
  donnees <- data.frame(age=sample(0:80,100,replace=TRUE), sexe=sample(c("H","F"),100,replace=TRUE))
  p <- pyramide_ages(donnees, "age", "sexe")
  exporter_graphique(p, file.path(tempdir(), "pyramide.png"))
#> Warning: No shared levels found between `names(values)` of the manual scale and the
#> data's fill values.
#> Warning: No shared levels found between `names(values)` of the manual scale and the
#> data's fill values.
#> Graphique exporté : /tmp/RtmpzPOrs2/pyramide.png (78.4 Ko)
# }
```
