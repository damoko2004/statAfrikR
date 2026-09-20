# -*- coding: UTF-8 -*-
#' @title statAfrikR — Outils statistiques pour les INS africains
#' @description Boite a outils statistique complete pour les Instituts
#'   Nationaux de Statistique (INS) d'Afrique.
#' @seealso Site web : \url{https://statafrikr.org/}
#'   GitHub : \url{https://github.com/damoko2004/statAfrikR}
#'   Discord : \url{https://discord.com/invite/kcfA27Yz}
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom dplyr across all_of bind_rows case_when distinct filter
#'   group_by left_join mutate n pull right_join select slice_tail
#'   summarise ungroup
#' @importFrom ggplot2 aes element_blank element_line element_rect
#'   element_text geom_col geom_errorbar geom_line geom_point geom_sf
#'   geom_text geom_vline ggplot labs margin scale_color_manual
#'   scale_fill_gradientn scale_fill_manual scale_x_continuous
#'   scale_y_continuous theme theme_minimal theme_void
#' @importFrom rlang abort warn
#' @importFrom stringr str_squish str_to_lower str_to_title str_to_upper
#'   str_replace_all str_pad
#' @importFrom tibble as_tibble tibble add_column
#' @importFrom tidyr pivot_longer
#' @importFrom scales percent
#' @importFrom stats as.formula complete.cases weighted.mean
#' @importFrom utils head
## usethis namespace: end

utils::globalVariables(c(
  ".data", ".row_id",
  "Freq", "proportion", "effectif", "total_groupe",
  "classe_age", "sexe", "valeur_plot",
  ":="
))


# =============================================================================
# NOTE METHODOLOGIQUE — INTERVALLES DE CONFIANCE (IC)
# =============================================================================
#
# statAfrikR utilise deux methodes de calcul des IC selon le contexte :
#
# 1. IC WILSON (methode exacte binomiale)
#    Utilise pour : proportions simples (sante, emploi, genre, bien-etre)
#    Formule : IC = (p + z^2/2n +/- z*sqrt(p(1-p)/n + z^2/4n^2)) / (1 + z^2/n)
#    Quand : echantillon simple ou poids uniformes
#    Avantage : robuste meme pour p proche de 0 ou 1
#    Limite : ne tient pas compte du plan de sondage complexe
#
# 2. IC SURVEY (linearisation de Taylor)
#    Utilise pour : estimations FGT, Gini via creer_design() + survey::svydesign
#    Formule : SE = sqrt(Var_Taylor), IC = estimation +/- z * SE
#    Quand : plan complexe avec strates, grappes, poids differentiels
#    Avantage : tient compte de la structure du plan de sondage (DEFF)
#    Recommande : pour toute publication officielle INS
#
# RECOMMANDATION INS :
#   - Analyses exploratoires et sous-groupes : IC Wilson acceptable
#   - Publications officielles : utiliser creer_design() + survey::svydesign
#     pour obtenir des IC bases sur la variance de Taylor
#   - Toujours indiquer la methode IC dans les notes methodologiques
#
# Reference : Lumley T. (2010). Complex Surveys. Wiley.
#             Cochran W.G. (1977). Sampling Techniques. Wiley.
# =============================================================================

NULL
