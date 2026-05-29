# Generer un rapport de suivi des ODD parametre

Genere un rapport de suivi des Objectifs de Developpement Durable au
format standard PARIS21/Nations Unies.

## Usage

``` r
generer_rapport_odd(
  resultats_odd,
  pays = "Pays",
  annee = as.integer(format(Sys.Date(), "%Y")),
  cibles = NULL,
  sortie = c("html", "pdf", "word"),
  chemin_sortie = tempdir(),
  ouvrir = FALSE
)
```

## Arguments

- resultats_odd:

  list – Liste d'objets `saf_odd` (resultats de
  [`odd_indicateur()`](https://damoko2004.github.io/statAfrikR/reference/odd_indicateur.md))

- pays:

  character – Nom du pays. Defaut : "Pays"

- annee:

  integer – Annee de reference. Defaut : annee courante

- cibles:

  list ou NULL – Cibles nationales par code ODD. Defaut : NULL

- sortie:

  character – Format : `"html"`, `"pdf"` ou `"word"`. Defaut : "html"

- chemin_sortie:

  character – Repertoire. Defaut :
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html)

- ouvrir:

  logical – Ouvrir apres generation. Defaut : FALSE

## Value

Chemin du fichier genere (invisible)

## Examples

``` r
if (FALSE) { # \dontrun{
  set.seed(42)
  menages <- data.frame(
    depense_pc  = c(rexp(70, 1/150000), rexp(30, 1/500000)),
    electricite = sample(c(0L,1L), 100, TRUE, c(0.45, 0.55)),
    internet    = sample(c(0L,1L), 100, TRUE, c(0.72, 0.28))
  )
  r1 <- odd_indicateur(menages, "1.2.1",
                       var_depense = "depense_pc", seuil = 200000)
  r2 <- odd_indicateur(menages, "7.1.1",
                       var_indicateur = "electricite")
  generer_rapport_odd(
    list(r1, r2),
    pays  = "Republique Centrafricaine",
    annee = 2026L,
    cibles = list("1.2.1" = 50, "7.1.1" = 80)
  )
} # }
```
