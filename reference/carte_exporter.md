# Exporter une carte en fichier image

Exporte un objet ggplot2 en PNG, PDF ou SVG.

## Usage

``` r
carte_exporter(carte, chemin, largeur = 20, hauteur = 15, resolution = 300L)
```

## Arguments

- carte:

  ggplot – Objet ggplot2

- chemin:

  character – Chemin de sortie (.png, .pdf, .svg)

- largeur:

  numeric – Largeur en cm. Defaut : 20

- hauteur:

  numeric – Hauteur en cm. Defaut : 15

- resolution:

  integer – Resolution DPI (PNG). Defaut : 300L

## Value

Chemin du fichier (invisible)

## Examples

``` r
if (FALSE) { # \dontrun{
  g <- carte_choroplethe(sf_enrichi, "taux_pauvrete")
  carte_exporter(g, file.path(tempdir(), "carte.png"))
} # }
```
