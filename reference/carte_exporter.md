# Exporter une carte

Exporte un objet ggplot2 (carte) en PNG, PDF ou SVG avec resolution et
dimensions optimisees pour les rapports INS.

## Usage

``` r
carte_exporter(carte, chemin, largeur = 20, hauteur = 15, resolution = 300L)
```

## Arguments

- carte:

  ggplot2 – Objet ggplot a exporter

- chemin:

  character – Chemin du fichier de sortie (extension determinant le
  format : .png, .pdf, .svg)

- largeur:

  numeric – Largeur en cm. Defaut : 20

- hauteur:

  numeric – Hauteur en cm. Defaut : 15

- resolution:

  integer – Resolution en DPI (PNG uniquement). Defaut : 300L

## Value

Chemin du fichier cree (invisible)

## Examples

``` r
if (FALSE) { # \dontrun{
  g <- carte_choroplethe(sf_enrichi, var = "taux_pauvrete")
  carte_exporter(g, file.path(tempdir(), "carte_pauvrete.png"))
} # }
```
