# Joindre des donnees statistiques a un fond de carte

Joint un objet sf avec un data.frame statistique. Normalise
automatiquement les cles pour eviter les erreurs de correspondance dues
aux accents, casses et espaces.

## Usage

``` r
carte_joindre(
  sf_obj,
  data,
  cle_geo,
  cle_data = NULL,
  type = c("gauche", "interne"),
  normaliser = TRUE
)
```

## Arguments

- sf_obj:

  sf – Objet geographique (depuis
  [`carte_zones()`](https://damoko2004.github.io/statAfrikR/reference/carte_zones.md)
  ou
  [`carte_import()`](https://damoko2004.github.io/statAfrikR/reference/carte_import.md))

- data:

  data.frame – Donnees statistiques

- cle_geo:

  character – Variable cle dans `sf_obj`

- cle_data:

  character – Variable cle dans `data`. Si NULL, utilise `cle_geo`.
  Defaut : NULL

- type:

  character – `"gauche"` (toutes zones conservees) ou `"interne"` (zones
  appariees uniquement). Defaut : "gauche"

- normaliser:

  logical – Normaliser les cles (recommande). Defaut : TRUE

## Value

Un objet `sf` enrichi

## Examples

``` r
# Avec les fonds de cartes integres
rca <- carte_zones("rca")
stats <- data.frame(
  prefecture    = rca$prefecture,
  taux_pauvrete = c(74.2, 71.8, 68.5, 65.3, 72.1,
                    55.4, 48.7, 51.2, 62.3, 58.9,
                    28.4, 42.1, 52.8, 63.7, 59.4,
                    44.6, 70.5)[seq_len(nrow(rca))]
)
sf_enrichi <- carte_joindre(rca, stats,
                             cle_geo  = "prefecture",
                             cle_data = "prefecture")
#> Jointure : 17/17 zones appariees (100%)
```
