# =============================================================================
# statAfrikR - Catalogue des indicateurs et methodes
# Fiches de conformite methodologique pour les INS africains
# Conforme GSBPM 5.2 / UN NQAF / PARIS21
# =============================================================================

utils::globalVariables(c(
  "code", "nom", "domaine", "standard", "formule",
  "population", "unite", "odd", "variance", "ins_ready"
))

# Registre interne des indicateurs
.CATALOGUE_INDICATEURS <- list(

  FGT0 = list(
    code            = "FGT0",
    nom             = "Incidence de la pauvrete",
    domaine         = "Pauvrete monetaire",
    definition      = "Proportion de la population vivant sous le seuil de pauvrete national",
    formule         = "FGT0 = (1/N) * sum(1(yi < z))",
    numerateur      = "Nombre d'individus avec consommation < seuil",
    denominateur    = "Population totale N",
    unite           = "Proportion [0-1]",
    population      = "Population totale ou sous-groupe",
    standard        = "Foster, Greer & Thorbecke (1984)",
    reference       = "Econometrica 52(3), 761-766",
    odd             = "ODD 1.1.1 / 1.2.1",
    variance        = "Taylor (plan complexe) / Wilson (simple)",
    seuil_cv        = 33,
    seuil_n         = 30L,
    fonction_r      = "calcul_fgt()",
    gsbpm           = "5.1 - Analyse",
    ins_ready       = TRUE
  ),

  FGT1 = list(
    code            = "FGT1",
    nom             = "Profondeur de la pauvrete",
    domaine         = "Pauvrete monetaire",
    definition      = "Intensite moyenne de la pauvrete parmi la population totale",
    formule         = "FGT1 = (1/N) * sum((z - yi)/z * 1(yi < z))",
    numerateur      = "Somme des ecarts normalises au seuil",
    denominateur    = "Population totale N",
    unite           = "Proportion [0-1]",
    population      = "Population totale",
    standard        = "Foster, Greer & Thorbecke (1984)",
    reference       = "Econometrica 52(3), 761-766",
    odd             = "ODD 1.1.1",
    variance        = "Taylor (plan complexe) / Wilson (simple)",
    seuil_cv        = 33,
    seuil_n         = 30L,
    fonction_r      = "calcul_fgt()",
    gsbpm           = "5.1 - Analyse",
    ins_ready       = TRUE
  ),

  FGT2 = list(
    code            = "FGT2",
    nom             = "Severite de la pauvrete",
    domaine         = "Pauvrete monetaire",
    definition      = "Indice mesurant l'inegalite au sein de la population pauvre",
    formule         = "FGT2 = (1/N) * sum(((z - yi)/z)^2 * 1(yi < z))",
    numerateur      = "Somme des carres des ecarts normalises",
    denominateur    = "Population totale N",
    unite           = "Proportion [0-1]",
    population      = "Population totale",
    standard        = "Foster, Greer & Thorbecke (1984)",
    reference       = "Econometrica 52(3), 761-766",
    odd             = "ODD 1.1.1",
    variance        = "Taylor (plan complexe) / Wilson (simple)",
    seuil_cv        = 33,
    seuil_n         = 30L,
    fonction_r      = "calcul_fgt()",
    gsbpm           = "5.1 - Analyse",
    ins_ready       = TRUE
  ),

  IPM = list(
    code            = "IPM",
    nom             = "Indice de Pauvrete Multidimensionnelle",
    domaine         = "Pauvrete multidimensionnelle",
    definition      = "Mesure composite de la pauvrete selon 3 dimensions et 10 indicateurs",
    formule         = "IPM = H * A (incidence * intensite)",
    numerateur      = "H = part menages pauvres MPI; A = intensite moyenne",
    denominateur    = "N total menages",
    unite           = "[0-1]",
    population      = "Menages",
    standard        = "Alkire & Foster (2011)",
    reference       = "Journal of Public Economics doi:10.1093/oep/gpr051",
    odd             = "ODD 1.2.2",
    variance        = "Bootstrap / Delta method",
    seuil_cv        = 33,
    seuil_n         = 30L,
    fonction_r      = "calcul_ipm()",
    gsbpm           = "5.1 - Analyse",
    ins_ready       = TRUE
  ),

  GINI = list(
    code            = "GINI",
    nom             = "Coefficient de Gini",
    domaine         = "Inegalites",
    definition      = "Mesure de l'inegalite de la distribution des revenus/depenses",
    formule         = "G = 1 - 2*integral(L(p)dp) [courbe de Lorenz]",
    numerateur      = "Aire entre droite d'egalite et courbe de Lorenz",
    denominateur    = "Aire totale sous la droite d'egalite",
    unite           = "[0-1]",
    population      = "Population totale",
    standard        = "Gini (1912) / World Bank",
    reference       = "Varianza e mutabilita, Memorie di Metodologia Statistica",
    odd             = "ODD 10.1",
    variance        = "Bootstrap",
    seuil_cv        = 20,
    seuil_n         = 100L,
    fonction_r      = "calcul_gini()",
    gsbpm           = "5.1 - Analyse",
    ins_ready       = TRUE
  ),

  STUNTING = list(
    code            = "STUNTING",
    nom             = "Retard de croissance (Stunting)",
    domaine         = "Sante et nutrition",
    definition      = "Proportion d'enfants avec HAZ < -2 ecarts-types",
    formule         = "HAZ = (taille_obs - mediane_ref) / SD_ref",
    numerateur      = "Enfants avec HAZ < -2SD",
    denominateur    = "Total enfants mesures",
    unite           = "Proportion [0-1]",
    population      = "Enfants 0-59 mois",
    standard        = "OMS (2006) Normes de croissance",
    reference       = "WHO Child Growth Standards",
    odd             = "ODD 2.2.1",
    variance        = "Wilson (IC exact)",
    seuil_cv        = 33,
    seuil_n         = 30L,
    fonction_r      = "retard_croissance()",
    gsbpm           = "5.1 - Analyse",
    ins_ready       = TRUE
  ),

  TAUX_ACTIVITE = list(
    code            = "TAUX_ACTIVITE",
    nom             = "Taux d'activite",
    domaine         = "Emploi",
    definition      = "Proportion de la population en age de travailler qui est active",
    formule         = "TA = Actifs (employes + chomeurs) / Pop. 15-64 ans",
    numerateur      = "Personnes actives (employes + chomeurs BIT)",
    denominateur    = "Population 15-64 ans",
    unite           = "Proportion [0-1]",
    population      = "Population 15-64 ans",
    standard        = "BIT / OIT Resolution 2013",
    reference       = "19th ICLS Resolution concerning statistics of work",
    odd             = "ODD 8.5",
    variance        = "Wilson (IC exact)",
    seuil_cv        = 33,
    seuil_n         = 30L,
    fonction_r      = "taux_activite()",
    gsbpm           = "5.1 - Analyse",
    ins_ready       = TRUE
  ),

  CHOMAGE = list(
    code            = "CHOMAGE",
    nom             = "Taux de chomage BIT",
    domaine         = "Emploi",
    definition      = "Proportion des actifs sans emploi et cherchant activement",
    formule         = "TC = Chomeurs BIT / Actifs totaux",
    numerateur      = "Chomeurs (sans emploi + disponibles + cherchant)",
    denominateur    = "Population active",
    unite           = "Proportion [0-1]",
    population      = "Population active 15+",
    standard        = "BIT / OIT Resolution 2013",
    reference       = "19th ICLS Resolution",
    odd             = "ODD 8.5.2",
    variance        = "Wilson (IC exact)",
    seuil_cv        = 33,
    seuil_n         = 30L,
    fonction_r      = "taux_activite()",
    gsbpm           = "5.1 - Analyse",
    ins_ready       = TRUE
  ),

  INFORMEL = list(
    code            = "INFORMEL",
    nom             = "Taux d'emploi informel",
    domaine         = "Emploi",
    definition      = "Proportion des employes sans contrat ni protection sociale",
    formule         = "EI = Employes informels / Total employes",
    numerateur      = "Employes sans contrat/protection sociale",
    denominateur    = "Total employes",
    unite           = "Proportion [0-1]",
    population      = "Population occupee",
    standard        = "OIT Resolution 2003",
    reference       = "17th ICLS Resolution on Informal Employment",
    odd             = "ODD 8.3.1",
    variance        = "Wilson (IC exact)",
    seuil_cv        = 33,
    seuil_n         = 30L,
    fonction_r      = "emploi_informel()",
    gsbpm           = "5.1 - Analyse",
    ins_ready       = TRUE
  ),

  MARIAGE_PRECOCE = list(
    code            = "MARIAGE_PRECOCE",
    nom             = "Taux de mariage precoce",
    domaine         = "Genre et inclusion",
    definition      = "Proportion de femmes/hommes maries ou en union avant 18 ans",
    formule         = "MP = Maries < 18 ans / Total population 20-24 ans",
    numerateur      = "Personnes 20-24 ans mariees avant 18 ans",
    denominateur    = "Total personnes 20-24 ans",
    unite           = "Proportion [0-1]",
    population      = "Femmes 20-24 ans (standard ONU)",
    standard        = "UNICEF / UNFPA",
    reference       = "Ending Child Marriage \u2014 UNICEF 2020",
    odd             = "ODD 5.3.1",
    variance        = "Wilson (IC exact)",
    seuil_cv        = 33,
    seuil_n         = 30L,
    fonction_r      = "mariage_precoce()",
    gsbpm           = "5.1 - Analyse",
    ins_ready       = TRUE
  ),

  SATISFACTION_VIE = list(
    code            = "SATISFACTION_VIE",
    nom             = "Score de satisfaction dans la vie",
    domaine         = "Bien-etre subjectif",
    definition      = "Score moyen de satisfaction sur l'echelle de Cantril (0-10)",
    formule         = "SV = moyenne ponderee des scores individuels [0-10]",
    numerateur      = "Somme des scores ponderes",
    denominateur    = "Somme des poids",
    unite           = "Score [0-10]",
    population      = "Population adulte 15+",
    standard        = "OCDE (2013) How's Life / Gallup World Poll",
    reference       = "OECD Guidelines on Measuring Subjective Well-being",
    odd             = "ODD 3.4 (bien-etre mental)",
    variance        = "Standard / Bootstrap",
    seuil_cv        = 20,
    seuil_n         = 100L,
    fonction_r      = "satisfaction_vie()",
    gsbpm           = "5.1 - Analyse",
    ins_ready       = TRUE
  ),

  PIB_CROISSANCE = list(
    code            = "PIB_CROISSANCE",
    nom             = "Taux de croissance du PIB reel",
    domaine         = "Comptes nationaux",
    definition      = "Variation du PIB en prix constants entre deux periodes",
    formule         = "g = (PIB_t - PIB_(t-1)) / PIB_(t-1) * 100",
    numerateur      = "PIB periode t (prix constants)",
    denominateur    = "PIB periode t-1 (prix constants)",
    unite           = "Pourcentage (%)",
    population      = "Economie nationale",
    standard        = "SCN 2008 (Nations Unies)",
    reference       = "System of National Accounts 2008 \u2014 ONU/FMI/BM/OCDE",
    odd             = "ODD 8.1.1",
    variance        = "Non applicable (agregat macroeconomique)",
    seuil_cv        = NA_real_,
    seuil_n         = NA_integer_,
    fonction_r      = "taux_croissance()",
    gsbpm           = "5.1 - Analyse",
    ins_ready       = TRUE
  ),

  WHIPPLE = list(
    code            = "WHIPPLE",
    nom             = "Indice de Whipple",
    domaine         = "Qualite demographique",
    definition      = "Mesure l'attraction des ages se terminant par 0 ou 5",
    formule         = "W = N(mult.5) / (N_total * prop_attendue) * 100",
    numerateur      = "Effectif aux ages multiples de 5",
    denominateur    = "Effectif attendu si distribution uniforme",
    unite           = "Indice (100 = qualite parfaite)",
    population      = "Population 23-62 ans",
    standard        = "ONU DESA (2002)",
    reference       = "Methods for Estimating Basic Demographic Measures",
    odd             = "Non applicable",
    variance        = "Non applicable",
    seuil_cv        = NA_real_,
    seuil_n         = 50L,
    fonction_r      = "whipple()",
    gsbpm           = "4.3 - Controle qualite",
    ins_ready       = TRUE
  )
)

