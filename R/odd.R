# =============================================================================
# statAfrikR - Module Indicateurs ODD
# Objectifs de Developpement Durable \u2014 top 20 prioritaires pour les INS
# Reference : Nations Unies (2023). SDG Indicators Global Database.
#   https://unstats.un.org/sdgs/indicators/database/
# Reference : PARIS21 (2022). Statistical Capacity Assessment Tool.
# =============================================================================

utils::globalVariables(c(
  "code_odd", "objectif", "titre_court", "disponibilite",
  "statut", "valeur", "numerateur", "denominateur"
))

# =============================================================================
# CATALOGUE DES INDICATEURS ODD
# =============================================================================

# Catalogue interne \u2014 20 indicateurs prioritaires pour les INS africains
# Selectionnes selon : PARIS21, AFRISTAT, disponibilite donnees INS
.ODD_CATALOGUE <- data.frame(
  code_odd       = c(
    "1.1.1", "1.2.1", "2.1.1", "2.2.1", "3.1.1",
    "3.2.1", "4.1.1", "5.3.1", "5.5.2", "6.1.1",
    "7.1.1", "8.5.2", "8.6.1", "10.1.1", "10.2.1",
    "11.1.1", "16.1.1", "16.9.1", "17.6.2", "17.8.1"
  ),
  objectif       = c(1L, 1L, 2L, 2L, 3L, 3L, 4L, 5L, 5L, 6L,
                     7L, 8L, 8L, 10L, 10L, 11L, 16L, 16L, 17L, 17L),
  titre_court    = c(
    "Pauvrete extreme",
    "Pauvrete nationale",
    "Sous-alimentation",
    "Retard de croissance",
    "Mortalite maternelle",
    "Mortalite infantile",
    "Competences lecture/calcul",
    "Mariage precoce",
    "Femmes postes direction",
    "Eau potable securisee",
    "Electricite",
    "Chomage",
    "NEET jeunes",
    "Croissance 40% inferieur",
    "Inclusion sociale",
    "Taudis",
    "Homicides",
    "Identite juridique",
    "Internet fixe",
    "Utilisation internet"
  ),
  titre_complet  = c(
    "Proportion de la population en dessous du seuil de pauvrete international (1,90 USD PPA/jour)",
    "Proportion de la population en dessous du seuil national de pauvrete",
    "Prevalence de la sous-alimentation",
    "Prevalence du retard de croissance chez les enfants de moins de 5 ans",
    "Taux de mortalite maternelle (pour 100 000 naissances vivantes)",
    "Taux de mortalite des enfants de moins de 5 ans (pour 1 000 naissances vivantes)",
    "Proportion d'enfants atteignant le niveau de competences minimum en lecture et calcul",
    "Proportion de femmes mariees ou en union avant l'age de 15 ans ou de 18 ans",
    "Proportion de femmes occupant des postes de direction",
    "Proportion de la population utilisant des services d'eau potable gerables en toute securite",
    "Proportion de la population ayant acces a l'electricite",
    "Taux de chomage (selon le BIT)",
    "Proportion de jeunes non scolarises, sans emploi ni formation (NEET)",
    "Taux de croissance des depenses des menages pour les 40% les plus pauvres",
    "Proportion de personnes vivant en dessous de 50% du revenu median",
    "Proportion de population urbaine habitant des taudis ou logements informels",
    "Nombre d'homicides volontaires (pour 100 000 habitants)",
    "Proportion d'enfants de moins de 5 ans dont la naissance a ete enregistree",
    "Abonnements au haut debit fixe (pour 100 habitants)",
    "Proportion de personnes utilisant Internet"
  ),
  formule        = c(
    "N(depense_pc < seuil_international) / N_total",
    "N(depense_pc < seuil_national) / N_total",
    "Modelisation FAO \u2014 donnees aggregees",
    "N(enfants retard croissance) / N(enfants < 5 ans)",
    "N(deces maternels) / N(naissances vivantes) * 100000",
    "N(deces < 5 ans) / N(naissances vivantes) * 1000",
    "N(niveau min atteint) / N(evaluations) * 100",
    "N(femmes mariees < 18 ans) / N(femmes 20-24 ans) * 100",
    "N(femmes postes direction) / N(postes direction) * 100",
    "N(menages eau securisee) / N(menages) * 100",
    "N(menages electricite) / N(menages) * 100",
    "N(chomeurs BIT) / N(actifs) * 100",
    "N(NEET 15-24 ans) / N(15-24 ans) * 100",
    "Taux croissance moyen depenses 40% inferieur",
    "N(revenu < 50% mediane) / N_total * 100",
    "N(menages taudis) / N(menages urbains) * 100",
    "N(homicides) / N(habitants) * 100000",
    "N(enfants < 5 ans enregistres) / N(enfants < 5 ans) * 100",
    "N(abonnements haut debit fixe) / N(habitants) * 100",
    "N(utilisateurs internet) / N(habitants) * 100"
  ),
  source_donnee  = c(
    "EHCVM / LSMS / Enquete menages",
    "EHCVM / LSMS / Enquete menages",
    "FAOSTAT / EDS / Enquete nutrition",
    "EDS / MICS / Enquete nutrition",
    "Etat civil / Registre sanitaire",
    "Etat civil / EDS / MICS",
    "PASEC / EGRA / Enquete educative",
    "EDS / MICS / Enquete menages",
    "Enquete emploi / Recensement",
    "MICS / EDS / Enquete menages",
    "MICS / EDS / Enquete menages",
    "Enquete emploi / ECM",
    "Enquete emploi / ECM",
    "EHCVM / LSMS / Panel menages",
    "EHCVM / Enquete menages",
    "RGPH / Enquete logement",
    "Statistiques judiciaires / Police",
    "RGPH / Etat civil",
    "ARCEP / ITU / Operateurs",
    "MICS / EDS / Enquete TIC"
  ),
  disponibilite  = c(
    "haute", "haute", "moyenne", "haute", "moyenne",
    "haute", "moyenne", "haute", "haute", "haute",
    "haute", "haute", "haute", "moyenne", "haute",
    "moyenne", "faible", "moyenne", "faible", "haute"
  ),
  unite          = c(
    "%", "%", "%", "%", "pour 100 000",
    "pour 1 000", "%", "%", "%", "%",
    "%", "%", "%", "%", "%",
    "%", "pour 100 000", "%", "pour 100", "%"
  ),
  statut         = c(
    "implementee", "implementee", "documentation", "implementee", "documentation",
    "implementee", "documentation", "implementee", "implementee", "implementee",
    "implementee", "implementee", "implementee", "implementee", "implementee",
    "implementee", "documentation", "implementee", "documentation", "implementee"
  ),
  stringsAsFactors = FALSE
)

