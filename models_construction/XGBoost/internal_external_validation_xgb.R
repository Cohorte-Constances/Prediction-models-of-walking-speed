# =========================================================================
# Internal-external validation of XGB models
#
# For each recruitment center in turn, the model is refit on all OTHER
# centers and evaluated on the left-out center (internal-external / "leave-
# one-cluster-out" cross-validation). Performance metrics on the left-out
# center are bootstrapped (b = 1..n_boot resamples of that center) to obtain
# a standard error per center, which is then used to pool the per-center
# estimates via a random-effects meta-analysis.
#
# Requires beforehand: `data` (raw data), plus a factor column `data$center`.
#
# Required packages: xgboost, caret (RMSE(), R2()), metafor (rma(), forest())
# =========================================================================

n_boot <- 500

control <- trainControl(method="cv", number=5, summaryFunction = defaultSummary,
                        savePredictions = TRUE,
                        returnResamp = "all")

# Number of centers to loop over
n_center <- nlevels(data$center)

rmse_vals <- vector("list", n_center)
r2_vals <- vector("list", n_center)
calib_slope_vals <- vector("list", n_center)
calib_inter_vals <- vector("list", n_center)


results_performance_boot <- list(center_test = rep("", n_center),
                                 nb_ind = rep(0,n_center),
                                 rmse = rep(0, n_center), 
                                 se_rmse = rep(0, n_center),
                                 r2 =  rep(0, n_center),
                                 se_r2 = rep(0, n_center),
                                 calib_slope = rep(0,n_center),
                                 se_calib_slope = rep(0,n_center),
                                 calib_inter = rep(0,n_center),
                                 se_calib_inter = rep(0,n_center)
)


# --- 1. Loop over the n_center centers ----------------------------------------
for(i in 1:n_center){
  cat("\n----- center", i, "/", n_center, ":", levels(data$center)[i], "-----\n")
  
  # Hold one center out as the test set; train on all remaining centers.
  center_test <- data[which(data$center == levels(data$center)[i]),-c("center")]
  centers_train <- data[-which(data$center == levels(data$center)[i]),-c("center")]
  
  # Train the model of your choice here, using the EXACT SAME variables as your
  # global model, but fit on `centers_train`.
  model <- iterative_variable_selection(centers_train, "fast_ws")$best_model
  var_imp_model <- var_imp_xgb(model)
  col_select <- variable.names(model)
  # col_select <- model$feature_names # For oldest xgboost versions
  
    for (b in 1:n_boot) {
      cat("  Bootstrap", b, "/", n_boot, "\r")
      flush.console()
      
      boot_matrix <- get_design_matrix(boot_sample[,c(col_select, "fast_ws")], "fast_ws")
      dtest <- xgb.DMatrix(data=boot_matrix)
      # Predict on the bootstrapped left-out center
      predictions <- predict(model, dtest)
      
      calibration <- lm(boot_sample$fast_ws*sd(centers_train$fast_ws) + mean(centers_train$fast_ws)~predictions)
      
      calib_inter <- coef(calibration)[1]
      calib_slope <- coef(calibration)[2]
      
      rmse_vals[[i]][b] <- RMSE(predictions, boot_sample$fast_ws*sd(centers_train$fast_ws) + mean(centers_train$fast_ws))
      r2_vals[[i]][b] <- R2(predictions, boot_sample$fast_ws*sd(centers_train$fast_ws) + mean(centers_train$fast_ws))
      calib_slope_vals[[i]][b] <- calib_slope
      calib_inter_vals[[i]][b] <- calib_inter
    }
  cat("  → Bootstraps finished for center", i, "\n")
  
  
  results_performance_boot$center_test[i] <- levels(data$center)[i]
  results_performance_boot$nb_ind[i] <- length(center_test$fast_ws)
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
center_to_check <- 5

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