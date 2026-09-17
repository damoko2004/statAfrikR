# =============================================================================
# statAfrikR - Module Controles qualite demographique
# Indices de Whipple & Myers, pyramides, tables de mortalite, projections
# Standards : Nations Unies / IUSSP / Pressat
# =============================================================================

utils::globalVariables(c(
  "age", "sexe", "effectif", "digit", "part", "groupe_age",
  "H", "F", "ratio", "taux_spec", "annee", "cohorte",
  "lx", "dx", "qx", "ex", "nLx", "Tx", "px",
  "composante", "valeur", "statut", "interpretation"
))

# =============================================================================
# 1. INDICE DE WHIPPLE
# =============================================================================

#' @title Calculer l'indice de Whipple
#' @description Mesure l'attraction des ages se terminant par 0 et 5 dans
#'   les declarations d'age. Un indice de Whipple < 105 indique des donnees
#'   de tres bonne qualite ; > 175 indique une qualite tres mauvaise.
#'   Methodologie Nations Unies / IUSSP.
#'
#' @param donnees data.frame -- Donnees individuelles
#' @param var_age character -- Variable age en annees revolues
#' @param age_min integer -- Age minimum pour le calcul. Defaut : 23L
#' @param age_max integer -- Age maximum pour le calcul. Defaut : 62L
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#'
#' @return Un objet de classe \code{saf_qualite_demo}
#'
#' @examples
#' set.seed(42)
#' n <- 1000
#' # Simulation d'attraction sur les multiples de 5
#' ages_base <- sample(23:62, n, TRUE)
#' attire    <- ages_base - (ages_base %% 5) # attire vers 0 et 5
#' ages      <- ifelse(runif(n) < 0.25, attire, ages_base)
#' individus <- data.frame(age = ages, poids = runif(n, 0.8, 1.3))
#' whipple(individus, "age")
#'
#' @export
whipple <- function(donnees,
                     var_age,
                     age_min = 23L,
                     age_max = 62L,
                     poids   = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_age %in% names(donnees)) {
    rlang::abort(paste0("Variable age '", var_age, "' introuvable."))
  }
  if (!is.null(poids) && !poids %in% names(donnees)) {
    rlang::abort(paste0("Variable poids '", poids, "' introuvable."))
  }

  ages <- as.integer(donnees[[var_age]])
  w    <- if (!is.null(poids)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp)|wp<=0] <- 1; wp
  } else rep(1, nrow(donnees))

  # Filtrer sur la plage d'age
  ok  <- !is.na(ages) & ages >= age_min & ages <= age_max
  ages_f <- ages[ok]; w_f <- w[ok]

  if (sum(ok) < 50L) {
    rlang::warn(paste0(
      "Moins de 50 observations dans la plage [", age_min, "-", age_max, "]. ",
      "L'indice de Whipple peut etre peu fiable."
    ))
  }

  # Nombre total et nombre aux ages multiples de 5
  n_total   <- sum(w_f)
  n_mult5   <- sum(w_f[ages_f %% 5 == 0])

  # Formule Whipple : W = (nb ages mult. de 5) / (total/5) * 100
  # Correction pour la plage d'age (ONU)
  n_ages_plage <- age_max - age_min + 1
  n_mult5_esperee <- n_total * (floor(n_ages_plage / 5) + 1) / n_ages_plage
  W <- n_mult5 / n_mult5_esperee * 100

  # Interpretation
  interp <- dplyr::case_when(
    W < 105 ~ "Tres bonne qualite (< 105)",
    W < 110 ~ "Bonne qualite (105-110)",
    W < 125 ~ "Qualite approximative (110-125)",
    W < 175 ~ "Qualite mauvaise (125-175)",
    TRUE    ~ "Qualite tres mauvaise (>= 175)"
  )

  message("=== Indice de Whipple ===")
  message("  Whipple : ", round(W, 1), "  (", interp, ")")
  message("  N obs   : ", format(round(n_total), big.mark=" "),
          " individus (ages ", age_min, "-", age_max, ")")

  structure(
    list(
      indice        = round(W, 2),
      interpretation = interp,
      n_obs         = sum(ok),
      age_min       = age_min,
      age_max       = age_max,
      methode       = "Whipple (ONU/IUSSP)"
    ),
    class = "saf_qualite_demo"
  )
}