# =============================================================================
# 1. CATALOGUE DES INDICATEURS ODD
# =============================================================================

#' @title Catalogue des indicateurs ODD pour les INS africains
#' @description Retourne le catalogue des indicateurs ODD implementes dans
#'   statAfrikR, selectionnes selon leur pertinence et disponibilite pour
#'   les INS africains (reference PARIS21, AFRISTAT, Nations Unies).
#'
#' @param objectif integer ou NULL -- Filtrer par numero d'ODD (1 a 17).
#'   NULL retourne tous les indicateurs. Defaut : NULL
#' @param disponibilite character ou NULL -- Filtrer par disponibilite des
#'   donnees : \code{"haute"}, \code{"moyenne"} ou \code{"faible"}.
#'   Defaut : NULL
#' @param statut character ou NULL -- Filtrer par statut d'implementation :
#'   \code{"implementee"} ou \code{"documentation"}.
#'   Defaut : NULL
#' @param format character -- \code{"tibble"} ou \code{"flextable"}.
#'   Defaut : "tibble"
#'
#' @return Tibble ou flextable du catalogue filtre
#'
#' @examples
#' # Tous les indicateurs
#' odd_catalogue()
#'
#' # Indicateurs ODD 1 (pauvrete) implementes
#' odd_catalogue(objectif = 1, statut = "implementee")
#'
#' # Indicateurs a haute disponibilite
#' odd_catalogue(disponibilite = "haute")
#'
#' @export
odd_catalogue <- function(objectif      = NULL,
                           disponibilite = NULL,
                           statut        = NULL,
                           format        = c("tibble", "flextable")) {

  format <- match.arg(format)

  cat <- .ODD_CATALOGUE

  if (!is.null(objectif)) {
    if (!is.numeric(objectif) || any(objectif < 1 | objectif > 17)) {
      rlang::abort("`objectif` doit etre un entier entre 1 et 17.")
    }
    cat <- cat[cat$objectif %in% as.integer(objectif), ]
  }

  if (!is.null(disponibilite)) {
    niveaux <- c("haute", "moyenne", "faible")
    if (!all(disponibilite %in% niveaux)) {
      rlang::abort(paste0(
        "`disponibilite` doit etre parmi : ",
        paste(niveaux, collapse = ", ")
      ))
    }
    cat <- cat[cat$disponibilite %in% disponibilite, ]
  }

  if (!is.null(statut)) {
    statuts <- c("implementee", "documentation")
    if (!all(statut %in% statuts)) {
      rlang::abort(paste0(
        "`statut` doit etre parmi : ",
        paste(statuts, collapse = ", ")
      ))
    }
    cat <- cat[cat$statut %in% statut, ]
  }

  if (nrow(cat) == 0) {
    rlang::warn("Aucun indicateur ne correspond aux filtres appliques.")
    return(tibble::as_tibble(cat))
  }

  res <- tibble::as_tibble(cat[, c("code_odd", "objectif", "titre_court",
                                    "source_donnee", "unite",
                                    "disponibilite", "statut")])

  if (format == "flextable") {
    .verifier_package("flextable", "odd_catalogue")
    return(
      flextable::flextable(res) |>
        flextable::set_caption(caption = "Catalogue ODD statAfrikR") |>
        flextable::bg(bg = "#0F2742", part = "header") |>
        flextable::color(color = "white", part = "header") |>
        flextable::bold(part = "header") |>
        flextable::font(fontname = "Arial", part = "all") |>
        flextable::fontsize(size = 9, part = "all") |>
        flextable::autofit()
    )
  }

  res
}

