# Fusionner plusieurs jeux de données

Fusionne plusieurs datasets horizontalement (jointure) ou verticalement
(empilement). Gère les conflits de noms de variables et produit un
rapport de fusion.

## Utilisation

``` r
fusion_datasets(
  liste_data,
  type = c("vertical", "horizontal"),
  cle = NULL,
  jointure = c("gauche", "interne", "droite", "complete"),
  suffixes = c("_1", "_2")
)
```

## Arguments

- liste_data:

  list — Liste nommée de data.frames/tibbles à fusionner

- type:

  character — Type de fusion : `"horizontal"` (jointure par clé),
  `"vertical"` (empilement / append). Défaut : "vertical".

- cle:

  character ou NULL — Variable(s) clé(s) pour la fusion horizontale.
  Obligatoire si `type = "horizontal"`. Défaut : NULL.

- jointure:

  character — Type de jointure horizontale : `"interne"`, `"gauche"`,
  `"droite"`, `"complete"`. Défaut : "gauche".

- suffixes:

  character — Suffixes pour les variables en conflit lors d'une fusion
  horizontale. Défaut : c("\_1", "\_2").

## Valeur de retour

Un tibble fusionné.

## Exemples

``` r
if (FALSE) { # \dontrun{
  # Empilement de deux vagues d'enquête
  donnees_total <- fusion_datasets(
    liste_data = list(vague1 = emop_2022, vague2 = emop_2023),
    type       = "vertical"
  )
  # Jointure ménages + individus
  donnees_merged <- fusion_datasets(
    liste_data = list(menages = df_menages, individus = df_individus),
    type       = "horizontal",
    cle        = "id_menage"
  )
} # }
```
