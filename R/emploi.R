# =============================================================================
# statAfrikR - Module Emploi etendu & Travail decent
# Conformes aux standards OIT/ILOSTAT \u2014 Cadre statistique du travail 2013
# Webinaire CEA/ACS : Statistiques des inegalites et du chomage en Afrique
# =============================================================================

utils::globalVariables(c(
  "indicateur", "valeur", "description", "norme", "statut",
  "groupe", "taux", "composante", "part", "categorie"
))

# Statuts d'emploi OIT 2013
.STATUTS_OIT <- c(
  "salarie_prive"     = "Salarie secteur prive",
  "salarie_public"    = "Salarie secteur public",
  "independant"       = "Travailleur independant",
  "employeur"         = "Employeur",
  "familial_non_rem"  = "Aide familial non remunere",
  "apprenti"          = "Apprenti",
  "autre"             = "Autre"
)

# =============================================================================
# 1. TAUX D'ACTIVITE
# =============================================================================

#' @title Calculer le taux d'activite
#' @description Calcule le taux d'activite selon la definition du Bureau
#'   International du Travail (BIT) : proportion de la population en age
#'   de travailler qui est active (employes + chomeurs). ODD 8.
#'
#' @param donnees data.frame -- Donnees individuelles ou menages
#' @param var_actif character -- Variable 0/1 : actif (employe ou chomeur)
#' @param var_age character ou NULL -- Variable age pour filtrer la
#'   population en age de travailler. Defaut : NULL
#' @param age_min integer -- Age minimum. Defaut : 15L
#' @param age_max integer -- Age maximum. Defaut : 64L
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation
#'   (sexe, milieu, region). Defaut : NULL
#'
#' @return Un objet de classe \code{saf_emploi}
#'
#' @examples
#' set.seed(42)
#' n <- 500
#' individus <- data.frame(
#'   actif  = rbinom(n, 1, 0.65),
#'   age    = sample(15:64, n, TRUE),
#'   sexe   = sample(c("H","F"), n, TRUE),
#'   milieu = sample(c("urbain","rural"), n, TRUE),
#'   poids  = runif(n, 0.8, 1.3)
#' )
#' taux_activite(individus, "actif", var_age="age", poids="poids",
#'               sous_groupes=c("sexe","milieu"))
#'
#' @export
taux_activite <- function(donnees,
                           var_actif,
                           var_age      = NULL,
                           age_min      = 15L,
                           age_max      = 64L,
                           poids        = NULL,
                           sous_groupes = NULL) {

  .calcul_taux_emploi(
    donnees      = donnees,
    var_cible    = var_actif,
    indicateur   = "Taux d'activite",
    code_ref     = "BIT/OIT",
    description  = "Population active / Population en age de travailler",
    var_age      = var_age,
    age_min      = age_min,
    age_max      = age_max,
    poids        = poids,
    sous_groupes = sous_groupes
  )
}

# =============================================================================
# 2. TAUX D'EMPLOI
# =============================================================================

#' @title Calculer le taux d'emploi
#' @description Proportion de la population en age de travailler ayant
#'   un emploi (salarie ou independant). Indicateur cle ODD 8.5.
#'
#' @param donnees data.frame -- Donnees individuelles
#' @param var_employe character -- Variable 0/1 : a un emploi
#' @param var_age character ou NULL -- Variable age. Defaut : NULL
#' @param age_min integer -- Age minimum. Defaut : 15L
#' @param age_max integer -- Age maximum. Defaut : 64L
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#'
#' @return Un objet de classe \code{saf_emploi}
#'
#' @examples
#' set.seed(42)
#' individus <- data.frame(
#'   employe = rbinom(500, 1, 0.55),
#'   age     = sample(15:64, 500, TRUE),
#'   sexe    = sample(c("H","F"), 500, TRUE),
#'   poids   = runif(500, 0.8, 1.3)
#' )
#' taux_emploi(individus, "employe", var_age="age",
#'             poids="poids", sous_groupes="sexe")
#'
#' @export
taux_emploi <- function(donnees,
                         var_employe,
                         var_age      = NULL,
                         age_min      = 15L,
                         age_max      = 64L,
                         poids        = NULL,
                         sous_groupes = NULL) {

  .calcul_taux_emploi(
    donnees      = donnees,
    var_cible    = var_employe,
    indicateur   = "Taux d'emploi",
    code_ref     = "ODD 8.5",
    description  = "Population occupee / Population en age de travailler",
    var_age      = var_age,
    age_min      = age_min,
    age_max      = age_max,
    poids        = poids,
    sous_groupes = sous_groupes
  )
}

