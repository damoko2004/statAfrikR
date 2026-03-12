# Analyse de régression

Ajuste un modèle de régression linéaire, logistique ou de Poisson avec
prise en compte optionnelle du plan de sondage complexe. Produit un
tableau de résultats formaté avec OR/RR si approprié.

## Usage

``` r
analyse_regression(
  formule,
  data,
  type = c("lineaire", "logistique", "poisson"),
  niveau_confiance = 0.95,
  format_sortie = c("tibble", "liste", "flextable")
)
```

## Arguments

- formule:

  formula — Formule du modèle (ex: `revenu ~ age + sexe`)

- data:

  data.frame, tibble ou objet `svydesign` — Données

- type:

  character — Type de modèle : `"lineaire"`, `"logistique"`,
  `"poisson"`. Défaut : "lineaire".

- niveau_confiance:

  numeric — Niveau de confiance pour les IC. Défaut : 0.95.

- format_sortie:

  character — `"liste"`, `"tibble"` ou `"flextable"`. Défaut : "tibble".

## Value

Selon format_sortie : liste complète, tibble ou flextable des
coefficients avec IC et p-valeurs.

## Examples

``` r
if (FALSE) { # \dontrun{
  # Régression linéaire simple
  analyse_regression(revenu ~ age + sexe, donnees)
  # Régression logistique avec plan de sondage
  analyse_regression(pauvre ~ age + region + sexe, plan,
                     type = "logistique")
} # }
```
