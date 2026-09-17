# Calculer l'indice de Myers (attraction sur tous les chiffres)

Mesure l'attraction sur les 10 chiffres terminaux (0-9). L'indice de
Myers varie de 0 (aucune attraction) a 90 (attraction maximale). Un
indice \< 10 indique une bonne qualite des donnees d'age.

## Usage

``` r
myers(donnees, var_age, age_min = 10L, age_max = 89L, poids = NULL)
```

## Arguments

- donnees:

  data.frame – Donnees individuelles

- var_age:

  character – Variable age en annees revolues

- age_min:

  integer – Age minimum. Defaut : 10L

- age_max:

  integer – Age maximum. Defaut : 89L

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

## Value

Un objet de classe `saf_qualite_demo`

## Examples

``` r
set.seed(42)
n <- 1000
ages_base <- sample(10:89, n, TRUE)
# Attraction sur les ages ronds
ages <- ifelse(runif(n) < 0.20,
               ages_base - (ages_base %% 10),
               ages_base)
individus <- data.frame(age = pmax(10, pmin(89, ages)))
myers(individus, "age")
#> === Indice de Myers ===
#>   Myers : 18  (Qualite mauvaise (15-20))
#> 
#> === Qualite des donnees demographiques ===
#>   Methode        : Myers (chiffres terminaux 0-9) 
#>   Indice         : 18.05 
#>   Interpretation : Qualite mauvaise (15-20) 
#>   N obs          : 1 000 
#> 
#> Distribution par chiffre terminal :
#>   Digit :  0 1 2 3 4 5 6 7 8 9 
#>   Part% :  28 8.2 9.1 8.3 7.1 6.8 8.7 7.9 7.6 8.3 
```