# Fonction interne commune aux taux de marche du travail
#' @keywords internal
.calcul_taux_emploi <- function(donnees, var_cible, indicateur, code_ref,
                                 description, var_age, age_min, age_max,
                                 poids, sous_groupes) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_cible %in% names(donnees)) {
    rlang::abort(paste0(
      "Variable '", var_cible, "' introuvable.\n",
      "Colonnes disponibles : ", paste(names(donnees), collapse=", ")
    ))
  }
  if (!is.null(poids) && !poids %in% names(donnees)) {
    rlang::abort(paste0("Variable de poids '", poids, "' introuvable."))
  }

  df <- donnees
  # Filtre par age si fourni
  if (!is.null(var_age) && var_age %in% names(df)) {
    ages <- as.integer(df[[var_age]])
    df   <- df[!is.na(ages) & ages >= age_min & ages <= age_max, ]
    if (nrow(df) == 0L) {
      rlang::abort(paste0(
        "Aucune observation apres filtrage par age [",
        age_min, "-", age_max, "]."
      ))
    }
  }

  v <- as.integer(df[[var_cible]])
  w <- if (!is.null(poids) && poids %in% names(df)) {
    wp <- as.numeric(df[[poids]]); wp[is.na(wp) | wp <= 0] <- 1; wp
  } else rep(1, nrow(df))

  ok   <- !is.na(v)
  taux_val <- stats::weighted.mean(v[ok], w[ok])
  n_obs    <- sum(ok)
  ic       <- .wilson_ic_emp(taux_val, n_obs)

  # Desagregation
  decomp <- NULL
  if (!is.null(sous_groupes)) {
    decomp <- lapply(sous_groupes, function(sg) {
      if (!sg %in% names(df)) {
        rlang::warn(paste0("Variable '", sg, "' introuvable \u2014 ignoree."))
        return(NULL)
      }
      g <- as.character(df[[sg]])
      dplyr::bind_rows(lapply(sort(unique(g[!is.na(g)])), function(gr) {
        idx <- which(g == gr)
        ok_g <- ok[idx]
        if (sum(ok_g) < 5L) return(NULL)
        tv <- stats::weighted.mean(v[idx][ok_g], w[idx][ok_g])
        tibble::tibble(
          variable = sg, groupe = gr,
          taux_pct = round(tv * 100, 2), n = sum(ok_g)
        )
      }))
    })
    decomp <- dplyr::bind_rows(decomp)
  }

  message("=== ", indicateur, " (", code_ref, ") ===")
  message("  Taux : ", round(taux_val * 100, 1), "%")
  message("  N    : ", format(n_obs, big.mark=" "))

  structure(
    list(
      indicateur  = indicateur,
      code_ref    = code_ref,
      description = description,
      taux        = round(taux_val, 4),
      taux_pct    = round(taux_val * 100, 2),
      ic_bas      = round(ic[1] * 100, 2),
      ic_haut     = round(ic[2] * 100, 2),
      n_obs       = n_obs,
      decomposition = decomp
    ),
    class = "saf_emploi"
  )
}

