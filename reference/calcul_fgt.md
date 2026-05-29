# Calcul des indices de pauvrete FGT

Calcule les indices Foster-Greer-Thorbecke (FGT0, FGT1, FGT2) avec prise
en compte optionnelle du plan de sondage complexe. Les trois indices
mesurent respectivement l'incidence, la profondeur et la severite de la
pauvrete monetaire.

## Usage

``` r
calcul_fgt(
  data,
  var_depense,
  seuil_pauvrete,
  poids = NULL,
  strate = NULL,
  grappe = NULL,
  sous_groupes = NULL,
  alpha = c(0, 1, 2),
  ic = TRUE,
  na.rm = TRUE
)
```

## Arguments

- data:

  data.frame, tibble ou objet `svydesign` – Donnees source

- var_depense:

  character – Nom de la variable de depenses ou revenus par tete (en
  monnaie locale, strictement positive)

- seuil_pauvrete:

  numeric – Seuil de pauvrete en monnaie locale. Meme unite que
  `var_depense`

- poids:

  character ou NULL – Nom de la variable de ponderation. Ignore si
  `data` est un `svydesign`. Defaut : NULL

- strate:

  character ou NULL – Variable de stratification. Defaut : NULL

- grappe:

  character ou NULL – Variable d'identifiant de grappe. Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de decomposition (region, milieu, sexe).
  Defaut : NULL

- alpha:

  numeric – Parametre de sensibilite : 0, 1, 2 ou vecteur. Defaut :
  `c(0, 1, 2)`

- ic:

  logical – Calculer les intervalles de confiance a 95%. Defaut : TRUE

- na.rm:

  logical – Exclure les valeurs manquantes. Defaut : TRUE

## Value

Un objet de classe `saf_fgt`

## References

Foster, J., Greer, J., & Thorbecke, E. (1984). A class of decomposable
poverty measures. Econometrica, 52(3), 761-766.
[doi:10.2307/1913475](https://doi.org/10.2307/1913475)

## Examples

``` r
set.seed(42)
menages <- data.frame(
  depense_pc = c(rexp(70, rate = 1/150000), rexp(30, rate = 1/400000)),
  poids      = runif(100, 0.8, 1.2),
  region     = sample(c("Bangui", "Ombella", "Lobaye"), 100, TRUE),
  milieu     = sample(c("urbain", "rural"), 100, TRUE, prob = c(0.4, 0.6))
)
fgt <- calcul_fgt(menages, var_depense = "depense_pc",
                  seuil_pauvrete = 220000, poids = "poids")
print(fgt)
#> 
#> === Indices FGT -- statAfrikR ===
#> Seuil de pauvrete : 220 000 
#> Variable          : depense_pc 
#> Effectif total    : 100 menages
#> Dont pauvres      : 70 (70% brut)
#> 
#> # A tibble: 1 × 10
#>   n_obs  fgt0 fgt0_ic_bas fgt0_ic_haut  fgt1 fgt1_ic_bas fgt1_ic_haut  fgt2
#>   <int> <dbl>       <dbl>        <dbl> <dbl>       <dbl>        <dbl> <dbl>
#> 1   100 0.707       0.617        0.796 0.411       0.340        0.482 0.297
#> # ℹ 2 more variables: fgt2_ic_bas <dbl>, fgt2_ic_haut <dbl>
```
