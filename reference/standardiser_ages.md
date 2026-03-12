# Standardiser les âges déclarés

Détecte et corrige le "heap effect" (attraction vers les âges ronds)
fréquent dans les enquêtes africaines où les âges sont déclarés. Calcule
l'indice de Whipple et l'indice de Myers pour évaluer la qualité.

## Usage

``` r
standardiser_ages(
  data,
  var_age = "age",
  methode = c("aucune", "interpolation", "united_nations"),
  age_min = 0L,
  age_max = 120L
)
```

## Arguments

- data:

  data.frame ou tibble — Données

- var_age:

  character — Nom de la variable d'âge

- methode:

  character — Méthode de correction : `"aucune"` (diagnostic
  uniquement), `"interpolation"` (répartition uniforme autour des âges
  ronds), `"united_nations"` (méthode Nations Unies). Défaut : "aucune".

- age_min:

  integer — Âge minimum valide. Défaut : 0.

- age_max:

  integer — Âge maximum valide. Défaut : 120.

## Value

Une liste avec :

- donnees:

  tibble avec âges corrigés si methode != "aucune"

- indice_whipple:

  numeric — Indice de Whipple (1 = parfait, \> 1.05 = problème)

- indice_myers:

  numeric — Indice de Myers (0 = parfait)

- diagnostic:

  character — Évaluation de la qualité

## Examples

``` r
if (FALSE) { # \dontrun{
  resultat <- standardiser_ages(donnees_rgph, "age")
  cat("Indice de Whipple :", resultat$indice_whipple)
} # }
```