#' @export
print.saf_emploi <- function(x, ...) {
  cat("\n===", x$indicateur, "(", x$code_ref, ") ===\n")
  cat(sprintf("  Taux  : %.1f%%  [IC 95%% : %.1f%% - %.1f%%]\n",
              x$taux_pct, x$ic_bas, x$ic_haut))
  cat(sprintf("  N obs : %s\n", format(x$n_obs, big.mark=" ")))
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
# 3. EMPLOI INFORMEL
# =============================================================================

#' @title Calculer le taux d'emploi informel
#' @description Calcule la part de l'emploi informel selon la definition
#'   OIT 2013. L'emploi informel comprend les travailleurs sans contrat
#'   ecrit, sans protection sociale et sans conges payes.
#'
#' @param donnees data.frame -- Donnees employes
#' @param var_informel character -- Variable 0/1 : emploi informel
#' @param var_statut character ou NULL -- Variable de statut d'emploi
#'   (pour decomposition). Defaut : NULL
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#'
#' @return Un objet de classe \code{saf_emploi}
#'
#' @examples
#' set.seed(42)
#' n <- 400
#' employes <- data.frame(
#'   informel = rbinom(n, 1, 0.72),
#'   secteur  = sample(c("agriculture","services","industrie"), n, TRUE),
#'   sexe     = sample(c("H","F"), n, TRUE),
#'   poids    = runif(n, 0.8, 1.3)
#' )
#' emploi_informel(employes, "informel", poids="poids",
#'                  sous_groupes=c("secteur","sexe"))
#'
#' @export
emploi_informel <- function(donnees,
                              var_informel,
                              var_statut   = NULL,
                              poids        = NULL,
                              sous_groupes = NULL) {

  .calcul_taux_emploi(
    donnees      = donnees,
    var_cible    = var_informel,
    indicateur   = "Taux d'emploi informel",
    code_ref     = "OIT 2013",
    description  = "Employes sans contrat/protection / Total employes",
    var_age      = NULL,
    age_min      = 15L,
    age_max      = 64L,
    poids        = poids,
    sous_groupes = sous_groupes
  )
}

# =============================================================================
# 4. SOUS-EMPLOI EN TEMPS DE TRAVAIL
# =============================================================================

#' @title Calculer le taux de sous-emploi en temps de travail
#' @description Calcule la proportion de personnes en emploi travaillant
#'   moins d'heures qu'elles ne le souhaitent (sous-emploi visible).
#'   Composante de LU2 dans la mesure de la sous-utilisation de la
#'   main-d'oeuvre OIT.
#'
#' @param donnees data.frame -- Donnees individus en emploi
#' @param var_heures_travaillees character -- Heures effectivement
#'   travaillees par semaine
#' @param var_heures_souhaitees character ou NULL -- Heures souhaitees.
#'   Si NULL, utilise le seuil. Defaut : NULL
#' @param seuil_heures integer -- Seuil d'heures hebdomadaires en dessous
#'   duquel il y a sous-emploi (defaut : 35L)
#' @param var_disponible character ou NULL -- Variable 0/1 : disponible
#'   pour travailler plus. Defaut : NULL
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#'
#' @return Un objet de classe \code{saf_emploi}
#'
#' @examples
#' set.seed(42)
#' n <- 400
#' employes <- data.frame(
#'   heures_trav = pmax(0, rnorm(n, 38, 15)),
#'   disponible  = rbinom(n, 1, 0.3),
#'   poids       = runif(n, 0.8, 1.3)
#' )
#' sous_emploi_temps(employes, "heures_trav",
#'                   seuil_heures = 35L, poids = "poids")
#'
#' @export
sous_emploi_temps <- function(donnees,
                               var_heures_travaillees,
                               var_heures_souhaitees = NULL,
                               seuil_heures          = 35L,
                               var_disponible        = NULL,
                               poids                 = NULL,
                               sous_groupes          = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_heures_travaillees %in% names(donnees)) {
    rlang::abort(paste0(
      "Variable '", var_heures_travaillees, "' introuvable."
    ))
  }

  h <- as.numeric(donnees[[var_heures_travaillees]])
  w <- if (!is.null(poids) && poids %in% names(donnees)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp) | wp <= 0] <- 1; wp
  } else rep(1, nrow(donnees))

  # Critere sous-emploi : < seuil ET disponible (si fourni)
  sous_emp <- as.integer(!is.na(h) & h < seuil_heures)
  if (!is.null(var_disponible) && var_disponible %in% names(donnees)) {
    dispo    <- as.integer(donnees[[var_disponible]])
    sous_emp <- as.integer(sous_emp == 1L & !is.na(dispo) & dispo == 1L)
  }

  ok <- !is.na(h)
  taux_val <- stats::weighted.mean(sous_emp[ok], w[ok])
  n_obs    <- sum(ok)

  message("=== Sous-emploi en temps de travail (OIT) ===")
  message("  Seuil : < ", seuil_heures, " heures/semaine")
  message("  Taux  : ", round(taux_val * 100, 1), "%")

  structure(
    list(
      indicateur  = "Sous-emploi en temps de travail",
      code_ref    = "OIT LU2",
      description = paste0("Heures travaillees < ", seuil_heures, "h/semaine"),
      taux        = round(taux_val, 4),
      taux_pct    = round(taux_val * 100, 2),
      ic_bas      = round(.wilson_ic_emp(taux_val, n_obs)[1] * 100, 2),
      ic_haut     = round(.wilson_ic_emp(taux_val, n_obs)[2] * 100, 2),
      n_obs       = n_obs,
      seuil_heures = as.integer(seuil_heures),
      decomposition = NULL
    ),
    class = "saf_emploi"
  )
}

