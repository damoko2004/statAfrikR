# Tracer le flux de traitement

Crée et maintient un journal horodaté des transformations appliquées à
un dataset. Permet l'auditabilité complète du pipeline de traitement des
données.

## Usage

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

## Value

Une liste mise à jour avec `$donnees` et `$journal`.

## Examples

``` r
# \donttest{
  donnees <- data.frame(id=1:3, val=c(10,20,30))
  e1 <- tracer_flux_traitement(donnees, action="Import")
#> [2026-05-29 14:00:28] Import (3 lignes x 2 colonnes)
  e2 <- tracer_flux_traitement(e1$donnees, action="Nettoyage", journal=e1$journal)
#> [2026-05-29 14:00:28] Nettoyage (3 lignes x 2 colonnes)
  print(e2$journal)
#> # A tibble: 2 × 5
#>   horodatage          action    n_lignes n_colonnes details
#>   <chr>               <chr>        <int>      <int> <chr>  
#> 1 2026-05-29 14:00:28 Import           3          2 NA     
#> 2 2026-05-29 14:00:28 Nettoyage        3          2 NA     
# }
```
