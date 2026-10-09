# =============================================================================
# Iterative XGBoost-based variable selection
#
# Fits an XGBoost model, then repeatedly (a) tunes hyperparameters by
# cross-validation, (b) refits on the full training set, (c) ranks variables
# by importance, and (d) drops the least important ~20% of variables - until
# performance stops improving or no further reduction is possible.
#
# Required packages: xgboost, dplyr
# =============================================================================


# --- 1. Design matrix helper -----------------------------------------------------
# Builds a numeric design matrix (dummy-coded factors, no intercept) for
# xgboost, excluding the target column.

get_design_matrix <- function(df, target) {
  predictors <- df[, setdiff(names(df), target), drop = FALSE]
  design_formula <- ~ . - 1
  X <- model.matrix(design_formula, data = predictors)

  X
}


# --- 2. Hyperparameter tuning by cross-validation ---------------------------------
tune_xgb_model <- function(df, target) {
  X <- get_design_matrix(df, target)
  y <- df[[target]]
  dtrain <- xgb.DMatrix(data = X, label = y)
  
  # Grid for parameter selection by cross-validation. Only max_depth actually
  # varies here (subsample, colsample_bytree, min_child_weight are fixed
  # single values) - widen the grid if you want a broader hyperparameter search.
  param_grid <- expand.grid(
    eta = c(0.01, 0.02, 0.05),
    max_depth = c(3, 5, 7),
    subsample = c(0.5),
    colsample_bytree = c(1),
    min_child_weight = c(5)
  )
  
  best_score <- Inf
  best_params <- NULL
  best_iteration <- NULL
  
  for (i in seq_len(nrow(param_grid))) {
    params <- as.list(param_grid[i, ])
    params$objective <- "reg:squarederror"
    params$eval_metric <- "rmse"
    
    cv <- xgb.cv(
      params = params,
      data = dtrain,
      nrounds = 1000,
      nfold = 5,
      early_stopping_rounds = 20,
      verbose = 0
    )
    
    rmse <- min(cv$evaluation_log$test_rmse_mean)
    if (rmse < best_score) { 
      best_score <- rmse 
      best_params <- params
      best_iteration <- cv$early_stop$best_iteration  
    }
    
    # For xgboost version <= 1.7.5.1:
    # log_cv <- cv$evaluation_log
    # it     <- which.min(log_cv$test_rmse_mean)
    # rmse   <- log_cv$test_rmse_mean[it]
    # 
    # if (rmse < best_score) {
    #   best_score     <- rmse
    #   best_params    <- params
    #   best_iteration <- it
    # }
  }
  
  list(
    best_params = best_params,
    best_iteration = best_iteration,
    best_score = best_score,       # cross-validated RMSE at the best iteration
    features = colnames(X),        # design-matrix column names
    dtrain = dtrain
  )
}


# --- 3. Variable importance ---------------------------------------------------------
# Gain-based feature importance, rescaled to 0-100 relative to the top feature.
var_imp_xgb <- function(model) {
  importance_table <- xgb.importance(feature_names = model$feature_names, model = model)
  var_imp <- importance_table %>%
    dplyr::select(Feature, Gain) %>%
    dplyr::mutate(RelativeImportance = 100 * Gain / max(Gain)) %>%
    dplyr::arrange(desc(RelativeImportance)) %>%
    dplyr::select(Feature, RelativeImportance)
  return(var_imp)
}


# --- 4. Iterative backward elimination ---------------------------------------------
# At each step: tune + refit on the current variable set, check whether
# performance improved, then drop the bottom ~20% of variables by importance
# and repeat.
iterative_variable_selection <- function(df, target, max_steps = 15) {
  
  model_final <- NULL
  dtrain <- NULL
  previous_rmse <- Inf
  df_current <- df
  
  for (step in 1:max_steps) {
    cat("\nEtape", step, "\n")
    
    result <- tune_xgb_model(df_current, target)
    
    model <- xgb.train(
      params = result$best_params,
      data = result$dtrain,
      nrounds = result$best_iteration,
      verbose = 0
    )
    
    # Cross-validated RMSE from the tuning step
    rmse <- round(result$best_score, 1)
    cat("-> RMSE (CV) =", rmse, "with", length(unique(result$features)), "variables\n")
    
    if (rmse > previous_rmse && step > 1) {
      cat("Arrêt : RMSE does not decrease anymore\n")
      break
    }
    
    # This step's model is valid and becomes the current "best" model,
    # regardless of whether it can be reduced any further below - updated
    # here (before the "no further reduction possible" check) so a fitted
    # model is never lost just because its variable set could not be pruned
    # any smaller.
    model_final <- model
    dtrain <- result$dtrain
    previous_rmse <- rmse
    
    importance <- var_imp_xgb(model)
    threshold <- round(0.8 * length(importance$Feature), 0)
    

    selected_features <- importance$Feature[seq_len(threshold)]
    
    cat("-> selected variables :", length(selected_features), "\n")
    
    if (length(selected_features) == 0 ||
        length(selected_features) == length(unique(result$features))) {
      cat("Arrêt : No variable eliminiation\n")
      break
    }
    
    df_current <- df[, c(target, selected_features), drop = FALSE]
  }
  
  return(list(
    best_model = model_final,
    dtrain = dtrain
  ))
}
