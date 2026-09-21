# Calculer un IPM national personnalise

Calcule un IPM national adapte aux realites locales (ODD 1.2.2). L'INS
peut choisir ses indicateurs, leurs poids et le seuil k.

## Utilisation

``` r
calcul_ipm_national(
  donnees,
  indicateurs,
  poids = NULL,
  seuil_k = 1/3,
  ic = FALSE,
  n_bootstrap = 200L
)
```

## Arguments

- donnees:

  data.frame – Donnees menages

- indicateurs:

  list – Liste nommee definissant les indicateurs : chaque element
  contient `var` (nom de variable), `poids` (poids numerique) et
  `dimension` (nom de la dimension).

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- seuil_k:

  numeric – Seuil de pauvrete. Defaut : 1/3

- ic:

  logical – Intervalles de confiance bootstrap. Defaut : FALSE

- n_bootstrap:

  integer – Replications bootstrap. Defaut : 200L

## Valeur de retour

Un objet `saf_ipm`

## Exemples

``` r
set.seed(42)
n <- 150
menages <- data.frame(
  eau        = rbinom(n, 1, 0.45),
  electricite = rbinom(n, 1, 0.60),
  scol       = rbinom(n, 1, 0.35),
  sante      = rbinom(n, 1, 0.25),
  poids      = runif(n, 0.8, 1.3)
)
indics <- list(
  acces_eau   = list(var = "eau",        poids = 0.25,
                     dimension = "Conditions de vie"),
  acces_elec  = list(var = "electricite", poids = 0.25,
                     dimension = "Conditions de vie"),
  education   = list(var = "scol",       poids = 0.30,
                     dimension = "Education"),
  sante_base  = list(var = "sante",      poids = 0.20,
                     dimension = "Sante")
)
res <- calcul_ipm_national(menages, indicateurs = indics,
                            poids = "poids", seuil_k = 1/3)
print(res)
#> 
#> === Indice de Pauvrete Multidimensionnelle (IPM) ===
#> Methode    : IPM National (Alkire-Foster adapte) - ODD 1.2.2 
#> Seuil k    : 33.3 %
#> N obs      : 150 
#> 
#>   IPM = 0.3866  (H x A)
#>   H   = 64.6% (incidence)
#>   A   = 59.8% (intensite)
#> 
#> Contributions par indicateur :
#>   acces_eau            [Conditions de vie]  30.4%
#>   acces_elec           [Conditions de vie]  34.6%
#>   education            [Education      ]  22.2%
#>   sante_base           [Sante          ]  12.8%
```
