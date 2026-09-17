# =============================================================================
# statAfrikR - Module Sante & Nutrition
# Indicateurs DHS/MICS/OMS pour les INS africains
# Conformes aux methodes WHO Child Growth Standards
# =============================================================================

utils::globalVariables(c(
  "indicateur", "valeur", "unite", "seuil_oms", "statut",
  "groupe", "antigene", "couverture", "niveau"
))

# =============================================================================
# 1. RETARD DE CROISSANCE (STUNTING)
# =============================================================================

#' @title Calculer le taux de retard de croissance (stunting)
#' @description Calcule la prevalence du retard de croissance chez les
#'   enfants de moins de 5 ans (taille-pour-age < -2 ecarts-types selon
#'   les standards OMS 2006). ODD 2.2.1.
#'
#' @param donnees data.frame -- Donnees enfants < 5 ans
#' @param var_taille_age_z character -- Score Z taille-pour-age
#'   (HAZ). Si NULL, calcule depuis var_taille, var_age et var_sexe.
#'   Defaut : NULL
#' @param var_taille character ou NULL -- Taille en cm. Defaut : NULL
#' @param var_age_mois character ou NULL -- Age en mois. Defaut : NULL
#' @param var_sexe character ou NULL -- Sexe (1=garcon, 2=fille ou
#'   "M"/"F"). Defaut : NULL
#' @param poids character ou NULL -- Variable de ponderation.
#'   Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#' @param seuil numeric -- Seuil (score Z). Defaut : -2
#'
#' @return Un objet de classe \code{saf_anthropo}
#'
#' @examples
#' set.seed(42)
#' n <- 500
#' enfants <- data.frame(
#'   haz   = rnorm(n, -1.2, 1.3),
#'   milieu = sample(c("urbain","rural"), n, TRUE),
#'   poids  = runif(n, 0.7, 1.4)
#' )
#' retard_croissance(enfants, var_taille_age_z = "haz", poids = "poids")
#'
#' @export
retard_croissance <- function(donnees,
                               var_taille_age_z = NULL,
                               var_taille       = NULL,
                               var_age_mois     = NULL,
                               var_sexe         = NULL,
                               poids            = NULL,
                               sous_groupes     = NULL,
                               seuil            = -2) {

  .calcul_anthropo(donnees,
    var_z        = var_taille_age_z,
    indicateur   = "Retard de croissance (stunting)",
    code_odd     = "ODD 2.2.1",
    seuil        = seuil,
    poids        = poids,
    sous_groupes = sous_groupes,
    description  = "Taille-pour-age < -2 ET (standards OMS 2006)"
  )
}

# =============================================================================
# 2. EMACIATION (WASTING)
# =============================================================================

#' @title Calculer le taux d'emaciation (wasting)
#' @description Prevalence de l'emaciation : poids-pour-taille < -2
#'   ecarts-types (standards OMS 2006). Indicateur de malnutrition aigue.
#'
#' @param donnees data.frame -- Donnees enfants < 5 ans
#' @param var_poids_taille_z character -- Score Z poids-pour-taille (WHZ)
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#' @param seuil numeric -- Seuil score Z. Defaut : -2
#'
#' @return Un objet de classe \code{saf_anthropo}
#'
#' @examples
#' set.seed(42)
#' n <- 400
#' enfants <- data.frame(
#'   whz  = rnorm(n, -0.8, 1.1),
#'   poids = runif(n, 0.8, 1.3)
#' )
#' emaciation(enfants, var_poids_taille_z = "whz", poids = "poids")
#'
#' @export
emaciation <- function(donnees,
                        var_poids_taille_z,
                        poids        = NULL,
                        sous_groupes = NULL,
                        seuil        = -2) {

  .calcul_anthropo(donnees,
    var_z        = var_poids_taille_z,
    indicateur   = "Emaciation (wasting)",
    code_odd     = "ODD 2.2.2",
    seuil        = seuil,
    poids        = poids,
    sous_groupes = sous_groupes,
    description  = "Poids-pour-taille < -2 ET (standards OMS 2006)"
  )
}

# =============================================================================
# 3. INSUFFISANCE PONDERALE (UNDERWEIGHT)
# =============================================================================

