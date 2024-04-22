# tests/testthat/test-renviron_load.R

library(testthat)
library(renviron)

# Test: Successfully loading environment variables
test_that("renviron_load loads all variables correctly", {
  # Create a temporary .Renviron file
  path <- tempfile()
  writeLines(c("API_KEY='12345'", "SECRET_KEY='67890'"), path)

  # Mock renviron_path to return our temporary file path
  mock_renviron_path <- function(scope = c("project", "user"), .file = ".Renviron") {
    return(path)
  }
  assignInNamespace("renviron_path", mock_renviron_path, ns = "renviron")

  # Load variables
  result <- renviron_load()

  # Check that the environment variables are set correctly
  expect_equal(Sys.getenv("API_KEY"), "12345")
  expect_equal(Sys.getenv("SECRET_KEY"), "67890")

  # Clean up
  Sys.unsetenv("API_KEY")
  Sys.unsetenv("SECRET_KEY")
})

# Test: Handling of non-existent .Renviron file
test_that("renviron_load returns NULL for non-existent files", {
  # Mock renviron_path to return non-existent path
  mock_renviron_path <- function(scope = c("project", "user"), .file = ".Renviron") {
    return("/non/existent/path")
  }
  assignInNamespace("renviron_path", mock_renviron_path, ns = "renviron")

  # Attempt to load variables
  result <- renviron_load()

  # Check that the result is NULL
  expect_type(result, "NULL")
})

# Test: Filtering variables with .vars parameter
test_that("renviron_load correctly filters with .vars parameter", {
  # Create a temporary .Renviron file
  path <- tempfile()
  writeLines(c("API_KEY='12345'", "SECRET_KEY='67890'", "UNUSED_VAR='none'"), path)

  # Mock renviron_path to use our temporary file
  assignInNamespace("renviron_path", function(...) return(path), ns = "renviron")

  # Load only specified variables
  result <- renviron_load(.vars = c("API_KEY", "SECRET_KEY"))

  # Check that only specified variables are loaded
  expect_equal(length(result), 2)
  expect_true("API_KEY" %in% names(result))
  expect_true("SECRET_KEY" %in% names(result))
  expect_false("UNUSED_VAR" %in% names(result))

  # Clean up
  Sys.unsetenv("API_KEY")
  Sys.unsetenv("SECRET_KEY")
  Sys.unsetenv("UNUSED_VAR")
})
