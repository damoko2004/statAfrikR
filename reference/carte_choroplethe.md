# Carte choroplethe statistique institutionnelle

Produit une carte choroplethe professionnelle. Utilise uniquement
ggplot2 (deja installe avec statAfrikR) et sf. Gestion automatique des
labels pour les petits pays.

## Usage

``` r
carte_choroplethe(
  sf_obj,
  var,
  titre = NULL,
  sous_titre = NULL,
  legende = NULL,
  palette = c("pauvrete", "developpement", "eau", "neutre"),
  n_classes = 5L,
  methode = c("quantile", "jenks", "egal", "sd"),
  col_label = NULL,
  inverser = FALSE,
  source = NULL
)
```

## Arguments

- sf_obj:

  sf – Objet sf enrichi (depuis
  [`carte_joindre()`](https://damoko2004.github.io/statAfrikR/reference/carte_joindre.md))

- var:

  character – Variable numerique a cartographier

- titre:

  character ou NULL – Titre. Defaut : NULL

- sous_titre:

  character ou NULL – Sous-titre. Defaut : NULL

- legende:

  character ou NULL – Titre de la legende. Defaut : NULL

- palette:

  character – Palette : `"pauvrete"` (jaune-rouge), `"developpement"`
  (rouge-vert), `"eau"` (bleu clair-fonce), `"neutre"` (gris-bleu).
  Defaut : "pauvrete"

- n_classes:

  integer – Nombre de classes (2-9). Defaut : 5L

- methode:

  character – Discretisation : `"quantile"`, `"jenks"`, `"egal"`,
  `"sd"`. Defaut : "quantile"

- col_label:

  character ou NULL – Variable a afficher comme label sur chaque zone.
  Defaut : NULL

- inverser:

  logical – Inverser la palette. Defaut : FALSE

- source:

  character ou NULL – Note de source. Defaut : NULL

## Value

Un objet `ggplot2`

## Examples

``` r
rca <- carte_zones("rca")
n <- nrow(rca)
stats <- data.frame(
  prefecture    = rca$prefecture,
  taux_pauvrete = c(74.2, 71.8, 68.5, 65.3, 72.1,
                    55.4, 48.7, 51.2, 62.3, 58.9,
                    28.4, 42.1, 52.8, 63.7, 59.4,
                    44.6, 70.5)[seq_len(n)]
)
sf_enr <- carte_joindre(rca, stats, "prefecture", "prefecture")
#> Jointure : 17/17 zones appariees (100%)
carte_choroplethe(sf_enr, "taux_pauvrete",
                  titre = "Pauvrete en RCA",
                  source = "Donnees simulees")

```
