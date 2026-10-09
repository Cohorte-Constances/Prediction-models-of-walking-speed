# =============================================================================
# Construction of M1-G-Lasso model (with only core predictors)
# =============================================================================

# --- 1. Model fitting: cross-validated LASSO ---------------------------
control <- trainControl(method="cv", number=10, summaryFunction = defaultSummary)
tune_grid <- expand.grid(alpha=1, lambda = 10^seq(2, -4, length=100)) # candidate lambda values, from a
# very strong penalty (100) down
# to almost no penalty (1e-4)

# Scaling of the continuous variables
continuous_vars <- c("age", "BMI", "height", "diploma", "fast_ws")

means_m1_g_lasso <- sapply(data[continuous_vars], mean, na.rm = TRUE)
sds_m1_g_lasso   <- sapply(data[continuous_vars], sd, na.rm = TRUE)

data_scale <- data
data_scale[continuous_vars] <- lapply(continuous_vars, function(v) {
  (data[[v]] - means_m1_g_lasso[[v]]) / sds_m1_g_lasso[[v]]
})

# Model training 
m1_g_lasso <- train(
  fast_ws ~ age + BMI + height + diploma + sex + I(age^2) +
    age:BMI + age:height + age:sex + age:diploma +
    sex:BMI + sex:height + sex:diploma,
  data = data_scale,
  method = "glmnet",
  trControl = control,
  tuneGrid = tune_grid,
  metric = "RMSE"
)

# Coefficients at the cross-validated best lambda 
coef_lasso <- coef(m1_g_lasso$finalModel, s = m1_g_lasso$bestTune$lambda)
var_select <- rownames(coef_lasso)[coef_lasso[, 1] != 0]
var_non_select <- rownames(coef_lasso)[coef_lasso[, 1] == 0]

# Coefficient table sorted by absolute magnitude, for inspection/reporting.
coef_best_lambda_df <- as.data.frame(as.matrix(coef_lasso))
coef_best_lambda_df$Importance <- abs(coef_best_lambda_df[[1]])  # 1st column = coefficient at best lambda
coef_best_lambda_df <- coef_best_lambda_df[order(-coef_best_lambda_df$Importance), ]
coef_best_lambda_df

# # Refit an unpenalized OLS model on the variables selected by the LASSO
# 
# # Map the dummy-coded "sexe1" name back to "sexe" so lm() can use the factor
# # directly, and drop the intercept row (assumed to be the first row of
# # coef_lasso, which is the standard glmnet/caret convention).
# formula0 <- paste0("fast_ws ~ ", paste(var_select, collapse = " + "))
# refit_m1_g_lasso <- lm(formula0, data = data_scale)
# summary(refit_m1_g_lasso)




# --- 2. Internal (apparent) performances ---------------------------------------

predictions_int <- predict(m1_g_lasso, data_scale)
# predictions_int <- predict(refit_m1_g_lasso, data_scale)

# Back-transform from the standardized fast_ws scale to the original scale
# (fast_ws was centered/scaled inside modelisation() using data's own mean/sd).
predictions_int <- predictions_int * sd(data$fast_ws) + mean(data$fast_ws)

RMSE(predictions_int, data$fast_ws)
R2(data$fast_ws, predictions_int)

calib_int <- lm(data$fast_ws ~ predictions_int)
summary(calib_int)
