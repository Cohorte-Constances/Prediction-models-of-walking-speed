# =============================================================================
# Construction of M3-G-Lasso model
#
# The script construction_m2_m3_g_lasso_functions.R must have
# been run before this script.
#
# Required packages: grpreg, caret 
#
# =============================================================================

cohort_variables <- c("age", "sex")
continuous_vars <- c("fast_ws", "age")

# --- 0. Variable preparation -------------------------------------
# separates claims-data variables into two
# groups depending on how many distinct values they have. Low-cardinality
# variables are recoded as binary indicators; high-cardinality variables
# (counts, costs) are modeled with restricted cubic splines.
snds_variables <- setdiff(names(data),c("age", "sex", "BMI", "diploma", "height", "fast_ws", "center"))

data_factor <- data %>% dplyr::select(-center)
data_factor[, snds_variables] <- lapply(data_factor[, snds_variables], as.factor)

nb_levels <- sapply(data_factor[, snds_variables], function(x) length(levels(x)))

level_threshold <- 30  # threshold on number of levels to decide nested_binary vs spline coding

var_nested_binary <- names(which(nb_levels < level_threshold))
length(var_nested_binary)

var_splines <- names(which(nb_levels >= level_threshold))
length(var_splines)

# --- 1. Build the design matrix and outcome vector via modelisation() --------

# If you have an external validation dataset (named new_data):
res <- modelisation(data, new_data, var_nested_binary, var_splines)
y <- res$y
X_all <- res$X_all
data_scale <- res$database_scale
X_test <- res$X_all_test
new_data_scale <- res$database_test_scale

# If you do NOT have an external validation dataset, use this instead:
# res <- modelisation(data)
# y <- res$y
# X_all <- res$X_all
# data_scale <- res$database_scale

# Group definition for the group LASSO: all spline basis columns generated
# for the same original variable (named "<var>_spline_1", "<var>_spline_2",
# ...) are collapsed into a single group, so the group LASSO includes or
# excludes all basis functions of a given spline together. Every other
# column (nested binary indicators, "_pos" presence flags, sex/age main
# effects and interactions...) keeps its own distinct name and therefore
# forms its own group of size 1, i.e. it is penalized like an ordinary
# (non-grouped) LASSO coefficient.
col_names <- colnames(X_all)
group_labels <- gsub("_spline_[0-9]+", "", col_names)
# levels = unique(group_labels) keeps a deterministic group order (order of
# first appearance) instead of factor()'s default alphabetical order, purely
# for readability when inspecting group_all.
group_all <- as.numeric(factor(group_labels, levels = unique(group_labels)))


# --- 2. Model fitting: cross-validated group LASSO ---------------------------
lambda_grid <- 10^seq(2, -4, length = 100)  # candidate lambda values, from a
# very strong penalty (100) down
# to almost no penalty (1e-4)

m3_g_lasso <- cv.grpreg(
  X_all, y,
  group = group_all,
  seed = 27102001,      # fixed seed -> reproducible cross-validation folds
  penalty = "grLasso",
  lambda = lambda_grid,
  standardize = FALSE   # predictors are already standardized/coded upstream
  # in modelisation(), so grpreg should not re-scale them
)
plot(m3_g_lasso)

best_lambda <- m3_g_lasso$lambda.min

# --- Alternative model-selection strategy (not used here, kept for reference) ---
# The "1 standard-error" rule selects a more parsimonious model than the
# strict CV-minimum, by taking the largest lambda within one SE of the best
# CV error. Uncomment and adapt if you want to use it instead of lambda.min.
# lambda_index <- m3_g_lasso$min
# best_cve <- m3_g_lasso$cve[lambda_index]
# cve_sd <- m3_g_lasso$cvse[lambda_index]
# threshold_1se <- best_cve + cve_sd
# lambda_1se <- m3_g_lasso$lambda[max(which(m3_g_lasso$cve <= threshold_1se))]

# Coefficients at the CV-selected best lambda, and the corresponding list of
# selected (non-zero) variable names.
coef_grlasso <- coef(m3_g_lasso, lambda = best_lambda)
var_select_m3 <- names(coef_grlasso[coef_grlasso != 0])

# Coefficient table sorted by decreasing absolute value, for inspection/reporting.
coef_best_lambda_df_m3 <- data.frame(
  Variable = names(coef_grlasso),
  Coefficient = as.numeric(coef_grlasso)
)
coef_best_lambda_df_m3$Importance <- abs(coef_best_lambda_df_m3$Coefficient)
coef_best_lambda_df_m3 <- coef_best_lambda_df_m3[order(-coef_best_lambda_df_m3$Importance), ]
coef_best_lambda_df_m3

# # Refit a linear regression on the selected variables
# formula0 <- paste0("fast_ws"~, paste(var_select_m3, collapse = "+"))
# refit_m3_g_lasso <- lm(formula0, data_scale)


# --- 3. Internal (apparent) performance ---------------------------------------

predictions_int <- predict(m3_g_lasso, X_all, lambda = best_lambda, type = "response")
# predictions_int <- predict(refit_m3_g_lasso, data_scale)
# Back-transform from the standardized fast_ws scale to the original scale
# (fast_ws was centered/scaled inside modelisation() using data's own mean/sd).
predictions_int <- predictions_int * sd(data$fast_ws) + mean(data$fast_ws)

RMSE(predictions_int, data$fast_ws)
R2(data$fast_ws, predictions_int)

calib_int <- lm(data$fast_ws ~ predictions_int)
summary(calib_int)
