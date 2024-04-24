library(testthat)
library(renviron)

# Test: Successfully unsetting all environment variables
test_that("renviron_unset_all unsets all variables correctly", {
  # Create a temporary .Renviron file
  path <- tempfile()
  writeLines(c("API_KEY='12345'", "SECRET_KEY='67890'"), path)

  # Mock renviron_path to return our temporary file path and use our test .Renviron file
  assignInNamespace("renviron_path", function(scope = c("project", "user"), .file = ".Renviron", verbosity = 1) {
    return(path)
  }, ns = "renviron")

  # Load and then unset variables
  renviron_load() # Loads variables into environment
  renviron_unset_all() # Should unset the loaded variables

  # Check that the environment variables are unset
  expect_equal(Sys.getenv("API_KEY"), "")
  expect_equal(Sys.getenv("SECRET_KEY"), "")

  # Clean up
  file.remove(path) # Optional: Clean up the temporary file
})
