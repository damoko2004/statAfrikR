# Anonymiser un jeu de données

Applique les techniques d'anonymisation conformes aux standards
IHSN/PARIS21 : suppression, masquage, generalisation, perturbation et
pseudonymisation des variables sensibles.

## Usage

``` r
anonymiser_donnees(
  data,
  vars_supprimer = NULL,
  vars_masquer = NULL,
  vars_perturber = NULL,
  vars_generaliser = NULL,
  niveau_bruit = 0.05,
  graine = 42L,
  rapport = TRUE
)
```

## Arguments

- data:

  data.frame ou tibble — Données à anonymiser

- vars_supprimer:

  character ou NULL — Variables à supprimer entièrement. Défaut : NULL.

- vars_masquer:

  character ou NULL — Variables à remplacer par des codes anonymes.
  Défaut : NULL.

- vars_perturber:

  character ou NULL — Variables numériques à perturber par bruit
  aléatoire. Défaut : NULL.

- vars_generaliser:

  list ou NULL — Liste nommée de variables à généraliser avec les bornes
  : `list(age = 5, revenu = 10000)`. Défaut : NULL.

- niveau_bruit:

  numeric — Niveau de bruit pour la perturbation (proportion de
  l'écart-type). Défaut : 0.05.

- graine:

  integer — Graine aléatoire. Défaut : 42.

- rapport:

  logical — Produire un rapport d'anonymisation. Défaut : TRUE.

## Value

Si `rapport = FALSE` : tibble anonymisé. Si `rapport = TRUE` : liste
avec `$donnees` et `$rapport`.

## Examples

``` r
if (FALSE) { # \dontrun{
  resultat <- anonymiser_donnees(
    donnees_enquete,
    vars_supprimer  = c("nom", "prenom", "telephone"),
    vars_masquer    = c("id_menage", "id_individu"),
    vars_perturber  = c("revenu_mensuel"),
    vars_generaliser = list(age = 5)
  )
  donnees_anon <- resultat$donnees
} # }
```
