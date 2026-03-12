# -*- coding: UTF-8 -*-
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

NULL
