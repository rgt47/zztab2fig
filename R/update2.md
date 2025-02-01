Here's the expanded procedure including Git and GitHub steps:

1. Create New Branch
   ```bash
   git checkout main         # Start from main branch
   git pull origin main     # Get latest changes
   git checkout -b feature-name   # Create & switch to new branch
   ```

2. Edit the R Code
   - Navigate to R/zzdataframe2graphic.R
   - Make your code changes
   - Document new parameters/changes in roxygen comments
   - Save file

3. Update Documentation
   ```r
   # In R:
   devtools::document()   # Updates NAMESPACE and man/ files
   ```

4. Write New Tests
   - Edit tests/testthat/test-zzdataframe2graphic.R
   - Add new test cases:
   ```r
   test_that("new feature works as expected", {
     result <- your_function(test_input)
     expect_equal(result, expected_output)
   })
   ```

5. Run Tests Locally
   ```r
   devtools::test()
   # Fix any failures and add more tests if needed
   ```

6. Update Version & Description
   - Edit DESCRIPTION file
   - Increment version number
   - Update date field
   - Update any dependencies if needed

7. Build and Check Package
   ```r
   devtools::build()
   devtools::check()
   ```

8. Additional Checks
   ```r
   devtools::check_win_devel()
   devtools::check_mac_release()
   rcmdcheck::rcmdcheck(args = c("--as-cran"))
   ```

9. Stage Changes
   ```bash
   git status                  # Review changes
   git add R/zzdataframe2graphic.R
   git add tests/testthat/test-zzdataframe2graphic.R
   git add DESCRIPTION
   git add man/*
   git add NAMESPACE
   ```

10. Commit Changes
    ```bash
    git commit -m "feat: add new feature to zzdataframe2graphic
    
    - Added X functionality
    - Updated documentation
    - Added tests"
    ```

11. Push to GitHub
    ```bash
    git push origin feature-name
    ```

12. Create Pull Request
    - Go to your GitHub repository
    - Click "Pull requests" tab
    - Click "New pull request"
    - Select:
      - base: main
      - compare: feature-name
    - Fill in PR description:
      - What changes were made
      - Why changes were made
      - How to test the changes
      - Any related issues

13. CI/Actions Check
    - Wait for GitHub Actions to complete
    - Review any failures
    - Make necessary fixes:
      ```bash
      git add .
      git commit -m "fix: address CI failures"
      git push origin feature-name
      ```

14. PR Review Process
    - Address any review comments
    - Make requested changes
    - Push additional commits
    - Request re-review if needed

15. Merge PR
    - Once approved and all checks pass
    - Choose merge strategy (usually "Squash and merge")
    - Update PR title if needed
    - Click "Squash and merge"

16. Clean Up
    ```bash
    git checkout main
    git pull origin main
    git branch -d feature-name    # Delete local branch
    ```

17. Create Release (optional)
    - Go to GitHub "Releases"
    - Click "Create new release"
    - Tag version (e.g., v0.2.1)
    - Add release notes
    - Publish release

Would you like me to elaborate on any of these steps or explain the reasoning behind any particular practices?
