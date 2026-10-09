# Prediction-models-of-walking-speed
This project contains code to predict and to (re)develop predictive models of walking speed from clinical and health insurance claims data. It is related to the manuscript "Development and validation of a machine-learning  prediction model for walking speed in the Constances study"by Kimmerling and colleagues.

There are two folders:

1) models_predictions (fast_ws or usual_ws)
   Use the 6 already-trained models (M1-G-Lasso, M2-G-Lasso, M1-XGBoost, M2-XGBoost,
   M3-G-Lasso, M3-XGBoost) to predict fast or usual walking speed in a new dataset.
   The outcome (fast_ws/ usual_ws) does not need to be known.
   
2) models_construction
   Redevelop the models from scratch using your own data. Requires fast_ws to be
   known. If your data is grouped by center (or another clustering
   variable), you can also reproduce the internal-external validation step,
   followed by external validation, to estimate how well the models
   generalize to new populations.You can also develop these models for usual 
   walking speed, but you will need to rename it "fast_ws" or to modify a few functions.


REQUIREMENTS
------------
R, with the following packages: dplyr (version 1.1.2), ggplot2 (version 3.4.2), 
reshape2 (version 1.4.5), Hmisc (version 5.0-1), glmnet (version 4.1-7), caret (version 6.0-94),
grpreg (version 3.4.0), xgboost (1.7.5.1), metafor (version 4.0-0), mgcv (version 1.8-42).

Your data should contain:
- core clinical variables (age, sex, diploma, BMI, height), needed for M1 and M2 models
- variables from claims datasets (comorbidities, procedures, drug deliveries, etc...),
  needed for M2 and M3 models
- a "center" column, only needed for internal-external validation in models_construction
- fast_ws, only needed for models_construction


FOLDER 1: models_predictions
-----------------------------
Applies the 6 pre-trained models to a new dataset to obtain predictions in a dataset
in which walking speed is not available.

The parameters learned during training (thresholds, spline knots,
standardization means/SDs, etc.) are included in the subfolder infos_models. The
functions that apply these transformations to new data are included in the 
program functions.R:
coding_nested_binary2, add_splines, prepare_new_data_for_prediction,
get_design_matrix.

Steps: 
  1) run the entire program functions.R
  2) run the section 0 of the program predictions.R (pre-treatment)
  3) run the subsection of your choice, depending on the model you wish to use 
  (Group Lasso, XGBoost, M1, M2, M3).

The 6 models are:
- M1-G-Lasso: LASSO on core clinical variables only (age, sex, diploma, BMI, height).
- M2-G-Lasso: Group LASSO on the full set of variables (clinical + claims
  data), where all spline basis columns of a given variable are
  selected/excluded together.
- M1-XGB: XGBoost on core clinical variables only (age, sex, diploma, BMI, height).
- M2-XGB: XGBoost on the full set of variables (clinical + claims
  data).
- M3-G-Lasso: Group LASSO on the variables from claims datasets only, where all 
  spline basis columns of a given variable are selected/excluded together.
- M3-XGBoost: XGBoost on the variables from claims datasets only.

FOLDER 2: models_construction
------------------------------
Contains all the code to build the models step by step.

Codes for G-Lasso and XGBoost models are separated in two different subfolders
and are organized the same way:

Step 1 - Run the entire construction_XXX_functions.R program (except for M1-G-Lasso)
(where XXX is m2_g_lasso or xgb).

Step 2 - Model construction: builds the model described above.

Step 3 - Internal-external validation by center (optional, needs a
"center" column): at each step, one center is set aside and the model is retrained 
on all other centers and evaluated on the excluded one, with bootstrap confidence
intervals. This procedure is repeated for each center. The performances obtained 
at each step are then pooled through a random-effects meta-analysis, giving an
overall performance estimate and a measure of heterogeneity across centers.

Step 4 - External validation (optional, needs a second independent
dataset with known fast_ws): evaluates the final model on a dataset that is
completely independent from the training dataset, and yields performance metrics, an
observed-vs-predicted plot, and recalibration (intercept only, then
intercept and slope) in the new dataset.

At the end, save whatever models_predictions will need (learned
parameters and fitted models) so it can be reused without rerunning the
training steps.


REMARKS
-----------------------
- New data (excluded center for the internal-external validation, or external 
  validation dataset) is always standardized using the training set's own mean/SD,
  spline knots,etc...from the training dataset's own - otherwise performance measures would be biased.
- Sex must be a numeric variable, 1 for males and 0 for females.
- Diploma is coded as a continuous variable corresponding to the number of years of study:
    without diploma ~ 8,
    DNB ~ 12,
    CAP ~ 14,
    BAC ~ 15,
    BAC+2 or +3 ~ 18,
    BAC+4 ~ 19,
    BAC+5 or more ~ 23.
- Some variable exclusions (for interactions with sex) are hard-coded and
  specific to our original dataset's variable names; check and adapt them
  if you rebuild the models on data with different variable names 
  (function 'modelisation' in script "construction_m2_g_lasso_functions.R").


R Environment Setup
-------------------
This project can be set up in three ways, depending on your needs. Try them in order.

### Option 1: You do NOT need to load the pre-trained xgboost models

Simply run the script:

```r
   source("0.packages_installation.R")
```

It installs the latest CRAN version of xgboost.

### Option 2: You need to load the pre-trained xgboost models

The models were developed with **xgboost 1.7.5.1**, which must be compiled from source.

1. Install **Rtools45** beforehand (Windows only): https://cran.r-project.org/bin/windows/Rtools/rtools45/rtools.html
   (macOS: Xcode Command Line Tools; Linux: `build-essential`). Restart RStudio after installing.
2. Run the script:

```r
   source("0bis.packages_installation.R")
```

### Option 3: If Option 2 does not work, restore the `renv` environment

1. Install **R 4.5.1** (or any 4.5.x version) and Rtools45 (see above).
2. Copy the project to a **local** folder (avoid network paths such as `\\server\...`) and open the `.Rproj` file in RStudio.
3. Restore the environment:

```r
   renv::restore()
```

4. Check the installation:

```r
   packageVersion("xgboost")   # should display 1.7.5.1
```

CONTACT
-------------------
vera.kimmerling@inserm.fr
alexis.elbaz@inserm.fr
