# Appliquer les pondérations d'enquête

Crée un objet de plan de sondage complexe à partir d'un tibble et des
variables de pondération, strates et grappes. Enveloppe ergonomique
autour de
[`survey::svydesign()`](https://rdrr.io/pkg/survey/man/svydesign.html)
avec validation complète des poids et messages d'erreur en français.

## Utilisation

``` r
appliquer_ponderations(
  data,
  var_poids,
  var_strate = NULL,
  var_grappe = NULL,
  var_fpc = NULL,
  normaliser = FALSE
)
```

## Arguments

- data:

  data.frame ou tibble — Données de l'enquête

- var_poids:

  character — Nom de la variable de pondération finale

- var_strate:

  character ou NULL — Variable de stratification. Défaut : NULL.

- var_grappe:

  character ou NULL — Variable d'unité primaire de sondage
  (UPS/cluster). Défaut : NULL.

- var_fpc:

  character ou NULL — Variable de correction pour population finie
  (FPC). Défaut : NULL.

- normaliser:

  logical — Normaliser les poids pour que leur somme soit égale à
  l'effectif de l'échantillon. Défaut : FALSE.

## Valeur de retour

Un objet `svydesign` du package `survey`.

## Voir également

[`tab_croisee`](https://damoko2004.github.io/statAfrikR/reference/tab_croisee.md),
[`stat_descr`](https://damoko2004.github.io/statAfrikR/reference/stat_descr.md)

## Exemples

``` r
if (FALSE) { # \dontrun{
  plan <- appliquer_ponderations(
    data       = donnees_menages,
    var_poids  = "poids_final",
    var_strate = "strate",
    var_grappe = "grappe_id"
  )
} # }
```
