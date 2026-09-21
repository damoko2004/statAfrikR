# Calculer l'indice d'autonomisation des femmes

Calcule un indice composite d'autonomisation des femmes base sur trois
dimensions : prises de decision, acces aux ressources et mobilite.
Conforme a la methodologie DHS/MICS.

## Utilisation

``` r
autonomisation_femmes(
  donnees,
  vars_decision = NULL,
  vars_ressources = NULL,
  vars_mobilite = NULL,
  poids = NULL,
  sous_groupes = NULL
)
```

## Arguments

- donnees:

  data.frame – Donnees femmes

- vars_decision:

  character ou NULL – Variables 0/1 de prise de decision (ex: decisions
  achat menage, sante, visites). Defaut : NULL

- vars_ressources:

  character ou NULL – Variables 0/1 d'acces aux ressources (ex: compte
  bancaire, revenu propre, terre). Defaut : NULL

- vars_mobilite:

  character ou NULL – Variables 0/1 de mobilite (ex: libre de se
  deplacer seule, rendre visite, marche). Defaut : NULL

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de desagregation. Defaut : NULL

## Valeur de retour

Un objet de classe `saf_genre`

## Exemples

``` r
set.seed(42)
n <- 400
femmes <- data.frame(
  dec_achat   = rbinom(n, 1, 0.55),
  dec_sante   = rbinom(n, 1, 0.48),
  compte_ban  = rbinom(n, 1, 0.32),
  rev_propre  = rbinom(n, 1, 0.41),
  libre_dep   = rbinom(n, 1, 0.62),
  milieu      = sample(c("urbain","rural"), n, TRUE),
  poids       = runif(n, 0.8, 1.3)
)
autonomisation_femmes(femmes,
  vars_decision   = c("dec_achat","dec_sante"),
  vars_ressources = c("compte_ban","rev_propre"),
  vars_mobilite   = c("libre_dep"),
  poids = "poids", sous_groupes = "milieu")
#> === Indice d'autonomisation des femmes ===
#>   Indice global : 47.7/100
#>   Decision : 50
#>   Ressources : 34.8
#>   Mobilite : 58.3
#> 
#> === Indice d'autonomisation des femmes ( DHS/MICS ) ===
#>   Indice global : 47.7 / 100
#> 
#> Desagregation :
#>   rural                : 0.473  (n=203)
#>   urbain               : 0.4812  (n=197)
```
