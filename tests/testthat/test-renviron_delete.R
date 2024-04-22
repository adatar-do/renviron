library(testthat)
library(renviron)

# Test: Successfully deleting a variable
test_that("renviron_delete successfully removes an environment variable", {
  # Setup
  key <- "TEMP_VAR"
  value <- "temporary_value"
  Sys.setenv(TEMP_VAR = value)  # Manually set an environment variable
  env <- list(TEMP_VAR = value)  # Simulate an environment list with the variable

  # Act
  env <- renviron_delete(key, .renviron = env, in_place = FALSE)

  # Assert
  expect_false(key %in% names(env))  # Should not exist in the list anymore
  expect_false(key %in% Sys.getenv())  # Should not exist in the system environment
})
