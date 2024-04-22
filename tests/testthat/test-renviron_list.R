library(testthat)
library(renviron)

# Test: Correct masking of environment variables
test_that("renviron_list masks all environment variable values", {
  # Setup
  env <- list(API_KEY = "12345", SECRET = "secret_value")
  # Act
  masked_env <- renviron_list(.renviron = env)
  # Assert
  expect_true(all(sapply(masked_env, function(x) x == "*****")),
              info = "All values should be masked as '*****'")
})
