# Valider la qualite statistique d'une enquete (INS Validation Suite)

Produit un rapport de validation complet couvrant 10 criteres de qualite
statistique institutionnelle : donnees, poids, plan de sondage, valeurs
manquantes, geographie, precision, confidentialite, metadonnees,
reproductibilite et indicateurs cles. Conforme aux standards IHSN /
PARIS21 / ONU.

## Usage

``` r
valider_statistique_ins(
  donnees,
  var_poids = NULL,
  var_region = NULL,
  var_milieu = NULL,
  var_depense = NULL,
  seuil_pauvrete = NULL,
  dictionnaire = NULL,
  seuil_na_alerte = 0.05,
  seuil_cv_alerte = 33,
  seuil_cellule = 5L,
  pays = "Pays",
  annee = as.integer(format(Sys.Date(), "%Y"))
)
```

## Arguments

- donnees:

  data.frame – Donnees de l'enquete

- var_poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- var_region:

  character ou NULL – Variable region/prefecture. Defaut : NULL

- var_milieu:

  character ou NULL – Variable milieu. Defaut : NULL

- var_depense:

  character ou NULL – Variable de consommation/depense pour le calcul
  FGT. Defaut : NULL

- seuil_pauvrete:

  numeric ou NULL – Seuil de pauvrete. Defaut : NULL

- dictionnaire:

  data.frame ou NULL – Dictionnaire des variables avec colonnes :
  variable, label, type_attendu. Defaut : NULL

- seuil_na_alerte:

  numeric – Seuil de % valeurs manquantes declenchant une alerte. Defaut
  : 0.05 (5%)

- seuil_cv_alerte:

  numeric – Seuil de CV declenchant une alerte. Defaut : 33.0

- seuil_cellule:

  integer – Seuil de confidentialite. Defaut : 5L

- pays:

  character – Nom du pays. Defaut : "Pays"

- annee:

  integer – Annee de l'enquete. Defaut : annee courante

## Value

Un objet de classe `saf_validation_ins` avec le rapport complet et le
statut global

## Examples

``` r
set.seed(42)
n <- 500
donnees <- data.frame(
  region  = sample(c("Nord","Sud","Est","Ouest"), n, TRUE),
  milieu  = sample(c("urbain","rural"), n, TRUE),
  poids   = runif(n, 800, 3500),
  depense = pmax(10000, rnorm(n, 165000, 90000)),
  sexe    = sample(c("H","F"), n, TRUE),
  age     = sample(15:80, n, TRUE),
  stringsAsFactors = FALSE
)
valider_statistique_ins(donnees,
  var_poids  = "poids",
  var_region = "region",
  var_milieu = "milieu",
  pays       = "Centrafrique",
  annee      = 2024L)
#> [ 1/10] Validation donnees...
#> [ 2/10] Validation poids de sondage...
#> [ 3/10] Analyse valeurs manquantes...
#> [ 4/10] Validation geographie...
#> [ 5/10] Evaluation precision statistique...
#> [ 6/10] Controle confidentialite...
#> [ 7/10] Verification metadonnees...
#> [ 8/10] Verification reproductibilite...
#> [ 9/10] Calcul indicateurs cles...
#> [10/10] Calcul statut global...
#> 
#> ============================================================
#>   statAfrikR -- RAPPORT DE VALIDATION INS
#>   Centrafrique - 2024
#> ============================================================
#>   [PASS] Qualite donnees
#>   [PASS] Poids de sondage
#>   [PASS] Valeurs manquantes
#>   [PASS] Geographie
#>   [PASS] Precision statistique
#>   [PASS] Confidentialite
#>   [WARN] Metadonnees
#>   [PASS] Reproductibilite
#>   [PASS] Indicateurs cles
#> ------------------------------------------------------------
#>   PASS : 10 | WARN : 1 | FAIL : 0
#>   STATUT GLOBAL : A VERIFIER
#>   Duree : 0.017000000000003s
#> ============================================================
#> 
#> 
#> === Rapport de validation INS ===
#>   Pays   : Centrafrique 
#>   Annee  : 2024 
#>   Statut : A VERIFIER 
#>   PASS   : 10 | WARN : 1 | FAIL : 0 
#>   Duree  : 0.017 s
```
