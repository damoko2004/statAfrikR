# Carte thematique de la pauvrete (FGT0)

Specialisation de
[`carte_choroplethe()`](https://damoko2004.github.io/statAfrikR/reference/carte_choroplethe.md)
pour les indices de pauvrete. Symbologie standardisee AFRISTAT/Banque
mondiale avec seuil d'alerte.

## Usage

``` r
carte_pauvrete(
  sf_obj,
  var_fgt0,
  seuil_alerte = 0.5,
  col_label = NULL,
  titre = NULL,
  source = NULL
)
```

## Arguments

- sf_obj:

  sf – Objet sf avec taux de pauvrete

- var_fgt0:

  character – Variable de taux de pauvrete

- seuil_alerte:

  numeric – Seuil d'alerte. Defaut : 0.5

- col_label:

  character ou NULL – Variable de label. Defaut : NULL

- titre:

  character ou NULL – Titre. Defaut : titre automatique

- source:

  character ou NULL – Source. Defaut : NULL

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
sf_enr$taux_prop <- sf_enr$taux_pauvrete / 100
carte_pauvrete(sf_enr, var_fgt0 = "taux_prop",
               source = "Donnees simulees")
#> Coordinate system already present.
#> ℹ Adding new coordinate system, which will replace the existing one.

```
