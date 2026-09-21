# Decomposer l'IPM par sous-groupe

Decompose l'IPM par region, milieu ou sexe du chef de menage. Retourne
H, A et IPM par groupe, ainsi que la contribution de chaque groupe a
l'IPM national.

## Utilisation

``` r
decomposer_ipm(res_ipm, donnees, var_groupe, poids = NULL)
```

## Arguments

- res_ipm:

  saf_ipm – Resultat de
  [`calcul_ipm()`](https://damoko2004.github.io/statAfrikR/reference/calcul_ipm.md)
  ou
  [`calcul_ipm_national()`](https://damoko2004.github.io/statAfrikR/reference/calcul_ipm_national.md)

- donnees:

  data.frame – Donnees originales (meme ordre que lors du calcul de
  l'IPM)

- var_groupe:

  character – Variable de sous-groupe (ex : "region", "milieu",
  "sexe_cm")

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

## Valeur de retour

Un tibble avec H, A, IPM, n_obs et contribution par groupe

## Exemples

``` r
set.seed(42)
n <- 300
menages <- data.frame(
  nutrition      = rbinom(n, 1, 0.35),
  electricite    = rbinom(n, 1, 0.60),
  eau            = rbinom(n, 1, 0.40),
  milieu         = sample(c("urbain","rural"), n, TRUE),
  poids          = runif(n, 0.8, 1.3)
)
res <- calcul_ipm(menages,
  var_nutrition = "nutrition", var_electricite = "electricite",
  var_eau = "eau", poids = "poids")
decomposer_ipm(res, menages, var_groupe = "milieu", poids = "poids")
#> Decomposition IPM par milieu : 2 groupes
#> # A tibble: 2 × 7
#>   milieu     H     A   IPM n_obs poids_groupe contribution_pct
#>   <chr>  <dbl> <dbl> <dbl> <int>        <dbl>            <dbl>
#> 1 rural   49.0  68.4 0.336   149         157.               49
#> 2 urbain  48.4  72.0 0.348   151         157.               51
```
