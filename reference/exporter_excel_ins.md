# Export Excel institutionnel multi-feuilles

Exporte une liste de tableaux dans un classeur Excel avec feuille de
sommaire.

## Usage

``` r
exporter_excel_ins(
  tableaux,
  chemin,
  titre_classeur = "Statistiques INS",
  pays = NULL,
  annee = NULL,
  style = c("ins_standard", "minimal")
)
```

## Arguments

- tableaux:

  list – Liste nommee de data.frames a exporter

- chemin:

  character – Chemin du fichier Excel

- titre_classeur:

  character – Titre general. Defaut : `"Statistiques INS"`

- pays:

  character ou NULL – Pays/organisation. Defaut : NULL

- annee:

  integer ou NULL – Annee de reference. Defaut : NULL

- style:

  character – Style : `"ins_standard"` ou `"minimal"`. Defaut :
  "ins_standard"

## Value

Chemin du fichier cree (invisible)

## Examples

``` r
if (FALSE) { # \dontrun{
  tableaux <- list(
    "Descriptif" = data.frame(
      variable = c("age", "revenu"),
      n        = c(200L, 200L),
      moyenne  = c(38.2, 245000)
    ),
    "Croisement" = data.frame(
      region = c("Nord", "Sud"),
      urbain = c(45.2, 32.1),
      rural  = c(54.8, 67.9)
    )
  )
  chemin <- file.path(tempdir(), "stats_ins.xlsx")
  exporter_excel_ins(tableaux, chemin,
                     titre_classeur = "Enquete menages 2026",
                     pays = "Centrafrique", annee = 2026L)
} # }
```
