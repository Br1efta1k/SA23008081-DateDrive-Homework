# Load required libraries
library(MASS)  # For Doubs dataset
library(vegan)  # For CCA and multivariate analysis
library(corrplot)  # For visualizing correlations
library(car)  # For Variance Inflation Factor (VIF)

# Load the Doubs dataset
data(doubs, package = "ade4")

# Extract fish and environmental data
fish <- doubs$fish
env <- doubs$env

# Remove rows with any missing data from the environmental dataset
env_clean <- na.omit(env)

# Step 1: Check for multicollinearity among environmental factors
if (ncol(env_clean) > 1) {
  # Calculate the correlation matrix
  cor_matrix <- cor(env_clean)
  
  # Visualize the correlation matrix
  corrplot(cor_matrix, method = "circle")
  
  # Calculate Variance Inflation Factors (VIF)
  tryCatch({
    # Build a linear model with environmental variables
    vif_model <- lm(as.matrix(env_clean) ~ 1)
    vif_results <- vif(vif_model)
    
    # Display VIF results
    print("Variance Inflation Factors:")
    print(vif_results)
    
    # Check for high VIF (commonly, VIF > 10 indicates multicollinearity)
    if (any(vif_results > 10)) {
      message("Warning: High multicollinearity detected among environmental factors.")
    }
  }, error = function(e) {
    message("Error calculating VIF: ", e$message)
  })
} else {
  warning("Not enough environmental variables to check for multicollinearity.")
}

# Step 2: Analysis of relationships between fish and environmental factors with CCA

# Remove rows with all zero values from the fish data
non_zero_rows <- rowSums(fish) > 0
fish_clean <- fish[non_zero_rows, ]

# Align the cleaned environmental data with the cleaned fish data
env_clean <- env_clean[non_zero_rows, ]

# Check for alignment consistency
if (nrow(fish_clean) == nrow(env_clean)) {
  # Perform Canonical Correspondence Analysis (CCA)
  cca_result <- cca(fish_clean ~ ., data = env_clean)
  
  # Display the summary of CCA
  summary(cca_result)
  
  # Plot the CCA results with sites and environmental vectors
  plot(cca_result, scaling = 2, display = c("sites", "bp"), main = "CCA of Fish and Environmental Factors")
  
  # Additional visualization with species and environmental vectors
  plot(cca_result, scaling = 2, display = c("species", "bp"), type = "n", main = "CCA: Species and Environmental Vectors")
  text(cca_result, display = "species", col = "red", cex = 0.8)  # Add species names
  arrows(0, 0, scores(cca_result, display = "bp")[, 1], scores(cca_result, display = "bp")[, 2], col = "blue", length = 0.1)  # Environmental vectors
} else {
  warning("Mismatch between cleaned fish data and environmental data. Check data consistency.")
}