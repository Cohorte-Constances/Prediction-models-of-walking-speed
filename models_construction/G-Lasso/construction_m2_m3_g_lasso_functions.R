# =============================================================================
# Preprocessing and modelling pipeline for M2-G-Lasso model
# =============================================================================


# --- 1. "nested_binary" coding for low-cardinality variables -----------------
# Most SNDS variables (counts of drug deliveries, procedures, etc.)
# are highly zero-inflated. Rather than using the raw value, we build 1 to 3
# binary indicators based on data-driven thresholds (1, median, 3rd quartile
# computed on strictly positive values), choosing the number of indicators
# depending on how "spread out" the positive part of the distribution is.

# case_nested_binary(): learns, for each numeric variable of df, which "case" (1-4)
# applies and the corresponding thresholds. Meant to be run ONCE on the
# training set; the resulting `case` and `seuils` are then reused (via
# coding_nested_binary2, see below) to encode any other dataset (e.g. a test set)
# consistently, without recomputing thresholds on that new dataset.
case_nested_binary <- function(df) {
  
  numeric_names <- names(df)[sapply(df, is.numeric)]
  case <- list()
  seuils <- list()
  
  for (var_name in numeric_names) {
    var <- df[[var_name]]
    
    if (mean(var == 0) > 0.95) {
      # case 1: variable is (almost) always zero -> single indicator (>=1)
      case[[var_name]] <- 1
      seuils[[var_name]] <- c(1)
    } else {
      median_value <- median(var[which(var > 0)])
      q75 <- quantile(var[which(var > 0)], 0.75)
      
      if (median_value <= 1) {
        if (q75 == median_value) {
          # case 1 (degenerate): median and q75 collapse to 1 -> single indicator
          case[[var_name]] <- 1
          seuils[[var_name]] <- c(1)
        } else {
          # case 2: median is 1 but q75 differs -> two indicators (>=1, >=q75)
          case[[var_name]] <- 2
          seuils[[var_name]] <- c(1, q75)
        }
      } else {
        if (q75 == median_value) {
          # case 3: median > 1 but q75 == median -> two indicators (>=1, >=median)
          case[[var_name]] <- 3
          seuils[[var_name]] <- c(1, median_value)
        } else {
          # case 4: general case -> three indicators (>=1, >=median, >=q75)
          case[[var_name]] <- 4
          seuils[[var_name]] <- c(1, median_value, q75)
        }
      }
    }
  }
  return(list(case = case, thresholds = seuils))
}

# coding_nested_binary(): applies the binary coding to df, RECOMPUTING the median
# and q75 thresholds from df itself. Use this only on the dataset the
# thresholds were learned from (typically the training set), since applying
# it to a different dataset would silently use different thresholds than
# those stored in `case`/`seuils`.
coding_nested_binary <- function(df, case) {
  
  numeric_names <- names(df)[sapply(df, is.numeric)]
  
  for (var_name in numeric_names) {
    var <- df[[var_name]]
    
    median_value <- median(var[which(var > 0)])
    q75 <- quantile(var[which(var > 0)], 0.75)
  
    if (case[[var_name]] == 1) {
      df[[paste0(var_name, "_1")]] <- ifelse(var >= 1, 1, 0)
      
    } else if (case[[var_name]] == 2) {
      df[[paste0(var_name, "_1")]] <- ifelse(var >= 1, 1, 0)
      df[[paste0(var_name, "_q75")]] <- ifelse(var >= q75, 1, 0)
      
    } else if (case[[var_name]] == 3) {
      df[[paste0(var_name, "_1")]] <- ifelse(var >= 1, 1, 0)
      df[[paste0(var_name, "_mediane")]] <- ifelse(var >= median_value, 1, 0)
      
    } else {
      df[[paste0(var_name, "_1")]] <- ifelse(var >= 1, 1, 0)
      df[[paste0(var_name, "_mediane")]] <- ifelse(var >= median_value, 1, 0)
      df[[paste0(var_name, "_q75")]] <- ifelse(var >= q75, 1, 0)
    }
  }
  
  df <- df[, !(names(df) %in% numeric_names), drop = FALSE]
  
  return(df)
}

