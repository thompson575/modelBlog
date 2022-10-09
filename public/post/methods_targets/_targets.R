# ----------------------------------------------------------
# 1. load the targets package
library(targets)
library(tarchetypes)

# ----------------------------------------------------------
# 2. source the functions needed for the computations
source("C:/Projects/Sliced/methods/methods_targets/project_functions.R")

# ----------------------------------------------------------
# 3. set project options, including all required packages
tar_option_set(packages = c("tidyverse", "broom") )

# ----------------------------------------------------------
# 4. list the steps in the computation
list(
  # filename: csv file of data
  tar_target(file, "data.csv", format = "file"),
  
  # get_data(): read the csv file
  tar_target(data, get_data(file)),
  
  # fit_model(): fit a model
  tar_target(model, fit_model(data)),
  
  # summarise_model(): examine the model fit
  tar_target(summary, summarise_model(model, data)),
  
  # report: html describing the results
  tar_render(report, "C:/Projects/Sliced/methods/methods_targets/project_report.rmd")
)