#---------------------------------
#Script Name
#Purpose:homework4
#Author:  botaoyuan
#Email:  botaoyuan@foxmail.com
#Date:  2024/05/09  edit
#
#-------------------------------
cat("\014") #clears the console
rm(list = ls()) #remove all variables

# Load required libraries
library(caret)
library(ggplot2)
library(dplyr)  # For data manipulation
library(tidyr)  # For reshaping data

# Load the dataset
data(mtcars)

# Step 1: Data Exploration and Structure Check
str(mtcars)  # Check data types
summary(mtcars)  # Summary statistics

# Step 2: Missing Data Handling
# Check for missing values
missing_values <- sapply(mtcars, function(x) sum(is.na(x)))
print(missing_values)  # If non-zero, additional handling would be needed

# Step 3: Feature Engineering
# Create a new feature, e.g., power-to-weight ratio
mtcars <- mtcars %>%
  mutate(power_to_weight = hp / wt)

# Step 4: Normalization and Scaling
# Scale all numeric variables except the target variable 'mpg'
num_vars <- sapply(mtcars, is.numeric)
scaling_params <- preProcess(mtcars[, num_vars], method = c("center", "scale"))
mtcars_scaled <- predict(scaling_params, mtcars)

# Step 5: Data Splitting
# Set a seed for reproducibility and split the data into training and testing sets (70-30 split)
set.seed(123)  # For reproducibility
trainIndex <- createDataPartition(mtcars_scaled$mpg, p = 0.7, list = FALSE)
trainData <- mtcars_scaled[trainIndex, ]
testData <- mtcars_scaled[-trainIndex, ]

# Step 6: Outlier Detection and Removal
# Detect outliers using boxplots
ggplot(trainData, aes(x = 1, y = mpg)) +
  geom_boxplot() +
  labs(title = "Outlier Detection in MPG")

# For the sake of simplicity, we will assume outliers are not problematic here.
# In practice, further handling might be required if outliers significantly affect the model's performance.

# Visualize the distributions and relationships between features and the target variable
ggplot(trainData, aes(x = hp, y = mpg)) +
  geom_point() +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  labs(title = "MPG vs Horsepower")

# Step 7: Train and Tune the Random Forest Model
# Set up a 10-fold cross-validation strategy
trainControl <- trainControl(method = "cv", number = 10)

# Tuning grid for Random Forest (e.g., mtry parameter)
tuneGrid <- expand.grid(mtry = c(2, 3, 4, 5, 6))

# Train the model with cross-validation
set.seed(123)
rfModel <- train(
  mpg ~ .,
  data = trainData,
  method = "rf",
  tuneGrid = tuneGrid,
  trControl = trainControl,
  importance = TRUE
)

# Print the model summary to understand the tuning results
print(rfModel)

# Step 8: Model Evaluation
# Predictions on the test set
predictions <- predict(rfModel, testData)

# Performance metrics (RMSE, MAE, R²)
results <- postResample(predictions, testData$mpg)
cat("RMSE:", results[1], "\n")
cat("MAE:", results[2], "\n")
cat("R²:", results[3], "\n")

# Feature Importance in the Random Forest model
importance <- varImp(rfModel, scale = TRUE)
plot(importance, main = "Feature Importance in Random Forest")
