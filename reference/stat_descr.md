# Statistiques descriptives pondérées

Calcule les statistiques descriptives complètes pour une ou plusieurs
variables numériques, avec prise en compte optionnelle du plan de
sondage complexe. Produit un tableau formaté prêt à publier.

## Usage

``` r
stat_descr(
  data,
  vars,
  groupe = NULL,
  ponderee = TRUE,
  ic = TRUE,
  format_sortie = c("tibble", "flextable")
)
```

## Arguments

- data:

  data.frame, tibble ou objet `svydesign` — Données source

- vars:

  character — Noms des variables à analyser

- groupe:

  character ou NULL — Variable de regroupement. Défaut : NULL.

- ponderee:

  logical — Utiliser les pondérations si data est un svydesign. Défaut :
  TRUE.

- ic:

  logical — Calculer les intervalles de confiance à 95%. Défaut : TRUE.

- format_sortie:

  character — Format : `"tibble"` ou `"flextable"`. Défaut : "tibble".

## Value

Tibble ou flextable avec : n, moyenne, médiane, écart-type, min, max,
IC95.

## Examples

``` r
if (FALSE) { # \dontrun{
  donnees <- data.frame(age=c(25,34,45), revenu=c(150000,200000,180000))
  stat_descr(donnees, vars=c("age","revenu"))
} # }
```
