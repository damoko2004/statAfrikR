# =============================================================================
# statAfrikR - Module Dashboard Shiny interactif
# Tableau de bord bien-etre institutionnel pour les INS africains
# Zero code Shiny requis pour l'utilisateur final
# =============================================================================

#' @importFrom stats rbinom rnorm runif
utils::globalVariables(c(
  "input", "output", "session", "reactive", "observe",
  "renderUI", "renderPlot", "renderTable", "renderText",
  "observeEvent", "req", "withProgress"
))

#' @title Lancer le tableau de bord interactif statAfrikR
#' @description Lance une application Shiny pre-configuree presentant
#'   tous les indicateurs de bien-etre calcules depuis les donnees
#'   fournies. Zero code Shiny requis. Fonctionne entierement hors ligne.
#'   Compatible EHCVM, DHS, MICS, EFT.
#'
#' @param donnees data.frame ou NULL -- Donnees menages. Si NULL, utilise
#'   des donnees de demonstration. Defaut : NULL
#' @param var_poids character ou NULL -- Variable de ponderation.
#'   Defaut : NULL
#' @param var_region character ou NULL -- Variable region/prefecture.
#'   Defaut : NULL
#' @param var_milieu character ou NULL -- Variable milieu (urbain/rural).
#'   Defaut : NULL
#' @param var_annee character ou NULL -- Variable annee. Defaut : NULL
#' @param pays character -- Nom du pays pour les titres. Defaut : "Pays"
#' @param titre character ou NULL -- Titre principal du dashboard.
#'   Defaut : "Tableau de bord - NOM_DU_PAYS" (nom du pays en parametre)
#' @param sous_titre character ou NULL -- Sous-titre du dashboard.
#'   Defaut : "Indicateurs de bien-etre - NOM_DU_PAYS - statAfrikR v0.2.0"
#' @param port integer -- Port Shiny. Defaut : 3838L
#' @param lancer logical -- Lancer l'app (TRUE) ou retourner l'objet
#'   shinyApp (FALSE). Defaut : TRUE
#' @param export_html character ou NULL -- Chemin pour exporter un rapport
#'   HTML statique sans lancer Shiny. Defaut : NULL
#'
#' @return Invisible : objet shinyApp si lancer=FALSE, NULL sinon
#'
#' @examples
#' \dontrun{
#'   lancer_dashboard()
#'   lancer_dashboard(
#'     donnees    = mon_enquete,
#'     var_poids  = "poids_sondage",
#'     var_region = "prefecture",
#'     pays       = "Centrafrique"
#'   )
#' }
#'
#' @export
lancer_dashboard <- function(donnees     = NULL,
                              var_poids   = NULL,
                              var_region  = NULL,
                              var_milieu  = NULL,
                              var_annee   = NULL,
                              pays        = "Pays",
                              titre       = NULL,
                              sous_titre  = NULL,
                              port        = 3838L,
                              lancer      = TRUE,
                              export_html = NULL) {

  if (!requireNamespace("shiny", quietly = TRUE)) {
    rlang::abort(paste0(
      "Le package 'shiny' est requis pour lancer_dashboard().\n",
      "Installez-le : install.packages('shiny')"
    ))
  }

  if (is.null(donnees)) {
    donnees    <- .demo_data_dashboard()
    var_poids  <- "poids"
    var_region <- "region"
    var_milieu <- "milieu"
    if (pays == "Pays") pays <- "Centrafrique (demonstration)"
  if (is.null(titre))     titre     <- paste0("Tableau de bord - ", pays)
  if (is.null(sous_titre)) sous_titre <- paste0("Indicateurs de bien-etre - ", pays, " - statAfrikR v0.2.0")
    message("Chargement des donnees de demonstration...")
  }

  if (!is.data.frame(donnees) || nrow(donnees) == 0L) {
    rlang::abort("`donnees` doit etre un data.frame non vide.")
  }

  for (nm in c(var_poids, var_region, var_milieu, var_annee)) {
    if (!is.null(nm) && !nm %in% names(donnees)) {
      rlang::warn(paste0("Variable '", nm, "' introuvable ? ignoree."))
    }
  }

  message("Pre-calcul des indicateurs...")
  indicateurs <- .precalculer_indicateurs(
    donnees    = donnees,
    var_poids  = var_poids,
    var_region = var_region,
    var_milieu = var_milieu,
    pays       = pays
  )
  message("  ", length(indicateurs$.meta$modules), " modules calcules.")

  if (!is.null(export_html)) {
    .exporter_html_dashboard(indicateurs, pays, export_html, titre, sous_titre)
    return(invisible(NULL))
  }

  ui     <- .build_ui(pays, indicateurs, titre, sous_titre)
  server <- .build_server(indicateurs, donnees, var_poids,
                           var_region, var_milieu)
  app    <- shiny::shinyApp(ui = ui, server = server)

  if (lancer) {
    shiny::runApp(app, port = as.integer(port),
                  launch.browser = TRUE, quiet = FALSE)
    return(invisible(NULL))
  }
  invisible(app)
}

