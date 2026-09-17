# Lancer le tableau de bord interactif statAfrikR

Lance une application Shiny pre-configuree presentant tous les
indicateurs de bien-etre calcules depuis les donnees fournies. Zero code
Shiny requis. Fonctionne entierement hors ligne. Compatible EHCVM, DHS,
MICS, EFT.

## Usage

``` r
lancer_dashboard(
  donnees = NULL,
  var_poids = NULL,
  var_region = NULL,
  var_milieu = NULL,
  var_annee = NULL,
  pays = "Pays",
  titre = NULL,
  sous_titre = NULL,
  port = 3838L,
  lancer = TRUE,
  export_html = NULL
)
```

## Arguments

- donnees:

  data.frame ou NULL – Donnees menages. Si NULL, utilise des donnees de
  demonstration. Defaut : NULL

- var_poids:

  character ou NULL – Variable de ponderation. Defaut : NULL

- var_region:

  character ou NULL – Variable region/prefecture. Defaut : NULL

- var_milieu:

  character ou NULL – Variable milieu (urbain/rural). Defaut : NULL

- var_annee:

  character ou NULL – Variable annee. Defaut : NULL

- pays:

  character – Nom du pays pour les titres. Defaut : "Pays"

- titre:

  character ou NULL – Titre principal du dashboard. Defaut : 'Tableau de
  bord - '

- sous_titre:

  character ou NULL – Sous-titre du dashboard. Defaut : 'Indicateurs de
  bien-etre - - statAfrikR v0.2.0'

- port:

  integer – Port Shiny. Defaut : 3838L

- lancer:

  logical – Lancer l'app (TRUE) ou retourner l'objet shinyApp (FALSE).
  Defaut : TRUE

- export_html:

  character ou NULL – Chemin pour exporter un rapport HTML statique sans
  lancer Shiny. Defaut : NULL

## Value

Invisible : objet shinyApp si lancer=FALSE, NULL sinon

## Examples

``` r
if (FALSE) { # \dontrun{
  lancer_dashboard()
  lancer_dashboard(
    donnees    = mon_enquete,
    var_poids  = "poids_sondage",
    var_region = "prefecture",
    pays       = "Centrafrique"
  )
} # }
```