# coding_nested_binary2(): same binary coding as coding_nested_binary(), but using
# thresholds already learned on the training set (via case_nested_binary) instead of
# recomputing them on df. This is the function that must be used to encode a
# NEW dataset (e.g. a test/validation set) with the exact same rules that
# were fitted on the training data, to avoid data leakage / inconsistent
# encoding between train and test.
coding_nested_binary2 <- function(df, case, seuils) {
  
  numeric_names <- names(df)[sapply(df, is.numeric)]
  
  for (var_name in numeric_names) {
    var <- df[[var_name]]
    thresholds <- seuils[[var_name]]
    
    if (case[[var_name]] == 1) {
      df[[paste0(var_name, "_1")]] <- ifelse(var >= thresholds[1], 1, 0)
      
    } else if (case[[var_name]] == 2) {
      df[[paste0(var_name, "_1")]] <- ifelse(var >= thresholds[1], 1, 0)
      df[[paste0(var_name, "_q75")]] <- ifelse(var >= thresholds[2], 1, 0)
      
    } else if (case[[var_name]] == 3) {
      df[[paste0(var_name, "_1")]] <- ifelse(var >= thresholds[1], 1, 0)
      df[[paste0(var_name, "_mediane")]] <- ifelse(var >= thresholds[2], 1, 0)
      
    } else {
      df[[paste0(var_name, "_1")]] <- ifelse(var >= thresholds[1], 1, 0)
      df[[paste0(var_name, "_mediane")]] <- ifelse(var >= thresholds[2], 1, 0)
      df[[paste0(var_name, "_q75")]] <- ifelse(var >= thresholds[3], 1, 0)
    }
  }
  
  df <- df[, !(names(df) %in% numeric_names), drop = FALSE]
  
  return(df)
}


# --- 2. Restricted cubic splines for high-cardinality variables --------------
# For variables with many distinct values (counts, costs...), we keep more
# information than a simple binary threshold by fitting restricted cubic
# splines on the standardized, strictly positive part of the distribution,
# plus a binary "presence" indicator (value > 0) to capture the excess of
# zeros separately from the shape of the positive part.

# create_knots(): learns, for each variable of `data` (numeric SNDS
# variables), the standardization parameters (mean, sd) and the spline knot
# locations (quantiles of the standardized positive values). Meant to be run
# ONCE on the training set; the outputs are then reused by add_splines() on
# any other dataset to guarantee train/test consistency.
create_knots <- function(data) {
  knots_all <- list()
  means_all <- list()
  sd_all <- list()
  
  for (variable in names(data)) {
    
    x <- data[[variable]]
    mean_x <- mean(x)
    sd_x <- sd(x)
    x <- scale(x)
    
    # Knots placed at the 5th/27.5th/50th/72.5th/95th percentiles of the
    # standardized STRICTLY POSITIVE values only (zeros are handled
    # separately via the "_pos" indicator, see add_splines()).
    knots <- quantile(x[x > 0], probs = c(0.05, 0.275, 0.5, 0.725, 0.95))
    knots_all[[variable]] <- knots
    means_all[[variable]] <- mean_x
    sd_all[[variable]] <- sd_x
  }
  return(list(knots_all = knots_all, means_all = means_all, sd_all = sd_all))
}


# add_splines(): builds, for each variable of `data`, a "_pos" binary presence
# indicator and a set of restricted cubic spline basis columns computed on
# the standardized strictly-positive values, using knots/mean/sd learned by
# create_knots() (on the training set). Observations with value == 0 are
# assigned the spline value corresponding to x = 0 (i.e. -mean/sd on the
# standardized scale), so that they sit at a consistent, meaningful point in
# the spline basis space rather than being dropped or extrapolated.
add_splines <- function(data, knots, means_all, sd_all) {
  n1 <- length(names(data))
  for (i in seq_along(names(data))) {
    variable <- names(data)[i]
    presence_col <- paste0(variable, "_pos")
    data[[presence_col]] <- as.integer(data[[variable]] > 0)
    
    x <- data[[variable]]
    mean_x <- means_all[[variable]]
    sd_x <- sd_all[[variable]]
    x_non_nuls_index <- which(x > 0)
    x <- (x - mean_x) / sd_x
    
    spline_vals <- rcspline.eval(x[x_non_nuls_index], inclx = TRUE, knots = knots[[i]])
    nb_splines <- ncol(spline_vals)
    
    # Value at x = 0 on the standardized scale, used for zero observations
    spline_mat <- matrix(-mean_x / sd_x, nrow = length(x), ncol = nb_splines)
    spline_mat[x_non_nuls_index, ] <- spline_vals
    
    spline_names <- paste0(variable, "_spline_", seq_len(ncol(spline_mat)))
    colnames(spline_mat) <- spline_names
    
    data <- cbind(data, spline_mat)
  }
  
  n2 <- length(names(data))
  return(data[, (n1 + 1):n2])
}