# =============================================================================
# 5. TAUX DE SOUS-UTILISATION COMPOSITE
# =============================================================================

#' @title Calculer le taux de sous-utilisation composite de la main-d'oeuvre
#' @description Calcule le taux composite OIT LU3 ou LU4 qui agrege
#'   le chomage, le sous-emploi en temps de travail et les actifs
#'   potentiels non recherchant activement. Depasse le simple taux
#'   de chomage pour mesurer la sous-utilisation reelle.
#'
#' @param donnees data.frame -- Donnees individuelles
#' @param var_chomeur character -- Variable 0/1 : chomeur (BIT)
#' @param var_sous_emploi_t character ou NULL -- Variable 0/1 : sous-emploi
#'   temps. Defaut : NULL
#' @param var_actif_potentiel character ou NULL -- Variable 0/1 : actif
#'   potentiel (souhaite travailler mais ne cherche pas). Defaut : NULL
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#'
#' @return Un tibble avec les composantes et le taux composite
#'
#' @examples
#' set.seed(42)
#' n <- 500
#' individus <- data.frame(
#'   chomeur         = rbinom(n, 1, 0.14),
#'   sous_emploi_t   = rbinom(n, 1, 0.08),
#'   actif_potentiel = rbinom(n, 1, 0.05),
#'   poids           = runif(n, 0.8, 1.3)
#' )
#' taux_sous_utilisation(individus, "chomeur",
#'                        var_sous_emploi_t = "sous_emploi_t",
#'                        var_actif_potentiel = "actif_potentiel",
#'                        poids = "poids")
#'
#' @export
taux_sous_utilisation <- function(donnees,
                                   var_chomeur,
                                   var_sous_emploi_t   = NULL,
                                   var_actif_potentiel = NULL,
                                   poids               = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_chomeur %in% names(donnees)) {
    rlang::abort(paste0("Variable chomeur '", var_chomeur, "' introuvable."))
  }

  w <- if (!is.null(poids) && poids %in% names(donnees)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp) | wp <= 0] <- 1; wp
  } else rep(1, nrow(donnees))

  .taux_var <- function(var) {
    if (is.null(var) || !var %in% names(donnees)) return(0)
    v  <- as.integer(donnees[[var]])
    ok <- !is.na(v)
    stats::weighted.mean(v[ok], w[ok])
  }

  t_chomage  <- .taux_var(var_chomeur)
  t_sous_emp <- .taux_var(var_sous_emploi_t)
  t_potentiel <- .taux_var(var_actif_potentiel)

  # LU2 = Chomage + Sous-emploi temps
  lu2 <- t_chomage + t_sous_emp
  # LU3 = LU2 + Actifs potentiels
  lu3 <- lu2 + t_potentiel

  res <- tibble::tibble(
    composante = c(
      "Chomage (LU1 / ODD 8.5.2)",
      "Sous-emploi en temps (LU2)",
      "Actifs potentiels (LU3)",
      "Total LU2 (chomage + sous-emploi)",
      "Total LU3 (composite)"
    ),
    taux_pct = round(c(
      t_chomage   * 100,
      t_sous_emp  * 100,
      t_potentiel * 100,
      lu2         * 100,
      lu3         * 100
    ), 2)
  )

  message("=== Sous-utilisation de la main-d'oeuvre (OIT) ===")
  message("  Chomage         : ", round(t_chomage  * 100, 1), "%")
  message("  Sous-emploi t.  : ", round(t_sous_emp * 100, 1), "%")
  message("  LU3 composite   : ", round(lu3        * 100, 1), "%")

  res
}

