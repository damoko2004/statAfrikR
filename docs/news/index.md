# Changements

## statAfrikR 0.2.1

Version CRAN : 2026-09-24

*Publié sur le CRAN le 24 septembre 2026*

### Corrections CRAN

- [`generer_rapport_enquete()`](https://damoko2004.github.io/statAfrikR/reference/generer_rapport_enquete.md),
  [`generer_bulletin()`](https://damoko2004.github.io/statAfrikR/reference/generer_bulletin.md),
  [`generer_rapport_odd()`](https://damoko2004.github.io/statAfrikR/reference/generer_rapport_odd.md)
  : copie du template Rmd dans
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html) avant
  [`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html)
  (conformité CRAN policy — écriture hors librairie utilisateur)
- URLs vignettes corrigées dans `README.md` (suppression préfixes `01-`
  `02-` `03-`)
- Version incrémentée de 0.2.0 à 0.2.1