# =============================================================================
# DONNEES DE DEMONSTRATION
# =============================================================================

#' @keywords internal
.demo_data_dashboard <- function(n = 2000L, seed = 42L) {
  set.seed(seed)
  regions <- c("Bangui","Ombella-MPoko","Bamingui-Bangoran",
                "Mbomou","Haute-Kotto","Kemo")
  data.frame(
    region        = sample(regions, n, TRUE),
    milieu        = sample(c("urbain","rural"), n, TRUE,
                           prob = c(0.38, 0.62)),
    sexe_cm       = sample(c("H","F"), n, TRUE, prob = c(0.72,0.28)),
    taille_men    = sample(3:9, n, TRUE),
    poids         = runif(n, 800, 3500),
    conso_pc      = pmax(10000, rnorm(n, 165000, 110000)),
    seuil_pauv    = rep(171000, n),
    haz           = rnorm(n, -1.2, 1.3),
    electricite   = rbinom(n, 1, 0.38),
    eau_potable   = rbinom(n, 1, 0.52),
    assainissement = rbinom(n, 1, 0.35),
    combustible   = rbinom(n, 1, 0.58),
    logement      = rbinom(n, 1, 0.42),
    actifs_men    = rbinom(n, 1, 0.28),
    scol_adulte   = rbinom(n, 1, 0.44),
    scol_enfants  = rbinom(n, 1, 0.32),
    mortalite_enf = rbinom(n, 1, 0.12),
    actif         = rbinom(n, 1, 0.65),
    employe       = rbinom(n, 1, 0.55),
    chomeur       = rbinom(n, 1, 0.14),
    informel      = rbinom(n, 1, 0.72),
    stunting      = rbinom(n, 1, 0.41),
    marie_18      = rbinom(n, 1, 0.42),
    satisfaction  = pmin(10, pmax(0, round(rnorm(n, 4.8, 2.2)))),
    bonheur_bin   = rbinom(n, 1, 0.61),
    securise      = rbinom(n, 1, 0.52),
    annee         = sample(2019:2022, n, TRUE),
    stringsAsFactors = FALSE
  )
}

# =============================================================================
# PRE-CALCUL DES INDICATEURS
# =============================================================================