#' @title Calculer le taux d'insuffisance ponderale
#' @description Prevalence de l'insuffisance ponderale : poids-pour-age
#'   < -2 ecarts-types chez les enfants de moins de 5 ans.
#'
#' @param donnees data.frame -- Donnees enfants < 5 ans
#' @param var_poids_age_z character -- Score Z poids-pour-age (WAZ)
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#' @param seuil numeric -- Seuil score Z. Defaut : -2
#'
#' @return Un objet de classe \code{saf_anthropo}
#'
#' @examples
#' set.seed(42)
#' n <- 400
#' enfants <- data.frame(
#'   waz  = rnorm(n, -1.0, 1.2),
#'   poids = runif(n, 0.8, 1.3)
#' )
#' insuffisance_ponderale(enfants, var_poids_age_z = "waz", poids = "poids")
#'
#' @export
insuffisance_ponderale <- function(donnees,
                                    var_poids_age_z,
                                    poids        = NULL,
                                    sous_groupes = NULL,
                                    seuil        = -2) {

  .calcul_anthropo(donnees,
    var_z        = var_poids_age_z,
    indicateur   = "Insuffisance ponderale (underweight)",
    code_odd     = "ODD 2.2.2",
    seuil        = seuil,
    poids        = poids,
    sous_groupes = sous_groupes,
    description  = "Poids-pour-age < -2 ET (standards OMS 2006)"
  )
}

# Fonction interne commune aux indicateurs anthropometriques
#' @keywords internal
.calcul_anthropo <- function(donnees, var_z, indicateur, code_odd,
                              seuil, poids, sous_groupes, description) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_z %in% names(donnees)) {
    rlang::abort(paste0(
      "Variable '", var_z, "' introuvable.\n",
      "Colonnes disponibles : ", paste(names(donnees), collapse = ", ")
    ))
  }
  if (!is.null(poids) && !poids %in% names(donnees)) {
    rlang::abort(paste0("Variable de poids '", poids, "' introuvable."))
  }

  z <- as.numeric(donnees[[var_z]])
  w <- if (!is.null(poids)) {
    wp <- as.numeric(donnees[[poids]])
    wp[is.na(wp) | wp <= 0] <- 1; wp
  } else rep(1, nrow(donnees))

  prive <- as.integer(!is.na(z) & z < seuil)
  idx_ok <- !is.na(z)
  taux  <- stats::weighted.mean(prive[idx_ok], w[idx_ok])
  n_obs <- sum(idx_ok)
  n_cas <- sum(prive[idx_ok] * w[idx_ok]) / mean(w[idx_ok])

  # IC 95% par methode Wilson
  ic <- .wilson_ic(taux, n_obs)

  # Desagregation
  decomp <- NULL
  if (!is.null(sous_groupes)) {
    decomp <- lapply(sous_groupes, function(sg) {
      if (!sg %in% names(donnees)) {
        rlang::warn(paste0("Variable '", sg, "' introuvable."))
        return(NULL)
      }
      g <- as.character(donnees[[sg]])
      dplyr::bind_rows(lapply(sort(unique(g[!is.na(g)])), function(gr) {
        idx <- which(g == gr)
        zg  <- z[idx]; wg <- w[idx]; pg <- prive[idx]
        ok  <- !is.na(zg)
        tibble::tibble(
          variable = sg, groupe = gr,
          taux_pct = round(stats::weighted.mean(pg[ok], wg[ok]) * 100, 2),
          n        = sum(ok)
        )
      }))
    })
    decomp <- dplyr::bind_rows(decomp)
  }

  cat_seuil <- dplyr::case_when(
    taux * 100 < 10 ~ "Acceptable (< 10%)",
    taux * 100 < 20 ~ "Preoccupant (10-20%)",
    taux * 100 < 30 ~ "Eleve (20-30%)",
    TRUE            ~ "Tres eleve (>= 30%)"
  )

  message("=== ", indicateur, " ===")
  message("  Taux : ", round(taux * 100, 1), "%  (", cat_seuil, ")")
  message("  N    : ", format(n_obs, big.mark=" "), " enfants")

  structure(
    list(
      indicateur  = indicateur,
      code_odd    = code_odd,
      description = description,
      taux        = round(taux, 4),
      taux_pct    = round(taux * 100, 2),
      ic_bas      = round(ic[1] * 100, 2),
      ic_haut     = round(ic[2] * 100, 2),
      n_obs       = n_obs,
      n_cas       = round(n_cas),
      categorie   = cat_seuil,
      seuil_z     = seuil,
      decomposition = decomp
    ),
    class = "saf_anthropo"
  )
}

