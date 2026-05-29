# Graphique des indices FGT

Visualise les indices FGT nationaux et/ou par sous-groupe.

## Usage

``` r
graphique_fgt(
  fgt_obj,
  type = c("barres", "indices"),
  variable = NULL,
  couleur = "#1B4965"
)
```

## Arguments

- fgt_obj:

  objet `saf_fgt` – Resultat de
  [`calcul_fgt()`](https://damoko2004.github.io/statAfrikR/reference/calcul_fgt.md)

- type:

  character – `"barres"` ou `"indices"`. Defaut : "barres"

- variable:

  character ou NULL – Variable de sous-groupe a representer

- couleur:

  character – Couleur principale. Defaut : `"#1B4965"`

## Value

Objet `ggplot2`

## Examples

``` r
if (FALSE) { # \dontrun{
  set.seed(42)
  menages <- data.frame(
    depense_pc = c(rexp(70, 1/150000), rexp(30, 1/400000)),
    poids  = runif(100, 0.8, 1.2),
    milieu = sample(c("urbain", "rural"), 100, TRUE, c(0.4, 0.6))
  )
  fgt <- calcul_fgt(menages, "depense_pc", 220000,
                    poids = "poids", sous_groupes = "milieu")
  graphique_fgt(fgt, type = "barres", variable = "milieu")
} # }
```