#' @keywords internal
.precalculer_indicateurs <- function(donnees, var_poids, var_region,
                                      var_milieu, pays) {
  ind <- list()
  sous_g <- c(var_region, var_milieu)
  sous_g <- sous_g[!sapply(sous_g, is.null) &
                     sous_g %in% names(donnees)]

  if (any(c("conso_par_tete","conso_pc") %in% names(donnees))) {

    ind$fgt <- tryCatch(suppressMessages(
      calcul_fgt(donnees, var_depense = if("conso_par_tete" %in% names(donnees)) "conso_par_tete" else "conso_pc",
                 seuil_pauvrete = 171000, poids = var_poids,
                 sous_groupes = if (length(sous_g)>0) sous_g else NULL)
    ), error = function(e) NULL)
  }

  vars_ipm_map <- list(
    var_nutrition      = "haz_score",
    var_mortalite_inf  = "mortalite_enf",
    var_annees_scol    = "scol_adulte",
    var_scolarisation  = "scol_enfants",
    var_combustible    = "combustible_sol",
    var_assainissement = "assainissement",
    var_eau            = "eau_potable",
    var_electricite    = "electricite",
    var_logement       = "logement_adeq",
    var_actifs         = "actifs_base"
  )
  vars_dispo <- Filter(function(v) v %in% names(donnees), vars_ipm_map)
  if (length(vars_dispo) >= 3L) {
    args_ipm <- c(list(donnees = donnees), vars_dispo)
    if (!is.null(var_poids)) args_ipm$poids <- var_poids
    ind$ipm <- tryCatch(suppressMessages(do.call(calcul_ipm, args_ipm)),
                         error = function(e) NULL)
  }

  if (any(c("conso_par_tete","conso_pc") %in% names(donnees))) {
    ind$gini <- tryCatch(suppressMessages(
      calcul_gini(donnees, if("conso_par_tete" %in% names(donnees)) "conso_par_tete" else "conso_pc", poids = var_poids,
                   sous_groupes = if (length(sous_g)>0) sous_g else NULL)
    ), error = function(e) NULL)
    ind$quintiles <- tryCatch(suppressMessages(
      part_quintile(donnees, if("conso_par_tete" %in% names(donnees)) "conso_par_tete" else "conso_pc", poids = var_poids)
    ), error = function(e) NULL)
  }

  if ("chomeur" %in% names(donnees)) {
    ind$chomage <- tryCatch(suppressMessages(
      taux_activite(donnees, "chomeur", poids = var_poids,
                    sous_groupes = if (length(sous_g)>0) sous_g else NULL)
    ), error = function(e) NULL)
  }
  if ("emploi_informel" %in% names(donnees)) {
    ind$informel <- tryCatch(suppressMessages(
      emploi_informel(donnees, "emploi_informel", poids = var_poids)
    ), error = function(e) NULL)
  }

  if ("haz_score" %in% names(donnees)) {
    ind$stunting <- tryCatch(suppressMessages(
      retard_croissance(donnees, var_taille_age_z = "haz_score",
                         poids = var_poids)
    ), error = function(e) NULL)
  }

  if ("marie_avant_18" %in% names(donnees)) {
    ind$mariage <- tryCatch(suppressMessages(
      mariage_precoce(donnees, "marie_avant_18", poids = var_poids)
    ), error = function(e) NULL)
  }

  if (any(c("satisfaction_vie","satisfaction") %in% names(donnees))) {
    ind$satisfaction <- tryCatch(suppressMessages(
      satisfaction_vie(donnees, if("satisfaction_vie" %in% names(donnees)) "satisfaction_vie" else "satisfaction", poids = var_poids,
                        sous_groupes = if (length(sous_g)>0) sous_g else NULL)
    ), error = function(e) NULL)
  }
  if ("bonheur_bin" %in% names(donnees)) {
    ind$bonheur <- tryCatch(suppressMessages(
      bonheur_declare(donnees, "bonheur_bin", codes_heureux = c(1L),
                       poids = var_poids)
    ), error = function(e) NULL)
  }

  ind$.meta <- list(
    pays       = pays,
    n_obs      = nrow(donnees),
    var_region = var_region,
    var_milieu = var_milieu,
    modules    = names(ind)[!startsWith(names(ind), ".")]
  )
  ind
}

# =============================================================================
# UI SHINY
# =============================================================================

#' @keywords internal
.kpi_card <- function(label, val, sub, color = "#1B4965") {
  sprintf(
    '<div class="kpi" style="border-color:%s">
      <div class="lbl">%s</div>
      <div class="val" style="color:%s">%s</div>
      <div class="sub">%s</div>
    </div>',
    color, label, color, val, sub
  )
}

