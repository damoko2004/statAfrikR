# Comparer le PIB entre sources (INS vs UNSD vs BM vs FMI)

Compare les estimations du PIB publiees par l'INS et les institutions
internationales. Identifie les ecarts, leurs causes probables et produit
un tableau de diagnostic. Outil cle pour renforcer la maitrise du
narratif statistique national.

## Usage

``` r
comparer_pib(
  pib_ins,
  pib_intl,
  pays = "Pays",
  annee = as.integer(format(Sys.Date(), "%Y")),
  unite = "Mds FCFA",
  methode_ins = NULL,
  seuil_alerte = 3
)
```

## Arguments

- pib_ins:

  numeric – PIB publie par l'INS (en milliards FCFA ou USD selon l'unite
  choisie)

- pib_intl:

  named numeric – PIB des institutions internationales. Vecteur nomme :
  ex : c(UNSD=245.2, BM=241.8, FMI=248.5)

- pays:

  character – Nom du pays. Defaut : "Pays"

- annee:

  integer – Annee de reference

- unite:

  character – Unite monetaire. Defaut : "Mds FCFA"

- methode_ins:

  character ou NULL – Methode INS : "production", "depenses", "revenus".
  Defaut : NULL

- seuil_alerte:

  numeric – Seuil d'ecart en % declenchant une alerte. Defaut : 3.0

## Value

Un objet de classe `saf_pib`

## Examples

``` r
res <- comparer_pib(
  pib_ins  = 2450.5,
  pib_intl = c(UNSD=2380.2, BM=2412.8, FMI=2398.5),
  pays     = "Cameroun",
  annee    = 2023L,
  unite    = "Mds FCFA"
)
#> === Comparaison PIB Cameroun - 2023 ===
#>   PIB INS : 2 450.5 Mds FCFA
#>   UNSD : 2 380.2 Mds FCFA  Ecart : 2.95%
#>   BM : 2 412.8 Mds FCFA  Ecart : 1.56%
#>   FMI : 2 398.5 Mds FCFA  Ecart : 2.17%
print(res)
#> 
#> === Comparaison PIB ===
#>   Pays      : Cameroun 
#>   Annee     : 2023 
#>   PIB INS   : 2 450.5 Mds FCFA 
#> 
#>   Source      PIB           Ecart         Statut
#>    ------------------------------------------------------- 
#>   UNSD        2 380.2       +2.95%      OK
#>   BM          2 412.8       +1.56%      OK
#>   FMI         2 398.5       +2.17%      OK
```
