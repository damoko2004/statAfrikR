# Palette de couleurs INS

Retourne une palette de couleurs officielle pour les graphiques INS,
compatible daltonisme.

## Usage

``` r
palette_ins(n = 6, type = c("categoriel", "sequentiel", "divergent"))
```

## Arguments

- n:

  integer — Nombre de couleurs souhaité. Défaut : 6.

- type:

  character — `"categoriel"`, `"sequentiel"`, `"divergent"`. Défaut :
  "categoriel".

## Value

Vecteur de codes couleurs hexadécimaux.

## Examples

``` r
if (FALSE) { # \dontrun{
  couleurs <- palette_ins(4)
} # }
```
