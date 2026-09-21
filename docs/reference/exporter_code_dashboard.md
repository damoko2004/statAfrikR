# Exporter le code source complet du dashboard

Genere un fichier R autonome et entierement commente que l'agent INS
peut ouvrir, modifier et relancer librement. Contient l'integralite du
code du dashboard avec des sections clairement identifiees pour la
personnalisation : titres, couleurs, indicateurs, filtres, sections.

## Utilisation

``` r
exporter_code_dashboard(
  chemin = "dashboard_statAfrikR.R",
  pays = "Pays",
  titre = NULL,
  sous_titre = NULL,
  var_poids = NULL,
  var_region = NULL,
  var_milieu = NULL
)
```

## Arguments

- chemin:

  character – Chemin du fichier R a generer. Defaut :
  "dashboard_statAfrikR.R"

- pays:

  character – Nom du pays pre-rempli. Defaut : "Pays"

- titre:

  character ou NULL – Titre pre-rempli. Defaut : NULL

- sous_titre:

  character ou NULL – Sous-titre pre-rempli. Defaut : NULL

- var_poids:

  character ou NULL – Variable poids pre-remplie. Defaut : NULL

- var_region:

  character ou NULL – Variable region pre-remplie. Defaut : NULL

- var_milieu:

  character ou NULL – Variable milieu pre-remplie. Defaut : NULL

## Valeur de retour

Invisible : chemin du fichier genere

## Exemples

``` r
if (FALSE) { # \dontrun{
  # Generer le code source personnalisable
  exporter_code_dashboard(
    chemin     = "mon_dashboard_rca.R",
    pays       = "Republique Centrafricaine",
    titre      = "Tableau de bord - Enquete EHCVM 2022",
    sous_titre = "Indicateurs bien-etre - INS RCA",
    var_poids  = "poids_sondage",
    var_region = "prefecture",
    var_milieu = "milieu"
  )
  # Ouvrir le fichier genere dans RStudio
  file.edit("mon_dashboard_rca.R")
} # }
```
