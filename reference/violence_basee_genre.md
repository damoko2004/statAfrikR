# Calculer la prevalence des violences basees sur le genre

Prevalence des violences physiques, sexuelles et/ou psychologiques
exercees par un partenaire intime ou un non-partenaire. Methodologie
DHS/OMS. ODD 5.2.1.

## Usage

``` r
violence_basee_genre(
  donnees,
  var_violence_physique = NULL,
  var_violence_sexuelle = NULL,
  var_violence_psycho = NULL,
  poids = NULL,
  sous_groupes = NULL
)
```

## Arguments

- donnees:

  data.frame – Donnees femmes (15-49 ans)

- var_violence_physique:

  character ou NULL – VBG physique (0/1)

- var_violence_sexuelle:

  character ou NULL – VBG sexuelle (0/1)

- var_violence_psycho:

  character ou NULL – VBG psychologique (0/1)

- poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- sous_groupes:

  character ou NULL – Variables de desagregation. Defaut : NULL

## Value

Un tibble avec prevalence par type de violence

## Examples

``` r
set.seed(42)
n <- 500
femmes <- data.frame(
  vbg_phys   = rbinom(n, 1, 0.28),
  vbg_sex    = rbinom(n, 1, 0.18),
  vbg_psycho = rbinom(n, 1, 0.35),
  milieu     = sample(c("urbain","rural"), n, TRUE),
  poids      = runif(n, 0.8, 1.3)
)
violence_basee_genre(femmes,
  var_violence_physique  = "vbg_phys",
  var_violence_sexuelle  = "vbg_sex",
  var_violence_psycho    = "vbg_psycho",
  poids = "poids", sous_groupes = "milieu")
#> === Violences basees sur le genre (ODD 5.2.1) ===
#>   Physique : 28.26%
#>   Sexuelle : 17.05%
#>   Psychologique : 34.29%
#>   Au moins une forme : 61.2%
#> # A tibble: 4 × 5
#>   type_violence      prevalence_pct ic_bas ic_haut n_obs
#>   <chr>                       <dbl>  <dbl>   <dbl> <int>
#> 1 Physique                     28.3   24.5    32.4   500
#> 2 Sexuelle                     17.0   14.0    20.6   500
#> 3 Psychologique                34.3   30.3    38.6   500
#> 4 Au moins une forme           61.2   56.9    65.4   500
```