#' @export
print.saf_anthropo <- function(x, ...) {
  cat("\n===", x$indicateur, "(", x$code_odd, ") ===\n")
  cat(sprintf("  Taux  : %.1f%%  [IC 95%% : %.1f%% - %.1f%%]\n",
              x$taux_pct, x$ic_bas, x$ic_haut))
  cat(sprintf("  N obs : %s enfants  |  N cas : %s\n",
              format(x$n_obs, big.mark=" "),
              format(x$n_cas, big.mark=" ")))
  cat(sprintf("  Seuil OMS : score Z < %g\n", x$seuil_z))
  cat(sprintf("  Categorie : %s\n", x$categorie))
  if (!is.null(x$decomposition) && nrow(x$decomposition) > 0) {
    cat("\nDesagregation :\n")
    for (i in seq_len(nrow(x$decomposition))) {
      cat(sprintf("  %-20s : %s%%  (n=%d)\n",
                  x$decomposition$groupe[i],
                  x$decomposition$taux_pct[i],
                  x$decomposition$n[i]))
    }
  }
  invisible(x)
}

# =============================================================================
# 4. PREVALENCE DE L'ANEMIE
# =============================================================================

#' @title Calculer la prevalence de l'anemie
#' @description Calcule la prevalence de l'anemie selon les seuils OMS
#'   (hemoglobine en g/dL). Distingue les niveaux legere, moderee, severe.
#'
#' @param donnees data.frame -- Donnees menages ou individus
#' @param var_hemoglobine character -- Taux d'hemoglobine en g/dL
#' @param var_groupe_cible character ou NULL -- Groupe cible :
#'   "femmes_15_49", "enfants_6_59", "enceintes", "tous".
#'   Defaut : NULL (tous)
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#'
#' @return Un tibble avec prevalence par niveau d'anemie
#'
#' @examples
#' set.seed(42)
#' n <- 400
#' femmes <- data.frame(
#'   hemoglobine = rnorm(n, 11.5, 2.1),
#'   milieu      = sample(c("urbain","rural"), n, TRUE),
#'   poids       = runif(n, 0.8, 1.3)
#' )
#' anemie(femmes, var_hemoglobine = "hemoglobine", poids = "poids")
#'
#' @export
anemie <- function(donnees,
                    var_hemoglobine,
                    var_groupe_cible = NULL,
                    poids            = NULL,
                    sous_groupes     = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_hemoglobine %in% names(donnees)) {
    rlang::abort(paste0(
      "Variable '", var_hemoglobine, "' introuvable.\n",
      "Colonnes disponibles : ", paste(names(donnees), collapse = ", ")
    ))
  }

  hb <- as.numeric(donnees[[var_hemoglobine]])
  w  <- if (!is.null(poids) && poids %in% names(donnees)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp) | wp <= 0] <- 1; wp
  } else rep(1, nrow(donnees))

  # Seuils OMS pour femmes non enceintes (defaut)
  # Severe < 8, Moderee 8-11, Legere 11-12, Normale >= 12
  seuils <- list(severe = 8, moderee = 11, legere = 12)

  ok <- !is.na(hb)
  hb_ok <- hb[ok]; w_ok <- w[ok]; n_ok <- sum(ok)

  res <- tibble::tibble(
    niveau          = c("Severe (< 8 g/dL)",
                        "Moderee (8-11 g/dL)",
                        "Legere (11-12 g/dL)",
                        "Total anemie (< 12 g/dL)",
                        "Normale (>= 12 g/dL)"),
    prevalence_pct  = c(
      round(stats::weighted.mean(hb_ok < 8,          w_ok) * 100, 2),
      round(stats::weighted.mean(hb_ok >= 8  & hb_ok < 11, w_ok) * 100, 2),
      round(stats::weighted.mean(hb_ok >= 11 & hb_ok < 12, w_ok) * 100, 2),
      round(stats::weighted.mean(hb_ok < 12,         w_ok) * 100, 2),
      round(stats::weighted.mean(hb_ok >= 12,         w_ok) * 100, 2)
    ),
    n_obs = n_ok
  )

  message("=== Prevalence de l'anemie (seuils OMS) ===")
  for (i in 1:4) {
    message("  ", res$niveau[i], " : ", res$prevalence_pct[i], "%")
  }

  # Desagregation
  if (!is.null(sous_groupes)) {
    for (sg in sous_groupes) {
      if (!sg %in% names(donnees)) next
      g <- as.character(donnees[[sg]])
      message("Desagregation par ", sg, " :")
      for (gr in sort(unique(g[!is.na(g)]))) {
        idx <- which(g == gr)
        hg  <- hb[idx]; wg <- w[idx]; okg <- !is.na(hg)
        taux <- stats::weighted.mean(hg[okg] < 12, wg[okg]) * 100
        message("  ", gr, " : ", round(taux, 1), "% anemie (< 12 g/dL)")
      }
    }
  }

  res
}