# =============================================================================
# 2. INDICE DE MYERS
# =============================================================================

#' @title Calculer l'indice de Myers (attraction sur tous les chiffres)
#' @description Mesure l'attraction sur les 10 chiffres terminaux (0-9).
#'   L'indice de Myers varie de 0 (aucune attraction) a 90 (attraction
#'   maximale). Un indice < 10 indique une bonne qualite des donnees d'age.
#'
#' @param donnees data.frame -- Donnees individuelles
#' @param var_age character -- Variable age en annees revolues
#' @param age_min integer -- Age minimum. Defaut : 10L
#' @param age_max integer -- Age maximum. Defaut : 89L
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#'
#' @return Un objet de classe \code{saf_qualite_demo}
#'
#' @examples
#' set.seed(42)
#' n <- 1000
#' ages_base <- sample(10:89, n, TRUE)
#' # Attraction sur les ages ronds
#' ages <- ifelse(runif(n) < 0.20,
#'                ages_base - (ages_base %% 10),
#'                ages_base)
#' individus <- data.frame(age = pmax(10, pmin(89, ages)))
#' myers(individus, "age")
#'
#' @export
myers <- function(donnees,
                   var_age,
                   age_min = 10L,
                   age_max = 89L,
                   poids   = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_age %in% names(donnees)) {
    rlang::abort(paste0("Variable age '", var_age, "' introuvable."))
  }

  ages <- as.integer(donnees[[var_age]])
  w    <- if (!is.null(poids) && poids %in% names(donnees)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp)|wp<=0] <- 1; wp
  } else rep(1, nrow(donnees))

  ok     <- !is.na(ages) & ages >= age_min & ages <= age_max
  ages_f <- ages[ok]; w_f <- w[ok]

  # Calcul Myers : proportion de chaque chiffre terminal
  digits <- 0:9
  blended <- sapply(digits, function(d) {
    # Somme ponderee commencant par le digit d et le digit d+10
    s1 <- sum(w_f[ages_f %% 10 == d & ages_f >= age_min])
    s2 <- sum(w_f[ages_f %% 10 == d & ages_f >= (age_min + 10)])
    s1 + s2
  })

  total   <- sum(blended)
  parts   <- blended / total * 100
  M       <- sum(abs(parts - 10)) / 2

  interp <- dplyr::case_when(
    M < 5  ~ "Tres bonne qualite (< 5)",
    M < 10 ~ "Bonne qualite (5-10)",
    M < 15 ~ "Qualite acceptable (10-15)",
    M < 20 ~ "Qualite mauvaise (15-20)",
    TRUE   ~ "Qualite tres mauvaise (>= 20)"
  )

  distrib <- tibble::tibble(
    digit  = as.character(digits),
    part   = round(parts, 2),
    ecart  = round(parts - 10, 2)
  )

  message("=== Indice de Myers ===")
  message("  Myers : ", round(M, 1), "  (", interp, ")")

  structure(
    list(
      indice         = round(M, 2),
      interpretation = interp,
      distribution   = distrib,
      n_obs          = sum(ok),
      methode        = "Myers (chiffres terminaux 0-9)"
    ),
    class = "saf_qualite_demo"
  )
}

#' @export
print.saf_qualite_demo <- function(x, ...) {
  cat("\n=== Qualite des donnees demographiques ===\n")
  cat("  Methode        :", x$methode, "\n")
  cat("  Indice         :", x$indice, "\n")
  cat("  Interpretation :", x$interpretation, "\n")
  cat("  N obs          :", format(x$n_obs, big.mark=" "), "\n")
  if (!is.null(x$distribution)) {
    cat("\nDistribution par chiffre terminal :\n")
    cat("  Digit : ", paste(x$distribution$digit, collapse=" "), "\n")
    cat("  Part% : ", paste(round(x$distribution$part, 1), collapse=" "), "\n")
  }
  invisible(x)
}

# =============================================================================
# 3. RAPPORT DE MASCULINITE
# =============================================================================

