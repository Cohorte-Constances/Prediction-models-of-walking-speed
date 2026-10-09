# coding_nested_binary2(): binary coding using thresholds already learned on the 
# training set. This is the function that must be used to encode a
# NEW dataset (e.g. a test/validation set) with the exact same rules that
# were fitted on the training data, to avoid data leakage / inconsistent
# encoding between train and test.
coding_nested_binary2 <- function(df, case, thresholds_list) {
  
  numeric_names <- names(df)[sapply(df, is.numeric)]
  
  for (var_name in numeric_names) {
    var <- df[[var_name]]
    thresholds <- thresholds_list[[var_name]]
    
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



# Variables transformation for prediction: given a `params` object (which 
# carries every parameter learned on
# the training set - thresholds, spline knots, standardization means/sds,
# dropped correlated columns, and the exact training column names/order),
# this function encodes a brand-new dataset EXACTLY like the training data
# was encoded, without recomputing (= without needing) anything from the
# original training set itself. The result can be fed directly into
# predict() on m2_g_lasso.
#
# Relies on the same globals as modelisation(): cohort_variables, var_biostat,
# var_splines, cas_biostat(), codage_biostat2(), add_splines().

prepare_new_data_for_prediction <- function(new_data, params) {
  
  var_nested_binary <- intersect(params$var_nested_binary, names(data))
  var_splines <- intersect(params$var_splines, names(data))
  
  # --- Apply the biostat coding with thresholds already learned on train ---
  base_new <- cbind.data.frame(
    new_data[, cohort_variables],
    coding_nested_binary2(new_data[, var_nested_binary], params$cases[var_nested_binary], params$thresholds[var_nested_binary])
  )
  
  # --- Apply the spline basis with knots/mean/sd already learned on train ---
  splines_new <- add_splines(new_data[, var_splines], params$knots[var_splines], params$means_splines[var_splines], params$sd_splines[var_splines])
  var_to_remove <- intersect(params$var_to_remove, names(splines_new))
  splines_new <- splines_new %>% dplyr::select(-dplyr::all_of(var_to_remove))
  base_new <- cbind.data.frame(base_new, splines_new)
  
  # --- Standardize continuous cohort variables using TRAINING means/sds ---
  # (never new_data's own mean/sd).
  base_new_scale <- base_new
  for (col in continuous_vars) {
    base_new_scale[[col]] <- (base_new_scale[[col]] - params$means[[col]]) / params$sds[[col]]
  }
  
  return(base_new_scale)
}


# Builds a numeric design matrix (dummy-coded factors, no intercept) for
# xgboost, excluding the target column.

get_design_matrix <- function(df, target) {
  if ((target %in% names(df))) {
    df <- df[, setdiff(names(df), target), drop = FALSE]
  }
  design_formula <- ~ . - 1
  X <- model.matrix(design_formula, data = df)
  
  X
}
