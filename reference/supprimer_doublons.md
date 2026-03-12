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
if (FALSE) { # \dontrun{
  resultat <- supprimer_doublons(donnees_enquete, cles = "id_menage")
  donnees_propres <- resultat$donnees
  cat("Doublons supprimés :", nrow(resultat$rapport))
} # }
```
