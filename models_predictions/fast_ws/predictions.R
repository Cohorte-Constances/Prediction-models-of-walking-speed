# =============================================================================
# Fast WS predictions using pretrained models
#
# The script functions.R must have been run before this script.
# =============================================================================

# 0. ------- Pre-treatment ----------------------------------------------------

# Extreme values truncation
snds_variables <- setdiff(names(data),c("age", "sex", "BMI", "diploma", "height"))
# For M3 models:
# snds_variables <- setdiff(names(data),c("age", "sex"))
load(file = "models_predictions/fast_ws/infos_models/extrem_values_snds.RData")

data[snds_variables] <- Map(
  function(x, vmax) round(pmin(x, vmax), 0),
  data[snds_variables],
  extrem_values_snds[snds_variables]
)

# 1. ------- Predictions ------------------------------------------------------

## 1.1 ----- G-Lasso ----------------------------------------------------------

load(file = "models_predictions/fast_ws/infos_models/means.RData")
load(file = "models_predictions/fast_ws/infos_models/sds.RData")
  
### 1.1.1 ----- M1-G-Lasso ----------------------------------------------------

load(file = "models_predictions/fast_ws/infos_models/coefs_m1_g_lasso.RData")
continuous_vars <- c("fast_ws", "age", "diploma", "BMI", "height")
cohort_variables <- c("age", "diploma", "BMI", "height", "sex")

data_scale <- lapply(names(data), function(col) {
  x <- data[[col]]
  if (col != "sex") {
    (x - means[[col]]) / sds[[col]]
  } else {
    x
  }
})
names(data_scale) <- names(data)
data_scale <- as.data.frame(data_scale)

predictions <- coefs_m1_g_lasso[1] + coefs_m1_g_lasso[["age"]]*data_scale$age + coefs_m1_g_lasso[["BMI"]]*data_scale$BMI +
  coefs_m1_g_lasso[["height"]]*data_scale$height + coefs_m1_g_lasso[["diploma"]]*data_scale$diploma + 
  coefs_m1_g_lasso[["sex"]]*data_scale$sex + coefs_m1_g_lasso[["I(age^2)"]]*(data_scale$age)^2 + 
  coefs_m1_g_lasso[["age:BMI"]]*data_scale$age*data_scale$BMI + coefs_m1_g_lasso[["age:height"]]*data_scale$age*data_scale$height +
  coefs_m1_g_lasso[["BMI:sex"]]*data_scale$sex*data_scale$BMI + coefs_m1_g_lasso[["diploma:sex"]]*data_scale$sex*data_scale$diploma

# converting predictions back from the standardized scale to the original scale:
predictions <- predictions*sds[["fast_ws"]] + means[["fast_ws"]] 

### 1.1.2 ----- M2-G-Lasso ----------------------------------------------------

load(file = "models_predictions/fast_ws/infos_models/coefs_m2_g_lasso.RData")
load(file = "models_predictions/fast_ws/infos_models/thresholds.RData")
load(file = "models_predictions/fast_ws/infos_models/cases.RData")
load(file = "models_predictions/fast_ws/infos_models/knots.RData")
load(file = "models_predictions/fast_ws/infos_models/means_splines.RData")
load(file = "models_predictions/fast_ws/infos_models/sd_splines.RData")
load(file = "models_predictions/fast_ws/infos_models/var_to_remove.RData")
load(file = "models_predictions/fast_ws/infos_models/var_nested_binary.RData")
load(file = "models_predictions/fast_ws/infos_models/var_splines.RData")
continuous_vars <- c("age", "diploma", "BMI", "height")
cohort_variables <- c("age", "diploma", "BMI", "height", "sex")

params <- list(
  thresholds=thresholds,
  cases=cases,
  knots = knots,
  means_splines = means_splines,
  sd_splines = sd_splines,
  var_nested_binary = var_nested_binary,
  var_splines = var_splines,
  var_to_remove = var_to_remove, 
  means = means, 
  sds =sds)

# transforming the new data the same way it was transformed at training time: 
data_scale <- prepare_new_data_for_prediction(data, params)

intercept <- coefs_m2_g_lasso[["(Intercept)"]]
coefs_no_intercept <- coefs_m2_g_lasso[names(coefs_m2_g_lasso) != "(Intercept)"]

formule <- as.formula(
  paste("~", paste(names(coefs_no_intercept), collapse = " + "))
)

X <- model.matrix(formule, data = data_scale)
X <- X[, colnames(X) != "(Intercept)", drop = FALSE]
X <- X[, names(coefs_no_intercept), drop = FALSE]

predictions <- intercept + as.numeric(X %*% coefs_no_intercept)
# converting predictions back from the standardized scale to the original scale:
predictions <- predictions*sds[["fast_ws"]] + means[["fast_ws"]]