# =============================================================================
# 5. COUVERTURE VACCINALE
# =============================================================================

#' @title Calculer la couverture vaccinale
#' @description Calcule la couverture vaccinale par antigene selon la
#'   methodologie DHS/MICS. Indicateurs ODD 3.b.1.
#'
#' @param donnees data.frame -- Donnees enfants
#' @param vars_vaccins named character -- Vecteur nomme : nom du vaccin ->
#'   nom de la variable (0/1). Ex: c(DTC3="dtc3", Rougeole="rougeole")
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param var_carte_sante character ou NULL -- Variable indiquant si
#'   l'enfant a une carte de sante (pour ajustement). Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#'
#' @return Un tibble avec couverture par antigene
#'
#' @examples
#' set.seed(42)
#' n <- 500
#' enfants <- data.frame(
#'   dtc3      = rbinom(n, 1, 0.72),
#'   rougeole  = rbinom(n, 1, 0.68),
#'   polio3    = rbinom(n, 1, 0.75),
#'   bcg       = rbinom(n, 1, 0.90),
#'   poids     = runif(n, 0.8, 1.3),
#'   milieu    = sample(c("urbain","rural"), n, TRUE)
#' )
#' vaccination(enfants,
#'   vars_vaccins = c(DTC3="dtc3", Rougeole="rougeole",
#'                    Polio3="polio3", BCG="bcg"),
#'   poids = "poids")
#'
#' @export
vaccination <- function(donnees,
                         vars_vaccins,
                         poids         = NULL,
                         var_carte_sante = NULL,
                         sous_groupes  = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (is.null(names(vars_vaccins)) || length(vars_vaccins) == 0L) {
    rlang::abort(paste0(
      "`vars_vaccins` doit etre un vecteur nomme.\n",
      "Exemple : c(DTC3='var_dtc3', Rougeole='var_rougeole')"
    ))
  }

  vars_abs <- vars_vaccins[!vars_vaccins %in% names(donnees)]
  if (length(vars_abs) > 0) {
    rlang::abort(paste0(
      "Variables introuvables : ", paste(vars_abs, collapse=", "), "\n",
      "Colonnes disponibles : ", paste(names(donnees), collapse=", ")
    ))
  }

  w <- if (!is.null(poids) && poids %in% names(donnees)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp) | wp <= 0] <- 1; wp
  } else rep(1, nrow(donnees))

  res <- lapply(names(vars_vaccins), function(nm) {
    v  <- vars_vaccins[[nm]]
    vv <- as.integer(donnees[[v]])
    ok <- !is.na(vv)
    couv <- stats::weighted.mean(vv[ok], w[ok])
    ic   <- .wilson_ic(couv, sum(ok))
    tibble::tibble(
      antigene       = nm,
      couverture_pct = round(couv * 100, 2),
      ic_bas         = round(ic[1] * 100, 2),
      ic_haut        = round(ic[2] * 100, 2),
      n_obs          = sum(ok),
      objectif_oms   = 95.0,
      ecart_objectif = round(95.0 - couv * 100, 1)
    )
  })
  res_df <- dplyr::bind_rows(res)

  message("=== Couverture vaccinale ===")
  for (i in seq_len(nrow(res_df))) {
    statut <- if (res_df$couverture_pct[i] >= 95) " [Objectif OMS atteint]"
              else paste0(" [Ecart : -", res_df$ecart_objectif[i], "%]")
    message("  ", res_df$antigene[i], " : ",
            res_df$couverture_pct[i], "%", statut)
  }

  res_df
}

