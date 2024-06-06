#---------------------------------
#Script Name
#Purpose:homework6
#Author:  botaoyuan
#Email:  botaoyuan@foxmail.com
#Date:  2024/05/13  edit
#
#-------------------------------
# Clear console and remove all variables
cat("\014")
rm(list = ls())

# Load required libraries
library(ade4)
library(corrplot)
library(car)
library(dplyr)

# Load Doubs dataset
data(doubs)

# Remove missing values
env <- na.omit(doubs$env) 
fish <- na.omit(doubs$fish)
xy <- na.omit(doubs$xy)
spe <- na.omit(doubs$species)

# Check the structure and summary of the datasets
str(env)
str(spe)
summary(spe)

# Check for multicollinearity among environmental factors
cor_matrix <- cor(env)
indices <- which(upper.tri(cor_matrix) & cor_matrix > 0.7, arr.ind = TRUE)
var_names <- colnames(cor_matrix)

if (length(indices) > 0) {
  cat("Highly collinear variables detected:\n")
  for (i in 1:nrow(indices)) {
    cat(var_names[indices[i, "row"]],
        "and",
        var_names[indices[i, "col"]],
        "have a correlation of",
        cor_matrix[indices[i, "row"], indices[i, "col"]],
        "\n")
  }
} else {
  cat("No correlations above 0.7\n")
}

# Remove highly collinear variables
env_clean <- subset(env, select = !(colnames(env) %in% c("pho", "amm")))

# Check VIF for multicollinearity in predicting fish presence
lm_model <- lm(fish$Lece ~ ., data = env)
vif_results <- car::vif(lm_model)

if (any(vif_results > 10)) {
  cat("Variables with VIF > 10 indicating multicollinearity:\n")
  print(vif_results[vif_results > 10])
} else {
  cat("No multicollinearity detected among environmental factors.\n")
}

# Build a linear regression model to analyze the relationship between fish presence and environmental factors
lm_model2 <- lm(fish$Lece ~ ., data = env_clean)
summary(lm_model2)

# Visualize the correlation between fish presence and environmental factors
lece_env <- bind_cols(select(fish, 10), select(env_clean, 1:7))  # Adjusted column indices
corr_lece <- cor(lece_env)
corrplot(corr_lece, method = "circle")
