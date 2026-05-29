# Valider la cohérence données / dictionnaire

Vérifie que les variables d'un dataset correspondent au dictionnaire
fourni : présence des variables, types, plages de valeurs, modalités
attendues. Produit un rapport de validation structuré avec un score de
qualité global.

## Usage

``` r
valider_dictionnaire(data, dictionnaire, stopper_si_critique = FALSE)
```

## Arguments

- data:

  data.frame ou tibble — Données à valider

- dictionnaire:

  data.frame — Dictionnaire avec colonnes obligatoires : `nom_variable`,
  `type`. Colonnes optionnelles : `valeurs_valides`, `min`, `max`,
  `obligatoire`.

- stopper_si_critique:

  logical — Arrêter l'exécution si des erreurs critiques sont détectées.
  Défaut : FALSE.

## Value

Une liste avec :

- valide:

  logical — TRUE si aucune erreur critique

- rapport:

  data.frame — Détail des anomalies

- score_qualite:

  numeric — Score de 0 à 100

## Examples

``` r
if (FALSE) { # \dontrun{
  dico <- data.frame(
    nom_variable = c("age", "sexe", "region"),
    type         = c("numeric", "character", "character"),
    obligatoire  = c(TRUE, TRUE, FALSE)
  )
  resultat <- valider_dictionnaire(donnees, dico)
  if (!resultat$valide) print(resultat$rapport)
} # }
```
