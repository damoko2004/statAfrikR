# Decomposer les inegalites selon l'indice de Theil

Decompose l'inegalite totale en composantes inter-groupe et intra-groupe
selon l'indice de Theil T (entropie generalisee GE(1)). Indispensable
pour identifier les sources spatiales ou sociales de l'inegalite.

## Utilisation

``` r
decomposer_theil(donnees, var_revenu, var_groupe, poids = NULL)

theil(donnees, var_revenu, var_groupe, poids = NULL)
```

## Arguments

- donnees:

  data.frame – Donnees menages

- var_revenu:

  character – Variable de revenu

- var_groupe:

  character – Variable de groupe (region, milieu, sexe_cm)

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

## Valeur de retour

Un tibble avec Theil total, inter-groupe, intra-groupe et contribution
de chaque groupe

## Exemples

``` r
set.seed(42)
menages <- data.frame(
  depense = c(rexp(200, 1/150000), rexp(100, 1/500000)),
  milieu  = sample(c("urbain","rural"), 300, TRUE),
  poids   = runif(300, 0.8, 1.3)
)
decomposer_theil(menages, "depense", "milieu", poids = "poids")
#> === Decomposition Theil (milieu) ===
#>   Theil total : 0.5525
#>   Intra-groupe : 0.5484 (99.3%)
#>   Inter-groupe : 0.0041 (0.7%)
#> 
#> === Decomposition Theil T ===
#>   Theil total  : 0.5525
#>   Inter-groupe : 0.0041  (0.7%)
#>   Intra-groupe : 0.5484  (99.3%)
#> 
#> Par groupe ( milieu ) :
#>   rural                : Theil=0.4356 | Part pop=48.58% | Part rev=53.07%
#>   urbain               : Theil=0.6761 | Part pop=51.42% | Part rev=46.93%
```
