# Importer des données ODK Central

Importe les soumissions d'un formulaire ODK Central via l'API REST ou
depuis un fichier d'export local (ZIP ou CSV). Compatible avec ODK
Central 1.x et 2.x.

## Usage

``` r
import_odk(
  source,
  projet_id = NULL,
  formulaire_id = NULL,
  email = Sys.getenv("ODK_EMAIL"),
  mot_de_passe = Sys.getenv("ODK_PASSWORD"),
  inclure_metadonnees = FALSE,
  verbose = TRUE
)
```

## Arguments

- source:

  character — URL du serveur ODK Central (ex: "https://odk.monins.org")
  ou chemin vers un fichier d'export .zip/.csv.

- projet_id:

  integer ou NULL — ID du projet ODK. Requis si source est une URL.
  Défaut : NULL.

- formulaire_id:

  character ou NULL — ID du formulaire ODK. Requis si source est une
  URL. Défaut : NULL.

- email:

  character ou NULL — Email de connexion ODK Central. Peut aussi être
  défini via `ODK_EMAIL`. Défaut : NULL.

- mot_de_passe:

  character — Mot de passe ODK Central. Peut aussi être défini via
  `ODK_PASSWORD`. Défaut : `Sys.getenv("ODK_PASSWORD")`.

- inclure_metadonnees:

  logical — Inclure les colonnes de métadonnées ODK (timestamps,
  deviceid, etc.). Défaut : FALSE.

- verbose:

  logical — Afficher les messages. Défaut : TRUE.

## Value

Un tibble contenant les soumissions du formulaire.

## Examples

``` r
if (FALSE) { # \dontrun{
  # Import depuis export ZIP local
  donnees <- import_odk(source = "data/odk_export_2024.zip")

  # Import depuis API ODK Central
  Sys.setenv(ODK_EMAIL = "admin@ins.org", ODK_PASSWORD = "motdepasse")
  donnees <- import_odk(
    source        = "https://odk.monins.org",
    projet_id     = 1,
    formulaire_id = "enquete_menage_2024"
  )
} # }
```
