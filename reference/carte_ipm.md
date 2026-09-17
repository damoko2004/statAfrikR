# Carte des privations IPM par zone

Cartographie l'IPM ou une composante (H, A, ou un indicateur de
privation) par zone geographique. Necessite un objet sf et les resultats
de decomposer_ipm().

## Usage

``` r
carte_ipm(
  decomp_ipm,
  sf_obj,
  cle_sf,
  cle_decomp,
  var = c("IPM", "H", "A"),
  titre = NULL,
  source = NULL
)
```

## Arguments

- decomp_ipm:

  tibble – Resultat de
  [`decomposer_ipm()`](https://damoko2004.github.io/statAfrikR/reference/decomposer_ipm.md)

- sf_obj:

  sf – Fond de carte (depuis
  [`carte_zones()`](https://damoko2004.github.io/statAfrikR/reference/carte_zones.md))

- cle_sf:

  character – Variable cle dans `sf_obj`

- cle_decomp:

  character – Variable cle dans `decomp_ipm`

- var:

  character – Variable a cartographier : `"IPM"`, `"H"` ou `"A"`. Defaut
  : "IPM"

- titre:

  character ou NULL – Titre. Defaut : NULL

- source:

  character ou NULL – Source. Defaut : NULL

## Value

Un objet `ggplot2`

## Examples

``` r
if (FALSE) { # \dontrun{
  rca <- carte_zones("rca")
  res <- calcul_ipm(menages_rca, ...)
  decomp <- decomposer_ipm(res, menages_rca, "prefecture")
  carte_ipm(decomp, rca, cle_sf="prefecture",
            cle_decomp="prefecture")
} # }
```
