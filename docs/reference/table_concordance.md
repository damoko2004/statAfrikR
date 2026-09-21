# Creer une table de concordance entre nomenclatures geographiques

Cree une table de correspondance entre les differentes nomenclatures
geographiques utilisees en Afrique : nomenclature locale des INS, codes
ISO 3166-2, codes GADM, codes EHCVM, et noms officiels. Essentielle pour
harmoniser les donnees entre plusieurs sources.

## Utilisation

``` r
table_concordance(
  donnees,
  var_nom_local = "nom_zone",
  var_code_ins = NULL,
  var_code_iso = NULL,
  var_code_gadm = NULL,
  var_niveau = NULL,
  var_pays = NULL
)
```

## Arguments

- donnees:

  data.frame – Donnees de reference avec les noms/codes des zones
  administratives

- var_nom_local:

  character – Variable nom local (utilise par l'INS). Defaut :
  "nom_zone"

- var_code_ins:

  character ou NULL – Variable code INS. Defaut : NULL

- var_code_iso:

  character ou NULL – Variable code ISO 3166-2. Defaut : NULL

- var_code_gadm:

  character ou NULL – Variable code GADM. Defaut : NULL

- var_niveau:

  character ou NULL – Variable niveau administratif (1 = region, 2 =
  departement, etc.). Defaut : NULL

- var_pays:

  character ou NULL – Variable pays (code ISO 3). Defaut : NULL

## Valeur de retour

Un objet de classe `saf_concordance`

## Exemples

``` r
zones_rca <- data.frame(
  nom_zone   = c("Bangui","Ombella-M'Poko","Bamingui-Bangoran",
                  "Mbomou","Haute-Kotto"),
  code_ins   = c("01","02","03","04","05"),
  code_iso   = c("CF-BGF","CF-MP","CF-BB","CF-MB","CF-HK"),
  code_gadm  = c("GADMa001","GADMa002","GADMa003","GADMa004","GADMa005"),
  niveau     = rep(1L, 5),
  pays       = rep("CAF", 5),
  stringsAsFactors = FALSE
)
table_concordance(zones_rca, var_nom_local="nom_zone",
                   var_code_ins="code_ins", var_code_iso="code_iso",
                   var_code_gadm="code_gadm", var_niveau="niveau",
                   var_pays="pays")
#> === Table de concordance ===
#>   Zones : 5
#>   Nomenclatures : 6 (nom_local + code_ins, code_iso, code_gadm, niveau, pays)
#> 
#> === Table de concordance geographique ===
#>   Zones         : 5 
#>   Nomenclatures : nom_local | code_ins | code_iso | code_gadm | niveau | pays 
#>   Doublons      : 0 
#> # A tibble: 5 × 7
#>   nom_local         code_ins code_iso code_gadm niveau pays  nom_normalise    
#>   <chr>             <chr>    <chr>    <chr>     <chr>  <chr> <chr>            
#> 1 Bangui            01       CF-BGF   GADMa001  1      CAF   bangui           
#> 2 Ombella-M'Poko    02       CF-MP    GADMa002  1      CAF   ombella-mpoko    
#> 3 Bamingui-Bangoran 03       CF-BB    GADMa003  1      CAF   bamingui-bangoran
#> 4 Mbomou            04       CF-MB    GADMa004  1      CAF   mbomou           
#> 5 Haute-Kotto       05       CF-HK    GADMa005  1      CAF   haute-kotto      
```
