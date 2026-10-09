# =============================================================================
# Internal-external validation of G-Lasso models
#
# For each recruitment center in turn, the model is refit on all OTHER
# centers and evaluated on the left-out center (internal-external / "leave-
# one-cluster-out" cross-validation). Performance metrics on the left-out
# center are bootstrapped (b = 1..n_boot resamples of that center) to obtain
# a standard error per center, which is then used to pool the per-center
# estimates via a random-effects meta-analysis.
#
# Requires beforehand: `data` (raw data) and `data_scale` (row-aligned with 
# `data`), both already loaded, plus a factor column `data$center`.
#
# Required packages: caret (train(), RMSE(), R2()), metafor (rma(), forest())
# =============================================================================


n_boot <- 500

control <- trainControl(
  method = "cv", number = 5,
  summaryFunction = defaultSummary,
  savePredictions = TRUE,
  returnResamp = "all"
)

# Number of centers to loop over
n_center <- nlevels(data$center)

rmse_vals <- vector("list", n_center)
r2_vals <- vector("list", n_center)
calib_slope_vals <- vector("list", n_center)
calib_inter_vals <- vector("list", n_center)

results_performance_boot <- list(
  center_test = rep("", n_center),
  nb_ind = rep(0, n_center),
  rmse = rep(0, n_center),
  se_rmse = rep(0, n_center),
  r2 = rep(0, n_center),
  se_r2 = rep(0, n_center),
  calib_slope = rep(0, n_center),
  se_calib_slope = rep(0, n_center),
  calib_inter = rep(0, n_center),
  se_calib_inter = rep(0, n_center)
)


# --- 1. Loop over the n_center centers ----------------------------------------
for (i in 1:n_center) {
  cat("\n----- center", i, "/", n_center, ":", levels(data$center)[i], "-----\n")
  
  # Hold one center out as the test set; train on all remaining centers.
  centers_train <- data[-which(data$center == levels(data$center)[i]), ]
  centers_train_scale <- data_scale[-which(data$center == levels(data$center)[i]), ]
  center_test_scale <- data_scale[which(data$center == levels(data$center)[i]), ]
  
  # For M2/M3-G-Lasso:
    # For M2-G-Lasso:
      cohort_variables <- c("age", "sex", "diploma", "height", "BMI")
      continuous_vars <- c("fast_ws", "age", "diploma", "height", "BMI")
    # For M3-G-Lasso:
      # cohort_variables <- c("age", "sex")
      # continuous_vars <- c("fast_ws", "age")
  
    centers_train_factor <- centers_train
    centers_train_factor[,snds_variables] <- lapply(centers_train_factor[,snds_variables], function(x) as.factor(x))
  
    nb_levels <- sapply(centers_train_factor[,snds_variables], function(x) length(levels(x)))
    seuil <- 30
    var_nested_binary <- names(which(nb_levels < seuil))
    var_splines <- names(which(nb_levels >=seuil))
  
    res <- modelisation(data[which(data$center != levels(data$center)[i]),], data[which(data$center == levels(data$center)[i]),],
                        var_nested_binary, var_splines)
  
    X_all <- res$X_all
    y <- res$y
    X_test <- res$X_all_test

    col_all_int <- colnames(X_all)
    group_labels_all_int <- gsub("_spline_[0-9]+", "", col_all_int)
    group_all_int <- as.numeric(factor(group_labels_all_int))
  
  # Train the model of your choice here, using the EXACT SAME formula as your
  # global model, but fit on `centers_train_scale`, or 'X_all'. 
  # For M1-G-Lasso:
    # model <- train(
    #   fast_ws ~ age + BMI + height + diploma + sex + I(age^2) +
    #     age:BMI + age:height + age:sex + age:diploma +
    #     sex:BMI + sex:height + sex:diploma,
    #   data = centers_train_scale,
    #   method = "glmnet",
    #   trControl = control,
    #   tuneGrid = tune_grid,
    #   metric = "RMSE"
    # )
    
  # For M2-G-Lasso:
    model <- cv.grpreg(
      X_all, y,
      group = group_all,
      seed = 27102001,      
      penalty = "grLasso",
      lambda = lambda_grid,
      standardize = FALSE
  )


  # # Refit a linear regression on the selected variables
  # formula0 <- paste0("fast_ws"~, paste(var_select, collapse = "+"))
  # refit<- lm(formula0, centers_train_scale)
  
  for (b in 1:n_boot) {
    cat("  Bootstrap", b, "/", n_boot, "\r")
    flush.console()
    
    boot_index <- sample(nrow(center_test_scale), replace = TRUE)
    boot_sample <- center_test_scale[boot_index, ]
    
    # Predict on the bootstrapped left-out center, then back-transform from
    # the standardized fast_ws scale to the original scale using the
    # TRAINING fold's mean/sd (centers_train) - NOT the overall data's
    # mean/sd, which would introduce a systematic offset since the model was
    # trained (and its outcome standardized) on centers_train only.
    
    # For M1-Lasso:
    # predictions <- predict(model, newdata = boot_sample) *
    #     sd(centers_train$fast_ws) + mean(centers_train$fast_ws)
      
    # For M2-G-Lasso:
    X_boot <- X_test[boot_index,]
    predictions <- predict(model, X_boot) *
      sd(centers_train$fast_ws) + mean(centers_train$fast_ws)
    
    # predictions <- predict(refit, newdata = boot_sample) *
    #   sd(centers_train$fast_ws) + mean(centers_train$fast_ws)
   
    observed <- boot_sample$fast_ws * sd(centers_train$fast_ws) + mean(centers_train$fast_ws)
    
    calibration <- lm(observed ~ predictions)
    calib_inter <- coef(calibration)[1]
    calib_slope <- coef(calibration)[2]
    
    rmse_vals[[i]][b] <- RMSE(predictions, observed)
    r2_vals[[i]][b] <- R2(predictions, observed)
    calib_slope_vals[[i]][b] <- calib_slope
    calib_inter_vals[[i]][b] <- calib_inter
  }
  cat("  -> Bootstraps finished for center", i, "\n")
  
  results_performance_boot$center_test[i] <- levels(data$center)[i]
  results_performance_boot$nb_ind[i] <- length(center_test_scale$fast_ws)
  results_performance_boot$rmse[i] <- mean(rmse_vals[[i]])
  results_performance_boot$r2[i] <- mean(r2_vals[[i]])
  results_performance_boot$calib_slope[i] <- mean(calib_slope_vals[[i]])
  results_performance_boot$calib_inter[i] <- mean(calib_inter_vals[[i]])
  
  results_performance_boot$se_rmse[i] <- sd(rmse_vals[[i]])
  results_performance_boot$se_r2[i] <- sd(r2_vals[[i]])
  results_performance_boot$se_calib_slope[i] <- sd(calib_slope_vals[[i]])
  results_performance_boot$se_calib_inter[i] <- sd(calib_inter_vals[[i]])
}