#' @keywords internal
.build_ui <- function(pays, indicateurs, titre = NULL, sous_titre = NULL) {
  nav_items <- list(
    list(id="accueil",    icon="Home",    label="Accueil"),
    list(id="pauvrete",   icon="Chart",   label="Pauvrete"),
    list(id="ipm",        icon="Grid",    label="IPM"),
    list(id="inegalites", icon="Trend",   label="Inegalites"),
    list(id="sante",      icon="Health",  label="Sante"),
    list(id="emploi",     icon="Work",    label="Emploi"),
    list(id="genre",      icon="Balance", label="Genre"),
    list(id="pib",        icon="Money",   label="PIB"),
    list(id="bienetre",   icon="Star",    label="Bien-etre")
  )
  nav_html <- paste(sapply(nav_items, function(it) {
    sprintf(
      '<div class="nav-item" id="nav-%s" onclick="showSection(\'%s\')">%s</div>',
      it$id, it$id, it$label
    )
  }), collapse = "\n")

  css <- paste0(
    '<style>',
    '*{box-sizing:border-box;margin:0;padding:0;',
    'font-family:Segoe UI,Arial,sans-serif;}',
    ':root{--navy:#0F2742;--petrol:#1B4965;--gold:#B8872F;',
    '--green:#16A34A;--red:#DC2626;--orange:#EA580C;',
    '--purple:#7C3AED;--teal:#0D9488;--gray:#64748B;}',
    'body{background:#F0F7FA;}',
    '.layout{display:flex;min-height:100vh;}',
    '.sidebar{width:200px;background:var(--navy);color:#fff;',
    'position:fixed;top:0;left:0;height:100vh;overflow-y:auto;z-index:100;}',
    '.brand{padding:16px;border-bottom:1px solid #1E3A5A;}',
    '.brand h2{font-size:17px;font-weight:800;color:#fff;}',
    '.brand p{font-size:10px;color:#8BBBCF;margin-top:2px;}',
    '.nav-item{padding:10px 16px;cursor:pointer;font-size:13px;',
    'color:#A0C4D8;border-left:3px solid transparent;transition:all .15s;}',
    '.nav-item:hover{background:#1E3A5A;color:#fff;}',
    '.nav-item.active{background:#1E3A5A;color:#fff;',
    'border-left-color:var(--gold);}',
    '.main{flex:1;margin-left:200px;display:flex;flex-direction:column;}',
    '.topbar{background:#fff;padding:10px 24px;display:flex;',
    'align-items:center;justify-content:space-between;',
    'border-bottom:1px solid #E2E8F0;',
    'position:sticky;top:0;z-index:90;',
    'box-shadow:0 1px 4px rgba(0,0,0,.06);}',
    '.topbar-title{font-size:15px;font-weight:700;color:var(--navy);}',
    '.content{padding:20px 24px;flex:1;}',
    '.section{display:none;}.section.active{display:block;}',
    '.kpi-grid{display:grid;grid-template-columns:repeat(4,1fr);',
    'gap:14px;margin-bottom:20px;}',
    '.kpi{background:#fff;border-radius:10px;padding:14px;',
    'box-shadow:0 1px 6px rgba(0,0,0,.07);border-top:4px solid;}',
    '.kpi .lbl{font-size:10px;color:var(--gray);font-weight:600;',
    'text-transform:uppercase;letter-spacing:.4px;}',
    '.kpi .val{font-size:24px;font-weight:800;margin:5px 0 2px;}',
    '.kpi .sub{font-size:10px;color:var(--gray);}',
    '</style>'
  )

  modules_list <- paste(indicateurs$.meta$modules, collapse = ", ")

  body_html <- paste0(
    '<div class="layout">',
    '<div class="sidebar">',
    '<div class="brand"><h2>statAfrikR</h2>',
    '<p>v0.2.0 &mdash; ', pays, '</p>',
    '<p style="font-size:9px;margin-top:4px;"><a href="https://statafrikr.org" style="color:#6B9DAF;text-decoration:none;">statafrikr.org</a></p></div>',
    nav_html,
    '</div>',
    '<div class="main">',
    '<div style="background:var(--navy);padding:14px 24px;display:flex;align-items:center;justify-content:space-between;position:sticky;top:0;z-index:95;box-shadow:0 2px 8px rgba(0,0,0,.18);">',
    '<div><div style="font-size:18px;font-weight:800;color:#fff;">', titre, '</div>',
    '<div style="font-size:11px;color:#A0C4D8;font-style:italic;">', sous_titre, '</div></div>',
    '</div>',
    '<div class="topbar" style="position:sticky;top:57px;z-index:90;">',
    '<div class="topbar-title" id="page-title">Accueil</div>',
    '<span style="font-size:11px;color:var(--gray);">',
    indicateurs$.meta$n_obs, ' obs. | ', pays, '</span>',
    '</div>',
    '<div class="content">',
    '<div class="section active" id="sec-accueil">',
    '<div class="kpi-grid">',
    .kpi_card("Observations",
              format(indicateurs$.meta$n_obs, big.mark = " "),
              "Menages analyses", "#1B4965"),
    .kpi_card("Modules actifs",
              length(indicateurs$.meta$modules),
              "Indicateurs calcules", "#16A34A"),
    .kpi_card("Package",
              "statAfrikR",
              "v0.2.0 GPL-3 CRAN", "#B8872F"),
    .kpi_card("Pays", pays, "Rapport interactif", "#0D9488"),
    '</div>',
    '<p style="font-size:12px;color:#64748B;padding:8px 0;">',
    'Modules disponibles : <strong>', modules_list, '</strong></p>',
    '</div>',  # sec-accueil
    '<div class="section" id="sec-pauvrete">',
    paste0(.shiny_section_pauvrete(indicateurs), collapse=''),
    '</div>',
    '<div class="section" id="sec-ipm">',
    paste0(.shiny_section_ipm(indicateurs), collapse=''),
    '</div>',
    '<div class="section" id="sec-inegalites">',
    paste0(.shiny_section_inegalites(indicateurs), collapse=''),
    '</div>',
    '<div class="section" id="sec-sante">',
    paste0(.shiny_section_sante(indicateurs), collapse=''),
    '</div>',
    '<div class="section" id="sec-emploi">',
    paste0(.shiny_section_emploi(indicateurs), collapse=''),
    '</div>',
    '<div class="section" id="sec-genre">',
    paste0(.shiny_section_genre(indicateurs), collapse=''),
    '</div>',
    '<div class="section" id="sec-pib">',
    '<p style="color:#94A3B8;padding:20px;font-size:13px;">',
    'Module PIB : utilisez comparer_pib() et tableau_bord_pib().</p>',
    '</div>',
    '<div class="section" id="sec-bienetre">',
    paste0(.shiny_section_bienetre(indicateurs), collapse=''),
    '</div>',
    '</div>',  # content
    '</div>',  # main
    '</div>',  # layout
    '<script>',
    'const titles={accueil:"Accueil",pauvrete:"Pauvrete (FGT)",',
    'ipm:"IPM Alkire-Foster",inegalites:"Inegalites",',
    'sante:"Sante & Nutrition",emploi:"Emploi",',
    'genre:"Genre & Inclusion",pib:"PIB",bienetre:"Bien-etre subjectif"};',
    'function showSection(id){',
    'document.querySelectorAll(".section").forEach(s=>s.classList.remove("active"));',
    'document.querySelectorAll(".nav-item").forEach(n=>n.classList.remove("active"));',
    'const s=document.getElementById("sec-"+id);',
    'const n=document.getElementById("nav-"+id);',
    'if(s)s.classList.add("active");',
    'if(n)n.classList.add("active");',
    'document.getElementById("page-title").textContent=titles[id]||id;}',
    'document.getElementById("nav-accueil").classList.add("active");',
    '</script>'
  )

  shiny::HTML(paste0('<!DOCTYPE html><html lang="fr"><head>',
                      '<meta charset="UTF-8">',
                      '<meta name="viewport" content="width=device-width">',
                      '<title>statAfrikR &mdash; ', pays, '</title>',
                      css, '</head><body>', body_html,
                      '</body></html>'))
}

