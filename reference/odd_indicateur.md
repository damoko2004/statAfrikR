# Calculer un indicateur ODD

Calcule un indicateur ODD specifique a partir des donnees d'enquete.
Retourne un objet `saf_odd` avec la valeur, les metadonnees et les
composantes du calcul.

## Usage

``` r
odd_indicateur(data, code_odd, ..., poids = NULL, na.rm = TRUE)
```

## Arguments

- data:

  data.frame ou `svydesign` – Donnees d'enquete

- code_odd:

  character – Code ODD au format "X.Y.Z" (ex : "1.1.1", "7.1.1"). Voir
  [`odd_catalogue()`](https://damoko2004.github.io/statAfrikR/reference/odd_catalogue.md)
  pour la liste

- ...:

  Arguments specifiques a chaque indicateur (voir Details)

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- na.rm:

  logical – Exclure les NA. Defaut : TRUE

## Value

Un objet de classe `saf_odd` avec :

- valeur:

  Valeur de l'indicateur

- unite:

  Unite de mesure

- code_odd:

  Code ODD

- titre_court:

  Libelle court

- numerateur:

  Numerateur du calcul

- denominateur:

  Denominateur du calcul

- n_obs:

  Observations utilisees

- na_count:

  Valeurs manquantes exclues

- meta:

  Metadonnees completes du catalogue

## Details

Arguments specifiques par indicateur :

- 1.1.1:

  `var_depense` : variable de depenses par tete, `seuil` : seuil en
  monnaie locale (defaut : equivalence 2.15 USD PPA)

- 1.2.1:

  `var_depense` : variable de depenses par tete, `seuil` : seuil
  national de pauvrete

- 2.2.1:

  `var_taille` : taille de l'enfant (cm), `var_age_mois` : age en mois,
  `var_sexe` : sexe (1=M, 2=F ou "M"/"F")

- 3.2.1:

  `var_deces_enfant` : indicateur deces enfant (0/1), `var_naissances` :
  nombre de naissances vivantes ou variable indicatrice

- 5.3.1:

  `var_age_mariage` : age au premier mariage, `var_age_actuel` : age
  actuel, `seuil_age` : seuil (defaut : 18)

- 5.5.2, 8.5.2, 8.6.1, 6.1.1, 7.1.1, 10.2.1, 11.1.1, 16.9.1, 17.8.1:

  `var_indicateur` : variable binaire (1 = condition remplie, 0 = non)

- 10.1.1:

  `var_depense` : variable de depenses, `var_periode` : variable de
  periode (annees), `seuil_pct` : percentile inferieur (defaut : 40)

## Examples

``` r
set.seed(42)
menages <- data.frame(
  depense_pc = c(rexp(70, rate = 1/150000), rexp(30, rate = 1/500000)),
  poids      = runif(100, 0.8, 1.2),
  electricite = sample(c(0L, 1L), 100, TRUE, prob = c(0.45, 0.55)),
  eau_potable = sample(c(0L, 1L), 100, TRUE, prob = c(0.35, 0.65)),
  internet    = sample(c(0L, 1L), 100, TRUE, prob = c(0.7, 0.3))
)

# ODD 1.2.1 - Pauvrete nationale
odd_indicateur(menages, "1.2.1",
               var_depense = "depense_pc", seuil = 200000,
               poids = "poids")
#> 
#> === Indicateur ODD 1.2.1 ===
#> Pauvrete nationale 
#> ----------------------------------------
#> Valeur      : 61.328 % 
#> Numerateur  : 60 
#> Denominateur: 98 
#> N obs       : 98.25475 

# ODD 7.1.1 - Acces a l'electricite
odd_indicateur(menages, "7.1.1", var_indicateur = "electricite",
               poids = "poids")
#> 
#> === Indicateur ODD 7.1.1 ===
#> Electricite 
#> ----------------------------------------
#> Valeur      : 65.21 % 
#> Numerateur  : 64 
#> Denominateur: 98 
#> N obs       : 98.25475 
```
