# =============================================================================
# Patch : mise à jour de carte_zones() pour saf_subdivisions_afrique
# A appliquer dans R/cartographie.R
# =============================================================================

# Remplacer .ZONES_DISPONIBLES dans R/cartographie.R
lines <- readLines("R/cartographie.R")

# Remplacer la definition des zones
idx <- grep(".ZONES_DISPONIBLES", lines)[1]
lines[idx] <- '.ZONES_DISPONIBLES <- c(
  "afrique"      = "saf_pays_afrique",
  "cemac"        = "saf_cemac",
  "cedeao"       = "saf_cedeao",
  "eau"          = "saf_eau",
  "sadc"         = "saf_sadc",
  "rca"          = "saf_rca_prefectures",
  "subdivisions" = "saf_subdivisions_afrique"
)'

# Mettre à jour la signature de carte_zones()
lines <- gsub(
  'zone = c\\("afrique", "cemac", "cedeao",\\s*"eau", "sadc", "rca"\\)',
  'zone = c("afrique", "cemac", "cedeao", "eau", "sadc", "rca", "subdivisions")',
  paste(lines, collapse = "\n")
)
lines <- strsplit(lines, "\n")[[1]]

writeLines(lines, "R/cartographie.R")
message("carte_zones() mise à jour avec 'subdivisions'")
