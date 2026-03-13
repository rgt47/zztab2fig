# Integration Test: Data Pipeline
# Tests the complete data processing pipeline from raw data to analysis

library(tinytest)
library(here)

if (!requireNamespace("palmerpenguins", quietly = TRUE)) {
  exit_file("palmerpenguins not installed")
}

library(palmerpenguins)

# Data pipeline runs successfully
data(penguins, package = "palmerpenguins")

expect_true(nrow(penguins) > 0)
expect_true(ncol(penguins) >= 7)
expect_true("bill_length_mm" %in% names(penguins))
expect_true("body_mass_g" %in% names(penguins))

clean_penguins <- penguins[complete.cases(penguins), ]
expect_true(nrow(clean_penguins) > 0)
expect_true(nrow(clean_penguins) <= nrow(penguins))

model <- lm(
  body_mass_g ~ bill_length_mm + species, data = clean_penguins
)
expect_inherits(model, "lm")
expect_true(length(coef(model)) >= 2)
expect_true(summary(model)$r.squared > 0)

# Data validation
expected_species <- c("Adelie", "Chinstrap", "Gentoo")
actual_species <- unique(penguins$species)
expect_true(all(actual_species %in% expected_species))

clean_penguins <- penguins[!is.na(penguins$bill_length_mm), ]
expect_true(all(clean_penguins$bill_length_mm > 0))
expect_true(all(clean_penguins$bill_length_mm < 100))

clean_mass <- penguins[!is.na(penguins$body_mass_g), ]
expect_true(all(clean_mass$body_mass_g > 0))
expect_true(all(clean_mass$body_mass_g < 10000))