### 1.1.3 ----- M3-G-Lasso ----------------------------------------------------

load(file = "models_predictions/fast_ws/infos_models/coefs_m3_g_lasso.RData")
load(file = "models_predictions/fast_ws/infos_models/thresholds.RData")
load(file = "models_predictions/fast_ws/infos_models/cases.RData")
load(file = "models_predictions/fast_ws/infos_models/knots.RData")
load(file = "models_predictions/fast_ws/infos_models/means_splines.RData")
load(file = "models_predictions/fast_ws/infos_models/sd_splines.RData")
load(file = "models_predictions/fast_ws/infos_models/var_to_remove.RData")
load(file = "models_predictions/fast_ws/infos_models/var_nested_binary.RData")
load(file = "models_predictions/fast_ws/infos_models/var_splines.RData")
continuous_vars <- c("age")
cohort_variables <- c("age", "sex")

params <- list(
  thresholds=thresholds,
  cases=cases,
  knots = knots,
  means_splines = means_splines,
  sd_splines = sd_splines,
  var_nested_binary = var_nested_binary,
  var_splines = var_splines,
  var_to_remove = var_to_remove, 
  means = means, 
  sds =sds)

# transforming the new data the same way it was transformed at training time: 
data_scale <- prepare_new_data_for_prediction(data, params)

intercept <- coefs_m3_g_lasso[["(Intercept)"]]
coefs_no_intercept <- coefs_m3_g_lasso[names(coefs_m3_g_lasso) != "(Intercept)"]

formule <- as.formula(
  paste("~", paste(names(coefs_no_intercept), collapse = " + "))
)

X <- model.matrix(formule, data = data_scale)
X <- X[, colnames(X) != "(Intercept)", drop = FALSE]
X <- X[, names(coefs_no_intercept), drop = FALSE]

predictions <- intercept + as.numeric(X %*% coefs_no_intercept)
# converting predictions back from the standardized scale to the original scale:
predictions <- predictions*sds[["fast_ws"]] + means[["fast_ws"]]

## 1.2 ----- XGB --------------------------------------------------------------

### 1.2.1 ----- M1-XGB --------------------------------------------------------

m1_xgb <- readRDS(file = "models_predictions/fast_ws/infos_models/m1_xgb.rds")

col_select <- m1_xgb$feature_names
col_select <- gsub("sexe0", "sexe", col_select)
col_select <- unique(gsub("sexe1", "sexe", col_select))

data_xgb <- data
names(data_xgb)[which(names(data_xgb)=="diploma")] <- "diplome_cont"
names(data_xgb)[which(names(data_xgb)=="height")] <- "taille_imput"
names(data_xgb)[which(names(data_xgb)=="sex")] <- "sexe"
data_xgb$sexe <- as.factor(data_xgb$sexe)

design_matrix <- get_design_matrix(data_xgb[,c(col_select, "fast_ws")], "fast_ws")
X_data <- xgb.DMatrix(data=design_matrix)
predictions <- predict(m1_xgb, newdata = X_data)

### 1.2.2 ----- M2-XGB --------------------------------------------------------

m2_xgb <- readRDS(file = "models_predictions/fast_ws/infos_models/m2_xgb.rds")

col_select <- m2_xgb$feature_names
col_select <- gsub("sexe0", "sexe", col_select)
col_select <- unique(gsub("sexe1", "sexe", col_select))

data_xgb <- data
names(data_xgb)[which(names(data_xgb)=="diploma")] <- "diplome_cont"
names(data_xgb)[which(names(data_xgb)=="height")] <- "taille_imput"
names(data_xgb)[which(names(data_xgb)=="sex")] <- "sexe"
data_xgb$sexe <- as.factor(data_xgb$sexe)

design_matrix <- get_design_matrix(data_xgb[,c(col_select, "fast_ws")], "fast_ws")
X_data <- xgb.DMatrix(data=design_matrix)
predictions <- predict(m2_xgb, newdata = X_data)

### 1.2.3 ----- M3-XGB --------------------------------------------------------

m3_xgb <- readRDS(file = "models_predictions/fast_ws/infos_models/m3_xgb.rds")

col_select <- m3_xgb$feature_names
col_select <- gsub("sexe0", "sexe", col_select)
col_select <- unique(gsub("sexe1", "sexe", col_select))

data_xgb <- data
names(data_xgb)[which(names(data_xgb)=="sex")] <- "sexe"
data_xgb$sexe <- as.factor(data_xgb$sexe)

design_matrix <- get_design_matrix(data_xgb[,c(col_select, "fast_ws")], "fast_ws")
X_data <- xgb.DMatrix(data=design_matrix)
predictions <- predict(m3_xgb, newdata = X_data)