# Visualization: plots the spline basis functions for one variable, useful to
# sanity-check the shape learned by add_splines() before using it in a model.
plot_splines <- function(df_spline, varname) {
  
  spline_cols <- grep(paste0("^", varname, "_spline"), names(df_spline), value = TRUE)
  
  x_vals <- df_spline[[varname]]
  mask <- x_vals > 0
  
  df_plot <- data.frame(x = x_vals[mask], df_spline[mask, spline_cols])
  df_long <- reshape2::melt(df_plot, id.vars = "x")
  
  ggplot(df_long, aes(x = x, y = value, color = variable)) +
    geom_line(size = 1) +
    theme_minimal() +
    labs(
      title = paste("Spline basis functions for", varname),
      x = varname, y = "Basis function value",
      color = "Spline basis"
    )
}


# --- 3. Correlation filtering ------------------------------------------------
# After recoding, some derived spline bases can
# be almost perfectly correlated with each other. get_strong_correlation()
# extracts pairs of splines with |correlation| > 0.90 (upper triangle only,
# to avoid duplicate pairs), so that one of the two can be dropped before
# fitting the model.
get_strong_correlation <- function(cor_mat) {
  cor_mat[lower.tri(cor_mat, diag = TRUE)] <- NA
  cor_df <- as.data.frame(as.table(cor_mat))
  cor_df <- na.omit(cor_df)
  cor_df <- cor_df[abs(cor_df$Freq) > 0.90, ]
  colnames(cor_df) <- c("Var1", "Var2", "Correlation")
  cor_df[order(-abs(cor_df$Correlation)), ]
}


# --- 4. Full modelling pipeline ----------------------------------------------
# Builds the full design matrix (X_all) and outcome vector (y) for the
# training set, and optionally for a new/test set (new_data), reusing the
# thresholds/knots learned on the training set. Also adds sex x covariate and
# age x covariate interaction terms.
#
# INTERACTIONS: sex is interacted with every other covariate (except sex
# itself and the outcome fast_ws) - i.e. sex x age, sex x diploma, sex x
# BMI, sex x height, and sex x all nested_binary/spline-derived columns. Age is
# interacted with every other covariate except age itself (and the outcome);
# age^2 is not a stored column (it only appears as a formula term when
# building the main-effects matrix X_mat_bis), so there is nothing extra to
# exclude for it. 

