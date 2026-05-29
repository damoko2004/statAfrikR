# Generer un bulletin statistique periodique

Genere un bulletin statistique mensuel ou trimestriel avec indicateurs
cles, graphiques de tendance et tableau de bord.

## Usage

``` r
generer_bulletin(
  indicateurs,
  periode,
  pays = "Pays",
  sortie = c("html", "word"),
  chemin_sortie = tempdir(),
  ouvrir = FALSE
)
```

## Arguments

- indicateurs:

  data.frame – Tableau des indicateurs avec colonnes : `indicateur`,
  `valeur`, `unite`, `periode`

- periode:

  character – Periode de reference (ex : "T1 2026", "Janvier 2026")

- pays:

  character – Nom du pays. Defaut : "Pays"

- sortie:

  character – Format : `"html"` ou `"word"`. Defaut : "html"

- chemin_sortie:

  character – Repertoire de destination. Defaut :
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html)

- ouvrir:

  logical – Ouvrir apres generation. Defaut : FALSE

## Value

Chemin du fichier genere (invisible)

## Examples

``` r
if (FALSE) { # \dontrun{
  indicateurs <- data.frame(
    indicateur = c("Taux de pauvrete", "Taux de chomage",
                   "Acces eau potable", "Taux alphabetisation"),
    valeur     = c(71.8, 14.5, 42.3, 56.7),
    unite      = c("%", "%", "%", "%"),
    periode    = rep("2026", 4)
  )
  generer_bulletin(indicateurs, periode = "T1 2026",
                   pays = "Republique Centrafricaine")
} # }
```