# =============================================================================
# 2. CALCUL D'UN INDICATEUR ODD
# =============================================================================

#' @title Calculer un indicateur ODD
#' @description Calcule un indicateur ODD specifique a partir des donnees
#'   d'enquete. Retourne un objet \code{saf_odd} avec la valeur, les
#'   metadonnees et les composantes du calcul.
#'
#' @param data data.frame ou \code{svydesign} -- Donnees d'enquete
#' @param code_odd character -- Code ODD au format "X.Y.Z"
#'   (ex : "1.1.1", "7.1.1"). Voir \code{odd_catalogue()} pour la liste
#' @param ... Arguments specifiques a chaque indicateur (voir Details)
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param na.rm logical -- Exclure les NA. Defaut : TRUE
#'
#' @details
#' Arguments specifiques par indicateur :
#' \describe{
#'   \item{1.1.1}{
#'     \code{var_depense} : variable de depenses par tete,
#'     \code{seuil} : seuil en monnaie locale (defaut : equivalence 2.15 USD PPA)
#'   }
#'   \item{1.2.1}{
#'     \code{var_depense} : variable de depenses par tete,
#'     \code{seuil} : seuil national de pauvrete
#'   }
#'   \item{2.2.1}{
#'     \code{var_taille} : taille de l'enfant (cm),
#'     \code{var_age_mois} : age en mois,
#'     \code{var_sexe} : sexe (1=M, 2=F ou "M"/"F")
#'   }
#'   \item{3.2.1}{
#'     \code{var_deces_enfant} : indicateur deces enfant (0/1),
#'     \code{var_naissances} : nombre de naissances vivantes ou variable indicatrice
#'   }
#'   \item{5.3.1}{
#'     \code{var_age_mariage} : age au premier mariage,
#'     \code{var_age_actuel} : age actuel,
#'     \code{seuil_age} : seuil (defaut : 18)
#'   }
#'   \item{5.5.2, 8.5.2, 8.6.1, 6.1.1, 7.1.1, 10.2.1, 11.1.1, 16.9.1, 17.8.1}{
#'     \code{var_indicateur} : variable binaire (1 = condition remplie, 0 = non)
#'   }
#'   \item{10.1.1}{
#'     \code{var_depense} : variable de depenses,
#'     \code{var_periode} : variable de periode (annees),
#'     \code{seuil_pct} : percentile inferieur (defaut : 40)
#'   }
#' }
#'
#' @return Un objet de classe \code{saf_odd} avec :
#' \describe{
#'   \item{valeur}{Valeur de l'indicateur}
#'   \item{unite}{Unite de mesure}
#'   \item{code_odd}{Code ODD}
#'   \item{titre_court}{Libelle court}
#'   \item{numerateur}{Numerateur du calcul}
#'   \item{denominateur}{Denominateur du calcul}
#'   \item{n_obs}{Observations utilisees}
#'   \item{na_count}{Valeurs manquantes exclues}
#'   \item{meta}{Metadonnees completes du catalogue}
#' }
#'
#' @examples
#' set.seed(42)
#' menages <- data.frame(
#'   depense_pc = c(rexp(70, rate = 1/150000), rexp(30, rate = 1/500000)),
#'   poids      = runif(100, 0.8, 1.2),
#'   electricite = sample(c(0L, 1L), 100, TRUE, prob = c(0.45, 0.55)),
#'   eau_potable = sample(c(0L, 1L), 100, TRUE, prob = c(0.35, 0.65)),
#'   internet    = sample(c(0L, 1L), 100, TRUE, prob = c(0.7, 0.3))
#' )
#'
#' # ODD 1.2.1 - Pauvrete nationale
#' odd_indicateur(menages, "1.2.1",
#'                var_depense = "depense_pc", seuil = 200000,
#'                poids = "poids")
#'
#' # ODD 7.1.1 - Acces a l'electricite
#' odd_indicateur(menages, "7.1.1", var_indicateur = "electricite",
#'                poids = "poids")
#'
#' @export
odd_indicateur <- function(data, code_odd, ..., poids = NULL, na.rm = TRUE) {

  # Validation du code ODD
  if (!code_odd %in% .ODD_CATALOGUE$code_odd) {
    rlang::abort(paste0(
      "Indicateur '", code_odd, "' non disponible dans statAfrikR.\n",
      "Consultez odd_catalogue() pour la liste des indicateurs disponibles."
    ))
  }

  meta    <- .ODD_CATALOGUE[.ODD_CATALOGUE$code_odd == code_odd, ]
  args    <- list(...)
  est_svy <- inherits(data, "survey.design")
  db      <- if (est_svy) data$variables else data

  # Routage vers la fonction de calcul appropriee
  res <- switch(code_odd,
    "1.1.1"  = , "1.2.1"  = .odd_pauvrete(db, args, poids, na.rm, meta),
    "2.2.1"  = .odd_retard_croissance(db, args, poids, na.rm, meta),
    "3.2.1"  = .odd_mortalite_infantile(db, args, poids, na.rm, meta),
    "5.3.1"  = .odd_mariage_precoce(db, args, poids, na.rm, meta),
    "10.1.1" = .odd_croissance_40(db, args, poids, na.rm, meta),
    # Indicateurs binaires : proportion de menages avec la caracteristique
    .odd_proportion(db, args, poids, na.rm, meta)
  )

  structure(res, class = "saf_odd")
}

