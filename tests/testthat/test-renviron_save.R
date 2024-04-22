library(testthat)
library(renviron)

# Test: Correct file saving without user confirmation
test_that("renviron_save correctly writes data to file without confirmation", {
  # Setup
  temp_env <- list(TEST_KEY = "test_value")
  temp_file_path <- tempfile()

  # Mock renviron_path to use the tempfile
  with_mocked_bindings(
    `renviron_path` = function(...) return(temp_file_path),
    {
      renviron_save(temp_env, confirm = FALSE)
      saved_content <- readLines(temp_file_path)
      expect_true(length(saved_content) == 1)
      expect_true(saved_content[1] == "TEST_KEY='test_value'")
    }
  )
})