#' @title Calculer le rapport de masculinite par groupe d'age
#' @description Calcule le rapport de masculinite (nombre d'hommes pour
#'   100 femmes) par groupe d'age quinquennal. Permet de detecter des
#'   anomalies liees aux guerres, migrations ou erreurs de collecte.
#'
#' @param donnees data.frame -- Donnees individuelles
#' @param var_age character -- Variable age en annees
#' @param var_sexe character -- Variable sexe
#' @param code_homme character ou numeric -- Code pour les hommes.
#'   Defaut : "H"
#' @param code_femme character ou numeric -- Code pour les femmes.
#'   Defaut : "F"
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param groupes_age integer -- Largeur des groupes d'age. Defaut : 5L
#'
#' @return Un tibble avec rapport de masculinite par groupe d'age
#'
#' @examples
#' set.seed(42)
#' n <- 2000
#' individus <- data.frame(
#'   age   = sample(0:79, n, TRUE),
#'   sexe  = sample(c("H","F"), n, TRUE, prob=c(0.49,0.51)),
#'   poids = runif(n, 0.8, 1.3)
#' )
#' ratio_masculinite(individus, "age", "sexe", poids="poids")
#'
#' @export
ratio_masculinite <- function(donnees,
                               var_age,
                               var_sexe,
                               code_homme    = "H",
                               code_femme    = "F",
                               poids         = NULL,
                               groupes_age   = 5L) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  for (v in c(var_age, var_sexe)) {
    if (!v %in% names(donnees)) {
      rlang::abort(paste0("Variable '", v, "' introuvable."))
    }
  }

  ages <- as.integer(donnees[[var_age]])
  sexe <- as.character(donnees[[var_sexe]])
  w    <- if (!is.null(poids) && poids %in% names(donnees)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp)|wp<=0] <- 1; wp
  } else rep(1, nrow(donnees))

  # Creer les groupes d'age quinquennaux
  age_max_obs <- max(ages, na.rm=TRUE)
  bornes <- seq(0, age_max_obs + groupes_age, by=groupes_age)

  # Assigner les groupes
  groupe <- cut(ages, breaks=bornes, right=FALSE, include.lowest=TRUE)
  niveaux <- levels(groupe)

  res <- dplyr::bind_rows(lapply(niveaux, function(g) {
    idx <- which(as.character(groupe) == g & !is.na(ages))
    if (length(idx) == 0) return(NULL)
    n_h <- sum(w[idx][sexe[idx] == as.character(code_homme)], na.rm=TRUE)
    n_f <- sum(w[idx][sexe[idx] == as.character(code_femme)],  na.rm=TRUE)
    ratio <- if (n_f > 0) round(n_h / n_f * 100, 1) else NA_real_
    tibble::tibble(
      groupe_age = g,
      H          = round(n_h, 0),
      F          = round(n_f, 0),
      ratio      = ratio,
      alerte     = !is.na(ratio) && (ratio < 90 | ratio > 110)
    )
  }))

  n_alertes <- sum(res$alerte, na.rm=TRUE)

  message("=== Rapport de masculinite par groupe d'age ===")
  message("  Groupes analyses : ", nrow(res))
  message("  Groupes en alerte (ratio < 90 ou > 110) : ", n_alertes)

  res
}

# =============================================================================
# 4. PYRAMIDE DES AGES
# =============================================================================

