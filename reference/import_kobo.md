# Importer des données depuis KoboToolbox

Importe un formulaire KoboToolbox via fichier local (XLS/JSON) ou via
l'API REST KoboToolbox. Retourne un tibble annoté avec les métadonnées
du formulaire. Compatible avec KoboToolbox et KoBoCAT.

## Usage

``` r
import_kobo(
  source,
  uid = NULL,
  token = Sys.getenv("KOBO_TOKEN"),
  format = c("xls", "json"),
  langue = "French (fr)",
  verbose = TRUE
)
```

## Arguments

- source:

  character — Chemin vers un fichier XLS/JSON local, ou URL de base de
  l'API (ex: "https://kf.kobotoolbox.org").

- uid:

  character ou NULL — Identifiant unique du formulaire (requis si source
  = URL API). Défaut : NULL.

- token:

  character — Jeton d'authentification API. Peut aussi être défini via
  la variable d'environnement `KOBO_TOKEN`. Défaut :
  `Sys.getenv("KOBO_TOKEN")`.

- format:

  character — Format du fichier local : "xls" ou "json". Ignoré si
  source est une URL. Défaut : "xls".

- langue:

  character — Code langue pour les labels multilingues (ex: "French
  (fr)", "English (en)"). Défaut : "French (fr)".

- verbose:

  logical — Afficher les messages. Défaut : TRUE.

## Value

Un tibble avec les colonnes du formulaire. L'attribut
`attr(., "metadonnees_kobo")` contient le dictionnaire des variables.

## Examples

``` r
# \donttest{
  # Import depuis fichier XLS local
  donnees <- import_kobo(source = "data/enquete_2024.xls")
#> Error in import_kobo(source = "data/enquete_2024.xls"): Fichier KoboToolbox introuvable : 'data/enquete_2024.xls'.

  # Import depuis API KoboToolbox
  Sys.setenv(KOBO_TOKEN = "mon_token_secret")
  donnees <- import_kobo(
    source = "https://kf.kobotoolbox.org",
    uid    = "aXmNk7pQrS",
    langue = "French (fr)"
  )
#> Connexion à l'API KoboToolbox (uid: aXmNk7pQrS)...
#> Error in value[[3L]](cond): Échec de la connexion à l'API KoboToolbox.
#> Vérifiez l'URL, le token et la connectivité réseau.
#> Erreur : HTTP 404 Not Found.
# }
```
