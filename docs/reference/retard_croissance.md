# Calculer le taux de retard de croissance (stunting)

Calcule la prevalence du retard de croissance chez les enfants de moins
de 5 ans (taille-pour-age \< -2 ecarts-types selon les standards OMS
2006). ODD 2.2.1.

## Utilisation

``` r
retard_croissance(
  donnees,
  var_taille_age_z = NULL,
  var_taille = NULL,
  var_age_mois = NULL,
  var_sexe = NULL,
  poids = NULL,
  sous_groupes = NULL,
  seuil = -2
)
```

## Arguments

- donnees:

  data.frame – Donnees enfants \< 5 ans

- var_taille_age_z:

  character – Score Z taille-pour-age (HAZ). Si NULL, calcule depuis
  var_taille, var_age et var_sexe. Defaut : NULL

- var_taille:

  character ou NULL – Taille en cm. Defaut : NULL

- var_age_mois:

  character ou NULL – Age en mois. Defaut : NULL

- var_sexe:

  character ou NULL – Sexe (1=garcon, 2=fille ou "M"/"F"). Defaut : NULL

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de desagregation. Defaut : NULL

- seuil:

  numeric – Seuil (score Z). Defaut : -2

## Valeur de retour

Un objet de classe `saf_anthropo`

## Exemples

``` r
set.seed(42)
n <- 500
enfants <- data.frame(
  haz   = rnorm(n, -1.2, 1.3),
  milieu = sample(c("urbain","rural"), n, TRUE),
  poids  = runif(n, 0.7, 1.4)
)
retard_croissance(enfants, var_taille_age_z = "haz", poids = "poids")
#> === Retard de croissance (stunting) ===
#>   Taux : 25.8%  (Eleve (20-30%))
#>   N    : 500 enfants
#> 
#> === Retard de croissance (stunting) ( ODD 2.2.1 ) ===
#>   Taux  : 25.8%  [IC 95% : 22.2% - 29.8%]
#>   N obs : 500 enfants  |  N cas : 129
#>   Seuil OMS : score Z < -2
#>   Categorie : Eleve (20-30%)
```
