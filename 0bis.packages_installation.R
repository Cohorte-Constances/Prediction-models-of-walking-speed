if (!requireNamespace("Hmisc", quietly = TRUE)) {
  install.packages("Hmisc", dependencies = TRUE)
}
library(Hmisc)

if (!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr", dependencies = TRUE)
}
library(dplyr)

install.packages("xgboost",
                 repos = "https://packagemanager.posit.co/cran/2023-04-20")
library(xgboost)

if (!requireNamespace("caret", quietly = TRUE)) {
  install.packages("caret", dependencies = TRUE)
}
library(caret)

if (!requireNamespace("grpreg", quietly = TRUE)) {
  install.packages("grpreg", dependencies = TRUE)
}
library(grpreg)

if (!requireNamespace("ggplot2", quietly = TRUE)) {
  install.packages("ggplot2", dependencies = TRUE)
}
library(ggplot2)

if (!requireNamespace("reshape2", quietly = TRUE)) {
  install.packages("reshape2", dependencies = TRUE)
}
library(reshape2)

if (!requireNamespace("metafor", quietly = TRUE)) {
  install.packages("metafor", dependencies = TRUE)
}
library(metafor)

if (!requireNamespace("glmnet", quietly = TRUE)) {
  install.packages("glmnet", dependencies = TRUE)
}
library(glmnet)

if (!requireNamespace("mgcv", quietly = TRUE)) {
  install.packages("mgcv", dependencies = TRUE)
}
library(mgcv)