# =============================================================================
# 6. PAUVRETE AU TRAVAIL
# =============================================================================

#' @title Calculer le taux de pauvrete au travail (working poor)
#' @description Proportion des actifs occupes vivant sous le seuil de
#'   pauvrete national. Indicateur ODD 8.1.1 et lien emploi-pauvrete.
#'
#' @param donnees data.frame -- Donnees individuelles (actifs occupes)
#' @param var_employe character -- Variable 0/1 : a un emploi
#' @param var_revenu character -- Variable de revenu ou consommation
#'   par tete du menage
#' @param seuil numeric -- Seuil de pauvrete national
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#'
#' @return Un objet de classe \code{saf_emploi}
#'
#' @examples
#' set.seed(42)
#' n <- 500
#' individus <- data.frame(
#'   employe = rbinom(n, 1, 0.60),
#'   revenu  = pmax(10000, rnorm(n, 180000, 90000)),
#'   milieu  = sample(c("urbain","rural"), n, TRUE),
#'   poids   = runif(n, 0.8, 1.3)
#' )
#' pauvrete_travail(individus, "employe", "revenu",
#'                   seuil = 144800, poids = "poids")
#'
#' @export
pauvrete_travail <- function(donnees,
                              var_employe,
                              var_revenu,
                              seuil,
                              poids        = NULL,
                              sous_groupes = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  for (v in c(var_employe, var_revenu)) {
    if (!v %in% names(donnees)) {
      rlang::abort(paste0("Variable '", v, "' introuvable."))
    }
  }

  emp <- as.integer(donnees[[var_employe]])
  rev <- as.numeric(donnees[[var_revenu]])
  w   <- if (!is.null(poids) && poids %in% names(donnees)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp) | wp <= 0] <- 1; wp
  } else rep(1, nrow(donnees))

  # Actifs occupes pauvres
  ok          <- !is.na(emp) & emp == 1L & !is.na(rev)
  pauvre_trav <- as.integer(rev < seuil)
  taux_val    <- if (sum(ok) > 0)
    stats::weighted.mean(pauvre_trav[ok], w[ok]) else 0
  n_obs <- sum(ok)

  # Desagregation
  decomp <- NULL
  if (!is.null(sous_groupes)) {
    decomp <- lapply(sous_groupes, function(sg) {
      if (!sg %in% names(donnees)) return(NULL)
      g <- as.character(donnees[[sg]])
      dplyr::bind_rows(lapply(sort(unique(g[!is.na(g)])), function(gr) {
        idx  <- which(g == gr)
        ok_g <- ok[idx]
        if (sum(ok_g) < 5L) return(NULL)
        tv <- stats::weighted.mean(pauvre_trav[idx][ok_g], w[idx][ok_g])
        tibble::tibble(variable=sg, groupe=gr,
                       taux_pct=round(tv*100,2), n=sum(ok_g))
      }))
    })
    decomp <- dplyr::bind_rows(decomp)
  }

  message("=== Pauvrete au travail (ODD 8.1.1) ===")
  message("  Taux : ", round(taux_val * 100, 1), "% des actifs occupes")
  message("  N    : ", format(n_obs, big.mark=" "), " actifs occupes")

  structure(
    list(
      indicateur   = "Pauvrete au travail (working poor)",
      code_ref     = "ODD 8.1.1",
      description  = paste0("Actifs occupes avec revenu < ",
                             format(seuil, big.mark=" "), " FCFA"),
      taux         = round(taux_val, 4),
      taux_pct     = round(taux_val * 100, 2),
      ic_bas       = round(.wilson_ic_emp(taux_val, n_obs)[1] * 100, 2),
      ic_haut      = round(.wilson_ic_emp(taux_val, n_obs)[2] * 100, 2),
      n_obs        = n_obs,
      seuil        = seuil,
      decomposition = decomp
    ),
    class = "saf_emploi"
  )
}

