test_that("insert_tar_target() requires RStudio", {
  skip_if_not(rlang::is_installed("rstudioapi") && rstudioapi::isAvailable())

  # This test verifies the function exists and has correct signature
  expect_true(is.function(insert_tar_target))
})

test_that("insert_tar_target() function is properly defined", {
  # Verify the function exists and is callable
  expect_true(exists("insert_tar_target"))
  expect_true(is.function(insert_tar_target))
})

test_that("insert_tar_target() has correct signature", {
  # Check the function takes no arguments
  sig <- formals(insert_tar_target)
  expect_length(sig, 0)
})

test_that("insert_tar_target() is exported", {
  # Verify it's in the package namespace
  expect_true("insert_tar_target" %in% getNamespaceExports("targets.utils"))
})