# --- 2. Bootstrap convergence checks -------------------------------------------
# Pick one center to inspect (change center_to_check to look at another one).
# If the SE curve flattens out as the number of bootstraps grows, that is a
# good sign the bootstrap has converged for that center; if the RMSE
# histogram is very wide or skewed, the estimate may be unstable and n_boot
# might need to be increased.
center_to_check <- 2

se_convergence <- sapply(1:n_boot, function(b) sd(unlist(rmse_vals[[center_to_check]][1:b])))
plot(se_convergence, type = "l",
     main = paste("Bootstrap SE(RMSE) stability - center", center_to_check),
     ylab = "SE(RMSE)", xlab = "Number of bootstrap replicates")

hist(unlist(rmse_vals[[center_to_check]]), breaks = 10,
     main = paste("RMSE distribution - center", center_to_check), xlab = "RMSE")


# --- 3. Meta-analysis of the RMSE results (repeat identically for R2 or calibration) --
# Pools the n_center per-center RMSE estimates into a single overall estimate
# via a random-effects meta-analysis, weighting each center by the precision
# (bootstrap SE) of its own RMSE estimate, and quantifies between-center
# heterogeneity.
df_meta <- data.frame(
  center = levels(data$center),
  rmse = results_performance_boot$rmse,
  n = results_performance_boot$nb_ind,
  se = results_performance_boot$se_rmse
)

res <- rma(yi = rmse, sei = se, data = df_meta, method = "REML")
summary(res)
forest(res, slab = df_meta$center)
predict(res)


# --- 4. Alternative I^2 statistic, not sensitive to total sample size -------------
# Standard I^2 tends to be inflated by large total sample sizes even when
# between-study heterogeneity is modest. iq2() computes an alternative
# heterogeneity index that corrects for this, clipped at 0 (no negative
# heterogeneity).
iq2 <- function(n, y, sigy2) {
  N <- sum(n)
  k <- length(y)
  w <- 1 / sigy2
  yb <- sum(w * y) / sum(w)
  q <- sum(w * (y - yb)^2)
  iq2_value <- (q - (k - 1)) / (q - (k - 1) + N - sum(n^2) / N)
  iq2_value <- max(0, iq2_value)
  return(iq2_value)
}

n <- as.numeric(table(data$center))
iq2(n, df_meta$rmse, df_meta$se^2)
