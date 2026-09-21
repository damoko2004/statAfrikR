# Produire un rapport de qualite des donnees demographiques

Synthetise les indicateurs de qualite des donnees demographiques
(Whipple, Myers, rapport de masculinite, coherence) en un tableau
institutionnel conforme aux standards Nations Unies.

## Utilisation

``` r
rapport_qualite_demo(
  donnees,
  var_age,
  var_sexe = NULL,
  poids = NULL,
  pays = "Pays",
  annee = as.integer(format(Sys.Date(), "%Y")),
  source_donnees = "Recensement"
)
```

## Arguments

- donnees:

  data.frame – Donnees individuelles

- var_age:

  character – Variable age

- var_sexe:

  character ou NULL – Variable sexe. Defaut : NULL

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- pays:

  character – Nom du pays. Defaut : "Pays"

- annee:

  integer – Annee. Defaut : annee courante

- source_donnees:

  character – Source des donnees. Defaut : "Recensement"

## Valeur de retour

Un tibble de rapport qualite

## Exemples

``` r
set.seed(42)
n <- 2000
ages_base <- sample(10:79, n, TRUE)
ages <- ifelse(runif(n) < 0.15, ages_base - ages_base%%5, ages_base)
individus <- data.frame(
  age   = ages,
  sexe  = sample(c("H","F"), n, TRUE),
  poids = runif(n, 0.8, 1.3)
)
rapport_qualite_demo(individus, "age", var_sexe="sexe",
                      poids="poids", pays="RCA", annee=2024L)
#> === Rapport qualite demographique : RCA - 2024 ===
#>   [Attention] Indice de Whipple (attraction 0 et 5) : 123.51
#>   [OK] Indice de Myers (attraction tous chiffres) : 9.02
#>   [Attention] Rapport de masculinite (groupes anomaux) : 5
#> # A tibble: 3 × 9
#>   indicateur valeur interpretation seuil_bonne_qualite statut pays  annee source
#>   <chr>       <dbl> <chr>          <chr>               <chr>  <chr> <int> <chr> 
#> 1 Indice de… 124.   Qualite appro… < 105               Atten… RCA    2024 Recen…
#> 2 Indice de…   9.02 Bonne qualite… < 10                OK     RCA    2024 Recen…
#> 3 Rapport d…   5    5 groupe(s) a… 0 groupe anormal    Atten… RCA    2024 Recen…
#> # ℹ 1 more variable: n_obs <int>
```
