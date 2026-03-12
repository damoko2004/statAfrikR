# Graphique de tendance temporelle

Génère un graphique de tendance pour un ou plusieurs indicateurs sur une
période temporelle. Adapté au suivi des indicateurs ODD et des
indicateurs macroéconomiques.

## Usage

``` r
graphique_tendance(
  data,
  var_temps,
  var_valeur = NULL,
  var_indicateur = NULL,
  vars_indicateurs = NULL,
  titre = NULL,
  label_y = "Valeur",
  afficher_points = TRUE,
  afficher_valeurs = FALSE,
  lisser = FALSE
)
```

## Arguments

- data:

  data.frame ou tibble — Données en format long ou large

- var_temps:

  character — Variable temporelle (année, trimestre...)

- var_valeur:

  character — Variable de valeur (format long) ou NULL si format large.
  Défaut : NULL.

- var_indicateur:

  character ou NULL — Variable d'indicateur (format long). Défaut :
  NULL.

- vars_indicateurs:

  character ou NULL — Vecteur de colonnes à tracer (format large).
  Défaut : NULL.

- titre:

  character ou NULL — Titre. Défaut : NULL.

- label_y:

  character — Label axe Y. Défaut : "Valeur".

- afficher_points:

  logical — Afficher les points. Défaut : TRUE.

- afficher_valeurs:

  logical — Annoter les valeurs. Défaut : FALSE.

- lisser:

  logical — Ajouter une courbe lissée (loess). Défaut : FALSE.

## Value

Un objet `ggplot`.

## Examples

``` r
if (FALSE) { # \dontrun{
  graphique_tendance(
    data            = evolution_pib,
    var_temps       = "annee",
    vars_indicateurs = c("pib_reel", "pib_nominal"),
    titre           = "Évolution du PIB 2000-2023"
  )
} # }
```