# =============================================================================
# 6. MORTALITE DES ENFANTS DE MOINS DE 5 ANS
# =============================================================================

#' @title Calculer le taux de mortalite des enfants de moins de 5 ans
#' @description Calcule le taux de mortalite infanto-juvenile (U5MR)
#'   en pour 1 000 naissances vivantes. ODD 3.2.1.
#'
#' @param donnees data.frame -- Donnees femmes en age de procrer (15-49 ans)
#'   ou historique des naissances
#' @param var_naissances_vivantes character -- Nombre total de naissances
#'   vivantes par femme
#' @param var_deces_enfants character -- Nombre de deces d'enfants < 5 ans
#'   par femme
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#'
#' @return Un objet de classe \code{saf_mortalite}
#'
#' @examples
#' set.seed(42)
#' n <- 600
#' femmes <- data.frame(
#'   naissances_vivantes = rpois(n, 3.5),
#'   deces_enfants       = rbinom(n, 4, 0.08),
#'   milieu              = sample(c("urbain","rural"), n, TRUE),
#'   poids               = runif(n, 0.8, 1.3)
#' )
#' mortalite_5ans(femmes,
#'   var_naissances_vivantes = "naissances_vivantes",
#'   var_deces_enfants       = "deces_enfants",
#'   poids                   = "poids")
#'
#' @export
mortalite_5ans <- function(donnees,
                            var_naissances_vivantes,
                            var_deces_enfants,
                            poids        = NULL,
                            sous_groupes = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  for (v in c(var_naissances_vivantes, var_deces_enfants)) {
    if (!v %in% names(donnees)) {
      rlang::abort(paste0("Variable '", v, "' introuvable."))
    }
  }
  if (!is.null(poids) && !poids %in% names(donnees)) {
    rlang::abort(paste0("Variable de poids '", poids, "' introuvable."))
  }

  nv <- as.numeric(donnees[[var_naissances_vivantes]])
  dc <- as.numeric(donnees[[var_deces_enfants]])
  w  <- if (!is.null(poids)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp) | wp <= 0] <- 1; wp
  } else rep(1, nrow(donnees))

  # Taux de mortalite = total deces / total naissances vivantes * 1000
  ok         <- !is.na(nv) & !is.na(dc) & nv > 0
  total_nv   <- sum(w[ok] * nv[ok])
  total_dc   <- sum(w[ok] * pmin(dc[ok], nv[ok]))  # deces <= naissances
  u5mr       <- total_dc / total_nv * 1000
  n_femmes   <- sum(ok)

  # IC approximatif (Poisson)
  ic_bas  <- (total_dc * (1 - 1/(9*total_dc) -
                           1.96/sqrt(9*total_dc))^3) / total_nv * 1000
  ic_haut <- ((total_dc + 1) * (1 - 1/(9*(total_dc+1)) +
                                  1.96/sqrt(9*(total_dc+1)))^3) /
    total_nv * 1000

  cat_u5mr <- dplyr::case_when(
    u5mr < 25  ~ "Faible (< 25 pour 1000)",
    u5mr < 50  ~ "Moderee (25-50)",
    u5mr < 100 ~ "Elevee (50-100)",
    TRUE       ~ "Tres elevee (>= 100)"
  )

  message("=== Mortalite des enfants < 5 ans (ODD 3.2.1) ===")
  message("  U5MR : ", round(u5mr, 1), " pour 1 000 naissances vivantes")
  message("  IC 95% : [", round(ic_bas,1), " ; ", round(ic_haut,1), "]")
  message("  N femmes : ", format(n_femmes, big.mark=" "))

  # Desagregation
  decomp <- NULL
  if (!is.null(sous_groupes)) {
    decomp <- lapply(sous_groupes, function(sg) {
      if (!sg %in% names(donnees)) return(NULL)
      g <- as.character(donnees[[sg]])
      dplyr::bind_rows(lapply(sort(unique(g[!is.na(g)])), function(gr) {
        idx <- which(g == gr)
        ok_g <- ok[idx]
        if (sum(ok_g) < 5L) return(NULL)
        tnv  <- sum(w[idx][ok_g] * nv[idx][ok_g])
        tdc  <- sum(w[idx][ok_g] * pmin(dc[idx][ok_g], nv[idx][ok_g]))
        tibble::tibble(
          variable = sg, groupe = gr,
          u5mr     = round(tdc/tnv*1000, 1),
          n        = sum(ok_g)
        )
      }))
    })
    decomp <- dplyr::bind_rows(decomp)
  }

  structure(
    list(
      indicateur = "Mortalite des enfants < 5 ans",
      code_odd   = "ODD 3.2.1",
      u5mr       = round(u5mr, 2),
      ic_bas     = round(ic_bas, 2),
      ic_haut    = round(ic_haut, 2),
      total_naissances = round(total_nv),
      total_deces      = round(total_dc),
      n_femmes   = n_femmes,
      categorie  = cat_u5mr,
      decomposition = decomp
    ),
    class = "saf_mortalite"
  )
}

