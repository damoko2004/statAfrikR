# Valider la coherence de la couverture geographique

Verifie que les donnees couvrent l'ensemble des zones du referentiel
officiel. Identifie les zones manquantes, les doublons et les zones
surnumeraires (non dans le referentiel).

## Utilisation

``` r
valider_coherence_geo(donnees, var_zone, referentiel, var_ref = "nom_local")
```

## Arguments

- donnees:

  data.frame – Donnees a verifier

- var_zone:

  character – Variable zone dans les donnees

- referentiel:

  data.frame ou saf_concordance – Referentiel officiel

- var_ref:

  character – Variable zone dans le referentiel. Defaut : "nom_local"

## Valeur de retour

Un tibble de rapport de coherence

## Exemples

``` r
donnees <- data.frame(
  region = c("Bangui","Ombella-M'Poko","Bangui"),
  valeur = c(100, 200, 50),
  stringsAsFactors = FALSE
)
ref <- data.frame(
  nom_local = c("Bangui","Ombella-M'Poko","Kemo","Mbomou"),
  stringsAsFactors = FALSE
)
valider_coherence_geo(donnees, "region", ref, "nom_local")
#> === Coherence geographique ===
#>   Couverture : 2/4 zones (50%)
#>   Manquantes : Kemo, Mbomou
#> # A tibble: 5 × 3
#>   critere                                valeur statut   
#>   <chr>                                   <dbl> <chr>    
#> 1 Zones du referentiel couvertes              2 Incomplet
#> 2 Zones manquantes dans les donnees           2 Alerte   
#> 3 Zones surnumeraires (hors referentiel)      0 OK       
#> 4 Doublons dans les donnees                   1 Attention
#> 5 Taux de couverture (%)                     50 Alerte   
```
