# Lister les templates de rapport disponibles

Retourne la liste des templates R Markdown disponibles dans statAfrikR
avec leur description et parametres.

## Usage

``` r
lister_templates()
```

## Value

Un tibble avec : nom, description, parametres, format_sortie

## Examples

``` r
lister_templates()
#> # A tibble: 3 × 4
#>   nom            description                                    fonction formats
#>   <chr>          <chr>                                          <chr>    <chr>  
#> 1 enquete_menage Rapport complet d'enquete menage : page de ga… generer… html, …
#> 2 bulletin       Bulletin statistique periodique : tableau de … generer… html, …
#> 3 rapport_odd    Rapport de suivi ODD : indicateurs SDG, cible… generer… html, …
```
