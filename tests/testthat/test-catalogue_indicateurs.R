# Tests catalogue_indicateurs

test_that("catalogue_indicateurs() : retourne tibble", {
  res <- suppressMessages(catalogue_indicateurs())
  expect_s3_class(res, "data.frame")
  expect_gte(nrow(res), 10L)
})

test_that("catalogue_indicateurs() : colonnes attendues", {
  res <- suppressMessages(catalogue_indicateurs())
  expect_true(all(c("code","nom","domaine","standard","odd",
                     "variance","fonction_r","gsbpm","ins_ready") %in% names(res)))
})

test_that("catalogue_indicateurs('FGT0') : retourne tibble 1 ligne", {
  res <- suppressMessages(catalogue_indicateurs("FGT0"))
  expect_equal(nrow(res), 1L)
  expect_equal(res$code, "FGT0")
})

test_that("catalogue_indicateurs('IPM') : format liste", {
  res <- catalogue_indicateurs("IPM", format="liste")
  expect_true(is.list(res))
  expect_equal(res$code, "IPM")
  expect_true("formule" %in% names(res))
})

test_that("catalogue_indicateurs() : code invalide => erreur", {
  expect_error(catalogue_indicateurs("INCONNU"), regexp="introuvable")
})

test_that("catalogue_indicateurs() : filtre domaine Emploi", {
  res <- suppressMessages(catalogue_indicateurs(domaine="Emploi"))
  expect_true(all(grepl("Emploi", res$domaine, ignore.case=TRUE)))
  expect_gte(nrow(res), 2L)
})

test_that("catalogue_indicateurs() : tous INS-ready", {
  res <- suppressMessages(catalogue_indicateurs())
  expect_true(all(res$ins_ready))
})

test_that("catalogue_indicateurs() : ODD present pour indicateurs ODD", {
  res <- suppressMessages(catalogue_indicateurs("FGT0", format="liste"))
  expect_true(grepl("ODD", res$odd))
})
