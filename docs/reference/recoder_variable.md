# Recoder une variable

Recode une variable selon une table de correspondance explicite.
Supporte le recodage numérique (classes d'âge, quintiles) et textuel
(modalités). Traçabilité complète des transformations.

## Utilisation

``` r
recoder_variable(
  data,
  var,
  table_recodage,
  var_sortie = NULL,
  na_si_absent = TRUE
)
```

## Arguments

- data:

  data.frame ou tibble — Données

- var:

  character — Nom de la variable à recoder

- table_recodage:

  data.frame — Table avec colonnes `avant` et `apres`, ou vecteur nommé.

- var_sortie:

  character ou NULL — Nom de la variable recodée. Si NULL, remplace la
  variable originale. Défaut : NULL.

- na_si_absent:

  logical — Mettre NA si la valeur n'est pas dans la table de recodage.
  Défaut : TRUE.

## Valeur de retour

Le tibble avec la variable recodée.

## Exemples

``` r
if (FALSE) { # \dontrun{
  # Recodage des classes d'âge
  table_age <- data.frame(
    avant = c("15-24", "25-34", "35-49", "50+"),
    apres = c("Jeune", "Adulte", "Adulte", "Senior")
  )
  donnees <- recoder_variable(donnees, "classe_age", table_age)
  # Recodage avec vecteur nommé
  donnees <- recoder_variable(
    donnees, "sexe",
    table_recodage = c("1" = "Masculin", "2" = "Féminin")
  )
} # }
```
