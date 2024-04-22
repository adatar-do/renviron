library(testthat)
library(renviron)

# Test: Successfully adding a new variable
test_that("renviron_add successfully adds a new environment variable", {
  # Prepare
  key <- "NEW_VAR"
  value <- "test_value"
  env <- list()  # Simulate an empty .Renviron environment

  # Act
  env <- renviron_add(key, value, .renviron = env, in_place = FALSE)

  # Assert
  expect_equal(Sys.getenv(key), value)
  expect_equal(env[[key]], value)

  # Clean up
  Sys.unsetenv(key)
})

# Test: Updating an existing variable
test_that("renviron_add updates an existing environment variable", {
  # Prepare
  key <- "EXISTING_VAR"
  original_value <- "original"
  new_value <- "updated"
  Sys.setenv(EXISTING_VAR = original_value)
  env <- list(EXISTING_VAR = original_value)

  # Act
  env <- renviron_add(key, new_value, .renviron = env, in_place = FALSE)

  # Assert
  expect_equal(Sys.getenv(key), new_value)
  expect_equal(env[[key]], new_value)

  # Clean up
  Sys.unsetenv(key)
})


# Test: Handling of non-existent keys in non-saving mode
test_that("renviron_add handles non-existent keys gracefully in non-saving mode", {
  # Prepare
  key <- "NON_EXISTENT_VAR"
  value <- "non_existent"
  env <- list()  # Empty environment

  # Act
  result <- renviron_add(key, value, .renviron = env, in_place = FALSE)

  # Assert
  expect_equal(result[[key]], value)
  expect_false(key %in% names(renviron_load()))  # Confirm not saved

  # Clean up
  Sys.unsetenv(key)
})
