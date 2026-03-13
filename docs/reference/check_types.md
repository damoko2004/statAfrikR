# Vérifier les types de variables

Vérifie la cohérence des types de variables par rapport aux types
attendus. Détecte les problèmes courants : dates stockées en caractères,
nombres stockés en texte, variables binaires incohérentes.

## Utilisation

``` r
check_types(data, dictionnaire = NULL)
```

## Arguments

- data:

  data.frame ou tibble — Données à vérifier

- dictionnaire:

  data.frame ou NULL — Dictionnaire avec colonnes `nom_variable` et
  `type_attendu`. Si NULL, détection automatique des problèmes courants.
  Défaut : NULL.

## Valeur de retour

Un tibble avec les anomalies détectées : `variable`, `type_actuel`,
`type_attendu`, `probleme`.

## Exemples

``` r
if (FALSE) { # \dontrun{
  anomalies <- check_types(donnees_enquete)
} # }
```
