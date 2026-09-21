# Migrer d'une nomenclature geographique vers une autre

Convertit les codes ou noms d'une nomenclature vers une autre en
utilisant une table de concordance. Gere les fusions et scissions de
zones administratives dans le temps.

## Utilisation

``` r
migrer_nomenclature(
  donnees,
  var_zone_source,
  concordance,
  var_source = "nom_local",
  var_cible = "code_iso",
  var_resultat = "zone_harmonisee",
  conserver_non_apparies = TRUE
)
```

## Arguments

- donnees:

  data.frame – Donnees a convertir

- var_zone_source:

  character – Variable zone source

- concordance:

  saf_concordance ou data.frame – Table de concordance

- var_source:

  character – Variable source dans la concordance. Defaut : "nom_local"

- var_cible:

  character – Variable cible dans la concordance. Defaut : "code_iso"

- var_resultat:

  character – Nom de la nouvelle variable. Defaut : "zone_harmonisee"

- conserver_non_apparies:

  logical – Conserver les zones non appariees (NA dans var_cible).
  Defaut : TRUE

## Valeur de retour

Un data.frame avec la nouvelle variable de zone

## Exemples

``` r
concordance_df <- data.frame(
  nom_local  = c("Bangui","Ombella-M'Poko","Bamingui-Bangoran"),
  code_iso   = c("CF-BGF","CF-MP","CF-BB"),
  code_ins   = c("01","02","03"),
  stringsAsFactors = FALSE
)
concordance <- table_concordance(concordance_df, "nom_local",
                                  var_code_iso="code_iso",
                                  var_code_ins="code_ins")
#> === Table de concordance ===
#>   Zones : 3
#>   Nomenclatures : 3 (nom_local + code_ins, code_iso)
donnees_enquete <- data.frame(
  zone   = c("Bangui","Ombella-M'Poko","Zone inconnue"),
  valeur = c(100, 200, 150),
  stringsAsFactors = FALSE
)
migrer_nomenclature(donnees_enquete, "zone", concordance,
                     var_source="nom_local", var_cible="code_iso")
#> Migration : 2/3 zones converties | 1 non appariee(s)
#>             zone valeur zone_harmonisee
#> 1         Bangui    100          CF-BGF
#> 2 Ombella-M'Poko    200           CF-MP
#> 3  Zone inconnue    150            <NA>
```
