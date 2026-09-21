# Creer un objet design d'enquete complexe

Cree un objet de design d'enquete en precisant les strates, grappes,
poids de sondage et la correction de population finie (FPC). Compatible
avec les enquetes EHCVM, DHS, MICS, EFT, RGPH.

## Utilisation

``` r
creer_design(
  donnees,
  var_poids,
  var_strate = NULL,
  var_grappe = NULL,
  var_fpc = NULL,
  type = c("stratifie_grappes", "stratifie", "en_grappes", "simple")
)
```

## Arguments

- donnees:

  data.frame – Donnees de l'enquete

- var_poids:

  character – Variable de poids de sondage

- var_strate:

  character ou NULL – Variable de stratification. Defaut : NULL

- var_grappe:

  character ou NULL – Variable d'unites primaires de sondage (grappes /
  UPS). Defaut : NULL

- var_fpc:

  character ou NULL – Variable de correction de population finie (taille
  de la strate dans la population). Defaut : NULL

- type:

  character – Type de design : "stratifie", "en_grappes",
  "stratifie_grappes", "simple". Defaut : "stratifie_grappes"

## Valeur de retour

Un objet de classe `saf_design` encapsulant un objet
[`survey::svydesign`](https://rdrr.io/pkg/survey/man/svydesign.html)

## Exemples

``` r
set.seed(42)
n <- 300
donnees <- data.frame(
  poids_sond = runif(n, 1800, 3500),
  strate     = sample(c("Urbain","Rural","Semi-urbain"), n, TRUE),
  grappe     = sample(1:30, n, TRUE),
  revenu     = pmax(0, rnorm(n, 180000, 90000)),
  pauvre     = rbinom(n, 1, 0.45)
)
design <- creer_design(donnees, "poids_sond",
                        var_strate="strate", var_grappe="grappe")
#> Plan de sondage cree :
#>   - Observations : 300
#>   - Strates : 3
#>   - Grappes (UPS) : 30
print(design)
#> 
#> === Design d'enquete complexe ===
#>   Type         : stratifie_grappes 
#>   N obs        : 300 
#>   Strates      : 3 
#>   Grappes (UPS): 30 
#>   Variable poids: poids_sond 
```