# =============================================================================
# 7. EMPLOI VULNERABLE
# =============================================================================

#' @title Calculer le taux d'emploi vulnerable
#' @description Part des actifs occupes en situation d'emploi vulnerable :
#'   travailleurs familiaux non remuneres et travailleurs independants
#'   precaires. ODD 8.3.1.
#'
#' @param donnees data.frame -- Donnees actifs occupes
#' @param var_vulnerable character -- Variable 0/1 : emploi vulnerable
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#'
#' @return Un objet de classe \code{saf_emploi}
#'
#' @examples
#' set.seed(42)
#' n <- 400
#' employes <- data.frame(
#'   vulnerable = rbinom(n, 1, 0.55),
#'   sexe       = sample(c("H","F"), n, TRUE),
#'   poids      = runif(n, 0.8, 1.3)
#' )
#' emploi_vulnerable(employes, "vulnerable", poids="poids",
#'                    sous_groupes="sexe")
#'
#' @export
emploi_vulnerable <- function(donnees,
                               var_vulnerable,
                               poids        = NULL,
                               sous_groupes = NULL) {

  .calcul_taux_emploi(
    donnees      = donnees,
    var_cible    = var_vulnerable,
    indicateur   = "Emploi vulnerable",
    code_ref     = "ODD 8.3.1",
    description  = "Familiaux non rem. + independants precaires / Total employes",
    var_age      = NULL,
    age_min      = 15L,
    age_max      = 64L,
    poids        = poids,
    sous_groupes = sous_groupes
  )
}

# =============================================================================
# 8. PROTECTION SOCIALE
# =============================================================================

