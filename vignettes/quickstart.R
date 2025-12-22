## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## ----install------------------------------------------------------------------
# # Install from GitHub
# # devtools::install_github("rgt47/zztab2fig")
# 
# library(zztab2fig)

## ----basic--------------------------------------------------------------------
# t2f(mtcars[1:6, 1:4], filename = "basic_table")

## ----themes-------------------------------------------------------------------
# # NEJM (New England Journal of Medicine)
# t2f(mtcars[1:6, 1:4], theme = "nejm", filename = "nejm_table")
# 
# # APA (American Psychological Association)
# t2f(mtcars[1:6, 1:4], theme = "apa", filename = "apa_table")
# 
# # Nature
# t2f(mtcars[1:6, 1:4], theme = "nature", filename = "nature_table")
# 
# # Minimal (clean, light styling)
# t2f(mtcars[1:6, 1:4], theme = "minimal", filename = "minimal_table")

## ----global-theme-------------------------------------------------------------
# t2f_theme_set("nejm")
# t2f(mtcars[1:6, 1:4])
# t2f(iris[1:6, ])

## ----custom-theme-------------------------------------------------------------
# t2f_list_themes()
# 
# my_theme <- t2f_theme(
#   name = "custom",
#   scolor = "green!8",
#   header_bold = TRUE,
#   font_size = "small",
#   striped = TRUE
# )
# t2f_theme_set(my_theme)

## ----stats-objects------------------------------------------------------------
# # Linear models
# model <- lm(mpg ~ cyl + hp + wt, data = mtcars)
# t2f(model, filename = "regression")
# 
# # GLM with odds ratios
# logit <- glm(am ~ mpg + hp, data = mtcars, family = binomial)
# t2f(logit, exponentiate = TRUE, filename = "logistic")
# 
# # ANOVA tables
# aov_result <- aov(mpg ~ cyl + gear, data = mtcars)
# t2f(aov_result, filename = "anova")
# 
# # Hypothesis tests
# ttest <- t.test(mtcars$mpg, mu = 20)
# t2f(ttest, filename = "ttest")
# 
# # Matrices
# cor_matrix <- cor(mtcars[, 1:4])
# t2f(cor_matrix, filename = "correlation")

## ----regression-comparison----------------------------------------------------
# m1 <- lm(mpg ~ cyl, data = mtcars)
# m2 <- lm(mpg ~ cyl + hp, data = mtcars)
# m3 <- lm(mpg ~ cyl + hp + wt, data = mtcars)
# 
# t2f_regression(
#   Model1 = m1,
#   Model2 = m2,
#   Model3 = m3,
#   stars = TRUE,
#   filename = "model_comparison"
# )

## ----caption-label------------------------------------------------------------
# t2f(mtcars[1:6, 1:4],
#     caption = "Motor Trend Car Road Tests (1974)",
#     label = "tab:mtcars",
#     filename = "captioned_table")

## ----alignment----------------------------------------------------------------
# # Auto-detect (numeric=right, character=left)
# t2f(iris[1:6, ], align = NULL)
# 
# # Explicit alignment
# t2f(mtcars[1:6, 1:4], align = c("l", "r", "r", "r"))
# 
# # Single value for all columns
# t2f(mtcars[1:6, 1:4], align = "c")

## ----longtable----------------------------------------------------------------
# t2f(mtcars,
#     longtable = TRUE,
#     caption = "Complete mtcars Dataset",
#     filename = "long_table")