#' @export
print.saf_odd <- function(x, ...) {
  cat("\n=== Indicateur ODD", x$code_odd, "===\n")
  cat(x$titre_court, "\n")
  cat(rep("-", 40), "\n", sep = "")
  cat("Valeur      :", round(x$valeur, 3), x$unite, "\n")
  cat("Numerateur  :", x$numerateur, "\n")
  cat("Denominateur:", x$denominateur, "\n")
  cat("N obs       :", x$n_obs, "\n")
  if (x$na_count > 0) cat("NA exclus   :", x$na_count, "\n")
  invisible(x)
}

#' @export
as.data.frame.saf_odd <- function(x, ...) {
  data.frame(
    code_odd     = x$code_odd,
    titre_court  = x$titre_court,
    valeur       = x$valeur,
    unite        = x$unite,
    numerateur   = x$numerateur,
    denominateur = x$denominateur,
    n_obs        = x$n_obs
  )
}

# =============================================================================
# 3. TABLEAU MULTI-INDICATEURS ODD
# =============================================================================

#' @title Tableau de suivi des indicateurs ODD
#' @description Calcule et presente plusieurs indicateurs ODD dans un tableau
#'   de suivi formate selon les standards de reporting PARIS21/Nations Unies.
#'
#' @param resultats list -- Liste nommee d'objets \code{saf_odd}
#'   (resultats de \code{odd_indicateur()})
#' @param pays character ou NULL -- Nom du pays. Defaut : NULL
#' @param annee integer ou NULL -- Annee de reference. Defaut : NULL
#' @param cibles list ou NULL -- Liste nommee des cibles nationales par
#'   code ODD. Ex : \code{list("1.2.1" = 25, "7.1.1" = 80)}.
#'   Defaut : NULL
#' @param format character -- \code{"tibble"}, \code{"flextable"} ou
#'   \code{"excel"}. Defaut : "tibble"
#' @param chemin character ou NULL -- Chemin Excel. Defaut : NULL
#'
#' @return Tibble, flextable ou chemin Excel
#'
#' @examples
#' set.seed(42)
#' menages <- data.frame(
#'   depense_pc  = c(rexp(70, 1/150000), rexp(30, 1/500000)),
#'   poids       = runif(100, 0.8, 1.2),
#'   electricite = sample(c(0L, 1L), 100, TRUE, c(0.45, 0.55)),
#'   eau_potable = sample(c(0L, 1L), 100, TRUE, c(0.35, 0.65))
#' )
#' r1 <- odd_indicateur(menages, "1.2.1",
#'                      var_depense = "depense_pc", seuil = 200000)
#' r2 <- odd_indicateur(menages, "7.1.1",
#'                      var_indicateur = "electricite")
#' tableau_odd(list(r1, r2), pays = "Centrafrique", annee = 2026L)
#'
#' @export
tableau_odd <- function(resultats,
                         pays    = NULL,
                         annee   = NULL,
                         cibles  = NULL,
                         format  = c("tibble", "flextable", "excel"),
                         chemin  = NULL) {

  format <- match.arg(format)

  if (!is.list(resultats) || length(resultats) == 0) {
    rlang::abort("`resultats` doit etre une liste non vide d'objets saf_odd.")
  }

  # Verifier que tous sont des saf_odd
  non_odd <- !sapply(resultats, inherits, what = "saf_odd")
  if (any(non_odd)) {
    rlang::abort(paste0(
      length(which(non_odd)),
      " element(s) ne sont pas des objets saf_odd."
    ))
  }

  # Construire le tableau
  rows <- lapply(resultats, function(r) {
    cible_val <- if (!is.null(cibles) && r$code_odd %in% names(cibles)) {
      cibles[[r$code_odd]]
    } else NA_real_

    ecart <- if (!is.na(cible_val)) round(r$valeur - cible_val, 2) else NA_real_

    data.frame(
      code_odd     = r$code_odd,
      indicateur   = r$titre_court,
      valeur       = round(r$valeur, 2),
      unite        = r$unite,
      cible        = cible_val,
      ecart_cible  = ecart,
      n_obs        = r$n_obs,
      stringsAsFactors = FALSE
    )
  })

  tab <- dplyr::bind_rows(rows)

  if (!is.null(pays))  tab$pays  <- pays
  if (!is.null(annee)) tab$annee <- annee

  res <- tibble::as_tibble(tab)

  if (format == "tibble") return(res)

  if (format == "flextable") {
    .verifier_package("flextable", "tableau_odd")
    titre_cap <- paste0(
      "Tableau de suivi ODD",
      if (!is.null(pays))  paste0(" -- ", pays),
      if (!is.null(annee)) paste0(" (", annee, ")")
    )
    ft <- flextable::flextable(res) |>
      flextable::set_caption(caption = titre_cap) |>
      flextable::bg(bg = "#0F2742", part = "header") |>
      flextable::color(color = "white", part = "header") |>
      flextable::bold(part = "header") |>
      flextable::font(fontname = "Arial", part = "all") |>
      flextable::fontsize(size = 10, part = "all") |>
      flextable::autofit()
    return(ft)
  }

  if (format == "excel") {
    .verifier_package("openxlsx2", "tableau_odd")
    if (is.null(chemin))
      chemin <- file.path(tempdir(), "tableau_odd.xlsx")
    wb <- openxlsx2::wb_workbook()
    wb <- openxlsx2::wb_add_worksheet(wb, sheet = "ODD")
    wb <- openxlsx2::wb_add_data(wb, sheet = "ODD",
                                  x = res, start_row = 1L)
    wb <- openxlsx2::wb_add_fill(
      wb, sheet = "ODD",
      color = openxlsx2::wb_color("#0F2742"),
      dims  = openxlsx2::wb_dims(rows = 1L, cols = seq_len(ncol(res)))
    )
    wb <- openxlsx2::wb_add_font(
      wb, sheet = "ODD",
      bold  = TRUE,
      color = openxlsx2::wb_color("FFFFFF"),
      dims  = openxlsx2::wb_dims(rows = 1L, cols = seq_len(ncol(res)))
    )
    openxlsx2::wb_save(wb, file = chemin, overwrite = TRUE)
    message("Tableau ODD exporte : ", chemin)
    return(invisible(chemin))
  }
}

