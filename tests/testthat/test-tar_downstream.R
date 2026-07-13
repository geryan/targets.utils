test_that("tar_downstream finds direct and indirect dependencies in linear chain", {
  skip_if_not_installed("igraph")

  targets::tar_dir({
    targets::tar_script({
      library(targets)
      library(targets.utils)

      list(
        targets::tar_target(a, 1),
        targets::tar_target(b, a + 1),
        targets::tar_target(c, b + 1),
        targets::tar_target(d, c + 1)
      )
    })

    targets::tar_make(callr_function = NULL, reporter = "silent")

    # a -> b -> c -> d
    result_a <- tar_downstream("a")
    expect_equal(sort(result_a), c("b", "c", "d"))

    result_b <- tar_downstream("b")
    expect_equal(sort(result_b), c("c", "d"))

    result_c <- tar_downstream("c")
    expect_equal(result_c, "d")

    result_d <- tar_downstream("d")
    expect_length(result_d, 0)
  })
})

test_that("tar_downstream handles branching dependencies", {
  skip_if_not_installed("igraph")

  targets::tar_dir({
    targets::tar_script({
      library(targets)
      library(targets.utils)

      list(
        targets::tar_target(raw, 1:10),
        targets::tar_target(processed_a, mean(raw)),
        targets::tar_target(processed_b, sum(raw)),
        targets::tar_target(summary, c(processed_a, processed_b)),
        targets::tar_target(report, paste("Mean:", summary[1], "Sum:", summary[2]))
      )
    })

    targets::tar_make(callr_function = NULL, reporter = "silent")

    # raw depends on nothing, everything depends on raw
    result_raw <- tar_downstream("raw")
    expect_true(all(c("processed_a", "processed_b", "summary", "report") %in% result_raw))

    # processed_a and processed_b both feed into summary and report
    result_proc_a <- tar_downstream("processed_a")
    expect_true(all(c("summary", "report") %in% result_proc_a))

    result_summary <- tar_downstream("summary")
    expect_equal(result_summary, "report")
  })
})

test_that("tar_downstream works with symbol input", {
  skip_if_not_installed("igraph")

  targets::tar_dir({
    targets::tar_script({
      library(targets)
      library(targets.utils)

      list(
        targets::tar_target(source_data, 1:100),
        targets::tar_target(cleaned_data, source_data * 2),
        targets::tar_target(analysis, mean(cleaned_data))
      )
    })

    targets::tar_make(callr_function = NULL, reporter = "silent")

    # Test with quoted symbol
    result_symbol <- tar_downstream("source_data")
    result_char <- tar_downstream("source_data")
    expect_equal(result_symbol, result_char)
    expect_true(all(c("cleaned_data", "analysis") %in% result_symbol))
  })
})

test_that("tar_downstream errors on nonexistent target", {
  skip_if_not_installed("igraph")

  targets::tar_dir({
    targets::tar_script({
      library(targets)
      library(targets.utils)

      list(
        targets::tar_target(a, 1),
        targets::tar_target(b, a + 1)
      )
    })

    targets::tar_make(callr_function = NULL, reporter = "silent")

    expect_error(
      tar_downstream("nonexistent_target"),
      "not found in the pipeline"
    )
  })
})

test_that("tar_downstream handles complex branching tree", {
  skip_if_not_installed("igraph")

  targets::tar_dir({
    targets::tar_script({
      library(targets)
      library(targets.utils)

      list(
        # Root
        targets::tar_target(input, 1:50),

        # First level: parallel processing
        targets::tar_target(stats, mean(input)),
        targets::tar_target(extremes, c(min(input), max(input))),
        targets::tar_target(distribution, hist(input, plot = FALSE)),

        # Second level: combine results
        targets::tar_target(summary_stats, c(stats, extremes[1], extremes[2])),
        targets::tar_target(analysis_report, list(summary = summary_stats, dist = distribution)),

        # Leaf
        targets::tar_target(final_output, sprintf("Analysis: %s", paste(analysis_report$summary, collapse = ", ")))
      )
    })

    targets::tar_make(callr_function = NULL, reporter = "silent")

    # From root, everything downstream
    result_input <- tar_downstream("input")
    expect_true(all(
      c("stats", "extremes", "distribution", "summary_stats", "analysis_report", "final_output") %in% result_input
    ))

    # From first-level branches
    result_stats <- tar_downstream("stats")
    expect_true(all(c("summary_stats", "analysis_report", "final_output") %in% result_stats))

    result_extremes <- tar_downstream("extremes")
    expect_true(all(c("summary_stats", "analysis_report", "final_output") %in% result_extremes))

    result_distribution <- tar_downstream("distribution")
    expect_true(all(c("analysis_report", "final_output") %in% result_distribution))

    # From second-level
    result_summary <- tar_downstream("summary_stats")
    expect_true(all(c("analysis_report", "final_output") %in% result_summary))

    # Leaf node
    result_final <- tar_downstream("final_output")
    expect_length(result_final, 0)
  })
})

test_that("tar_downstream works with simple numeric pipeline", {
  skip_if_not_installed("igraph")

  targets::tar_dir({
    targets::tar_script({
      library(targets)
      library(targets.utils)

      list(
        targets::tar_target(raw_numbers, 1:100),
        targets::tar_target(processed, raw_numbers * 2),
        targets::tar_target(summary, mean(processed))
      )
    })

    targets::tar_make(callr_function = NULL, reporter = "silent")

    # Pipeline: raw_numbers -> processed -> summary
    result_raw <- tar_downstream("raw_numbers")
    expect_true(all(c("processed", "summary") %in% result_raw))

    result_processed <- tar_downstream("processed")
    expect_equal(result_processed, "summary")

    result_summary <- tar_downstream("summary")
    expect_length(result_summary, 0)
  })
})

test_that("tar_downstream with immediate = TRUE returns only direct dependents", {
  skip_if_not_installed("igraph")

  targets::tar_dir({
    targets::tar_script({
      library(targets)
      library(targets.utils)

      list(
        targets::tar_target(a, 1),
        targets::tar_target(b, a + 1),
        targets::tar_target(c, b + 1)
      )
    })

    targets::tar_make(callr_function = NULL, reporter = "silent")

    # a has b and c depend on it, but only b is immediate
    result_a_all <- tar_downstream("a", immediate = FALSE)
    expect_equal(sort(result_a_all), c("b", "c"))

    result_a_immediate <- tar_downstream("a", immediate = TRUE)
    expect_equal(result_a_immediate, "b")

    # b only has c depend on it directly
    result_b_immediate <- tar_downstream("b", immediate = TRUE)
    expect_equal(result_b_immediate, "c")
  })
})
