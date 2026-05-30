#' Pays africains -- fond de carte integre
#' @description Fond de carte des 54 pays africains.
#' @format Objet sf avec colonnes : pays, pays_fr, iso2, iso3,
#'   sous_region, geometry.
#' @source Natural Earth via rnaturalearth -- statAfrikR Foundation
#' @examples
#' afrique <- carte_zones('afrique')
"saf_pays_afrique"

#' Zone CEMAC -- 6 pays membres
#' @description Cameroun, Centrafrique, Congo, Gabon,
#'   Guinee Equatoriale, Tchad.
#' @format Objet sf (sous-ensemble de saf_pays_afrique)
#' @source Natural Earth -- statAfrikR Foundation
#' @examples
#' cemac <- carte_zones('cemac')
"saf_cemac"

#' Zone CEDEAO -- 15 pays membres
#' @description Communaute Economique des Etats de l'Afrique de l'Ouest.
#' @format Objet sf (sous-ensemble de saf_pays_afrique)
#' @source Natural Earth -- statAfrikR Foundation
#' @examples
#' cedeao <- carte_zones('cedeao')
"saf_cedeao"

#' Zone EAC -- Afrique de l'Est
#' @description Communaute d'Afrique de l'Est.
#' @format Objet sf (sous-ensemble de saf_pays_afrique)
#' @source Natural Earth -- statAfrikR Foundation
#' @examples
#' eau <- carte_zones('eau')
"saf_eau"

#' Zone SADC -- Afrique Australe
#' @description Communaute de Developpement de l'Afrique Australe.
#' @format Objet sf (sous-ensemble de saf_pays_afrique)
#' @source Natural Earth -- statAfrikR Foundation
#' @examples
#' sadc <- carte_zones('sadc')
"saf_sadc"

#' Prefectures de la Republique Centrafricaine
#' @description 17 prefectures de la RCA avec codes administratifs.
#' @format Objet sf avec colonnes : pays, iso3, prefecture, code, geometry.
#' @source Natural Earth -- statAfrikR Foundation
#' @examples
#' rca <- carte_zones('rca')
"saf_rca_prefectures"

#' Subdivisions de niveau 1 -- tous les pays africains
#' @description Prefectures, regions et provinces de 43 pays africains
#'   (744 subdivisions + 17 prefectures RCA = 761 total).
#' @format Objet sf avec colonnes : pays, iso3, subdivision,
#'   code_admin, geometry.
#' @source Natural Earth -- statAfrikR Foundation
#' @examples
#' cam <- carte_zones('subdivisions', pays = 'CMR')
"saf_subdivisions_afrique"

#' Departements du Cameroun
#' @description 10 regions du Cameroun.
#' @format Objet sf avec colonnes : departement, code, geometry.
#' @source Natural Earth -- statAfrikR Foundation
#' @examples
#' cam <- carte_zones('subdivisions', pays = 'CMR')
"saf_cameroun_departements"

#' Regions du Senegal
#' @description 14 regions du Senegal.
#' @format Objet sf avec colonnes : region, code, geometry.
#' @source Natural Earth -- statAfrikR Foundation
#' @examples
#' sen <- carte_zones('subdivisions', pays = 'SEN')
"saf_senegal_regions"
