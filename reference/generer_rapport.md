# Générer un rapport statistique officiel

Produit un rapport Word (.docx) ou PDF à partir d'un template R
Markdown. Intègre automatiquement les tableaux, graphiques et
métadonnées. Compatible avec les templates AFRISTAT et PARIS21.

## Usage

``` r
generer_rapport(
  donnees,
  template = "bulletin_mensuel",
  format_sortie = c("word", "pdf"),
  fichier_sortie = NULL,
  metadonnees = NULL,
  ouvrir = FALSE
)
```

## Arguments

- donnees:

  data.frame ou tibble — Données à inclure dans le rapport

- template:

  character — Chemin vers le template .Rmd ou nom d'un template intégré
  : `"bulletin_mensuel"`, `"rapport_annuel"`, `"fiche_pays"`. Défaut :
  "bulletin_mensuel".

- format_sortie:

  character — `"word"` ou `"pdf"`. Défaut : "word".

- fichier_sortie:

  character ou NULL — Chemin du fichier de sortie. Si NULL, génère un
  nom automatique. Défaut : NULL.

- metadonnees:

  list ou NULL — Liste de métadonnées à injecter : titre, auteur, pays,
  annee, institution. Défaut : NULL.

- ouvrir:

  logical — Ouvrir le rapport après génération. Défaut : FALSE.

## Value

Chemin du fichier généré (invisible).

## Examples

``` r
if (FALSE) { # \dontrun{
  generer_rapport(
    donnees        = resultats_enquete,
    template       = "bulletin_mensuel",
    format_sortie  = "word",
    metadonnees    = list(
      titre       = "Bulletin mensuel — Mars 2024",
      pays        = "Bénin",
      institution = "INSAE",
      annee       = 2024
    )
  )
} # }
```
