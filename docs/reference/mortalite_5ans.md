# Calculer le taux de mortalite des enfants de moins de 5 ans

Calcule le taux de mortalite infanto-juvenile (U5MR) en pour 1 000
naissances vivantes. ODD 3.2.1.

## Utilisation

``` r
mortalite_5ans(
  donnees,
  var_naissances_vivantes,
  var_deces_enfants,
  poids = NULL,
  sous_groupes = NULL
)
```

## Arguments

- donnees:

  data.frame – Donnees femmes en age de procrer (15-49 ans) ou
  historique des naissances

- var_naissances_vivantes:

  character – Nombre total de naissances vivantes par femme

- var_deces_enfants:

  character – Nombre de deces d'enfants \< 5 ans par femme

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de desagregation. Defaut : NULL

## Valeur de retour

Un objet de classe `saf_mortalite`

## Exemples

``` r
set.seed(42)
n <- 600
femmes <- data.frame(
  naissances_vivantes = rpois(n, 3.5),
  deces_enfants       = rbinom(n, 4, 0.08),
  milieu              = sample(c("urbain","rural"), n, TRUE),
  poids               = runif(n, 0.8, 1.3)
)
mortalite_5ans(femmes,
  var_naissances_vivantes = "naissances_vivantes",
  var_deces_enfants       = "deces_enfants",
  poids                   = "poids")
#> === Mortalite des enfants < 5 ans (ODD 3.2.1) ===
#>   U5MR : 84.7 pour 1 000 naissances vivantes
#>   IC 95% : [72.9 ; 97.8]
#>   N femmes : 580
#> 
#> === Mortalite des enfants < 5 ans ( ODD 3.2.1 ) ===
#>   U5MR : 84.7 pour 1 000 naissances vivantes
#>   IC 95% : [72.9 ; 97.8]
#>   Total naissances : 2 182 | Total deces : 185
#>   Categorie : Elevee (50-100)
```
