# Generer un rapport d'enquete menage parametre

Genere un rapport statistique complet a partir de donnees d'enquete
menage, en utilisant un template R Markdown pre-construit. Le rapport
inclut une page de garde, des statistiques descriptives, une pyramide
demographique et les indicateurs cles.

## Usage

``` r
generer_rapport_enquete(
  donnees,
  meta = list(),
  template = c("enquete_menage", "bulletin"),
  sortie = c("html", "pdf", "word"),
  chemin_sortie = tempdir(),
  vars_analyse = NULL,
  var_poids = NULL,
  ouvrir = FALSE
)
```

## Arguments

- donnees:

  data.frame – Donnees d'enquete menage

- meta:

  list – Metadonnees du rapport. Elements attendus : `pays`, `titre`,
  `annee`, `source`, `auteur` (tous optionnels)

- template:

  character – Nom du template : `"enquete_menage"` ou `"bulletin"`.
  Defaut : "enquete_menage"

- sortie:

  character – Format de sortie : `"html"`, `"pdf"` ou `"word"`. Defaut :
  "html"

- chemin_sortie:

  character – Repertoire de destination. Defaut :
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html)

- vars_analyse:

  character ou NULL – Variables a analyser. Si NULL, detecte
  automatiquement les variables numeriques. Defaut : NULL

- var_poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- ouvrir:

  logical – Ouvrir le rapport apres generation. Defaut : FALSE

## Value

Chemin du fichier genere (invisible)

## Examples

``` r
if (FALSE) { # \dontrun{
  set.seed(42)
  donnees <- data.frame(
    age    = sample(18:70, 200, replace = TRUE),
    revenu = rexp(200, rate = 1/250000),
    sexe   = sample(c("H","F"), 200, TRUE),
    milieu = sample(c("urbain","rural"), 200, TRUE),
    poids  = runif(200, 0.8, 1.3)
  )
  meta <- list(
    pays   = "Republique Centrafricaine",
    titre  = "Enquete sur les conditions de vie des menages",
    annee  = 2026L,
    source = "ICASEES",
    auteur = "Direction des Statistiques"
  )
  generer_rapport_enquete(donnees, meta, sortie = "html")
} # }
```
