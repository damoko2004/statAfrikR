# Calculer le sentiment de securite

Proportion de la population se sentant en securite (le soir dans le
quartier, au travail, dans les transports). Methodologie Afrobarometer /
Gallup.

## Utilisation

``` r
sentiment_securite(
  donnees,
  var_securite,
  codes_securise = NULL,
  poids = NULL,
  sous_groupes = NULL
)
```

## Arguments

- donnees:

  data.frame – Donnees individuelles

- var_securite:

  character – Variable de securite percue (0/1 ou codes_securise)

- codes_securise:

  numeric ou NULL – Codes indiquant "securise". Defaut : NULL (variable
  deja binaire)

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de desagregation. Defaut : NULL

## Valeur de retour

Un objet de classe `saf_subjectif`

## Exemples

``` r
set.seed(42)
n <- 400
individus <- data.frame(
  securise = rbinom(n, 1, 0.52),
  sexe     = sample(c("H","F"), n, TRUE),
  milieu   = sample(c("urbain","rural"), n, TRUE),
  poids    = runif(n, 0.8, 1.3)
)
sentiment_securite(individus, "securise", poids="poids",
                    sous_groupes=c("sexe","milieu"))
#> === Sentiment de securite percue ===
#>   Taux : 53%
#> 
#> === Sentiment de securite percue ( Afrobarometer / Gallup ) ===
#>   Taux : 53.0%  [IC 95% : 48.1% - 57.8%]
#>   N obs : 400
#> 
#> Desagregation :
#>   F                    : 49.3  (n=202)
#>   H                    : 56.72  (n=198)
#>   rural                : 50.47  (n=199)
#>   urbain               : 55.42  (n=201)
```