#' @title Construire et tracer la pyramide des ages
#' @description Produit une pyramide des ages institutionnelle au format
#'   ggplot2. Permet la superposition de deux annees pour l'analyse des
#'   tendances demographiques.
#'
#' @param donnees data.frame -- Donnees individuelles
#' @param var_age character -- Variable age en annees
#' @param var_sexe character -- Variable sexe
#' @param code_homme character ou numeric -- Code hommes. Defaut : "H"
#' @param code_femme character ou numeric -- Code femmes. Defaut : "F"
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param groupes_age integer -- Largeur des groupes. Defaut : 5L
#' @param titre character ou NULL -- Titre. Defaut : NULL
#' @param source character ou NULL -- Source. Defaut : NULL
#'
#' @return Un objet \code{ggplot2}
#'
#' @examples
#' set.seed(42)
#' n <- 3000
#' individus <- data.frame(
#'   age   = round(rexp(n, 1/30)),
#'   sexe  = sample(c("H","F"), n, TRUE),
#'   poids = runif(n, 0.8, 1.3)
#' )
#' individus$age <- pmin(individus$age, 85)
#' pyramide_age(individus, "age", "sexe", poids="poids",
#'              titre="Pyramide des ages", source="Recensement 2024")
#'
#' @export
pyramide_age <- function(donnees,
                          var_age,
                          var_sexe,
                          code_homme  = "H",
                          code_femme  = "F",
                          poids       = NULL,
                          groupes_age = 5L,
                          titre       = NULL,
                          source      = NULL) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  for (v in c(var_age, var_sexe)) {
    if (!v %in% names(donnees)) {
      rlang::abort(paste0("Variable '", v, "' introuvable."))
    }
  }

  ages <- as.integer(donnees[[var_age]])
  sexe <- as.character(donnees[[var_sexe]])
  w    <- if (!is.null(poids) && poids %in% names(donnees)) {
    wp <- as.numeric(donnees[[poids]]); wp[is.na(wp)|wp<=0] <- 1; wp
  } else rep(1, nrow(donnees))

  # Groupes d'age
  age_max_obs <- min(max(ages, na.rm=TRUE), 85)
  bornes  <- seq(0, age_max_obs + groupes_age, by=groupes_age)
  groupe  <- cut(ages, breaks=bornes, right=FALSE, include.lowest=TRUE)
  niveaux <- levels(groupe)

  # Calcul des effectifs
  df_plot <- dplyr::bind_rows(lapply(niveaux, function(g) {
    idx <- which(as.character(groupe) == g & !is.na(ages))
    n_h <- sum(w[idx][sexe[idx] == as.character(code_homme)], na.rm=TRUE)
    n_f <- sum(w[idx][sexe[idx] == as.character(code_femme)],  na.rm=TRUE)
    tibble::tibble(
      groupe_age = g,
      H          = n_h,
      F          = -n_f  # Negatif pour la pyramide
    )
  }))

  df_long <- tidyr::pivot_longer(
    df_plot, cols=c("H","F"),
    names_to="sexe", values_to="effectif"
  )
  df_long$groupe_age <- factor(df_long$groupe_age, levels=niveaux)

  g <- ggplot2::ggplot(df_long,
    ggplot2::aes(x=.data$effectif,
                 y=.data$groupe_age,
                 fill=.data$sexe)) +
    ggplot2::geom_bar(stat="identity", width=0.85, alpha=0.9) +
    ggplot2::scale_fill_manual(
      values = c(H="#1B4965", F="#DC2626"),
      labels = c(H="Hommes", F="Femmes"),
      name   = "Sexe"
    ) +
    ggplot2::scale_x_continuous(
      labels = function(x) format(abs(x), big.mark=" ")
    ) +
    ggplot2::geom_vline(xintercept=0, color="#1E293B", linewidth=0.5) +
    ggplot2::theme_minimal(base_size=11) +
    ggplot2::theme(
      plot.background = ggplot2::element_rect(fill="#F0F7FF", color=NA),
      plot.title      = ggplot2::element_text(size=13, face="bold",
                                               color="#0F2742"),
      legend.position = "bottom",
      panel.grid.minor = ggplot2::element_blank()
    ) +
    ggplot2::labs(
      title   = if (!is.null(titre)) titre else "Pyramide des ages",
      x       = "Effectifs",
      y       = "Groupe d'age",
      caption = if (!is.null(source))
        paste0("Source : ", source, " | statAfrikR")
      else "statAfrikR Foundation"
    )
  g
}

# =============================================================================
# 5. COHERENCE DEMOGRAPHIQUE
# =============================================================================

