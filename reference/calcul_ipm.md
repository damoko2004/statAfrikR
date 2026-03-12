# Calculer l'Indice de Pauvreté Multidimensionnelle (IPM)

Calcule l'IPM selon la méthodologie OPHI/PNUD (Alkire-Foster). Supporte
les dimensions standard (santé, éducation, niveau de vie) et des
dimensions personnalisées.

## Usage

``` r
calcul_ipm(
  data,
  indicateurs,
  poids_dimensions = NULL,
  seuil_pauvrete = 1/3,
  var_poids = NULL
)
```

## Arguments

- data:

  data.frame ou tibble — Données individuelles ou ménages

- indicateurs:

  list — Liste nommée des indicateurs par dimension. Chaque élément est
  un vecteur de noms de variables (0/1 : 1 = privation). Ex:
  `list(sante = c("malnutrition", "mortalite_enfant"), ...)`

- poids_dimensions:

  numeric ou NULL — Poids de chaque dimension (doit sommer à 1). Si
  NULL, poids égaux. Défaut : NULL.

- seuil_pauvrete:

  numeric — Seuil de privation pour être considéré
  multidimensionnellement pauvre (entre 0 et 1). Défaut : 1/3.

- var_poids:

  character ou NULL — Variable de pondération. Défaut : NULL.

## Value

Une liste avec : `ipm`, `H` (incidence), `A` (intensité),
`contributions` par dimension, `donnees_enrichies`.

## References

Alkire, S. & Foster, J. (2011). Counting and multidimensional poverty
measurement. Journal of Public Economics, 95(7-8), 476-487.

## Examples

``` r
if (FALSE) { # \dontrun{
  indicateurs_ipm <- list(
    sante     = c("malnutrition", "mortalite_enfant"),
    education = c("annees_scolarisation", "enfants_scolarises"),
    niveau_vie = c("electricite", "eau_potable", "assainissement",
                   "combustible", "actifs", "logement")
  )
  resultat <- calcul_ipm(donnees_menages, indicateurs_ipm)
  cat("IPM :", resultat$ipm)
} # }
```
