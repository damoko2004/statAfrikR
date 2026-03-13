# Thème ggplot2 officiel INS

Applique un thème graphique professionnel adapté aux publications
officielles des Instituts Nationaux de Statistique africains. Inspiré
des chartes graphiques AFRISTAT/PARIS21.

## Utilisation

``` r
theme_ins(
  base_size = 11,
  base_family = "sans",
  couleur_fond = "white",
  grille = TRUE,
  grille_mineure = FALSE
)
```

## Arguments

- base_size:

  numeric — Taille de base de la police. Défaut : 11.

- base_family:

  character — Famille de police. Défaut : "sans".

- couleur_fond:

  character — Couleur de fond du panneau. Défaut : "white".

- grille:

  logical — Afficher les lignes de grille. Défaut : TRUE.

- grille_mineure:

  logical — Afficher la grille mineure. Défaut : FALSE.

## Valeur de retour

Un objet `theme` ggplot2.

## Exemples

``` r
if (FALSE) { # \dontrun{
  library(ggplot2)
  ggplot(mtcars, aes(wt, mpg)) +
    geom_point() +
    theme_ins()
} # }
```