# =============================================================================
# SECTIONS HTML
# =============================================================================

#' @keywords internal
.shiny_section_pauvrete <- function(ind) {
  if (is.null(ind$fgt)) return('<p style="color:#94A3B8;font-size:13px;">Donnees FGT non disponibles.</p>')


  fgt <- ind$fgt$national
  paste0(
    '<div class="kpi-grid">',
    .kpi_card("FGT0 - Incidence",
              paste0(round(fgt$fgt0 * 100, 1), "%"),
              "Population sous le seuil national", "#DC2626"),
    .kpi_card("FGT1 - Profondeur",
              paste0(round(fgt$fgt1 * 100, 1), "%"),
              "Intensite moyenne de la pauvrete", "#EA580C"),
    .kpi_card("FGT2 - Severite",
              paste0(round(fgt$fgt2 * 100, 1), "%"),
              "Inegalite parmi les pauvres", "#7C3AED"),
    .kpi_card("N observations",
              format(fgt$n_obs, big.mark = " "),
              "Menages analyses", "#0D9488"),
    '</div>'
  )
}

#' @keywords internal
.shiny_section_ipm <- function(ind) {
  if (is.null(ind$ipm)) return('<p style="color:#94A3B8;font-size:13px;">Donnees IPM non disponibles.</p>')


  ipm <- ind$ipm
  paste0(
    '<div class="kpi-grid">',
    .kpi_card("IPM = H x A", round(ipm$IPM, 4),
              "Indice Alkire-Foster (ODD 1.2.2)", "#1B4965"),
    .kpi_card("H - Incidence",
              paste0(round(ipm$H * 100, 1), "%"),
              "Menages multidim. pauvres", "#DC2626"),
    .kpi_card("A - Intensite",
              paste0(round(ipm$A * 100, 1), "%"),
              "Privations moyennes des pauvres", "#EA580C"),
    .kpi_card("Indicateurs",
              length(ipm$vars_actives),
              paste0("Seuil k = ", round(ipm$seuil_k * 100, 0), "%"),
              "#16A34A"),
    '</div>'
  )
}

