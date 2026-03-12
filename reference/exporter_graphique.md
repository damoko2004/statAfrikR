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
if (FALSE) { # \dontrun{
  p <- pyramide_ages(donnees_rgph, "age", "sexe")
  exporter_graphique(p, "outputs/pyramide_ages_2023.png")
} # }
```
