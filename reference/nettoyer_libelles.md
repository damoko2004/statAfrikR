# Nettoyer les libellés de variables textuelles

Normalise les chaînes de caractères : suppression des espaces superflus,
normalisation de la casse, gestion des caractères spéciaux, correction
des encodages. Préserve les caractères accentués africains et
francophones.

## Usage

``` r
nettoyer_libelles(
  data,
  vars = NULL,
  casse = c("titre", "majuscule", "minuscule", "aucune"),
  supprimer_espaces = TRUE,
  supprimer_ponctuation = FALSE,
  encodage = "UTF-8"
)
```

## Arguments

- data:

  data.frame ou tibble — Données à nettoyer

- vars:

  character ou NULL — Variables à nettoyer. Si NULL, toutes les
  variables de type character. Défaut : NULL.

- casse:

  character — Normalisation de la casse : `"titre"` (Première Lettre
  Majuscule), `"majuscule"`, `"minuscule"`, `"aucune"`. Défaut :
  "titre".

- supprimer_espaces:

  logical — Supprimer les espaces multiples et les espaces en début/fin.
  Défaut : TRUE.

- supprimer_ponctuation:

  logical — Supprimer la ponctuation superflue. Défaut : FALSE.

- encodage:

  character — Encodage cible. Défaut : "UTF-8".

## Value

Un tibble avec les variables textuelles nettoyées.

## Examples

``` r
if (FALSE) { # \dontrun{
  donnees_propres <- nettoyer_libelles(donnees_enquete)
  donnees_propres <- nettoyer_libelles(
    donnees_enquete,
    vars  = c("region", "commune"),
    casse = "majuscule"
  )
} # }
```
