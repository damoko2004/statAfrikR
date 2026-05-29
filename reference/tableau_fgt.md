# Tableau institutionnel des indices FGT

Genere un tableau des indices FGT formate selon les conventions des INS
africains et de la Banque mondiale (EHCVM).

## Usage

``` r
tableau_fgt(
  fgt_obj,
  format = c("tibble", "flextable", "excel"),
  chemin = NULL,
  titre = NULL,
  inclure_sous_groupes = TRUE
)
```

## Arguments

- fgt_obj:

  objet `saf_fgt` – Resultat de
  [`calcul_fgt()`](https://damoko2004.github.io/statAfrikR/reference/calcul_fgt.md)

- format:

  character – Format de sortie : `"tibble"`, `"flextable"` ou `"excel"`.
  Defaut : "tibble"

- chemin:

  character ou NULL – Chemin du fichier Excel. Si NULL, utilise
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html). Defaut : NULL

- titre:

  character – Titre du tableau

- inclure_sous_groupes:

  logical – Inclure les tableaux par sous-groupe. Defaut : TRUE

## Value

Tibble, flextable ou chemin du fichier Excel

## Examples

``` r
set.seed(42)
menages <- data.frame(
  depense_pc = c(rexp(70, rate = 1/150000), rexp(30, rate = 1/400000)),
  poids      = runif(100, 0.8, 1.2)
)
fgt <- calcul_fgt(menages, "depense_pc", 220000, poids = "poids")
tableau_fgt(fgt)
#> # A tibble: 1 × 11
#>   Niveau       N `FGT0 (%)` `IC bas FGT0` `IC haut FGT0`  FGT1 `IC bas FGT1`
#>   <chr>    <int>      <dbl>         <dbl>          <dbl> <dbl>         <dbl>
#> 1 National   100       70.7         0.617          0.796 0.411         0.340
#> # ℹ 4 more variables: `IC haut FGT1` <dbl>, FGT2 <dbl>, `IC bas FGT2` <dbl>,
#> #   `IC haut FGT2` <dbl>
```
