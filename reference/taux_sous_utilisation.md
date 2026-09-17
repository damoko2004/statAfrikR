# Calculer le taux de sous-utilisation composite de la main-d'oeuvre

Calcule le taux composite OIT LU3 ou LU4 qui agrege le chomage, le
sous-emploi en temps de travail et les actifs potentiels non recherchant
activement. Depasse le simple taux de chomage pour mesurer la
sous-utilisation reelle.

## Usage

``` r
taux_sous_utilisation(
  donnees,
  var_chomeur,
  var_sous_emploi_t = NULL,
  var_actif_potentiel = NULL,
  poids = NULL
)
```

## Arguments

- donnees:

  data.frame – Donnees individuelles

- var_chomeur:

  character – Variable 0/1 : chomeur (BIT)

- var_sous_emploi_t:

  character ou NULL – Variable 0/1 : sous-emploi temps. Defaut : NULL

- var_actif_potentiel:

  character ou NULL – Variable 0/1 : actif potentiel (souhaite
  travailler mais ne cherche pas). Defaut : NULL

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

## Value

Un tibble avec les composantes et le taux composite

## Examples

``` r
set.seed(42)
n <- 500
individus <- data.frame(
  chomeur         = rbinom(n, 1, 0.14),
  sous_emploi_t   = rbinom(n, 1, 0.08),
  actif_potentiel = rbinom(n, 1, 0.05),
  poids           = runif(n, 0.8, 1.3)
)
taux_sous_utilisation(individus, "chomeur",
                       var_sous_emploi_t = "sous_emploi_t",
                       var_actif_potentiel = "actif_potentiel",
                       poids = "poids")
#> === Sous-utilisation de la main-d'oeuvre (OIT) ===
#>   Chomage         : 14.4%
#>   Sous-emploi t.  : 7.5%
#>   LU3 composite   : 25.4%
#> # A tibble: 5 × 2
#>   composante                        taux_pct
#>   <chr>                                <dbl>
#> 1 Chomage (LU1 / ODD 8.5.2)            14.4 
#> 2 Sous-emploi en temps (LU2)            7.49
#> 3 Actifs potentiels (LU3)               3.55
#> 4 Total LU2 (chomage + sous-emploi)    21.9 
#> 5 Total LU3 (composite)                25.4 
```
