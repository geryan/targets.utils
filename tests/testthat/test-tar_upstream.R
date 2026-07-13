test_that("tar_upstream finds all upstream dependencies in linear chain", {
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

    # d <- c <- b <- a
    result_d <- tar_upstream("d")
    expect_equal(sort(result_d), c("a", "b", "c"))

    result_c <- tar_upstream("c")
    expect_equal(sort(result_c), c("a", "b"))

    result_b <- tar_upstream("b")
    expect_equal(result_b, "a")

    result_a <- tar_upstream("a")
    expect_length(result_a, 0)
  })
})

test_that("tar_upstream finds upstream dependencies with branching", {
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
        targets::tar_target(report, paste("Summary:", summary[1]))
      )
    })

    targets::tar_make(callr_function = NULL, reporter = "silent")

    # report depends on summary, summary depends on processed_a and processed_b,
    # both depend on raw
    result_report <- tar_upstream("report")
    expect_true(all(c("summary", "processed_a", "processed_b", "raw") %in% result_report))

    result_summary <- tar_upstream("summary")
    expect_true(all(c("processed_a", "processed_b", "raw") %in% result_summary))

    result_proc_a <- tar_upstream("processed_a")
    expect_equal(result_proc_a, "raw")
  })
})

test_that("tar_upstream with immediate = TRUE returns only direct dependencies", {
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

    # c only directly depends on b
    result_c_all <- tar_upstream("c", immediate = FALSE)
    expect_equal(sort(result_c_all), c("a", "b"))

    result_c_immediate <- tar_upstream("c", immediate = TRUE)
    expect_equal(result_c_immediate, "b")

    # b only directly depends on a
    result_b_immediate <- tar_upstream("b", immediate = TRUE)
    expect_equal(result_b_immediate, "a")
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

    # a has b and c depend on it, but b is direct and c is indirect
    result_a_all <- tar_downstream("a", immediate = FALSE)
    expect_equal(sort(result_a_all), c("b", "c"))

    result_a_immediate <- tar_downstream("a", immediate = TRUE)
    expect_equal(result_a_immediate, "b")

    # b only has c depend on it directly
    result_b_immediate <- tar_downstream("b", immediate = TRUE)
    expect_equal(result_b_immediate, "c")
  })
})

test_that("tar_upstream and tar_downstream are inverses", {
  skip_if_not_installed("igraph")

  targets::tar_dir({
    targets::tar_script({
      library(targets)
      library(targets.utils)

      list(
        targets::tar_target(input, 1:50),
        targets::tar_target(processed_a, mean(input)),
        targets::tar_target(processed_b, sum(input)),
        targets::tar_target(combined, c(processed_a, processed_b)),
        targets::tar_target(final, sqrt(combined[1]))
      )
    })

    targets::tar_make(callr_function = NULL, reporter = "silent")

    # For any target, tar_upstream should contain input
    downstream_input <- tar_downstream("input")
    upstream_final <- tar_upstream("final")

    # input is upstream of final
    expect_true("input" %in% upstream_final)
    # final is downstream of input
    expect_true("final" %in% downstream_input)

    # processed_a and processed_b are both upstream of final and downstream of input
    expect_true(all(c("processed_a", "processed_b") %in% upstream_final))
    expect_true(all(c("processed_a", "processed_b") %in% downstream_input))
  })
})

test_that("tar_upstream works with symbol input", {
  skip_if_not_installed("igraph")

  targets::tar_dir({
    targets::tar_script({
      library(targets)
      library(targets.utils)

      list(
        targets::tar_target(source, 1:100),
        targets::tar_target(processed, source * 2),
        targets::tar_target(summary, mean(processed))
      )
    })

    targets::tar_make(callr_function = NULL, reporter = "silent")

    # Test with character
    result_char <- tar_upstream("summary")
    result_char_immediate <- tar_upstream("summary", immediate = TRUE)

    expect_equal(sort(result_char), c("processed", "source"))
    expect_equal(result_char_immediate, "processed")
  })
})

test_that("tar_upstream errors on nonexistent target", {
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
      tar_upstream("nonexistent_target"),
      "not found in the pipeline"
    )
  })
})

test_that("tar_upstream handles complex branching tree", {
  skip_if_not_installed("igraph")

  targets::tar_dir({
    targets::tar_script({
      library(targets)
      library(targets.utils)

      list(
        targets::tar_target(input, 1:50),
        targets::tar_target(stats, mean(input)),
        targets::tar_target(extremes, c(min(input), max(input))),
        targets::tar_target(distribution, hist(input, plot = FALSE)),
        targets::tar_target(summary_stats, c(stats, extremes[1], extremes[2])),
        targets::tar_target(analysis_report, list(summary = summary_stats, dist = distribution)),
        targets::tar_target(final_output, sprintf("Analysis: %s", paste(analysis_report$summary, collapse = ", ")))
      )
    })

    targets::tar_make(callr_function = NULL, reporter = "silent")

    # final_output depends on everything
    result_final <- tar_upstream("final_output")
    expect_true(all(
      c("analysis_report", "summary_stats", "stats", "extremes", "distribution", "input") %in% result_final
    ))

    # Only immediate for final_output
    result_final_immediate <- tar_downstream("analysis_report", immediate = TRUE)
    expect_equal(result_final_immediate, "final_output")

    # summary_stats only directly depends on stats and extremes (immediate)
    result_summary_immediate <- tar_upstream("summary_stats", immediate = TRUE)
    expect_equal(sort(result_summary_immediate), c("extremes", "stats"))
  })
})
