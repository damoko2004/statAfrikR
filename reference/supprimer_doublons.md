# Détecter et supprimer les doublons

Identifie et supprime les enregistrements dupliqués selon une ou
plusieurs clés d'identification. Produit un rapport des doublons
détectés.

## Usage

``` r
supprimer_doublons(
  data,
  cles = NULL,
  garder = c("premier", "dernier", "aucun"),
  rapport = TRUE
)
```

## Arguments

- data:

  data.frame ou tibble — Données à dédupliquer

- cles:

  character ou NULL — Variables clés pour la détection. Si NULL, utilise
  toutes les colonnes. Défaut : NULL.

- garder:

  character — Quel doublon conserver : `"premier"` (première
  occurrence), `"dernier"` (dernière occurrence), `"aucun"` (supprimer
  tous les doublons). Défaut : "premier".

- rapport:

  logical — Retourner un rapport des doublons. Défaut : TRUE.

## Value

Si `rapport = FALSE` : tibble dédupliqué. Si `rapport = TRUE` : liste
avec `$donnees` et `$rapport`.

## Examples

``` r
# \donttest{
  donnees <- data.frame(id=c(1,2,2,3), val=c(10,20,20,30))
  supprimer_doublons(donnees, cles="id")
#> 1 doublon(s) supprimé(s) sur 4 enregistrements (3 conservés).
#> $donnees
#>   id val
#> 1  1  10
#> 2  2  20
#> 3  3  30
#> 
#> $rapport
#>   id val
#> 2  2  20
#> 3  2  20
#> 
# }
```