# =============================================================================
# FONCTIONS INTERNES DE CALCUL
# =============================================================================

#' @keywords internal
.odd_proportion <- function(db, args, poids, na.rm, meta) {
  var_ind <- args$var_indicateur
  if (is.null(var_ind)) {
    rlang::abort(paste0(
      "Argument `var_indicateur` requis pour l'indicateur ", meta$code_odd,
      ".\nEx : odd_indicateur(data, '", meta$code_odd,
      "', var_indicateur = 'nom_variable')"
    ))
  }
  if (!var_ind %in% names(db)) {
    rlang::abort(paste0("Variable introuvable : '", var_ind, "'."))
  }

  x        <- db[[var_ind]]
  na_count <- sum(is.na(x))
  if (na.rm) x <- x[!is.na(x)]

  if (!all(x %in% c(0, 1, NA))) {
    rlang::warn(paste0(
      "'", var_ind, "' doit etre binaire (0/1). ",
      "Valeurs != 0/1 traitees comme : >= 0.5 => 1."
    ))
    x <- as.integer(x >= 0.5)
  }

  if (!is.null(poids) && poids %in% names(db)) {
    w    <- db[[poids]][!is.na(db[[var_ind]])]
    num  <- sum(x * w, na.rm = TRUE)
    den  <- sum(w, na.rm = TRUE)
    val  <- num / den * 100
  } else {
    num <- sum(x, na.rm = TRUE)
    den <- length(x)
    val <- mean(x, na.rm = TRUE) * 100
  }

  list(
    valeur       = round(val, 3),
    unite        = meta$unite,
    code_odd     = meta$code_odd,
    titre_court  = meta$titre_court,
    numerateur   = round(num, 0),
    denominateur = round(den, 0),
    n_obs        = den,
    na_count     = na_count,
    meta         = meta
  )
}

