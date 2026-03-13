# Graphique en barres pondéré

Génère un graphique en barres avec intervalles de confiance optionnels,
adapté aux résultats d'enquêtes pondérées.

## Utilisation

``` r
graphique_barres(
  data,
  var_x,
  var_y,
  var_groupe = NULL,
  var_ic_bas = NULL,
  var_ic_haut = NULL,
  position = c("dodge", "stack"),
  titre = NULL,
  label_x = NULL,
  label_y = NULL,
  pourcentage = FALSE,
  trier = FALSE
)
```

## Arguments

- data:

  data.frame, tibble ou résultat de
  [`tab_croisee()`](https://damoko2004.github.io/statAfrikR/reference/tab_croisee.md)
  — Données source

- var_x:

  character — Variable en abscisse (catégories)

- var_y:

  character — Variable en ordonnée (valeurs)

- var_groupe:

  character ou NULL — Variable de regroupement (barres groupées). Défaut
  : NULL.

- var_ic_bas:

  character ou NULL — Variable borne inférieure IC. Défaut : NULL.

- var_ic_haut:

  character ou NULL — Variable borne supérieure IC. Défaut : NULL.

- position:

  character — `"dodge"` (groupé) ou `"stack"` (empilé). Défaut :
  "dodge".

- titre:

  character ou NULL — Titre. Défaut : NULL.

- label_x:

  character ou NULL — Label axe X. Défaut : NULL.

- label_y:

  character ou NULL — Label axe Y. Défaut : NULL.

- pourcentage:

  logical — Formater l'axe Y en pourcentage. Défaut : FALSE.

- trier:

  logical — Trier les barres par valeur décroissante. Défaut : FALSE.

## Valeur de retour

Un objet `ggplot`.

## Exemples

``` r
if (FALSE) { # \dontrun{
  resultats <- tab_croisee(donnees, "region", format_sortie = "tibble")
  graphique_barres(
    resultats,
    var_x   = "region",
    var_y   = "pourcentage",
    titre   = "Répartition par région"
  )
} # }
```
