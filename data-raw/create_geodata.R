# =============================================================================
# data-raw/create_geodata.R
# Generation et mise a jour des fonds de cartes statAfrikR
# Sources : Natural Earth (rnaturalearth) + GADM (geodata) pour les pays
#           non couverts par Natural Earth
#
# UTILISATION :
#   source("data-raw/create_geodata.R")          # mise a jour complete
#   source("data-raw/create_geodata.R")           # avec verif changements
#
# PACKAGES REQUIS (une seule fois) :
#   install.packages(c("sf","rnaturalearth","rnaturalearthdata",
#                      "geodata","dplyr","usethis","digest"))
# =============================================================================

for (pkg in c("sf","rnaturalearth","rnaturalearthdata",
              "geodata","dplyr","usethis","digest")) {
  if (!requireNamespace(pkg, quietly = TRUE))
    stop(paste0("Package manquant. Installez : install.packages('", pkg, "')"))
}

library(sf)
library(rnaturalearth)
library(dplyr)

message("\n", strrep("=", 60))
message("  statAfrikR — Mise a jour des fonds de cartes")
message("  Date : ", format(Sys.Date(), "%d/%m/%Y"))
message(strrep("=", 60), "\n")

TOL <- 0.05  # Tolerance simplification

# ==========================================================================
# ETAPE 0 : LECTURE DES HACHAGES EXISTANTS
# Permet de detecter si une mise a jour est necessaire
# ==========================================================================

.lire_hachages <- function() {
  f <- "data-raw/.geodata_hashes.rds"
  if (file.exists(f)) readRDS(f) else list()
}

.ecrire_hachages <- function(hachages) {
  saveRDS(hachages, "data-raw/.geodata_hashes.rds")
}

.hacher_sf <- function(sf_obj) {
  digest::digest(list(
    nrow    = nrow(sf_obj),
    noms    = sort(unique(sf_obj[[names(sf_obj)[1]]])),
    colonnes = names(sf_obj)
  ), algo = "md5")
}

hachages_anciens <- .lire_hachages()
hachages_nouveaux <- list()
mises_a_jour      <- character(0)

message("ETAPE 0 : Chargement des hachages existants...")
if (length(hachages_anciens) == 0) {
  message("  Premiere generation — tous les datasets seront crees.")
} else {
  message("  ", length(hachages_anciens), " hachages existants trouves.")
}

# ==========================================================================
# ETAPE 1 : PAYS AFRICAINS (54 pays — Natural Earth)
# ==========================================================================

message("\nETAPE 1 : Pays africains (Natural Earth)...")

saf_pays_afrique_new <- ne_countries(
  continent   = "Africa",
  returnclass = "sf",
  scale       = "medium"
) |>
  dplyr::select(
    pays        = name,
    pays_fr     = name_fr,
    iso2        = iso_a2,
    iso3        = iso_a3,
    sous_region = subregion,
    geometry
  ) |>
  sf::st_transform(crs = 4326) |>
  sf::st_simplify(dTolerance = TOL, preserveTopology = TRUE) |>
  sf::st_make_valid()

hash_new <- .hacher_sf(saf_pays_afrique_new)
hachages_nouveaux[["saf_pays_afrique"]] <- hash_new

if (!identical(hachages_anciens[["saf_pays_afrique"]], hash_new)) {
  message("  CHANGEMENT DETECTE — mise a jour saf_pays_afrique")
  saf_pays_afrique <- saf_pays_afrique_new
  mises_a_jour     <- c(mises_a_jour, "saf_pays_afrique")
} else {
  message("  Aucun changement — conservation des donnees existantes")
  load("data/saf_pays_afrique.rda")
}
message("  Pays : ", nrow(saf_pays_afrique))

# ==========================================================================
# ETAPE 2 : ZONES REGIONALES
# ==========================================================================

message("\nETAPE 2 : Zones regionales...")

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

if ("saf_pays_afrique" %in% mises_a_jour) {
  mises_a_jour <- c(mises_a_jour, "saf_cemac","saf_cedeao","saf_eau","saf_sadc")
}

