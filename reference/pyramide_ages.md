# Pyramide des âges

Génère une pyramide des âges pondérée à partir de données individuelles
ou agrégées. Adapté aux recensements et enquêtes démographiques.

## Usage

``` r
pyramide_ages(
  data,
  var_age,
  var_sexe,
  var_poids = NULL,
  modalite_homme = "Masculin",
  modalite_femme = "Féminin",
  largeur_classe = 5L,
  age_max = 80L,
  titre = NULL,
  pourcentage = TRUE,
  couleur_homme = "#1B6CA8",
  couleur_femme = "#E8872A"
)
```

## Arguments

- data:

  data.frame ou tibble — Données individuelles

- var_age:

  character — Variable d'âge

- var_sexe:

  character — Variable de sexe/genre

- var_poids:

  character ou NULL — Variable de pondération. Défaut : NULL.

- modalite_homme:

  character — Modalité masculine. Défaut : "Masculin".

- modalite_femme:

  character — Modalité féminine. Défaut : "Féminin".

- largeur_classe:

  integer — Largeur des classes d'âge en années. Défaut : 5.

- age_max:

  integer — Âge maximum affiché. Défaut : 80.

- titre:

  character ou NULL — Titre du graphique. Défaut : NULL.

- pourcentage:

  logical — Afficher en pourcentage (TRUE) ou effectifs (FALSE). Défaut
  : TRUE.

- couleur_homme:

  character — Couleur hommes. Défaut : "#1B6CA8".

- couleur_femme:

  character — Couleur femmes. Défaut : "#E8872A".

## Value

Un objet `ggplot`.

## Examples

``` r
if (FALSE) { # \dontrun{
  pyramide_ages(
    donnees_rgph,
    var_age   = "age",
    var_sexe  = "sexe",
    var_poids = "poids",
    titre     = "Pyramide des âges — RGPH 2023"
  )
} # }
```
