# Calculer le rapport de masculinite par groupe d'age

Calcule le rapport de masculinite (nombre d'hommes pour 100 femmes) par
groupe d'age quinquennal. Permet de detecter des anomalies liees aux
guerres, migrations ou erreurs de collecte.

## Usage

``` r
ratio_masculinite(
  donnees,
  var_age,
  var_sexe,
  code_homme = "H",
  code_femme = "F",
  poids = NULL,
  groupes_age = 5L
)
```

## Arguments

- donnees:

  data.frame – Donnees individuelles

- var_age:

  character – Variable age en annees

- var_sexe:

  character – Variable sexe

- code_homme:

  character ou numeric – Code pour les hommes. Defaut : "H"

- code_femme:

  character ou numeric – Code pour les femmes. Defaut : "F"

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- groupes_age:

  integer – Largeur des groupes d'age. Defaut : 5L

## Value

Un tibble avec rapport de masculinite par groupe d'age

## Examples

``` r
set.seed(42)
n <- 2000
individus <- data.frame(
  age   = sample(0:79, n, TRUE),
  sexe  = sample(c("H","F"), n, TRUE, prob=c(0.49,0.51)),
  poids = runif(n, 0.8, 1.3)
)
ratio_masculinite(individus, "age", "sexe", poids="poids")
#> === Rapport de masculinite par groupe d'age ===
#>   Groupes analyses : 16
#>   Groupes en alerte (ratio < 90 ou > 110) : 11
#> # A tibble: 16 × 5
#>    groupe_age     H     F ratio alerte
#>    <chr>      <dbl> <dbl> <dbl> <lgl> 
#>  1 [0,5)         55    71  77.3 TRUE  
#>  2 [5,10)        67    70  95   FALSE 
#>  3 [10,15)       75    58 129.  TRUE  
#>  4 [15,20)       70    60 118.  TRUE  
#>  5 [20,25)       61    65  93.2 FALSE 
#>  6 [25,30)       70    74  94.8 FALSE 
#>  7 [30,35)       68    78  88   TRUE  
#>  8 [35,40)       75    50 148   TRUE  
#>  9 [40,45)       67    69  97.5 FALSE 
#> 10 [45,50)       63    69  92.5 FALSE 
#> 11 [50,55)       63    54 116.  TRUE  
#> 12 [55,60)       70    59 119   TRUE  
#> 13 [60,65)       85    58 146.  TRUE  
#> 14 [65,70)       61    54 113.  TRUE  
#> 15 [70,75)       60    76  79.1 TRUE  
#> 16 [75,80]       67    52 129.  TRUE  
```
