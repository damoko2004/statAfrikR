# Importer des données CSPro

Lit les fichiers de données produits par CSPro (format .dat avec
dictionnaire .dcf associé). Retourne un tibble avec les labels issus du
dictionnaire CSPro. Fonction prioritaire pour les RGPH africains.
Compatible avec CSPro 4.x à 8.x.

## Usage

``` r
import_cspro(
  fichier_dat,
  fichier_dcf = NULL,
  niveau = NULL,
  encoding = "UTF-8",
  max_lignes = NULL,
  verbose = TRUE
)
```

## Arguments

- fichier_dat:

  character — Chemin vers le fichier de données (.dat)

- fichier_dcf:

  character ou NULL — Chemin vers le dictionnaire (.dcf). Si NULL,
  recherche automatiquement un .dcf de même nom dans le même répertoire.
  Défaut : NULL.

- niveau:

  character ou NULL — Niveau d'enregistrement à lire (ex: "MENAGE",
  "INDIVIDU", "LOGEMENT"). Si NULL, lit le premier niveau. Défaut :
  NULL.

- encoding:

  character — Encodage du fichier source. Défaut : "UTF-8".

- max_lignes:

  integer ou NULL — Nombre maximum de lignes à lire (utile pour les
  tests sur grands fichiers RGPH). Défaut : NULL (tout lire).

- verbose:

  logical — Afficher les messages. Défaut : TRUE.

## Value

Un tibble avec une colonne par variable CSPro. Les labels de valeurs
sont stockés dans les attributs du tibble (`attr(., "labels_cspro")`).

## Examples

``` r
if (FALSE) { # \dontrun{
  # Import du niveau ménage d'un RGPH
  menages <- import_cspro(
    fichier_dat = "data/rgph_2024.dat",
    fichier_dcf = "data/rgph_2024.dcf",
    niveau      = "MENAGE"
  )

  # Test sur les 1000 premières lignes
  test <- import_cspro("data/rgph_2024.dat", max_lignes = 1000)
} # }
```
