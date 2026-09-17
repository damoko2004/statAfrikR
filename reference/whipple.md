# Calculer l'indice de Whipple

Mesure l'attraction des ages se terminant par 0 et 5 dans les
declarations d'age. Un indice de Whipple \< 105 indique des donnees de
tres bonne qualite ; \> 175 indique une qualite tres mauvaise.
Methodologie Nations Unies / IUSSP.

## Usage

``` r
whipple(donnees, var_age, age_min = 23L, age_max = 62L, poids = NULL)
```

## Arguments

- donnees:

  data.frame – Donnees individuelles

- var_age:

  character – Variable age en annees revolues

- age_min:

  integer – Age minimum pour le calcul. Defaut : 23L

- age_max:

  integer – Age maximum pour le calcul. Defaut : 62L

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

## Value

Un objet de classe `saf_qualite_demo`

## Examples

``` r
set.seed(42)
n <- 1000
# Simulation d'attraction sur les multiples de 5
ages_base <- sample(23:62, n, TRUE)
attire    <- ages_base - (ages_base %% 5) # attire vers 0 et 5
ages      <- ifelse(runif(n) < 0.25, attire, ages_base)
individus <- data.frame(age = ages, poids = runif(n, 0.8, 1.3))
whipple(individus, "age")
#> === Indice de Whipple ===
#>   Whipple : 184.2  (Qualite tres mauvaise (>= 175))
#>   N obs   : 989 individus (ages 23-62)
#> 
#> === Qualite des donnees demographiques ===
#>   Methode        : Whipple (ONU/IUSSP) 
#>   Indice         : 184.25 
#>   Interpretation : Qualite tres mauvaise (>= 175) 
#>   N obs          : 989 
```
