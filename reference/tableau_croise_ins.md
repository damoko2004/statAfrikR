# Tableau croise pondere - format institutionnel INS

Produit un tableau de contingence pondere avec marges, pourcentages et
test du chi-deux.

## Usage

``` r
tableau_croise_ins(
  data,
  ligne,
  colonne,
  poids = NULL,
  type_pct = c("colonne", "ligne", "total"),
  marges = TRUE,
  chi2 = TRUE,
  format = c("tibble", "flextable", "excel"),
  chemin = NULL,
  titre = NULL
)
```

## Arguments

- data:

  data.frame, tibble ou `svydesign` – Donnees

- ligne:

  character – Variable en ligne

- colonne:

  character – Variable en colonne

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- type_pct:

  character – `"colonne"`, `"ligne"` ou `"total"`. Defaut : "colonne"

- marges:

  logical – Afficher les totaux. Defaut : TRUE

- chi2:

  logical – Calculer le test du chi-deux. Defaut : TRUE

- format:

  character – `"tibble"`, `"flextable"` ou `"excel"`. Defaut : "tibble"

- chemin:

  character ou NULL – Chemin Excel. Defaut : NULL

- titre:

  character ou NULL – Titre. Defaut : NULL

## Value

Tibble, flextable ou chemin Excel

## Examples

``` r
set.seed(42)
donnees <- data.frame(
  region = sample(c("Nord", "Sud", "Est", "Ouest"), 300, TRUE),
  milieu = sample(c("urbain", "rural"), 300, TRUE, prob = c(0.4, 0.6)),
  poids  = runif(300, 0.7, 1.4)
)
tableau_croise_ins(donnees, "region", "milieu", poids = "poids")
#> # A tibble: 5 × 4
#>   region rural urbain     N
#>   <chr>  <dbl>  <dbl> <dbl>
#> 1 Est     19.1   19.8  60.8
#> 2 Nord    28.2   30.3  91.1
#> 3 Ouest   21.8   26.4  73.8
#> 4 Sud     30.9   23.5  88.8
#> 5 Total  100    100   315. 
```
