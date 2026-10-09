# =============================================================================
# Construction of M3-XGB model (claims data only)
#
# The script construction_xgb_functions.R must have
# been run before this script.
#
# This code supposes that you do not have columns named "diploma", "BMI", nor "height"
# in your dataset 'data'. If not, you will have to remove them before running the code.
# =============================================================================

# --- 1. Model fitting ---------------------------
xgb_selection_m3 <- iterative_variable_selection(data[,-c("center")], "fast_ws")

m3_xgb <- xgb_selection_m3$best_model
col_sel <-  variable.names(m3_xgb)

var_imp_xgb(m3_xgb)

# --- 2. Internal (apparent) performance ---------------------------------------
design_matrix <-  get_design_matrix(data[,c(col_sel, "fast_ws")], "fast_ws")
dtrain <- xgb.DMatrix(data=design_matrix)
predictions_int <- predict(m3_xgb, dtrain)

RMSE(predictions_int, data$fast_ws)
R2(data$fast_ws, predictions_int)

calib_int <- lm(data$fast_ws ~ predictions_int)
summary(calib_int)
