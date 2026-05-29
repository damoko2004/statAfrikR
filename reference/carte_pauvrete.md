# Carte thematique de la pauvrete

Surcouche de
[`carte_choroplethe()`](https://damoko2004.github.io/statAfrikR/reference/carte_choroplethe.md)
specialisee pour la cartographie des indices de pauvrete (FGT0, FGT1,
FGT2). Utilise une symbologie standardisee AFRISTAT/Banque mondiale.

## Usage

``` r
carte_pauvrete(
  sf_obj,
  var_fgt0,
  seuil_alerte = 0.5,
  titre = NULL,
  source = NULL,
  afficher_valeurs = FALSE,
  var_label = NULL
)
```

## Arguments

- sf_obj:

  sf – Objet geographique enrichi avec les taux de pauvrete

- var_fgt0:

  character – Variable du taux de pauvrete (FGT0, en proportion ou
  pourcentage)

- seuil_alerte:

  numeric – Seuil d'alerte (zones en rouge). Defaut : 0.5 (50%)

- titre:

  character ou NULL – Titre. Defaut : titre automatique

- source:

  character ou NULL – Note source. Defaut : NULL

- afficher_valeurs:

  logical – Afficher les valeurs sur la carte. Defaut : FALSE

- var_label:

  character ou NULL – Variable a utiliser comme etiquette (nom de la
  zone). Defaut : NULL

## Value

Un objet `ggplot2`

## Examples

``` r
if (FALSE) { # \dontrun{
  carte_pauvrete(regions_enrichi,
                 var_fgt0 = "taux_pauvrete",
                 seuil_alerte = 0.5,
                 titre = "Incidence de la pauvrete par region 2026")
} # }
```