#' @keywords internal
.odd_pauvrete <- function(db, args, poids, na.rm, meta) {
  var_dep <- args$var_depense
  seuil   <- args$seuil

  if (is.null(var_dep)) {
    rlang::abort(paste0(
      "Argument `var_depense` requis pour ", meta$code_odd, "."
    ))
  }
  if (is.null(seuil) || !is.numeric(seuil) || seuil <= 0) {
    rlang::abort(paste0(
      "Argument `seuil` requis et positif pour ", meta$code_odd, "."
    ))
  }
  if (!var_dep %in% names(db)) {
    rlang::abort(paste0("Variable introuvable : '", var_dep, "'."))
  }

  y        <- db[[var_dep]]
  na_count <- sum(is.na(y))
  if (na.rm) {
    if (!is.null(poids) && poids %in% names(db)) {
      w <- db[[poids]][!is.na(y)]
    }
    y <- y[!is.na(y)]
  } else if (!is.null(poids) && poids %in% names(db)) {
    w <- db[[poids]]
  }

  pauvres <- as.integer(y < seuil)

  if (!is.null(poids) && poids %in% names(db)) {
    if (!exists("w")) w <- db[[poids]]
    num <- sum(pauvres * w, na.rm = TRUE)
    den <- sum(w, na.rm = TRUE)
    val <- num / den * 100
  } else {
    num <- sum(pauvres, na.rm = TRUE)
    den <- length(y)
    val <- mean(pauvres, na.rm = TRUE) * 100
  }

  list(
    valeur       = round(val, 3),
    unite        = meta$unite,
    code_odd     = meta$code_odd,
    titre_court  = meta$titre_court,
    numerateur   = round(num, 0),
    denominateur = round(den, 0),
    n_obs        = den,
    na_count     = na_count,
    meta         = meta
  )
}

