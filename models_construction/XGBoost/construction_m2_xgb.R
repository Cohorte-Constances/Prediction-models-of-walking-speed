# =============================================================================
# Construction of M2-XGB model (core predictors+claims data)
#
# The script construction_xgb_functions.R must have
# been run before this script.
# =============================================================================

# --- 1. Model fitting ---------------------------
xgb_selection_m2 <- iterative_variable_selection(data[,-c("center")], "fast_ws")

m2_xgb <- xgb_selection_m2$best_model
col_sel <-  variable.names(m2_xgb)
# col_sel <- m2_xgb$feature_names # For oldest xgboost versions

var_imp_xgb(m2_xgb)

# --- 2. Internal (apparent) performance ---------------------------------------
design_matrix <-  get_design_matrix(data[,c(col_sel, "fast_ws")], "fast_ws")
dtrain <- xgb.DMatrix(data=design_matrix)
predictions_int <- predict(m2_xgb, dtrain)

RMSE(predictions_int, data$fast_ws)
R2(data$fast_ws, predictions_int)

calib_int <- lm(data$fast_ws ~ predictions_int)
summary(calib_int)
