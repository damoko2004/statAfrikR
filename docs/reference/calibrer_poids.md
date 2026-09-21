# Calibrer les poids de sondage

Ajuste (cale) les poids de sondage pour que les estimations
correspondent aux totaux de population connus (rake / calage generalise
GREG). Methode post-stratification generalisee.

## Utilisation

``` r
calibrer_poids(
  saf_design,
  marges,
  var_calibrage,
  methode = c("raking", "post-stratification"),
  tolerance = 1e-06,
  max_iter = 50L
)
```

## Arguments

- saf_design:

  saf_design – Objet design a calibrer

- marges:

  list – Liste nommee des totaux de population par variable. Exemple :
  list(sexe=c(H=1200000, F=1350000), milieu=c(urbain=1500000,
  rural=1050000))

- var_calibrage:

  character – Variables de calage (doivent etre dans les donnees). Ex :
  c("sexe", "milieu")

- methode:

  character – "raking" ou "post-stratification". Defaut : "raking"

- tolerance:

  numeric – Tolerance de convergence. Defaut : 1e-6

- max_iter:

  integer – Nombre maximum d'iterations. Defaut : 50L

## Valeur de retour

Un objet `saf_design` avec poids calibres

## Exemples

``` r
set.seed(42)
n <- 300
donnees <- data.frame(
  poids_sond = runif(n, 1800, 3500),
  strate     = sample(c("Urbain","Rural"), n, TRUE),
  grappe     = sample(1:20, n, TRUE),
  sexe       = sample(c("H","F"), n, TRUE),
  milieu     = sample(c("urbain","rural"), n, TRUE)
)
design <- suppressMessages(
  creer_design(donnees,"poids_sond",var_strate="strate",var_grappe="grappe"))
marges <- list(
  sexe   = c(H=500000, F=550000),
  milieu = c(urbain=600000, rural=450000)
)
calibrer_poids(design, marges, var_calibrage=c("sexe","milieu"))
#> Poids normalises : somme = 792 485
#> Plan de sondage cree :
#>   - Observations : 300
#>   - Strates : 2
#>   - Grappes (UPS) : 20
#> 
#> === Design d'enquete complexe ===
#>   Type         : stratifie_grappes 
#>   N obs        : 300 
#>   Strates      : 2 
#>   Grappes (UPS): 20 
#>   Variable poids: .poids_calibre 
```