#' @keywords internal
.shiny_section_inegalites <- function(ind) {
  if (is.null(ind$gini)) return('<p style="color:#94A3B8;font-size:13px;">Donnees inegalites non disponibles.</p>')


  g <- ind$gini
  paste0(
    '<div class="kpi-grid">',
    .kpi_card("Coefficient de Gini", g$gini, g$interpretation, "#B8872F"),
    .kpi_card("N obs",
              format(g$n_obs, big.mark = " "),
              "Observations valides", "#1B4965"),
    '</div>'
  )
}

#' @keywords internal
.shiny_section_sante <- function(ind) {
  if (is.null(ind$stunting)) return('<p style="color:#94A3B8;font-size:13px;">Donnees sante non disponibles.</p>')


  s <- ind$stunting
  paste0(
    '<div class="kpi-grid">',
    .kpi_card("Stunting (HAZ < -2)",
              paste0(s$taux_pct, "%"),
              paste0(s$categorie, " | ODD 2.2.1"), "#DC2626"),
    .kpi_card("IC 95%",
              paste0("[", s$ic_bas, "% ; ", s$ic_haut, "%]"),
              "Intervalle de confiance Wilson", "#64748B"),
    .kpi_card("N observations",
              format(s$n_obs, big.mark = " "),
              "Enfants analyses", "#0D9488"),
    '</div>'
  )
}

#' @keywords internal
.shiny_section_emploi <- function(ind) {
  cards <- character(0)
  if (!is.null(ind$chomage)) {
    cards <- c(cards, .kpi_card(
      "Taux d'activite",
      paste0(ind$chomage$taux_pct, "%"),
      "Population active BIT", "#1B4965"))
  }
  if (!is.null(ind$informel)) {
    cards <- c(cards, .kpi_card(
      "Emploi informel",
      paste0(ind$informel$taux_pct, "%"),
      "OIT 2013", "#EA580C"))
  }
  if (length(cards) == 0) return('<p style="color:#94A3B8;font-size:13px;">Donnees emploi non disponibles.</p>')


  paste0('<div class="kpi-grid">', paste(cards, collapse = ""), '</div>')
}

#' @keywords internal
.shiny_section_genre <- function(ind) {
  if (is.null(ind$mariage)) return('<p style="color:#94A3B8;font-size:13px;">Donnees genre non disponibles.</p>')


  m <- ind$mariage
  paste0(
    '<div class="kpi-grid">',
    .kpi_card("Mariage precoce",
              paste0(m$taux_pct, "%"),
              "Avant 18 ans | ODD 5.3.1", "#DC2626"),
    .kpi_card("IC 95%",
              paste0("[", m$ic_bas, "% ; ", m$ic_haut, "%]"),
              "Intervalle de confiance", "#64748B"),
    '</div>'
  )
}

#' @keywords internal
.shiny_section_bienetre <- function(ind) {
  cards <- character(0)
  if (!is.null(ind$satisfaction)) {
    cards <- c(cards, .kpi_card(
      "Satisfaction de vie",
      paste0(round(ind$satisfaction$score_moy, 2), "/10"),
      "Echelle Cantril | OCDE", "#B8872F"))
  }
  if (!is.null(ind$bonheur)) {
    cards <- c(cards, .kpi_card(
      "Bonheur declare",
      paste0(ind$bonheur$taux_pct, "%"),
      "Tres heureux ou heureux", "#16A34A"))
  }
  if (length(cards) == 0) return('<p style="color:#94A3B8;font-size:13px;">Donnees bien-etre non disponibles.</p>')


  paste0('<div class="kpi-grid">', paste(cards, collapse = ""), '</div>')
}

# =============================================================================
# SERVER ET EXPORT
# =============================================================================

#' @keywords internal
.build_server <- function(indicateurs, donnees, var_poids,
                           var_region, var_milieu) {
  function(input, output, session) { invisible(NULL) }
}

#' @keywords internal
.exporter_html_dashboard <- function(indicateurs, pays, chemin, titre = NULL, sous_titre = NULL) {
  ui_html <- .build_ui(pays, indicateurs, titre, sous_titre)
  writeLines(as.character(ui_html), chemin)
  message("Dashboard exporte : ", chemin)
  invisible(chemin)
}

# =============================================================================
# EXPORT CODE SOURCE DU DASHBOARD
# =============================================================================

