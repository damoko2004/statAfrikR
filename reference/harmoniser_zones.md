# Harmoniser les noms de zones geographiques

Normalise automatiquement les noms de zones : suppression des accents,
standardisation de la casse, suppression des caracteres speciaux. Permet
de faire des jointures geographiques robustes meme quand les
orthographes different entre sources.

## Usage

``` r
harmoniser_zones(
  donnees,
  var_zone,
  reference = NULL,
  var_ref = "nom_local",
  seuil_similarite = 0.85
)
```

## Arguments

- donnees:

  data.frame – Donnees a harmoniser

- var_zone:

  character – Variable contenant les noms de zones

- reference:

  saf_concordance ou data.frame – Table de reference. Si NULL, harmonise
  seulement les noms (sans correspondance). Defaut : NULL

- var_ref:

  character – Variable de la reference correspondant. Defaut :
  "nom_local"

- seuil_similarite:

  numeric – Seuil de score Jaro-Winkler pour l'appariement automatique
  (0-1). Defaut : 0.85

## Value

Un data.frame avec colonne supplementaire de nom harmonise

## Examples

``` r
donnees_enquete <- data.frame(
  region    = c("Bangui","BANGUI","Ombella Mpoko","Bamingui Bangoran"),
  valeur    = c(120, 85, 200, 150),
  stringsAsFactors = FALSE
)
harmoniser_zones(donnees_enquete, "region")
#> Nettoyage effectue sur 1 variable(s) :
#>   region : 4 valeur(s) modifiee(s)
#>              region valeur  region_normalise
#> 1            Bangui    120            bangui
#> 2            BANGUI     85            bangui
#> 3     Ombella Mpoko    200     ombella mpoko
#> 4 Bamingui Bangoran    150 bamingui bangoran
```
