# Consulter le catalogue des indicateurs statistiques

Retourne la fiche methodologique complete d'un indicateur : definition,
formule, standard de reference, ODD, methode de variance, seuils de
qualite et statut INS-ready. Conforme GSBPM 5.2 / UN NQAF.

## Usage

``` r
catalogue_indicateurs(
  code = NULL,
  domaine = NULL,
  format = c("tableau", "liste", "complet")
)
```

## Arguments

- code:

  character ou NULL – Code de l'indicateur. Si NULL, retourne la liste
  de tous les indicateurs disponibles. Codes disponibles : "FGT0",
  "FGT1", "FGT2", "IPM", "GINI", "STUNTING", "TAUX_ACTIVITE", "CHOMAGE",
  "INFORMEL", "MARIAGE_PRECOCE", "SATISFACTION_VIE", "PIB_CROISSANCE",
  "WHIPPLE"

- domaine:

  character ou NULL – Filtrer par domaine. Ex : "Pauvrete monetaire",
  "Emploi", "Sante et nutrition". Defaut : NULL (tous les domaines)

- format:

  character – Format de sortie : "liste" (objet R complet), "tableau"
  (tibble synthetique), "complet" (impression detaillee). Defaut :
  "tableau"

## Value

Un tibble, une liste ou un affichage selon le format choisi

## Examples

``` r
# Lister tous les indicateurs
catalogue_indicateurs()
#> # A tibble: 13 × 9
#>    code         nom   domaine standard odd   variance fonction_r gsbpm ins_ready
#>    <chr>        <chr> <chr>   <chr>    <chr> <chr>    <chr>      <chr> <lgl>    
#>  1 FGT0         Inci… Pauvre… Foster,… ODD … Taylor … calcul_fg… 5.1 … TRUE     
#>  2 FGT1         Prof… Pauvre… Foster,… ODD … Taylor … calcul_fg… 5.1 … TRUE     
#>  3 FGT2         Seve… Pauvre… Foster,… ODD … Taylor … calcul_fg… 5.1 … TRUE     
#>  4 IPM          Indi… Pauvre… Alkire … ODD … Bootstr… calcul_ip… 5.1 … TRUE     
#>  5 GINI         Coef… Inegal… Gini (1… ODD … Bootstr… calcul_gi… 5.1 … TRUE     
#>  6 STUNTING     Reta… Sante … OMS (20… ODD … Wilson … retard_cr… 5.1 … TRUE     
#>  7 TAUX_ACTIVI… Taux… Emploi  BIT / O… ODD … Wilson … taux_acti… 5.1 … TRUE     
#>  8 CHOMAGE      Taux… Emploi  BIT / O… ODD … Wilson … taux_acti… 5.1 … TRUE     
#>  9 INFORMEL     Taux… Emploi  OIT Res… ODD … Wilson … emploi_in… 5.1 … TRUE     
#> 10 MARIAGE_PRE… Taux… Genre … UNICEF … ODD … Wilson … mariage_p… 5.1 … TRUE     
#> 11 SATISFACTIO… Scor… Bien-e… OCDE (2… ODD … Standar… satisfact… 5.1 … TRUE     
#> 12 PIB_CROISSA… Taux… Compte… SCN 200… ODD … Non app… taux_croi… 5.1 … TRUE     
#> 13 WHIPPLE      Indi… Qualit… ONU DES… Non … Non app… whipple()  4.3 … TRUE     

# Fiche methodologique d'un indicateur
catalogue_indicateurs("FGT0")
#> # A tibble: 1 × 9
#>   code  nom           domaine standard odd   variance fonction_r gsbpm ins_ready
#>   <chr> <chr>         <chr>   <chr>    <chr> <chr>    <chr>      <chr> <lgl>    
#> 1 FGT0  Incidence de… Pauvre… Foster,… ODD … Taylor … calcul_fg… 5.1 … TRUE     
catalogue_indicateurs("IPM")
#> # A tibble: 1 × 9
#>   code  nom           domaine standard odd   variance fonction_r gsbpm ins_ready
#>   <chr> <chr>         <chr>   <chr>    <chr> <chr>    <chr>      <chr> <lgl>    
#> 1 IPM   Indice de Pa… Pauvre… Alkire … ODD … Bootstr… calcul_ip… 5.1 … TRUE     
catalogue_indicateurs("GINI")
#> # A tibble: 1 × 9
#>   code  nom           domaine standard odd   variance fonction_r gsbpm ins_ready
#>   <chr> <chr>         <chr>   <chr>    <chr> <chr>    <chr>      <chr> <lgl>    
#> 1 GINI  Coefficient … Inegal… Gini (1… ODD … Bootstr… calcul_gi… 5.1 … TRUE     

# Filtrer par domaine
catalogue_indicateurs(domaine = "Emploi")
#> # A tibble: 3 × 9
#>   code          nom   domaine standard odd   variance fonction_r gsbpm ins_ready
#>   <chr>         <chr> <chr>   <chr>    <chr> <chr>    <chr>      <chr> <lgl>    
#> 1 TAUX_ACTIVITE Taux… Emploi  BIT / O… ODD … Wilson … taux_acti… 5.1 … TRUE     
#> 2 CHOMAGE       Taux… Emploi  BIT / O… ODD … Wilson … taux_acti… 5.1 … TRUE     
#> 3 INFORMEL      Taux… Emploi  OIT Res… ODD … Wilson … emploi_in… 5.1 … TRUE     

# Format complet avec impression
catalogue_indicateurs("FGT0", format = "complet")
#> -------------------------------------------------------
#>   Code       : FGT0
#>   Nom        : Incidence de la pauvrete
#>   Domaine    : Pauvrete monetaire
#>   Definition : Proportion de la population vivant sous le seuil de pauvrete national
#>   Formule    : FGT0 = (1/N) * sum(1(yi < z))
#>   Population : Population totale ou sous-groupe
#>   Unite      : Proportion [0-1]
#>   Standard   : Foster, Greer & Thorbecke (1984)
#>   ODD        : ODD 1.1.1 / 1.2.1
#>   Variance   : Taylor (plan complexe) / Wilson (simple)
#>   Fonction R : calcul_fgt()
#>   GSBPM      : 5.1 - Analyse
#>   INS-ready  : Oui
#> 
```