# =============================================================================
# FONCTION PRINCIPALE
# =============================================================================

#' @title Consulter le catalogue des indicateurs statistiques
#' @description Retourne la fiche methodologique complete d'un indicateur :
#'   definition, formule, standard de reference, ODD, methode de variance,
#'   seuils de qualite et statut INS-ready. Conforme GSBPM 5.2 / UN NQAF.
#'
#' @param code character ou NULL -- Code de l'indicateur. Si NULL, retourne
#'   la liste de tous les indicateurs disponibles.
#'   Codes disponibles : "FGT0", "FGT1", "FGT2", "IPM", "GINI", "STUNTING",
#'   "TAUX_ACTIVITE", "CHOMAGE", "INFORMEL", "MARIAGE_PRECOCE",
#'   "SATISFACTION_VIE", "PIB_CROISSANCE", "WHIPPLE"
#' @param domaine character ou NULL -- Filtrer par domaine.
#'   Ex : "Pauvrete monetaire", "Emploi", "Sante et nutrition".
#'   Defaut : NULL (tous les domaines)
#' @param format character -- Format de sortie : "liste" (objet R complet),
#'   "tableau" (tibble synthetique), "complet" (impression detaillee).
#'   Defaut : "tableau"
#'
#' @return Un tibble, une liste ou un affichage selon le format choisi
#'
#' @examples
#' # Lister tous les indicateurs
#' catalogue_indicateurs()
#'
#' # Fiche methodologique d'un indicateur
#' catalogue_indicateurs("FGT0")
#' catalogue_indicateurs("IPM")
#' catalogue_indicateurs("GINI")
#'
#' # Filtrer par domaine
#' catalogue_indicateurs(domaine = "Emploi")
#'
#' # Format complet avec impression
#' catalogue_indicateurs("FGT0", format = "complet")
#'
#' @export
catalogue_indicateurs <- function(code    = NULL,
                                   domaine = NULL,
                                   format  = c("tableau","liste","complet")) {

  format <- match.arg(format)
  cat_list <- .CATALOGUE_INDICATEURS

  # Filtrer par domaine
  if (!is.null(domaine)) {
    cat_list <- Filter(function(x) {
      grepl(domaine, x$domaine, ignore.case=TRUE)
    }, cat_list)
    if (length(cat_list) == 0) {
      rlang::warn(paste0(
        "Aucun indicateur trouve pour le domaine '", domaine, "'.\n",
        "Domaines disponibles : ",
        paste(unique(sapply(.CATALOGUE_INDICATEURS, `[[`, "domaine")),
              collapse=", ")
      ))
      return(invisible(NULL))
    }
  }

  # Un indicateur specifique
  if (!is.null(code)) {
    code <- toupper(code)
    if (!code %in% names(cat_list)) {
      codes_dispo <- paste(names(.CATALOGUE_INDICATEURS), collapse=", ")
      rlang::abort(paste0(
        "Indicateur '", code, "' introuvable.\n",
        "Codes disponibles : ", codes_dispo
      ))
    }
    ind <- cat_list[[code]]

    if (format == "complet") {
      .afficher_fiche_indicateur(ind)
      return(invisible(ind))
    } else if (format == "liste") {
      return(ind)
    } else {
      return(.indicateur_to_tibble(ind))
    }
  }

  # Tous les indicateurs
  res <- dplyr::bind_rows(lapply(cat_list, .indicateur_to_tibble))

  if (format == "complet") {
    message("=== Catalogue statAfrikR \u2014 ", nrow(res), " indicateurs ===\n")
    for (nm in names(cat_list)) {
      .afficher_fiche_indicateur(cat_list[[nm]], court=TRUE)
    }
    return(invisible(res))
  }

  res
}

#' @keywords internal
.indicateur_to_tibble <- function(ind) {
  tibble::tibble(
    code       = ind$code,
    nom        = ind$nom,
    domaine    = ind$domaine,
    standard   = ind$standard,
    odd        = ind$odd,
    variance   = ind$variance,
    fonction_r = ind$fonction_r,
    gsbpm      = ind$gsbpm,
    ins_ready  = ind$ins_ready
  )
}

#' @keywords internal
.afficher_fiche_indicateur <- function(ind, court=FALSE) {
  message(strrep("-", 55))
  message("  Code       : ", ind$code)
  message("  Nom        : ", ind$nom)
  message("  Domaine    : ", ind$domaine)
  if (!court) {
    message("  Definition : ", ind$definition)
    message("  Formule    : ", ind$formule)
    message("  Population : ", ind$population)
    message("  Unite      : ", ind$unite)
  }
  message("  Standard   : ", ind$standard)
  message("  ODD        : ", ind$odd)
  message("  Variance   : ", ind$variance)
  message("  Fonction R : ", ind$fonction_r)
  message("  GSBPM      : ", ind$gsbpm)
  message("  INS-ready  : ", if (ind$ins_ready) "Oui" else "Non")
  message("")
}
