test_that("tml() makes and loads a specific target", {
  skip_if_not_installed("targets")
  
  td <- tempfile()
  dir.create(td)
  
  withr::with_dir(td, {
    targets::tar_script({
      library(targets)
      
      list(
        targets::tar_target(data, data.frame(x = 1:10, y = 11:20)),
        targets::tar_target(summary_stats, data.frame(mean_x = mean(data$x)))
      )
    }, ask = FALSE)
    
    # Make the first target manually
    targets::tar_make(data, callr_function = NULL)
    
    # Clear environment
    rm(list = ls(envir = .GlobalEnv), envir = .GlobalEnv)
    
    # Use tml() to make and load summary_stats
    tml(summary_stats)
    
    # Check that summary_stats is loaded in the global environment
    expect_true(exists("summary_stats", envir = .GlobalEnv))
    expect_equal(get("summary_stats", envir = .GlobalEnv)$mean_x, 5.5)
  })
})

test_that("tml() makes target that depends on other targets", {
  skip_if_not_installed("targets")
  
  td <- tempfile()
  dir.create(td)
  
  withr::with_dir(td, {
    targets::tar_script({
      library(targets)
      
      list(
        targets::tar_target(x, 100),
        targets::tar_target(y, x * 2),
        targets::tar_target(z, y + 50)
      )
    }, ask = FALSE)
    
    # Clear environment
    rm(list = ls(envir = .GlobalEnv), envir = .GlobalEnv)
    
    # tml() should handle dependencies and make all upstream targets
    tml(z)
    
    expect_true(exists("z", envir = .GlobalEnv))
    expect_equal(get("z", envir = .GlobalEnv), 250)
  })
})

test_that("tml() errors on non-existent target", {
  skip_if_not_installed("targets")
  
  td <- tempfile()
  dir.create(td)
  
  withr::with_dir(td, {
    targets::tar_script({
      library(targets)
      
      list(
        targets::tar_target(real_target, 42)
      )
    }, ask = FALSE)
    
    # Attempting to tml() a non-existent target should error
    expect_error(tml(nonexistent_target))
  })
})
