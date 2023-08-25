# --------------------------------------------------
# Pipeline for the crab age project
#
library(makepipe)
library(fs)

# --- folders --------------------------------------
cache   <- "C:/Projects/Kaggle/Playground/crab/data/cache"
rawData <- "C:/Projects/Kaggle/Playground/crab/data/rawData"
code    <- "C:/Projects/Kaggle/Playground/crab/code"
reports <- "C:/Projects/Kaggle/Playground/crab/reports"

# --- Step 1: Read the downloaded data -------------
make_with_source (
  source       = path(code,      "step1_read_data.R"),
  dependencies = c(path(rawData, "train.csv"),
                   path(rawData, "test.csv"),
                   path(rawData, "sample_submission.csv")),
  targets      = c(path(cache,   "train.rds"),
                   path(cache,   "test.rds"),
                   path(cache,   "submission.rds")) )

# --- Step 2: EDA report ---------------------------
make_with_recipe (
  recipe       = rmarkdown::render(path(reports, "Step2_crab_eda.Rmd")),
  dependencies = path(cache, "train.rds"),
  targets      = path(reports, "Step2_crab_eda.html"))
# --- Step 3: clean training data -------------------
make_with_source (
  source       = path(code,  "step3_cleaning.R"),
  dependencies = path(cache, "train.rds"),
  targets      = path(cache, "clean.rds"))
# --- Step 4: EDA of clean data report --------------
make_with_recipe (
  recipe       = rmarkdown::render(path(reports, "Step4_clean_crab_eda.Rmd")),
  dependencies = path(cache, "clean.rds"),
  targets      = path(reports, "Step4_clean_crab_eda.html"))
# --- Step 5: xgboost model -------------------------
make_with_source (
  source       = path(code,  "step5_xgboost.R"),
  dependencies = path(cache, "clean.rds"),
  targets      = c(path(cache, "estimate.rds"),
                   path(cache, "validate.rds"),
                   path(cache, "xgboost.rds")) )
# --- Step 6: mars model ----------------------------
make_with_source (
  source       = path(code,  "step6_mars.R"),
  dependencies = path(cache, "estimate.rds"),
  targets      = path(cache, "mars.rds") )
# --- Step 7: cross-validation ----------------------
make_with_source (
  source       = path(code,  "step7_cross_validation.R"),
  dependencies = path(cache, "clean.rds"),
  targets      = path(cache, "cv_mae.rds") )
# --- Step 8: modelling report ---------------------
make_with_recipe (
  recipe       = rmarkdown::render(path(reports, "Step8_model_performance.Rmd")),
  dependencies = c(path(cache, "estimate.rds"),
                   path(cache, "validate.rds"),
                   path(cache, "xgboost.rds"),
                   path(cache, "mars.rds"),
                   path(cache, "cv_mae.rds")),
  targets      = path(reports, "Step8_model_performance.html"))
# --- Step 9: clean test data ---------------------
make_with_source (
  source       = path(code,  "step9_clean_test_data.R"),
  dependencies = c(path(cache, "train.rds"),
                   path(cache, "test.rds")),
  targets      = path(cache, "clean_test.rds") )
# --- Step 10: submission ------------------------
make_with_source (
  source       = path(code,  "step10_submission.R"),
  dependencies = c(path(cache, "clean.rds"),
                   path(cache, "clean_test.rds")),
  targets      = path(cache, "submission.csv") )

