# Imputer les valeurs manquantes

Impute les valeurs manquantes d'un dataset selon la méthode spécifiée.
Supporte l'imputation simple (statistiques descriptives), hot-deck et
par régression. Produit un rapport de traçabilité.

## Usage

``` r
imputer_valeurs(
  data,
  vars = NULL,
  methode = c("mediane", "moyenne", "mode", "hot_deck", "regression"),
  vars_auxiliaires = NULL,
  graine = 42L,
  rapport = TRUE
)
```

## Arguments

- data:

  data.frame ou tibble — Données avec valeurs manquantes

- vars:

  character ou NULL — Variables à imputer. Si NULL, toutes les variables
  avec valeurs manquantes. Défaut : NULL.

- methode:

  character — Méthode d'imputation : `"mediane"`, `"moyenne"`, `"mode"`,
  `"hot_deck"`, `"regression"`. Défaut : "mediane".

- vars_auxiliaires:

  character ou NULL — Variables auxiliaires pour l'imputation par
  régression ou hot-deck. Défaut : NULL.

- graine:

  integer — Graine aléatoire pour la reproductibilité. Défaut : 42.

- rapport:

  logical — Retourner un rapport d'imputation. Défaut : TRUE.

## Value

Si `rapport = FALSE` : tibble imputé. Si `rapport = TRUE` : liste avec
`$donnees` et `$rapport`.

## Examples

``` r
# \donttest{
  donnees <- data.frame(revenu_mensuel=c(150000,NA,200000), age=c(25,34,NA))
  imputer_valeurs(donnees, vars=c("revenu_mensuel","age"), methode="mediane")
#>   revenu_mensuel : 1/1 valeurs imputées (méthode : mediane)
#>   age : 1/1 valeurs imputées (méthode : mediane)
#> $donnees
#>   revenu_mensuel  age
#> 1         150000 25.0
#> 2         175000 34.0
#> 3         200000 29.5
#> 
#> $rapport
#> # A tibble: 2 × 6
#>   variable       methode n_na_avant n_na_apres n_imputes taux_imputation
#>   <chr>          <chr>        <int>      <int>     <int>           <dbl>
#> 1 revenu_mensuel mediane          1          0         1               1
#> 2 age            mediane          1          0         1               1
#> 
# }
```
