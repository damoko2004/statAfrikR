# Calculer le taux de sous-emploi en temps de travail

Calcule la proportion de personnes en emploi travaillant moins d'heures
qu'elles ne le souhaitent (sous-emploi visible). Composante de LU2 dans
la mesure de la sous-utilisation de la main-d'oeuvre OIT.

## Usage

``` r
sous_emploi_temps(
  donnees,
  var_heures_travaillees,
  var_heures_souhaitees = NULL,
  seuil_heures = 35L,
  var_disponible = NULL,
  poids = NULL,
  sous_groupes = NULL
)
```

## Arguments

- donnees:

  data.frame – Donnees individus en emploi

- var_heures_travaillees:

  character – Heures effectivement travaillees par semaine

- var_heures_souhaitees:

  character ou NULL – Heures souhaitees. Si NULL, utilise le seuil.
  Defaut : NULL

- seuil_heures:

  integer – Seuil d'heures hebdomadaires en dessous duquel il y a
  sous-emploi (defaut : 35L)

- var_disponible:

  character ou NULL – Variable 0/1 : disponible pour travailler plus.
  Defaut : NULL

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de desagregation. Defaut : NULL

## Value

Un objet de classe `saf_emploi`

## Examples

``` r
set.seed(42)
n <- 400
employes <- data.frame(
  heures_trav = pmax(0, rnorm(n, 38, 15)),
  disponible  = rbinom(n, 1, 0.3),
  poids       = runif(n, 0.8, 1.3)
)
sous_emploi_temps(employes, "heures_trav",
                  seuil_heures = 35L, poids = "poids")
#> === Sous-emploi en temps de travail (OIT) ===
#>   Seuil : < 35 heures/semaine
#>   Taux  : 41.4%
#> 
#> === Sous-emploi en temps de travail ( OIT LU2 ) ===
#>   Taux  : 41.4%  [IC 95% : 36.7% - 46.3%]
#>   N obs : 400
```
