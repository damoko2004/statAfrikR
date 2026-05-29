# Decomposer les indices FGT par sous-groupe

Decompose un indice FGT en contributions relatives de chaque sous-groupe
a la pauvrete nationale.

## Usage

``` r
decomposer_fgt(fgt_obj, variable, alpha_cible = 0)
```

## Arguments

- fgt_obj:

  objet `saf_fgt` – Resultat de
  [`calcul_fgt()`](https://damoko2004.github.io/statAfrikR/reference/calcul_fgt.md)
  avec `sous_groupes` renseigne

- variable:

  character – Sous-groupe a decomposer

- alpha_cible:

  numeric – Indice a decomposer : 0, 1 ou 2. Defaut : 0

## Value

Tibble avec contributions absolues et relatives

## Examples

``` r
set.seed(42)
menages <- data.frame(
  depense_pc = c(rexp(70, rate = 1/150000), rexp(30, rate = 1/400000)),
  poids  = runif(100, 0.8, 1.2),
  milieu = sample(c("urbain", "rural"), 100, TRUE, prob = c(0.4, 0.6))
)
fgt <- calcul_fgt(menages, "depense_pc", 220000,
                  poids = "poids", sous_groupes = "milieu")
decomposer_fgt(fgt, "milieu", alpha_cible = 0)
#> FGT0 national : 0.7065
#> Total contributions : 100% (doit = 100%)
#> # A tibble: 2 × 6
#>   modalite fgt_local     n part_population contribution_abs contribution_rel
#>   <chr>        <dbl> <int>           <dbl>            <dbl>            <dbl>
#> 1 rural        0.707    68            0.68            0.481             68.0
#> 2 urbain       0.706    32            0.32            0.226             32.0
```
