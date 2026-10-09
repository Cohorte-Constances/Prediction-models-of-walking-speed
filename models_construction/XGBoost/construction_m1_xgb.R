# =============================================================================
# Construction of M1-XGB model (with only core predictors)
#
# The script construction_xgb_functions.R must have
# been run before this script.
# =============================================================================


# --- 1. Model fitting ---------------------------
cohort_variables <- c("age", "sex", "diploma", "height", "BMI")
xgb_selection_m1 <- iterative_variable_selection(data[,c(cohort_variables, "fast_ws")], "fast_ws") 
m1_xgb <- xgb_selection_m1$best_model
col_sel <- variable.names(m1_xgb)
# col_sel <- m1_xgb$feature_names # For oldest xgboost versions
var_imp_xgb(m1_xgb)

# --- 2. Internal (apparent) performance ---------------------------------------
design_matrix <-  get_design_matrix(data[,c(col_sel, "fast_ws")], "fast_ws")
dtrain <- xgb.DMatrix(data=design_matrix)
predictions_int <- predict(m1_xgb, dtrain)

RMSE(predictions_int, data$fast_ws)
R2(data$fast_ws, predictions_int)

calib_int <- lm(data$fast_ws ~ predictions_int)
summary(calib_int)
