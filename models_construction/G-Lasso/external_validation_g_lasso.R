# =============================================================================
# External validation on an independent dataset (new_data)
#
#
# Evaluates the final, already-fitted `model` (trained on the full `data`) on
# a genuinely external dataset `new_data`. Requires beforehand:
#   - model          : the final fitted model (trained on `data`)
#   - new_data       : raw external validation data.frame (with fast_ws)
#   - new_data_scale : `new_data` transformed with the SAME coding/scaling as
#                       the training data (for M1-G-Lasso)
#   - X_test         : matrix obtained with modelisation() (for M2-G-Lasso)
#   - data           : the original training data.frame (needed below to
#                       back-transform predictions to the original scale)
#
# Required packages: ggplot2, mgcv (used internally by geom_smooth(method="gam")), caret
# =============================================================================


# --- 1. Predictions of the model on new_data -----------------------------------
# predict() returns predictions on the STANDARDIZED fast_ws scale (the scale
# the model was trained on), so they must be back-transformed using the
# TRAINING data's mean/sd. 

# For M1 G-Lasso:
new_data_scale <- new_data
new_data_scale[continuous_vars] <- lapply(continuous_vars, function(v) {
  (new_data[[v]] - means_m1_g_lasso[[v]]) / sds_m1_g_lasso[[v]]
})

predictions_new_data <- predict(m1_g_lasso, new_data_scale) * sd(data$fast_ws) + mean(data$fast_ws)

# For M2 G-Lasso:
predictions_new_data <- predict(m2_g_lasso, X_test, lambda = m2_g_lasso$lambda.min, type = "response") * sd(data$fast_ws) + mean(data$fast_ws)

# For M3 G-Lasso:
predictions_new_data <- predict(m3_g_lasso, X_test, lambda = m3_g_lasso$lambda.min, type = "response") * sd(data$fast_ws) + mean(data$fast_ws)


RMSE(predictions_new_data, new_data$fast_ws)
R2(predictions_new_data, new_data$fast_ws)


axis_range <- range(c(new_data$fast_ws, predictions_new_data), na.rm = TRUE)

ggplot(data.frame(actual = new_data$fast_ws, predicted = predictions_new_data),
       aes(x = predicted, y = actual)) +
  geom_point(alpha = 0.4) +
  geom_smooth(method = "gam", formula = y ~ s(x, bs = "cs"), color = "blue") +
  geom_abline(slope = 1, intercept = 0, color = "red") +
  xlim(axis_range) +
  ylim(axis_range) +
  labs(x = "Predictions (cm/s)", y = "Observed walking speed (cm/s)") +
  theme_minimal()


# --- 2. Calibration --------------------------------------------------------------
# Regresses observed fast_ws on the model's predictions: the intercept
# reflects overall bias ("calibration-in-the-large"), the slope reflects
# whether predictions are too extreme (slope < 1) or too conservative
# (slope > 1) relative to the observed spread.
calibration_new_data <- lm(new_data$fast_ws ~ predictions_new_data)
summary(calibration_new_data)


# --- 3. Recalibration of the intercept only ---------------------------------------
# Refits with the slope fixed at 1 (via offset()), so the estimated
# intercept is exactly the average bias between observed and predicted
# values - the standard "intercept-only" recalibration used to correct a
# systematic offset without touching the relative ranking/spread of predictions.
recalibration_intercept <- lm(new_data$fast_ws ~ offset(predictions_new_data))
summary(recalibration_intercept)

# Recalibrated predictions = original predictions + estimated bias. 
y_recalibration_intercept <- predictions_new_data + coef(recalibration_intercept)[1]

# Sanity check: regressing observed values on the intercept-recalibrated
# predictions should now show a near-zero intercept (the bias has been
# removed). 
summary(lm(new_data$fast_ws ~ y_recalibration_intercept))


# --- 4. Recalibration of the intercept + slope -------------------------------------
# Recalibrated predictions = the fitted values of the full intercept+slope
# calibration model from section 2.
predictions_new_data_recalib <- fitted(calibration_new_data)

# NOTE: this next check is an identity by construction (predictions_new_data_recalib
# IS the set of fitted values of calibration_new_data), so this regression
# will trivially show intercept = 0, slope = 1, and the same R^2 as
# calibration_new_data above - it's a sanity check, not new information.
summary(lm(new_data$fast_ws ~ predictions_new_data_recalib))
