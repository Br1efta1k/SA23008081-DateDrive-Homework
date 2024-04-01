# Load necessary libraries
library(caret)
library(randomForest)

# Load the dataset
data(mtcars)

# Data preparation and pre-process
# Convert cyl and vs to factors
mtcars$cyl <- as.factor(mtcars$cyl)
mtcars$vs <- as.factor(mtcars$vs)

# Feature selection and visualization
# Explore the dataset
summary(mtcars)

# Split the data into training and testing sets
set.seed(123)
trainIndex <- createDataPartition(mtcars$mpg, p = 0.8, 
                                  list = FALSE, 
                                  times = 1)
trainData <- mtcars[trainIndex, ]
testData <- mtcars[-trainIndex, ]

# Training and tuning the model using random forest algorithm
# Define the control using trainControl
ctrl <- trainControl(method = "repeatedcv",
                     repeats = 3,
                     number = 10,
                     verboseIter = TRUE)

# Train the model
set.seed(123)
rf_model <- train(mpg ~ ., data = trainData, 
                  method = "rf", 
                  trControl = ctrl)

# Evaluate the performance of the model
print(rf_model)

# Make predictions
predictions <- predict(rf_model, testData)

# Calculate RMSE
rmse <- sqrt(mean((predictions - testData$mpg)^2))
print(paste("RMSE:", rmse))

# Visualize actual vs predicted
plot(testData$mpg, predictions, 
     xlab = "Actual MPG", 
     ylab = "Predicted MPG", 
     main = "Actual vs Predicted MPG")
abline(0, 1, col = "red")