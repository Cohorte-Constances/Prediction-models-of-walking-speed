# REQUIRED INPUTS (must be defined before running this script):
#   - data            : a data.frame containing all variables below
#   - cohort_variables: character vector, names of the "core" cohort variables
#                        (e.g. age, sex, diploma, BMI, height...)
#   - snds_variables  : character vector, names of the claims-data (SNDS)
#                        variables to be recoded (comorbidities, procedures,
#                        drug reimbursements, etc.)
#   - data must contain a column named "center" indicating the recruitment
#     center of each participant (removed before recoding, not used as a
#     predictor in this script)
#   - `sex` must be a numeric variable, 1 corresponding to male and 0 to female.
#
# Required packages: dplyr, caret, Hmisc, ggplot2, reshape2
# =============================================================================

# ADDITIONAL PREDICTORS:
# You can add other variables in the data frame data (thus, you will need to add 
# these variables also in cohort_variables or in snds_variables), but you will 
# need to adapt the formulas of the models, and the functions in the file 
# constructions_m2_g_lasso_functions.R
# =============================================================================