#' @title Verifier la coherence demographique des donnees
#' @description Detecte les incoherences courantes dans les donnees
#'   demographiques : age mere < age enfant, dates d'evenements
#'   incoherentes, ages impossibles, sex-ratio aberrants, etc.
#'
#' @param donnees data.frame -- Donnees individuelles ou menages
#' @param var_age character ou NULL -- Variable age. Defaut : NULL
#' @param var_age_mere character ou NULL -- Variable age de la mere.
#'   Defaut : NULL
#' @param var_age_enfant character ou NULL -- Variable age de l'enfant.
#'   Defaut : NULL
#' @param var_age_deces character ou NULL -- Variable age au deces.
#'   Defaut : NULL
#' @param var_sexe character ou NULL -- Variable sexe. Defaut : NULL
#' @param age_max_plausible integer -- Age maximum plausible. Defaut : 120L
#'
#' @return Un tibble des anomalies detectees avec leur nombre
#'
#' @examples
#' set.seed(42)
#' n <- 500
#' menages <- data.frame(
#'   age         = c(sample(0:100, n-5, TRUE), rep(-1, 3), rep(130, 2)),
#'   age_mere    = sample(15:60, n, TRUE),
#'   age_enfant  = sample(0:30,  n, TRUE),
#'   age_deces   = c(sample(1:90, n-10, TRUE), rep(NA, 10)),
#'   sexe        = sample(c("H","F","X"), n, TRUE, prob=c(0.49,0.49,0.02))
#' )
#' coherence_demo(menages,
#'   var_age="age", var_age_mere="age_mere",
#'   var_age_enfant="age_enfant",
#'   var_sexe="sexe")
#'
#' @export
coherence_demo <- function(donnees,
                            var_age            = NULL,
                            var_age_mere       = NULL,
                            var_age_enfant     = NULL,
                            var_age_deces      = NULL,
                            var_sexe           = NULL,
                            age_max_plausible  = 120L) {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }

  problemes <- list()

  # Ages negatifs ou impossibles
  if (!is.null(var_age) && var_age %in% names(donnees)) {
    ages <- as.integer(donnees[[var_age]])
    n_neg <- sum(!is.na(ages) & ages < 0)
    n_imp <- sum(!is.na(ages) & ages > age_max_plausible)
    if (n_neg > 0) {
      problemes[["Ages negatifs"]] <- tibble::tibble(
        type_anomalie = "Age negatif (< 0)",
        n_anomalies   = n_neg,
        pct           = round(n_neg/nrow(donnees)*100, 2),
        gravite       = "Critique"
      )
    }
    if (n_imp > 0) {
      problemes[["Ages impossibles"]] <- tibble::tibble(
        type_anomalie = paste0("Age > ", age_max_plausible, " ans"),
        n_anomalies   = n_imp,
        pct           = round(n_imp/nrow(donnees)*100, 2),
        gravite       = "Critique"
      )
    }
  }

  # Age mere < age enfant + ecart min
  if (!is.null(var_age_mere) && !is.null(var_age_enfant) &&
      var_age_mere %in% names(donnees) &&
      var_age_enfant %in% names(donnees)) {
    am <- as.integer(donnees[[var_age_mere]])
    ae <- as.integer(donnees[[var_age_enfant]])
    ok <- !is.na(am) & !is.na(ae)
    # Mere doit avoir au moins 12 ans de plus que l'enfant
    n_inc <- sum(ok & (am - ae) < 12)
    if (n_inc > 0) {
      problemes[["Mere-enfant"]] <- tibble::tibble(
        type_anomalie = "Age mere - age enfant < 12 ans",
        n_anomalies   = n_inc,
        pct           = round(n_inc/sum(ok)*100, 2),
        gravite       = "Important"
      )
    }
  }

  # Sexe invalide
  if (!is.null(var_sexe) && var_sexe %in% names(donnees)) {
    sx   <- as.character(donnees[[var_sexe]])
    vals_valides <- c("h","m","homme","garcon","male","1",
                      "f","femme","fille","female","2")
    n_inv <- sum(!is.na(sx) & !tolower(sx) %in% vals_valides)
    if (n_inv > 0) {
      problemes[["Sexe invalide"]] <- tibble::tibble(
        type_anomalie = "Code sexe invalide",
        n_anomalies   = n_inv,
        pct           = round(n_inv/nrow(donnees)*100, 2),
        gravite       = "Important"
      )
    }
  }

  if (length(problemes) == 0) {
    message("=== Coherence demographique : aucune anomalie detectee ===")
    return(tibble::tibble(
      type_anomalie = "Aucune anomalie detectee",
      n_anomalies   = 0L,
      pct           = 0,
      gravite       = "OK"
    ))
  }

  res <- dplyr::bind_rows(problemes)
  message("=== Coherence demographique ===")
  message("  Anomalies detectees : ", nrow(res), " type(s)")
  for (i in seq_len(nrow(res))) {
    message("  [", res$gravite[i], "] ", res$type_anomalie[i],
            " : n=", res$n_anomalies[i], " (", res$pct[i], "%)")
  }
  res
}

