# Imputer les valeurs manquantes

Impute les valeurs manquantes d'un dataset selon la méthode spécifiée.
Supporte l'imputation simple (statistiques descriptives), hot-deck et
par régression. Produit un rapport de traçabilité.

## Usage

``` r
imputer_valeurs(
  data,
  vars = NULL,
  methode = c("mediane", "moyenne", "mode", "hot_deck", "regression"),
  vars_auxiliaires = NULL,
  graine = 42L,
  rapport = TRUE
)
```

## Arguments

- data:

  data.frame ou tibble — Données avec valeurs manquantes

- vars:

  character ou NULL — Variables à imputer. Si NULL, toutes les variables
  avec valeurs manquantes. Défaut : NULL.

- methode:

  character — Méthode d'imputation : `"mediane"`, `"moyenne"`, `"mode"`,
  `"hot_deck"`, `"regression"`. Défaut : "mediane".

- vars_auxiliaires:

  character ou NULL — Variables auxiliaires pour l'imputation par
  régression ou hot-deck. Défaut : NULL.

- graine:

  integer — Graine aléatoire pour la reproductibilité. Défaut : 42.

- rapport:

  logical — Retourner un rapport d'imputation. Défaut : TRUE.

## Value

Si `rapport = FALSE` : tibble imputé. Si `rapport = TRUE` : liste avec
`$donnees` et `$rapport`.

## Examples

``` r
if (FALSE) { # \dontrun{
  resultat <- imputer_valeurs(
    data    = donnees_enquete,
    vars    = c("revenu_mensuel", "age"),
    methode = "mediane"
  )
  donnees_propres <- resultat$donnees
} # }
```
