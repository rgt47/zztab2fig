# Integration Test: Analysis Scripts
# Tests that analysis scripts run without errors and produce expected outputs

library(tinytest)
library(here)

# Database setup script
script_path <- here("analysis", "scripts", "00_database_setup.R")
expect_true(file.exists(script_path))
source(script_path, local = new.env())

# Data validation script
script_path <- here("analysis", "scripts", "02_data_validation.R")
expect_true(file.exists(script_path))
source(script_path, local = new.env())

# Reproducibility check script
script_path <- here("analysis", "scripts", "99_reproducibility_check.R")
expect_true(file.exists(script_path))
source(script_path, local = new.env())

# Analysis outputs
figures_dir <- here("analysis", "figures")
expect_true(dir.exists(figures_dir))

test_plot_path <- file.path(figures_dir, "test_plot.png")
png(test_plot_path, width = 800, height = 600)
plot(1:10, 1:10, main = "Test Plot")
dev.off()
expect_true(file.exists(test_plot_path))
if (file.exists(test_plot_path)) unlink(test_plot_path)

tables_dir <- here("analysis", "tables")
expect_true(dir.exists(tables_dir))