#' @export
print.saf_mortalite <- function(x, ...) {
  cat("\n===", x$indicateur, "(", x$code_odd, ") ===\n")
  cat(sprintf("  U5MR : %.1f pour 1 000 naissances vivantes\n", x$u5mr))
  cat(sprintf("  IC 95%% : [%.1f ; %.1f]\n", x$ic_bas, x$ic_haut))
  cat(sprintf("  Total naissances : %s | Total deces : %s\n",
              format(x$total_naissances, big.mark=" "),
              format(x$total_deces, big.mark=" ")))
  cat(sprintf("  Categorie : %s\n", x$categorie))
  invisible(x)
}

# =============================================================================
# 7. ACCOUCHEMENTS ASSISTES
# =============================================================================

#' @title Calculer le taux d'accouchements assistes
#' @description Proportion des naissances assistees par un personnel de
#'   sante qualifie (medecin, sage-femme, infirmier). ODD 3.1.2.
#'
#' @param donnees data.frame -- Donnees naissances recentes
#' @param var_assiste character -- Variable 0/1 indiquant un accouchement
#'   assiste par personnel qualifie
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#'
#' @return Un tibble avec taux global et par sous-groupe
#'
#' @examples
#' set.seed(42)
#' n <- 400
#' naissances <- data.frame(
#'   assiste = rbinom(n, 1, 0.65),
#'   milieu  = sample(c("urbain","rural"), n, TRUE),
#'   region  = sample(paste0("R", 1:5), n, TRUE),
#'   poids   = runif(n, 0.8, 1.3)
#' )
#' accouchements_assistes(naissances, "assiste",
#'                         poids = "poids",
#'                         sous_groupes = c("milieu","region"))
#'
#' @export
accouchements_assistes <- function(donnees,
                                    var_assiste,
                                    poids        = NULL,
                                    sous_groupes = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_assiste %in% names(donnees)) {
    rlang::abort(paste0("Variable '", var_assiste, "' introuvable."))
  }

  v <- as.integer(donnees[[var_assiste]])
  w <- if (!is.null(poids) && poids %in% names(donnees)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp) | wp <= 0] <- 1; wp
  } else rep(1, nrow(donnees))

  ok   <- !is.na(v)
  taux <- stats::weighted.mean(v[ok], w[ok])
  n    <- sum(ok)
  ic   <- .wilson_ic(taux, n)

  res_global <- tibble::tibble(
    groupe         = "Total",
    taux_pct       = round(taux * 100, 2),
    ic_bas         = round(ic[1] * 100, 2),
    ic_haut        = round(ic[2] * 100, 2),
    n_obs          = n
  )

  message("=== Accouchements assistes (ODD 3.1.2) ===")
  message("  Taux global : ", round(taux*100,1), "%")

  if (!is.null(sous_groupes)) {
    res_sg <- lapply(sous_groupes, function(sg) {
      if (!sg %in% names(donnees)) return(NULL)
      g <- as.character(donnees[[sg]])
      dplyr::bind_rows(lapply(sort(unique(g[!is.na(g)])), function(gr) {
        idx <- which(g == gr)
        ok_g <- ok[idx]
        tg   <- stats::weighted.mean(v[idx][ok_g], w[idx][ok_g])
        ic_g <- .wilson_ic(tg, sum(ok_g))
        message("  ", sg, " - ", gr, " : ", round(tg*100,1), "%")
        tibble::tibble(
          groupe  = paste0(sg, " : ", gr),
          taux_pct = round(tg * 100, 2),
          ic_bas   = round(ic_g[1] * 100, 2),
          ic_haut  = round(ic_g[2] * 100, 2),
          n_obs    = sum(ok_g)
        )
      }))
    })
    res_global <- dplyr::bind_rows(res_global, dplyr::bind_rows(res_sg))
  }

  res_global
}

