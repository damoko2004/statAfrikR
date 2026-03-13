# Build propre sans .Rmd et .html dans inst/doc
devtools::build_vignettes()
# Supprimer les fichiers invalides
unlink(list.files("inst/doc", pattern = "\\.(Rmd|html)$", full.names = TRUE))
# Builder le tarball
devtools::build()