message("  CEMAC : ", nrow(saf_cemac), " | CEDEAO : ", nrow(saf_cedeao),
        " | EAC : ", nrow(saf_eau), " | SADC : ", nrow(saf_sadc))

# ==========================================================================
# ETAPE 3 : SUBDIVISIONS NIVEAU 1 — TOUS LES PAYS
# Source principale : Natural Earth
# Source complementaire : GADM pour les 11 pays manquants
# ==========================================================================

message("\nETAPE 3 : Subdivisions niveau 1 (Natural Earth + GADM)...")
message("  Pays couverts par Natural Earth...")

iso3_afrique  <- saf_pays_afrique$iso3
pays_noms     <- saf_pays_afrique$pays

# ---- 3a. Natural Earth ----
toutes_subdiv_ne <- lapply(seq_along(pays_noms), function(i) {
  tryCatch({
    s <- ne_states(country = pays_noms[i], returnclass = "sf") |>
      dplyr::select(subdivision = name,
                    code_admin  = iso_3166_2,
                    geometry) |>
      dplyr::mutate(pays = pays_noms[i],
                    iso3 = iso3_afrique[i],
                    .before = 1) |>
      sf::st_transform(crs = 4326) |>
      sf::st_simplify(dTolerance = TOL, preserveTopology = TRUE) |>
      sf::st_make_valid()
    message("  OK  [NE] ", iso3_afrique[i], " — ", pays_noms[i],
            " (", nrow(s), ")")
    s
  }, error = function(e) NULL)
})

ne_ok    <- !sapply(toutes_subdiv_ne, is.null)
ne_iso   <- iso3_afrique[ne_ok]
manquants_iso <- iso3_afrique[!ne_ok]

message("\n  Pays manquants (", length(manquants_iso),
        ") — complement via GADM...")

# ---- 3b. GADM pour les pays manquants ----
# ISO3 des pays africains non couverts par Natural Earth
# (hors Sahara Occidental ESH — territoire dispute non reconnu)
gadm_iso_cibles <- setdiff(
  manquants_iso,
  c("ESH")  # Sahara Occidental exclu (statut territorial dispute)
)

toutes_subdiv_gadm <- lapply(gadm_iso_cibles, function(iso) {
  pays_nom <- saf_pays_afrique$pays[saf_pays_afrique$iso3 == iso]
  tryCatch({
    # GADM retourne un SpatVector (terra) — convertir en sf
    gadm_raw <- geodata::gadm(
      country = iso,
      level   = 1,
      path    = tempdir()
    )
    col_name <- intersect(c("NAME_1","name_1","Name_1"), names(gadm_raw))[1]
    s <- sf::st_as_sf(gadm_raw) |>
      dplyr::rename(subdivision = dplyr::all_of(col_name)) |>
      dplyr::select(subdivision, geometry) |>
      dplyr::mutate(
        code_admin = paste0(iso, "-", seq_len(dplyr::n())),
        pays       = pays_nom,
        iso3       = iso,
        .before    = 1
      ) |>
      sf::st_transform(crs = 4326) |>
      sf::st_simplify(dTolerance = TOL, preserveTopology = TRUE) |>
      sf::st_make_valid()
    message("  OK  [GADM] ", iso, " — ", pays_nom,
            " (", nrow(s), ")")
    s
  }, error = function(e) {
    message("  N/A [GADM] ", iso, " — ", pays_nom,
            " (non disponible)")
    NULL
  })
})

# ---- 3c. Combiner Natural Earth + GADM ----
toutes_ne_valides   <- Filter(Negate(is.null), toutes_subdiv_ne)
toutes_gadm_valides <- Filter(Negate(is.null), toutes_subdiv_gadm)
toutes_combinees    <- c(toutes_ne_valides, toutes_gadm_valides)

saf_subdivisions_new <- dplyr::bind_rows(toutes_combinees)

# ---- 3d. Prefectures RCA (Natural Earth direct) ----
saf_rca_new <- tryCatch(
  ne_states("Central African Republic", returnclass = "sf") |>
    dplyr::select(subdivision = name, code_admin = iso_3166_2, geometry) |>
    dplyr::mutate(pays = "Central African Republic",
                  iso3 = "CAF", .before = 1) |>
    sf::st_transform(crs = 4326) |>
    sf::st_simplify(dTolerance = TOL, preserveTopology = TRUE) |>
    sf::st_make_valid(),
  error = function(e) NULL
)

