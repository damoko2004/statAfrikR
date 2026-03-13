# Décomposer les inégalités

Calcule les mesures d'inégalité (Gini, Theil, Atkinson) et leur
décomposition inter/intra-groupe pour une variable de revenu ou de
dépense.

## Utilisation

``` r
decomposer_inegalite(
  data,
  var_revenu,
  var_groupe = NULL,
  var_poids = NULL,
  mesures = c("all", "gini", "theil", "atkinson")
)
```

## Arguments

- data:

  data.frame ou tibble — Données

- var_revenu:

  character — Variable de revenu/dépense (strictement positive)

- var_groupe:

  character ou NULL — Variable de groupe pour la décomposition. Défaut :
  NULL.

- var_poids:

  character ou NULL — Variable de pondération. Défaut : NULL.

- mesures:

  character — Mesures à calculer : `"gini"`, `"theil"`, `"atkinson"`,
  `"all"`. Défaut : "all".

## Valeur de retour

Une liste avec les mesures d'inégalité et leur décomposition.

## Exemples

``` r
if (FALSE) { # \dontrun{
  inegalites <- decomposer_inegalite(
    donnees_menages,
    var_revenu = "depense_totale",
    var_groupe = "milieu"
  )
} # }
```