#' @title Calculer la couverture de protection sociale
#' @description Calcule la proportion de la population couverte par au
#'   moins un regime de protection sociale (retraite, assurance maladie,
#'   allocations). ODD 1.3.1.
#'
#' @param donnees data.frame -- Donnees menages ou individus
#' @param vars_protection named character -- Vecteur nomme : type de
#'   protection -> variable 0/1. Ex: c(Retraite="retraite",
#'   Assurance_maladie="assur_maladie")
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#'
#' @return Un tibble avec couverture par type de protection
#'
#' @examples
#' set.seed(42)
#' n <- 400
#' individus <- data.frame(
#'   retraite      = rbinom(n, 1, 0.18),
#'   assur_maladie = rbinom(n, 1, 0.22),
#'   allocations   = rbinom(n, 1, 0.12),
#'   poids         = runif(n, 0.8, 1.3)
#' )
#' protection_sociale(individus,
#'   vars_protection = c(Retraite="retraite",
#'                       Assurance_maladie="assur_maladie",
#'                       Allocations="allocations"),
#'   poids = "poids")
#'
#' @export
protection_sociale <- function(donnees,
                                vars_protection,
                                poids        = NULL,
                                sous_groupes = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (is.null(names(vars_protection)) || length(vars_protection) == 0L) {
    rlang::abort(paste0(
      "`vars_protection` doit etre un vecteur nomme.\n",
      "Exemple : c(Retraite='var_retraite', Maladie='var_maladie')"
    ))
  }

  vars_abs <- vars_protection[!vars_protection %in% names(donnees)]
  if (length(vars_abs) > 0) {
    rlang::abort(paste0(
      "Variables introuvables : ", paste(vars_abs, collapse=", ")
    ))
  }

  w <- if (!is.null(poids) && poids %in% names(donnees)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp) | wp <= 0] <- 1; wp
  } else rep(1, nrow(donnees))

  res <- lapply(names(vars_protection), function(nm) {
    v  <- as.integer(donnees[[vars_protection[[nm]]]])
    ok <- !is.na(v)
    tv <- stats::weighted.mean(v[ok], w[ok])
    tibble::tibble(
      type_protection = nm,
      couverture_pct  = round(tv * 100, 2),
      n_obs           = sum(ok)
    )
  })
  res_df <- dplyr::bind_rows(res)

  # Couverture par au moins un regime
  mat <- sapply(vars_protection, function(v) {
    as.integer(donnees[[v]])
  })
  au_moins_un <- as.integer(rowSums(mat, na.rm=TRUE) > 0)
  ok_tot <- rowSums(!is.na(mat)) > 0
  taux_global <- stats::weighted.mean(au_moins_un[ok_tot], w[ok_tot])

  res_df <- dplyr::bind_rows(
    res_df,
    tibble::tibble(
      type_protection = "Au moins un regime",
      couverture_pct  = round(taux_global * 100, 2),
      n_obs           = sum(ok_tot)
    )
  )

  message("=== Protection sociale (ODD 1.3.1) ===")
  for (i in seq_len(nrow(res_df))) {
    message("  ", res_df$type_protection[i], " : ",
            res_df$couverture_pct[i], "%")
  }

  res_df
}

# =============================================================================
# 9. TRAVAIL DES ENFANTS
# =============================================================================

#' @title Calculer la prevalence du travail des enfants
#' @description Prevalence du travail des enfants (5-17 ans) selon la
#'   definition OIT/MICS. ODD 8.7.1.
#'
#' @param donnees data.frame -- Donnees enfants 5-17 ans
#' @param var_travail_enfant character -- Variable 0/1 : enfant au travail
#' @param var_age character ou NULL -- Variable age pour filtrer 5-17 ans.
#'   Defaut : NULL
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param sous_groupes character ou NULL -- Variables de desagregation.
#'   Defaut : NULL
#'
#' @return Un objet de classe \code{saf_emploi}
#'
#' @examples
#' set.seed(42)
#' n <- 600
#' enfants <- data.frame(
#'   travail = rbinom(n, 1, 0.22),
#'   age     = sample(5:17, n, TRUE),
#'   sexe    = sample(c("H","F"), n, TRUE),
#'   milieu  = sample(c("urbain","rural"), n, TRUE),
#'   poids   = runif(n, 0.8, 1.3)
#' )
#' travail_enfants(enfants, "travail", var_age="age",
#'                  poids="poids", sous_groupes=c("sexe","milieu"))
#'
#' @export
travail_enfants <- function(donnees,
                             var_travail_enfant,
                             var_age      = NULL,
                             poids        = NULL,
                             sous_groupes = NULL) {

  .calcul_taux_emploi(
    donnees      = donnees,
    var_cible    = var_travail_enfant,
    indicateur   = "Travail des enfants",
    code_ref     = "ODD 8.7.1",
    description  = "Enfants 5-17 ans au travail / Total enfants 5-17 ans",
    var_age      = var_age,
    age_min      = 5L,
    age_max      = 17L,
    poids        = poids,
    sous_groupes = sous_groupes
  )
}

