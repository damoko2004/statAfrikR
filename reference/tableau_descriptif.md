# Tableau de statistiques descriptives institutionnel

Produit un tableau de statistiques descriptives pondere, formate selon
les conventions des INS africains. Exportable en Word (flextable) ou
Excel (openxlsx2).

## Usage

``` r
tableau_descriptif(
  data,
  vars,
  poids = NULL,
  par = NULL,
  stats = c("n", "moyenne", "mediane", "ecart_type", "min", "max", "ic"),
  format = c("tibble", "flextable", "excel"),
  chemin = NULL,
  titre = NULL,
  source = NULL
)
```

## Arguments

- data:

  data.frame, tibble ou objet `svydesign` – Donnees

- vars:

  character – Variables numeriques a analyser

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- par:

  character ou NULL – Variable de ventilation (groupe). Defaut : NULL

- stats:

  character – Statistiques parmi : `"n"`, `"moyenne"`, `"mediane"`,
  `"ecart_type"`, `"min"`, `"max"`, `"ic"`. Defaut : toutes

- format:

  character – `"tibble"`, `"flextable"` ou `"excel"`. Defaut : "tibble"

- chemin:

  character ou NULL – Chemin Excel. Defaut : NULL

- titre:

  character ou NULL – Titre du tableau. Defaut : NULL

- source:

  character ou NULL – Note source. Defaut : NULL

## Value

Tibble, flextable ou chemin fichier Excel

## Examples

``` r
set.seed(42)
donnees <- data.frame(
  age    = sample(18:65, 200, replace = TRUE),
  revenu = rexp(200, rate = 1/250000),
  poids  = runif(200, 0.8, 1.3),
  milieu = sample(c("urbain", "rural"), 200, TRUE)
)
tableau_descriptif(donnees, vars = c("age", "revenu"), poids = "poids")
#> # A tibble: 2 × 9
#>   variable     n  moyenne   ic_bas  ic_haut mediane ecart_type   min     max
#>   <chr>    <int>    <dbl>    <dbl>    <dbl>   <dbl>      <dbl> <dbl>   <dbl>
#> 1 age        200     42.0     40.2     43.9     44        13.4  18       65 
#> 2 revenu     200 283619.  250497.  316740.  224193.   237137.   70.2 993229.
```