#' @title Exporter le code source complet du dashboard
#' @description Genere un fichier R autonome et entierement commente que
#'   l'agent INS peut ouvrir, modifier et relancer librement. Contient
#'   l'integralite du code du dashboard avec des sections clairement
#'   identifiees pour la personnalisation : titres, couleurs, indicateurs,
#'   filtres, sections.
#'
#' @param chemin character -- Chemin du fichier R a generer.
#'   Defaut : "dashboard_statAfrikR.R"
#' @param pays character -- Nom du pays pre-rempli. Defaut : "Pays"
#' @param titre character ou NULL -- Titre pre-rempli. Defaut : NULL
#' @param sous_titre character ou NULL -- Sous-titre pre-rempli.
#'   Defaut : NULL
#' @param var_poids character ou NULL -- Variable poids pre-remplie.
#'   Defaut : NULL
#' @param var_region character ou NULL -- Variable region pre-remplie.
#'   Defaut : NULL
#' @param var_milieu character ou NULL -- Variable milieu pre-remplie.
#'   Defaut : NULL
#'
#' @return Invisible : chemin du fichier genere
#'
#' @examples
#' \dontrun{
#'   # Generer le code source personnalisable
#'   exporter_code_dashboard(
#'     chemin     = "mon_dashboard_rca.R",
#'     pays       = "Republique Centrafricaine",
#'     titre      = "Tableau de bord - Enquete EHCVM 2022",
#'     sous_titre = "Indicateurs bien-etre - INS RCA",
#'     var_poids  = "poids_sondage",
#'     var_region = "prefecture",
#'     var_milieu = "milieu"
#'   )
#'   # Ouvrir le fichier genere dans RStudio
#'   file.edit("mon_dashboard_rca.R")
#' }
#'
#' @export
exporter_code_dashboard <- function(chemin      = "dashboard_statAfrikR.R",
                                     pays        = "Pays",
                                     titre       = NULL,
                                     sous_titre  = NULL,
                                     var_poids   = NULL,
                                     var_region  = NULL,
                                     var_milieu  = NULL) {

  if (is.null(titre))     titre     <- paste0("Tableau de bord - ", pays)
  if (is.null(sous_titre)) sous_titre <- paste0(
    "Indicateurs de bien-etre - ", pays, " - statAfrikR v0.2.0")
  if (is.null(var_poids))  var_poids  <- "poids_sondage"
  if (is.null(var_region)) var_region <- "region"
  if (is.null(var_milieu)) var_milieu <- "milieu"

  code <- paste0(
'# =============================================================================
# DASHBOARD statAfrikR - ', pays, '
# Genere automatiquement par statAfrikR::exporter_code_dashboard()
# Vous pouvez modifier ce fichier librement et le relancer.
# =============================================================================

library(statAfrikR)

# =============================================================================
# SECTION 1 - VOS DONNEES
# Remplacez cette ligne par le chargement de vos propres donnees
# Exemples :
#   donnees <- read.csv("enquete_menages.csv")
#   donnees <- haven::read_dta("ehcvm_2022.dta")
#   donnees <- readRDS("donnees_enquete.rds")
# =============================================================================

donnees <- NULL  # <- Remplacez par vos donnees

# =============================================================================
# SECTION 2 - PARAMETRES DU DASHBOARD
# Modifiez ces parametres selon votre enquete
# =============================================================================

PAYS        <- "', pays, '"
TITRE       <- "', titre, '"
SOUS_TITRE  <- "', sous_titre, '"

# Variables de votre jeu de donnees
VAR_POIDS   <- "', var_poids, '"   # Variable poids de sondage
VAR_REGION  <- "', var_region, '"  # Variable region / prefecture
VAR_MILIEU  <- "', var_milieu, '"  # Variable milieu (urbain/rural)
VAR_ANNEE   <- NULL                # Variable annee (si panel, sinon NULL)
PORT        <- 3838L               # Port Shiny (modifiable si conflit)

# =============================================================================
# SECTION 3 - LANCER LE DASHBOARD
# Executez cette section pour ouvrir le dashboard dans votre navigateur
# =============================================================================

lancer_dashboard(
  donnees    = donnees,
  var_poids  = VAR_POIDS,
  var_region = VAR_REGION,
  var_milieu = VAR_MILIEU,
  var_annee  = VAR_ANNEE,
  pays       = PAYS,
  titre      = TITRE,
  sous_titre = SOUS_TITRE,
  port       = PORT,
  lancer     = TRUE
)

# =============================================================================
# SECTION 4 - EXPORT HTML STATIQUE (sans Shiny)
# Pour partager le dashboard sans que le destinataire ait R installe
# =============================================================================

# lancer_dashboard(
#   donnees     = donnees,
#   var_poids   = VAR_POIDS,
#   var_region  = VAR_REGION,
#   var_milieu  = VAR_MILIEU,
#   pays        = PAYS,
#   titre       = TITRE,
#   sous_titre  = SOUS_TITRE,
#   export_html = paste0("dashboard_", PAYS, "_2024.html")
# )

# =============================================================================
# SECTION 5 - INDICATEURS INDIVIDUELS
# Vous pouvez aussi calculer et afficher les indicateurs un par un
# =============================================================================

# --- Pauvrete FGT ---
# res_fgt <- calcul_fgt(donnees,
#   var_depense    = "consommation_pc",
#   seuil_pauvrete = 171000,
#   poids          = VAR_POIDS,
#   sous_groupes   = c(VAR_REGION, VAR_MILIEU)
# )
# print(res_fgt)
# graphique_fgt(res_fgt)

# --- IPM Alkire-Foster ---
# res_ipm <- calcul_ipm(donnees,
#   var_nutrition      = "malnutrition",
#   var_mortalite_inf  = "mortalite_enf",
#   var_annees_scol    = "scol_adulte",
#   var_scolarisation  = "scol_enfants",
#   var_electricite    = "electricite",
#   var_eau            = "eau_potable",
#   var_assainissement = "assainissement",
#   var_combustible    = "combustible_sol",
#   var_logement       = "logement_adeq",
#   var_actifs         = "actifs_menage",
#   poids              = VAR_POIDS
# )
# print(res_ipm)
# graphique_ipm(res_ipm)
# tableau_ipm(res_ipm, pays = PAYS, annee = 2024L)

# --- Inegalites ---
      calcul_gini(donnees, if("conso_par_tete" %in% names(donnees)) "conso_par_tete" else "conso_pc", poids = var_poids,
# courbe_lorenz(donnees, "consommation_pc", poids = VAR_POIDS)

# --- Sante & Nutrition ---
# res_stunting <- retard_croissance(donnees,
#   var_taille_age_z = "haz_score", poids = VAR_POIDS)
# res_vaccin <- vaccination(donnees,
#   vars_vaccins = c(DTC3 = "dtc3", Rougeole = "rougeole"),
#   poids = VAR_POIDS)

# --- Emploi ---
# res_activite <- taux_activite(donnees, "actif", poids = VAR_POIDS)
# res_informel <- emploi_informel(donnees, "emploi_informel",
#   poids = VAR_POIDS)

# --- Genre ---
# res_mariage <- mariage_precoce(donnees, "marie_avant_18",
#   poids = VAR_POIDS)
# res_isp <- parite_education(donnees, "scolarise", "sexe",
#   poids = VAR_POIDS)

# --- Bien-etre subjectif ---
      satisfaction_vie(donnees, if("satisfaction_vie" %in% names(donnees)) "satisfaction_vie" else "satisfaction", poids = var_poids,
#   poids = VAR_POIDS)

# =============================================================================
# SECTION 6 - CARTOGRAPHIE
# Produire des cartes des indicateurs par region
# =============================================================================

# carte_pauvrete(donnees,
#   var_depense    = "consommation_pc",
#   seuil_pauvrete = 171000,
#   var_region     = VAR_REGION,
#   poids          = VAR_POIDS,
#   pays           = PAYS
# )

# =============================================================================
# SECTION 7 - RAPPORTS AUTOMATIQUES
# Generer des rapports Word ou HTML
# =============================================================================

# generer_rapport_enquete(
#   donnees  = donnees,
#   poids    = VAR_POIDS,
#   region   = VAR_REGION,
#   pays     = PAYS,
#   annee    = 2024L,
#   format   = "word",   # "html", "pdf", "word"
#   chemin   = paste0("rapport_", PAYS, "_2024.docx")
# )

# =============================================================================
# FIN DU FICHIER
# Documentation complete : https://statafrikr.org/
# Support : diamoko@gmail.com | Discord : discord.gg/kcfA27Yz
# =============================================================================
')

  writeLines(code, chemin)
  message("Code dashboard exporte : ", chemin)
  message("Ouvrez ce fichier dans RStudio et modifiez la SECTION 1 et 2.")
  invisible(chemin)
}