# =============================================================================
# 8. TABLEAU DE BORD SANTE
# =============================================================================

#' @title Tableau de bord des indicateurs de sante
#' @description Synthetise tous les indicateurs de sante disponibles en un
#'   seul tableau institutionnel. Produit un rapport comparable aux
#'   tableaux de bord DHS/MICS.
#'
#' @param indicateurs list -- Liste nommee d'objets saf_anthropo ou
#'   saf_mortalite, ou tibbles de vaccination/accouchements
#' @param pays character -- Nom du pays. Defaut : "Pays"
#' @param annee integer -- Annee. Defaut : annee courante
#' @param source character ou NULL -- Source des donnees. Defaut : NULL
#'
#' @return Un tibble institutionnel
#'
#' @examples
#' set.seed(42)
#' n <- 400
#' enfants <- data.frame(
#'   haz  = rnorm(n,-1.2,1.3), waz = rnorm(n,-1.0,1.2),
#'   poids = runif(n,0.8,1.3)
#' )
#' r1 <- suppressMessages(
#'   retard_croissance(enfants, var_taille_age_z="haz", poids="poids"))
#' r2 <- suppressMessages(
#'   insuffisance_ponderale(enfants, var_poids_age_z="waz", poids="poids"))
#' tableau_sante(list(stunting=r1, underweight=r2),
#'               pays="Centrafrique", annee=2026L)
#'
#' @export
tableau_sante <- function(indicateurs,
                           pays   = "Pays",
                           annee  = as.integer(format(Sys.Date(), "%Y")),
                           source = NULL) {

  if (!is.list(indicateurs) || length(indicateurs) == 0L) {
    rlang::abort("`indicateurs` doit etre une liste non vide.")
  }

  rows <- lapply(names(indicateurs), function(nm) {
    ind <- indicateurs[[nm]]
    if (inherits(ind, "saf_anthropo")) {
      tibble::tibble(
        indicateur = ind$indicateur,
        code_odd   = ind$code_odd,
        valeur_pct = ind$taux_pct,
        ic_bas     = ind$ic_bas,
        ic_haut    = ind$ic_haut,
        n_obs      = ind$n_obs,
        categorie  = ind$categorie,
        pays       = pays,
        annee      = annee
      )
    } else if (inherits(ind, "saf_mortalite")) {
      tibble::tibble(
        indicateur = ind$indicateur,
        code_odd   = ind$code_odd,
        valeur_pct = ind$u5mr,
        ic_bas     = ind$ic_bas,
        ic_haut    = ind$ic_haut,
        n_obs      = ind$n_femmes,
        categorie  = ind$categorie,
        pays       = pays,
        annee      = annee
      )
    } else if (is.data.frame(ind)) {
      # Pour vaccination ou accouchements_assistes
      tibble::tibble(
        indicateur = nm,
        code_odd   = "ODD 3",
        valeur_pct = if ("couverture_pct" %in% names(ind))
          ind$couverture_pct[1]
        else if ("taux_pct" %in% names(ind)) ind$taux_pct[1]
        else NA_real_,
        ic_bas     = NA_real_,
        ic_haut    = NA_real_,
        n_obs      = if ("n_obs" %in% names(ind)) ind$n_obs[1] else NA_integer_,
        categorie  = "",
        pays       = pays,
        annee      = annee
      )
    } else NULL
  })

  res <- dplyr::bind_rows(rows)
  message("Tableau de bord sante : ", pays, " - ", annee,
          " (", nrow(res), " indicateurs)")
  res
}

# =============================================================================
# FONCTIONS INTERNES
# =============================================================================

#' @keywords internal
.wilson_ic <- function(p, n, alpha = 0.05) {
  z   <- stats::qnorm(1 - alpha/2)
  denom <- 1 + z^2/n
  centre <- (p + z^2/(2*n)) / denom
  marge  <- z * sqrt(p*(1-p)/n + z^2/(4*n^2)) / denom
  c(max(0, centre - marge), min(1, centre + marge))
}
