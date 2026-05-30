# =============================================================================
# data-raw/create_geodata.R
# Generation COMPLETE des fonds de cartes embarques dans statAfrikR
# - 54 pays africains (contours nationaux)
# - Toutes les subdivisions de niveau 1 (prefectures/regions/provinces)
#   pour tous les pays africains
# - Zones regionales : CEMAC, CEDEAO, EAC, SADC
# - Prefectures RCA
#
# A executer UNE SEULE FOIS pour regenerer les donnees
# Necessite : rnaturalearth, rnaturalearthdata, sf, dplyr, usethis
# =============================================================================

for (pkg in c("sf","rnaturalearth","rnaturalearthdata","dplyr","usethis")) {
  if (!requireNamespace(pkg, quietly = TRUE))
    stop(paste0("Installez : install.packages('", pkg, "')"))
}

library(sf)
library(rnaturalearth)
library(dplyr)

message("\n=== Generation des fonds de cartes statAfrikR ===\n")

TOL <- 0.05  # Tolerance simplification (degres)

# ==========================================================================
# 1. PAYS AFRICAINS (54 pays — contours nationaux)
# ==========================================================================

message("1. Pays africains (contours nationaux)...")

saf_pays_afrique <- ne_countries(
  continent   = "Africa",
  returnclass = "sf",
  scale       = "medium"
) |>
  dplyr::select(
    pays       = name,
    pays_fr    = name_fr,
    iso2       = iso_a2,
    iso3       = iso_a3,
    sous_region = subregion,
    geometry
  ) |>
  sf::st_transform(crs = 4326) |>
  sf::st_simplify(dTolerance = TOL, preserveTopology = TRUE) |>
  sf::st_make_valid()

message("   Pays : ", nrow(saf_pays_afrique))

# ==========================================================================
# 2. ZONES REGIONALES
# ==========================================================================

message("2. Zones regionales...")

iso_cemac  <- c("CMR","CAF","COG","GAB","GNQ","TCD")
iso_cedeao <- c("BEN","BFA","CPV","CIV","GMB","GHA",
                 "GIN","GNB","LBR","MLI","NER","NGA",
                 "SEN","SLE","TGO")
iso_eau    <- c("BDI","COM","DJI","ERI","ETH","KEN",
                 "MDG","MWI","MUS","MOZ","RWA","SYC",
                 "SOM","SSD","TZA","UGA","ZMB","ZWE")
iso_sadc   <- c("AGO","BWA","COM","COD","LSO","MDG",
                 "MWI","MUS","MOZ","NAM","SYC","ZAF",
                 "SWZ","TZA","ZMB","ZWE")

saf_cemac  <- dplyr::filter(saf_pays_afrique, .data$iso3 %in% iso_cemac)
saf_cedeao <- dplyr::filter(saf_pays_afrique, .data$iso3 %in% iso_cedeao)
saf_eau    <- dplyr::filter(saf_pays_afrique, .data$iso3 %in% iso_eau)
saf_sadc   <- dplyr::filter(saf_pays_afrique, .data$iso3 %in% iso_sadc)

message("   CEMAC : ", nrow(saf_cemac),
        " | CEDEAO : ", nrow(saf_cedeao),
        " | EAC : ", nrow(saf_eau),
        " | SADC : ", nrow(saf_sadc))

# ==========================================================================
# 3. SUBDIVISIONS NIVEAU 1 — TOUS LES PAYS AFRICAINS
#    (prefectures / regions / provinces / etats)
# ==========================================================================

message("3. Subdivisions niveau 1 pour tous les pays africains...")
message("   (operation de 1 a 2 minutes selon la connexion)\n")

# Liste de tous les pays africains avec leur nom rnaturalearth
pays_afrique_noms <- saf_pays_afrique$pays

# Charger toutes les subdivisions d'Afrique
# ne_states() retourne toutes les subdiv mondiales — on filtre ensuite
message("   Chargement global des subdivisions africaines...")

# Codes ISO3 africains
iso3_afrique <- saf_pays_afrique$iso3

# Recuperer les subdiv pour chaque pays
toutes_subdiv <- lapply(seq_along(pays_afrique_noms), function(i) {
  pays_nom <- pays_afrique_noms[i]
  iso_code <- iso3_afrique[i]

  subdiv <- tryCatch({
    s <- ne_states(country = pays_nom, returnclass = "sf")

    # Harmoniser les colonnes
    s <- s |>
      dplyr::select(
        subdivision = name,
        code_admin  = iso_3166_2,
        geometry
      ) |>
      dplyr::mutate(
        pays    = pays_nom,
        iso3    = iso_code,
        .before = 1
      ) |>
      sf::st_transform(crs = 4326) |>
      sf::st_simplify(dTolerance = TOL, preserveTopology = TRUE) |>
      sf::st_make_valid()

    message("   OK  ", iso_code, " — ", pays_nom,
            " (", nrow(s), " subdivisions)")
    s

  }, error = function(e) {
    message("   N/A ", iso_code, " — ", pays_nom,
            " (pas de donnees niveau 1)")
    NULL
  })

  subdiv
})

# Combiner tous les pays en un seul sf
toutes_subdiv_valides <- Filter(Negate(is.null), toutes_subdiv)
saf_subdivisions_afrique <- dplyr::bind_rows(toutes_subdiv_valides)

message("\n   Total subdivisions : ", nrow(saf_subdivisions_afrique),
        " dans ", length(toutes_subdiv_valides), " pays")

# Dataset RCA specifique (usage frequent)
saf_rca_prefectures <- dplyr::filter(
  saf_subdivisions_afrique, .data$iso3 == "CAF"
) |>
  dplyr::rename(prefecture = subdivision)

message("   RCA prefectures : ", nrow(saf_rca_prefectures))

# ==========================================================================
# 4. SAUVEGARDE
# ==========================================================================

message("\n4. Sauvegarde des donnees...")

usethis::use_data(saf_pays_afrique,         overwrite = TRUE, compress = "xz")
usethis::use_data(saf_cemac,                overwrite = TRUE, compress = "xz")
usethis::use_data(saf_cedeao,               overwrite = TRUE, compress = "xz")
usethis::use_data(saf_eau,                  overwrite = TRUE, compress = "xz")
usethis::use_data(saf_sadc,                 overwrite = TRUE, compress = "xz")
usethis::use_data(saf_rca_prefectures,      overwrite = TRUE, compress = "xz")
usethis::use_data(saf_subdivisions_afrique, overwrite = TRUE, compress = "xz")

message("\n=== Fonds de cartes generes avec succes ===")
message("Fichiers dans data/ :")
for (f in list.files("data/", full.names = TRUE)) {
  message("  ", basename(f), " : ",
          round(file.size(f) / 1024, 1), " Ko")
}
total_ko <- sum(file.size(list.files("data/", full.names = TRUE))) / 1024
message("  TOTAL : ", round(total_ko, 0), " Ko")
