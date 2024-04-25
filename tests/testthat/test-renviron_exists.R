library(testthat)
library(renviron)


# Test: Check for variable in a provided list
test_that("Variable correctly identified in provided list", {
  env_list <- list(API_KEY = "12345", SECRET = "s3cr3t")
  expect_true(renviron_exists("API_KEY", .renviron = env_list))
  expect_false(renviron_exists("NON_EXISTENT_KEY", .renviron = env_list))
})

# Test: Verify non-existence handling
test_that("Correctly identifies non-existent variables", {
  expect_false(renviron_exists("I_DO_NOT_EXIST"))
})

# Test: Integration with renviron_load for scopes
test_that("Correctly integrates with renviron_load using scope", {
  # Mocking renviron_load to simulate loading variables
  with_mocked_bindings(
    `renviron_load` = function(scope = c("user", "project"), ...) {
      if ("user" %in% scope) {
        return(list(USER_VAR = "exists"))
      } else {
        return(list(PROJECT_VAR = "exists"))
      }
    },
    {
      expect_true(renviron_exists("USER_VAR", scope = "user"))
      expect_false(renviron_exists("USER_VAR", scope = "project"))
      expect_true(renviron_exists("PROJECT_VAR", scope = "project"))
      expect_false(renviron_exists("PROJECT_VAR", scope = "user"))
    }
  )
})