modelisation <- function(df, new_data = NULL, var_nested_binary, var_splines) {
  
  train_data <- df
  test_data <- new_data
  
  means <- sapply(train_data, function(x) if (is.numeric(x)) mean(x) else NA)
  sds <- sapply(train_data, function(x) if (is.numeric(x)) sd(x) else NA)
  
  # --- nested_binary coding (learned on train, applied to train) ---
  case_nested_binarys_res <- case_nested_binary(train_data[, var_nested_binary])
  case <- case_nested_binarys_res$case
  thresholds <- case_nested_binarys_res$thresholds
  database <- cbind.data.frame(
    train_data[, c(cohort_variables, "fast_ws")],
    coding_nested_binary(train_data[, var_nested_binary], case)
  )
  
  # --- Splines (learned on train, applied to train) ---
  res_knots <- create_knots(train_data[, var_splines])
  knots <- res_knots$knots_all
  means_splines <- res_knots$means_all
  sd_splines <- res_knots$sd_all
  splines <- add_splines(train_data[, var_splines], knots, means_splines, sd_splines)
  
  # Drop one variable from each pair of highly correlated spline columns
  spline_cols <- grep("spline", names(splines), value = TRUE)
  cor_mat <- cor(splines[, spline_cols], method = "pearson")
  strong_corr_table <- get_strong_correlation(cor_mat)
  var_to_remove <- strong_corr_table$Var2  # columns to remove (2nd member of each correlated pair)
  splines <- splines %>% dplyr::select(-dplyr::all_of(var_to_remove))
  
  database <- cbind.data.frame(database, splines)
  
  # --- Standardize continuous cohort variables ---
  database_scale <- database
  database_scale[, continuous_vars] <- scale(database_scale[, continuous_vars])
  
  y <- database_scale$fast_ws
  
  # Main effects design matrix, including a quadratic age term.
  # `-1` removes the intercept (handled separately downstream).
  predictors <- setdiff(names(database_scale), "fast_ws")
  X_mat_bis <- model.matrix(~ I(age^2) + . - 1, data = database_scale[, predictors])
  
  # All covariates eligible for interactions = every column except the
  # outcome (fast_ws). Sex interacts with everything except sex itself;
  # age interacts with everything except age itself (age^2 is not a stored
  # column - it only appears as a formula term in X_mat_bis above - so
  # there is nothing extra to exclude for it).
  covariates_for_int <- setdiff(names(database_scale), "fast_ws")
  
  # --- Sex x (everything else, except sex) interactions ---
  X_sex_int <- model.matrix(
    ~ 0 + sex:.,
    data = cbind(
      sex = database_scale$sex,
      database_scale[, setdiff(covariates_for_int, "sex"), drop = FALSE]
    )
  )
  
  # Drop interactions with variables that are only meaningful for one sex
  # (e.g. sex-specific drug classes ATC_G/ATC_V, or sex-specific procedures
  # such as breast cancer care [CANSEIN] or midwife acts [SAGE_FEMME]).
  colnames_int_sex <- colnames(X_sex_int)[grepl("^sex", colnames(X_sex_int))]
  colnames_int_sex <- colnames_int_sex[!grepl("^sex:ATC_G", colnames_int_sex)]
  colnames_int_sex <- colnames_int_sex[!grepl("^sex:ATC_V", colnames_int_sex)]
  colnames_int_sex <- colnames_int_sex[!grepl("^sex:TOTAL_J_CCAM", colnames_int_sex)]
  colnames_int_sex <- colnames_int_sex[!grepl("^sex:TOTAL_G_LPP", colnames_int_sex)]
  colnames_int_sex <- colnames_int_sex[!grepl("^sex:CANSEIN|^sex:SAGE_FEMME", colnames_int_sex)]
  
  X_sex_int <- X_sex_int[, colnames_int_sex[-1]]  # drop sex main effect, keep interactions only
  
  # --- Age x (everything else, except age) interactions ---
  X_age_int <- model.matrix(
    ~ 0 + age:.,
    data = cbind(
      age = database_scale$age,
      database_scale[, setdiff(covariates_for_int, "age"), drop = FALSE]
    )
  )
  X_age_int <- X_age_int[, grepl("^age:", colnames(X_age_int))]
  
  # --- Merge all design blocks ---
  X_all <- cbind(X_mat_bis, X_sex_int, X_age_int)
  
  if (!is.null(new_data)) {
    
    # --- Apply the SAME encoding (case/seuils/knots learned on train) to the test set ---
    database_test <- cbind.data.frame(
      test_data[, c(cohort_variables, "fast_ws")],
      coding_nested_binary2(test_data[, var_nested_binary], case, thresholds)
    )
    splines_test <- add_splines(test_data[, var_splines], knots, means_splines, sd_splines)
    splines_test <- splines_test %>% dplyr::select(-dplyr::all_of(var_to_remove))
    database_test <- cbind.data.frame(database_test, splines_test)
    
    # Standardize using train means/sds (avoids leakage from test set)
    database_test_scale <- database_test
    for (col in continuous_vars) {
      database_test_scale[[col]] <- (database_test_scale[[col]] - means[[col]]) / sds[[col]]
    }
    
    predictors_test <- setdiff(names(database_test_scale), "fast_ws")
    X_test <- model.matrix(~ I(age^2) + . - 1, data = database_test_scale[, predictors_test])
    
    covariates_for_int_test <- setdiff(names(database_test_scale), "fast_ws")
    
    X_sex_int <- model.matrix(
      ~ 0 + sex:.,
      data = cbind(
        sex = database_test_scale$sex,
        database_test_scale[, setdiff(covariates_for_int_test, "sex"), drop = FALSE]
      )
    )
    
    colnames_int_sex <- colnames(X_sex_int)[grepl("^sex", colnames(X_sex_int))]
    colnames_int_sex <- colnames_int_sex[!grepl("^sex:ATC_G", colnames_int_sex)]
    colnames_int_sex <- colnames_int_sex[!grepl("^sex:ATC_V", colnames_int_sex)]
    colnames_int_sex <- colnames_int_sex[!grepl("^sex:TOTAL_J_CCAM", colnames_int_sex)]
    colnames_int_sex <- colnames_int_sex[!grepl("^sex:TOTAL_G_LPP", colnames_int_sex)]
    colnames_int_sex <- colnames_int_sex[!grepl("^sex:CANSEIN|^sex:SAGE_FEMME", colnames_int_sex)]
    
    X_sex_int <- X_sex_int[, colnames_int_sex[-1]]
    
    X_age_int <- model.matrix(
      ~ 0 + age:.,
      data = cbind(
        age = database_test_scale$age,
        database_test_scale[, setdiff(covariates_for_int_test, "age"), drop = FALSE]
      )
    )
    X_age_int <- X_age_int[, grepl("^age:", colnames(X_age_int))]
    
    X_all_test <- cbind(X_test, X_sex_int, X_age_int)
    
    return(list(
      y = y, X_all = X_all, database_scale = database_scale,
      X_all_test = X_all_test, database_test_scale = database_test_scale
    ))
  } else {
    return(list(y = y, X_all = X_all, database_scale = database_scale))
  }
}