#' @keywords internal
.odd_retard_croissance <- function(db, args, poids, na.rm, meta) {
  var_t <- args$var_taille
  var_a <- args$var_age_mois

  if (is.null(var_t) || is.null(var_a)) {
    rlang::abort(paste0(
      "Arguments `var_taille` et `var_age_mois` requis pour ",
      meta$code_odd, "."
    ))
  }
  for (v in c(var_t, var_a)) {
    if (!v %in% names(db)) {
      rlang::abort(paste0("Variable introuvable : '", v, "'."))
    }
  }

  taille   <- db[[var_t]]
  age_mois <- db[[var_a]]

  # Z-score taille-pour-age simplifie (OMS 2006)
  # Mediane et ecart-type approximatifs \u2014 formule simplifiee
  # Pour une implementation complete, utiliser le package anthro (WHO)
  mediane_taa <- 45 + 1.5 * age_mois  # approximation lineaire 0-59 mois
  sd_taa      <- 3.5

  z_score <- (taille - mediane_taa) / sd_taa
  retard  <- as.integer(z_score < -2)

  idx_valide <- !is.na(z_score) & age_mois >= 0 & age_mois <= 59
  na_count   <- sum(!idx_valide)
  retard_v   <- retard[idx_valide]

  if (!is.null(poids) && poids %in% names(db)) {
    w   <- db[[poids]][idx_valide]
    num <- sum(retard_v * w, na.rm = TRUE)
    den <- sum(w, na.rm = TRUE)
    val <- num / den * 100
  } else {
    num <- sum(retard_v, na.rm = TRUE)
    den <- length(retard_v)
    val <- mean(retard_v, na.rm = TRUE) * 100
  }

  list(
    valeur       = round(val, 3),
    unite        = meta$unite,
    code_odd     = meta$code_odd,
    titre_court  = meta$titre_court,
    numerateur   = round(num, 0),
    denominateur = round(den, 0),
    n_obs        = den,
    na_count     = na_count,
    meta         = meta
  )
}

#' @keywords internal
.odd_mortalite_infantile <- function(db, args, poids, na.rm, meta) {
  var_d <- args$var_deces_enfant
  var_n <- args$var_naissances

  if (is.null(var_d)) {
    rlang::abort(paste0(
      "Argument `var_deces_enfant` requis pour ", meta$code_odd, "."
    ))
  }
  if (!var_d %in% names(db)) {
    rlang::abort(paste0("Variable introuvable : '", var_d, "'."))
  }

  deces    <- db[[var_d]]
  na_count <- sum(is.na(deces))
  if (na.rm) deces <- deces[!is.na(deces)]

  num <- sum(deces, na.rm = TRUE)

  if (!is.null(var_n) && var_n %in% names(db)) {
    naiss <- db[[var_n]]
    if (na.rm) naiss <- naiss[!is.na(deces)]
    den <- sum(naiss, na.rm = TRUE)
  } else {
    den <- length(deces)
  }

  val <- num / max(den, 1) * 1000

  list(
    valeur       = round(val, 3),
    unite        = meta$unite,
    code_odd     = meta$code_odd,
    titre_court  = meta$titre_court,
    numerateur   = round(num, 0),
    denominateur = round(den, 0),
    n_obs        = den,
    na_count     = na_count,
    meta         = meta
  )
}