if (!is.null(saf_rca_new)) {
  saf_subdivisions_new <- dplyr::bind_rows(
    dplyr::filter(saf_subdivisions_new, .data$iso3 != "CAF"),
    saf_rca_new
  )
}

# Detection de changement
hash_subdiv_new <- .hacher_sf(saf_subdivisions_new)
hachages_nouveaux[["saf_subdivisions_afrique"]] <- hash_subdiv_new

if (!identical(hachages_anciens[["saf_subdivisions_afrique"]],
               hash_subdiv_new)) {
  message("\n  CHANGEMENT DETECTE — mise a jour saf_subdivisions_afrique")
  saf_subdivisions_afrique <- saf_subdivisions_new
  mises_a_jour <- c(mises_a_jour, "saf_subdivisions_afrique")
} else {
  message("\n  Aucun changement sur les subdivisions")
  if (file.exists("data/saf_subdivisions_afrique.rda"))
    load("data/saf_subdivisions_afrique.rda")
}

# Dataset RCA specifique
saf_rca_prefectures <- dplyr::filter(
  saf_subdivisions_afrique, .data$iso3 == "CAF"
) |>
  dplyr::rename(prefecture = subdivision)

n_pays_couverts <- length(unique(saf_subdivisions_afrique$iso3))
message("\n  Total : ", nrow(saf_subdivisions_afrique),
        " subdivisions dans ", n_pays_couverts, " pays")
message("  RCA : ", nrow(saf_rca_prefectures), " prefectures")

# ==========================================================================
# ETAPE 4 : SAUVEGARDE CONDITIONNELLE
# ==========================================================================

message("\nETAPE 4 : Sauvegarde...")

if (length(mises_a_jour) == 0) {
  message("  AUCUNE MISE A JOUR NECESSAIRE.")
  message("  Tous les fonds de cartes sont a jour.")
} else {
  message("  Datasets a mettre a jour : ",
          paste(mises_a_jour, collapse = ", "))

  if ("saf_pays_afrique" %in% mises_a_jour) {
    usethis::use_data(saf_pays_afrique, overwrite = TRUE, compress = "xz")
    usethis::use_data(saf_cemac,        overwrite = TRUE, compress = "xz")
    usethis::use_data(saf_cedeao,       overwrite = TRUE, compress = "xz")
    usethis::use_data(saf_eau,          overwrite = TRUE, compress = "xz")
    usethis::use_data(saf_sadc,         overwrite = TRUE, compress = "xz")
  }
  if ("saf_subdivisions_afrique" %in% mises_a_jour) {
    usethis::use_data(saf_subdivisions_afrique,
                      overwrite = TRUE, compress = "xz")
    usethis::use_data(saf_rca_prefectures,
                      overwrite = TRUE, compress = "xz")
  }

  # Sauvegarder les nouveaux hachages
  .ecrire_hachages(modifyList(hachages_anciens, hachages_nouveaux))
  message("  Hachages mis a jour.")
}

# ==========================================================================
# RAPPORT FINAL
# ==========================================================================

message("\n", strrep("=", 60))
message("  RAPPORT FINAL")
message(strrep("=", 60))
message("  Date            : ", format(Sys.Date(), "%d/%m/%Y"))
message("  Pays couverts   : 54")
message("  Subdivisions    : ", nrow(saf_subdivisions_afrique))
message("  Pays avec subdiv: ", n_pays_couverts, "/54")
message("  RCA prefectures : ", nrow(saf_rca_prefectures))
message("  Mises a jour    : ",
        if (length(mises_a_jour) == 0) "aucune"
        else paste(length(mises_a_jour), "dataset(s)"))
if (length(mises_a_jour) > 0) {
  message("  Tailles finales :")
  for (f in list.files("data/", full.names = TRUE)) {
    message("    ", basename(f), " : ",
            round(file.size(f)/1024, 1), " Ko")
  }
}
message(strrep("=", 60))
