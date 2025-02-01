I'll provide a detailed step-by-step procedure for updating your R package:

1. Edit the R Code
   - Navigate to R/zzdataframe2graphic.R in your package directory
   - Make your code changes
   - Document any new parameters or changes in the roxygen comments above the function
   - Save the file

2. Update Documentation
   - Run `devtools::document()` in R to update documentation
   - This will update the NAMESPACE and man/ files based on your roxygen comments

3. Write New Tests
   - Navigate to tests/testthat/
   - Open or create test file (likely test-zzdataframe2graphic.R)
   - Add new test cases for your feature using testthat syntax:
   ```r
   test_that("new feature works as expected", {
     # Test setup
     result <- your_function(test_input)
     expect_equal(result, expected_output)
     # Add more expectations as needed
   })
   ```

4. Run Tests Locally
   - Run `devtools::test()` to execute all tests
   - Fix any test failures
   - Add more test cases if needed

5. Update Version Number
   - Open DESCRIPTION file
   - Increment version number (follow semantic versioning)
   - Update date field

6. Build and Check Package
   ```r
   # In R:
   devtools::build()         # Creates package tarball
   devtools::check()         # Comprehensive package check
   ```

7. Address Any Warnings/Notes
   - Fix any issues reported by R CMD check
   - Common issues include:
     - Missing documentation
     - Undocumented function parameters
     - Code style issues
     - Missing dependencies in DESCRIPTION

8. Run Additional Checks
   ```r
   devtools::check_win_devel()    # Check on Windows
   devtools::check_mac_release()   # Check on Mac
   rcmdcheck::rcmdcheck(args = c("--as-cran"))  # More stringent CRAN checks
   ```

9. Final Test
   - Install package from source and test new feature:
   ```r
   devtools::install()
   library(zzdataframe2graphic)
   # Test new functionality
   ```

10. Version Control
    - Stage changes:
    ```bash
    git add R/zzdataframe2graphic.R
    git add tests/testthat/test-zzdataframe2graphic.R
    git add DESCRIPTION
    git add man/*
    ```
    - Commit changes with descriptive message
    - Push to repository

Would you like me to elaborate on any of these steps?
