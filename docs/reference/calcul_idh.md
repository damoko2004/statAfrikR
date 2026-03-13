# Calculer l'Indice de Développement Humain (IDH)

Calcule l'IDH et ses trois dimensions (santé, éducation, revenu) selon
la méthodologie officielle PNUD post-2010. Applicable au niveau national
ou infranational.

## Utilisation

``` r
calcul_idh(
  esperance_vie,
  annees_scol_moy,
  annees_scol_att,
  rnb_habitant,
  niveau = c("national", "infranational"),
  annee = NULL
)
```

## Arguments

- esperance_vie:

  numeric — Espérance de vie à la naissance (années)

- annees_scol_moy:

  numeric — Durée moyenne de scolarisation (années)

- annees_scol_att:

  numeric — Durée attendue de scolarisation (années)

- rnb_habitant:

  numeric — RNB par habitant en PPA (USD constants 2017)

- niveau:

  character — `"national"` ou `"infranational"`. Défaut : "national".

- annee:

  integer ou NULL — Année de référence. Défaut : NULL.

## Valeur de retour

Une liste avec : `idh`, `indice_sante`, `indice_education`,
`indice_revenu`, `categorie`.

## Références

PNUD (2023). Technical Notes: Calculating the Human Development Indices.

## Exemples

``` r
if (FALSE) { # \dontrun{
  idh <- calcul_idh(
    esperance_vie   = 61.2,
    annees_scol_moy = 5.4,
    annees_scol_att = 9.8,
    rnb_habitant    = 2350,
    annee           = 2023
  )
  cat("IDH :", idh$idh, "—", idh$categorie)
} # }
```
