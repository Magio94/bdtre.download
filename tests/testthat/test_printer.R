

context("A test for the bdtre.download package")

library(testthat)

test_that("Whether printer gives us the same output", {

  set.seed(1)
  Biella_province <- get_municipality_codes("096")
  expect_equal(nrow(Biella_province), 74)

  set.seed(2)
  download_municipality(Biella_province)
  n_rows <- c(selection_path('limi_comuni_piem'))
  expect_equal(length(n_rows), 74)
  unlink("Downloaded", recursive = TRUE)

}

)