# =============================================================================
# 10. TABLEAU DE BORD MARCHE DU TRAVAIL
# =============================================================================

#' @title Tableau de bord du marche du travail
#' @description Synthetise tous les indicateurs du marche du travail en un
#'   tableau institutionnel unique, comparable aux publications OIT/ILOSTAT
#'   et aux rapports nationaux sur l'emploi.
#'
#' @param indicateurs list -- Liste nommee d'objets saf_emploi ou tibbles
#'   (protection_sociale, taux_sous_utilisation)
#' @param pays character -- Nom du pays. Defaut : "Pays"
#' @param annee integer -- Annee. Defaut : annee courante
#' @param source character ou NULL -- Source. Defaut : NULL
#'
#' @return Un tibble institutionnel
#'
#' @examples
#' set.seed(42)
#' n <- 500
#' ind <- data.frame(
#'   actif      = rbinom(n, 1, 0.65),
#'   employe    = rbinom(n, 1, 0.55),
#'   informel   = rbinom(n, 1, 0.72),
#'   poids      = runif(n, 0.8, 1.3),
#'   stringsAsFactors = FALSE
#' )
#' r1 <- suppressMessages(taux_activite(ind, "actif", poids="poids"))
#' r2 <- suppressMessages(taux_emploi(ind, "employe", poids="poids"))
#' r3 <- suppressMessages(emploi_informel(ind, "informel", poids="poids"))
#' tableau_marche_travail(list(activite=r1, emploi=r2, informel=r3),
#'                         pays="Centrafrique", annee=2026L)
#'
#' @export
tableau_marche_travail <- function(indicateurs,
                                    pays   = "Pays",
                                    annee  = as.integer(
                                      format(Sys.Date(), "%Y")),
                                    source = NULL) {

  if (!is.list(indicateurs) || length(indicateurs) == 0L) {
    rlang::abort("`indicateurs` doit etre une liste non vide.")
  }

  rows <- lapply(names(indicateurs), function(nm) {
    ind <- indicateurs[[nm]]
    if (inherits(ind, "saf_emploi")) {
      tibble::tibble(
        indicateur   = ind$indicateur,
        code_ref     = ind$code_ref,
        valeur_pct   = ind$taux_pct,
        ic_bas       = ind$ic_bas,
        ic_haut      = ind$ic_haut,
        n_obs        = ind$n_obs,
        pays         = pays,
        annee        = annee
      )
    } else if (is.data.frame(ind)) {
      # Pour protection_sociale ou taux_sous_utilisation
      tibble::tibble(
        indicateur = nm,
        code_ref   = "OIT",
        valeur_pct = if ("couverture_pct" %in% names(ind))
          ind$couverture_pct[nrow(ind)]
        else if ("taux_pct" %in% names(ind)) ind$taux_pct[nrow(ind)]
        else NA_real_,
        ic_bas     = NA_real_,
        ic_haut    = NA_real_,
        n_obs      = if ("n_obs" %in% names(ind))
          ind$n_obs[nrow(ind)] else NA_integer_,
        pays       = pays,
        annee      = annee
      )
    } else NULL
  })

  res <- dplyr::bind_rows(rows)
  message("Tableau de bord marche du travail : ", pays, " - ", annee,
          " (", nrow(res), " indicateurs)")
  res
}

# =============================================================================
# FONCTION INTERNE
# =============================================================================

#' @keywords internal
.wilson_ic_emp <- function(p, n, alpha = 0.05) {
  if (n == 0) return(c(0, 0))
  z      <- stats::qnorm(1 - alpha/2)
  denom  <- 1 + z^2/n
  centre <- (p + z^2/(2*n)) / denom
  marge  <- z * sqrt(p*(1-p)/n + z^2/(4*n^2)) / denom
  c(max(0, centre - marge), min(1, centre + marge))
}
