# Tracer le flux de traitement

Crée et maintient un journal horodaté des transformations appliquées à
un dataset. Permet l'auditabilité complète du pipeline de traitement des
données.

## Utilisation

``` r
tracer_flux_traitement(data, action, journal = NULL, details = NULL)
```

## Arguments

- data:

  data.frame ou tibble — Données traitées

- action:

  character — Description de l'action effectuée

- journal:

  list ou NULL — Journal existant à compléter. Si NULL, crée un nouveau
  journal. Défaut : NULL.

- details:

  list ou NULL — Détails supplémentaires à enregistrer (ex: paramètres
  utilisés). Défaut : NULL.

## Valeur de retour

Une liste mise à jour avec `$donnees` et `$journal`.

## Exemples

``` r
if (FALSE) { # \dontrun{
  donnees <- data.frame(id=1:3, val=c(10,20,30))
  e1 <- tracer_flux_traitement(donnees, action="Import")
  e2 <- tracer_flux_traitement(e1$donnees, action="Nettoyage", journal=e1$journal)
  print(e2$journal)
} # }
```