# =============================================================================
# 6. RAPPORT DE QUALITE DEMOGRAPHIQUE
# =============================================================================

#' @title Produire un rapport de qualite des donnees demographiques
#' @description Synthetise les indicateurs de qualite des donnees
#'   demographiques (Whipple, Myers, rapport de masculinite, coherence)
#'   en un tableau institutionnel conforme aux standards Nations Unies.
#'
#' @param donnees data.frame -- Donnees individuelles
#' @param var_age character -- Variable age
#' @param var_sexe character ou NULL -- Variable sexe. Defaut : NULL
#' @param poids character ou NULL -- Variable de ponderation. Defaut : NULL
#' @param pays character -- Nom du pays. Defaut : "Pays"
#' @param annee integer -- Annee. Defaut : annee courante
#' @param source_donnees character -- Source des donnees.
#'   Defaut : "Recensement"
#'
#' @return Un tibble de rapport qualite
#'
#' @examples
#' set.seed(42)
#' n <- 2000
#' ages_base <- sample(10:79, n, TRUE)
#' ages <- ifelse(runif(n) < 0.15, ages_base - ages_base%%5, ages_base)
#' individus <- data.frame(
#'   age   = ages,
#'   sexe  = sample(c("H","F"), n, TRUE),
#'   poids = runif(n, 0.8, 1.3)
#' )
#' rapport_qualite_demo(individus, "age", var_sexe="sexe",
#'                       poids="poids", pays="RCA", annee=2024L)
#'
#' @export
rapport_qualite_demo <- function(donnees,
                                  var_age,
                                  var_sexe      = NULL,
                                  poids         = NULL,
                                  pays          = "Pays",
                                  annee         = as.integer(
                                    format(Sys.Date(),"%Y")),
                                  source_donnees = "Recensement") {

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }
  if (!var_age %in% names(donnees)) {
    rlang::abort(paste0("Variable age '", var_age, "' introuvable."))
  }

  # Whipple
  w_res <- suppressMessages(whipple(donnees, var_age, poids=poids))

  # Myers
  m_res <- suppressMessages(myers(donnees, var_age, poids=poids))

  indicateurs <- tibble::tibble(
    indicateur = c(
      "Indice de Whipple (attraction 0 et 5)",
      "Indice de Myers (attraction tous chiffres)"
    ),
    valeur = c(w_res$indice, m_res$indice),
    interpretation = c(w_res$interpretation, m_res$interpretation),
    seuil_bonne_qualite = c("< 105", "< 10"),
    statut = c(
      if (w_res$indice < 105) "OK" else if (w_res$indice < 125) "Attention" else "Alerte",
      if (m_res$indice < 10)  "OK" else if (m_res$indice < 20)  "Attention" else "Alerte"
    )
  )

  # Rapport de masculinite si sexe fourni
  if (!is.null(var_sexe) && var_sexe %in% names(donnees)) {
    rm_res <- suppressMessages(
      ratio_masculinite(donnees, var_age, var_sexe, poids=poids))
    n_alertes_rm <- sum(rm_res$alerte, na.rm=TRUE)
    indicateurs <- dplyr::bind_rows(indicateurs, tibble::tibble(
      indicateur = "Rapport de masculinite (groupes anomaux)",
      valeur     = n_alertes_rm,
      interpretation = paste0(n_alertes_rm, " groupe(s) avec ratio < 90 ou > 110"),
      seuil_bonne_qualite = "0 groupe anormal",
      statut = if (n_alertes_rm == 0) "OK" else "Attention"
    ))
  }

  indicateurs$pays          <- pays
  indicateurs$annee         <- annee
  indicateurs$source        <- source_donnees
  indicateurs$n_obs         <- nrow(donnees)

  message("=== Rapport qualite demographique : ", pays, " - ", annee, " ===")
  for (i in seq_len(nrow(indicateurs))) {
    message("  [", indicateurs$statut[i], "] ",
            indicateurs$indicateur[i], " : ", indicateurs$valeur[i])
  }

  indicateurs
}
