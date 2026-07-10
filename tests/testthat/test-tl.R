test_that("tl() loads globals and all targets", {
  skip_if_not_installed("targets")
  
  # Create a simple targets pipeline in a temp directory
  td <- tempfile()
  dir.create(td)
  
  withr::with_dir(td, {
    # Set up a minimal targets script
    targets::tar_script({
      library(targets)
      
      my_global <- 42
      
      list(
        targets::tar_target(x, 1 + 1),
        targets::tar_target(y, x + 10)
      )
    }, ask = FALSE)
    
    # Run the pipeline
    targets::tar_make(callr_function = NULL)
    
    # Clear the environment
    rm(list = ls(envir = .GlobalEnv), envir = .GlobalEnv)
    
    # Now call tl() which should load everything
    tl()
    
    # Check that targets were loaded
    expect_true(exists("x", envir = .GlobalEnv))
    expect_true(exists("y", envir = .GlobalEnv))
    expect_equal(get("x", envir = .GlobalEnv), 2)
    expect_equal(get("y", envir = .GlobalEnv), 12)
  })
})

test_that("tl() works even with no targets loaded", {
  skip_if_not_installed("targets")
  
  # In an empty environment, tl() should work
  td <- tempfile()
  dir.create(td)
  
  withr::with_dir(td, {
    targets::tar_script({
      library(targets)
      # Empty targets list is not valid, use at least one target
      list(
        targets::tar_target(dummy, 1)
      )
    }, ask = FALSE)
    
    targets::tar_make(callr_function = NULL)
    
    rm(list = ls(envir = .GlobalEnv), envir = .GlobalEnv)
    
    # Should not error even with minimal pipeline
    expect_no_error(tl())
  })
})