#' @keywords internal
.odd_mariage_precoce <- function(db, args, poids, na.rm, meta) {
  var_am <- args$var_age_mariage
  var_aa <- args$var_age_actuel
  seuil  <- if (!is.null(args$seuil_age)) args$seuil_age else 18L

  if (is.null(var_am) || is.null(var_aa)) {
    rlang::abort(paste0(
      "Arguments `var_age_mariage` et `var_age_actuel` requis pour ",
      meta$code_odd, "."
    ))
  }
  for (v in c(var_am, var_aa)) {
    if (!v %in% names(db)) {
      rlang::abort(paste0("Variable introuvable : '", v, "'."))
    }
  }

  age_mariage <- db[[var_am]]
  age_actuel  <- db[[var_aa]]

  # Denominateur : femmes de 20-24 ans (reference ODD)
  idx_ref  <- age_actuel >= 20 & age_actuel <= 24 & !is.na(age_mariage)
  na_count <- sum(!idx_ref, na.rm = TRUE)

  am_ref   <- age_mariage[idx_ref]
  mariees  <- as.integer(!is.na(am_ref) & am_ref < seuil)

  if (!is.null(poids) && poids %in% names(db)) {
    w   <- db[[poids]][idx_ref]
    num <- sum(mariees * w, na.rm = TRUE)
    den <- sum(w, na.rm = TRUE)
    val <- num / max(den, 1) * 100
  } else {
    num <- sum(mariees, na.rm = TRUE)
    den <- length(mariees)
    val <- mean(mariees, na.rm = TRUE) * 100
  }

  list(
    valeur       = round(val, 3),
    unite        = meta$unite,
    code_odd     = meta$code_odd,
    titre_court  = meta$titre_court,
    numerateur   = round(num, 0),
    denominateur = round(den, 0),
    n_obs        = den,
    na_count     = na_count,
    meta         = meta
  )
}

#' @keywords internal
.odd_croissance_40 <- function(db, args, poids, na.rm, meta) {
  var_dep    <- args$var_depense
  var_per    <- args$var_periode
  seuil_pct  <- if (!is.null(args$seuil_pct)) args$seuil_pct else 40

  if (is.null(var_dep) || is.null(var_per)) {
    rlang::abort(paste0(
      "Arguments `var_depense` et `var_periode` requis pour ",
      meta$code_odd, "."
    ))
  }
  for (v in c(var_dep, var_per)) {
    if (!v %in% names(db)) {
      rlang::abort(paste0("Variable introuvable : '", v, "'."))
    }
  }

  dep      <- db[[var_dep]]
  per      <- db[[var_per]]
  na_count <- sum(is.na(dep) | is.na(per))
  if (na.rm) {
    idx <- !is.na(dep) & !is.na(per)
    dep <- dep[idx]
    per <- per[idx]
  }

  periodes <- sort(unique(per))
  if (length(periodes) < 2) {
    rlang::abort("Au moins 2 periodes sont necessaires pour calculer le taux de croissance.")
  }

  seuil_q <- stats::quantile(dep[per == periodes[1]],
                              probs = seuil_pct / 100, na.rm = TRUE)
  idx_40  <- dep <= seuil_q

  taux_croissance <- sapply(periodes[-length(periodes)], function(p) {
    dep_p0 <- dep[per == p & idx_40]
    dep_p1 <- dep[per == periodes[which(periodes == p) + 1] & idx_40]
    if (length(dep_p0) == 0 || length(dep_p1) == 0) return(NA_real_)
    (mean(dep_p1, na.rm = TRUE) - mean(dep_p0, na.rm = TRUE)) /
      mean(dep_p0, na.rm = TRUE) * 100
  })

  val <- mean(taux_croissance, na.rm = TRUE)
  num <- round(mean(dep[per == periodes[length(periodes)] & idx_40],
                    na.rm = TRUE), 0)
  den <- round(mean(dep[per == periodes[1] & idx_40], na.rm = TRUE), 0)

  list(
    valeur       = round(val, 3),
    unite        = meta$unite,
    code_odd     = meta$code_odd,
    titre_court  = meta$titre_court,
    numerateur   = num,
    denominateur = den,
    n_obs        = sum(idx_40),
    na_count     = na_count,
    meta         = meta
  )
}
