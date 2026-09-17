# Comparer l'IPM global et l'IPM national

Compare les resultats du MPI global PNUD/OPHI et d'un IPM national.
Produit un tableau des ecarts et un graphique.

## Usage

``` r
comparer_ipm(
  ipm_global,
  ipm_national,
  pays = "Pays",
  annee = as.integer(format(Sys.Date(), "%Y"))
)
```

## Arguments

- ipm_global:

  saf_ipm – Resultat IPM global (calcul_ipm())

- ipm_national:

  saf_ipm – Resultat IPM national (calcul_ipm_national())

- pays:

  character – Nom du pays. Defaut : "Pays"

- annee:

  integer – Annee. Defaut : annee courante

## Value

Un tibble comparatif + graphique (invisible)

## Examples

``` r
set.seed(42)
n <- 200
men <- data.frame(
  nutr = rbinom(n,1,0.35), elec = rbinom(n,1,0.6),
  eau  = rbinom(n,1,0.4),  scol = rbinom(n,1,0.3),
  mort = rbinom(n,1,0.12), comb = rbinom(n,1,0.5),
  poids = runif(n,0.8,1.3)
)
ipm_g <- calcul_ipm(men, var_nutrition="nutr",
  var_electricite="elec", var_eau="eau",
  var_scolarisation="scol", var_mortalite_inf="mort",
  var_combustible="comb", poids="poids")
ipm_n <- calcul_ipm_national(men,
  indicateurs=list(
    eau  = list(var="eau",  poids=0.4, dimension="Vie"),
    elec = list(var="elec", poids=0.35, dimension="Vie"),
    scol = list(var="scol", poids=0.25, dimension="Education")
  ), poids="poids")
comparer_ipm(ipm_g, ipm_n, pays="Centrafrique", annee=2026L)
#> === Comparaison MPI Global vs IPM National === Centrafrique - 2026
#>   IPM Global   : 0.2706  (H=55.7%, A=48.5%)
#>   IPM National : 0.4335  (H=78.1%, A=55.5%)
#>   Ecart IPM   : 0.1629  (60.2%)
```
