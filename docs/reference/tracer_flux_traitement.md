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
  # Initialiser le journal
  etape1 <- tracer_flux_traitement(
    data    = donnees_brutes,
    action  = "Import depuis fichier Excel"
  )
  # Ajouter une étape
  etape2 <- tracer_flux_traitement(
    data    = donnees_nettoyees,
    action  = "Nettoyage des libellés",
    journal = etape1$journal
  )
  # Afficher le journal
  print(etape2$journal)
} # }
```
