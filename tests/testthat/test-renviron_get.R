library(testthat)
library(renviron)

# Test: Successfully retrieving an existing variable
test_that("renviron_get successfully retrieves an existing environment variable", {
  # Setup
  key <- "EXISTING_VAR"
  value <- "example_value"
  env <- list(EXISTING_VAR = value)  # Simulate an environment list with the variable

  # Act
  result <- renviron_get(key, .renviron = env)

  # Assert
  expect_equal(result, value)
})
