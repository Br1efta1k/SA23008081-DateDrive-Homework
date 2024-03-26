# Create a sample data frame 
plant_height <- data.frame(
  Day = 1:5,
  A = c(0.7,1.0,1.5,1.8,2.2),
  B = c(0.5,0.7,0.9,1.3,1.8),
  C = c(0.3,0.6,1.0,1.2,1.2),
  D = c(0.4,0.7,1.2,1.5,3.2)
)

# Display data frame
print(plant_height)

# Save data as CSV file
write.csv(plant_height, "Prepare for homework3.csv", row.names = FALSE)

# Return message
cat("CSV file has been created and saved as Prepare for homework3.csv\n")

# Load necessary libraries
library(tidyverse)

# 1) Import and save data
# Since the data frame "plant_height" is already created, we don't need to import data from an external source
# Saving the data frame to a CSV file named "homework3.csv"
write.csv(plant_height, "Prepare fot homework3.csv", row.names = FALSE)

# 2) Inspect data structure
# View the first few rows of the data
head(plant_height)

# Summary statistics of the data
summary(plant_height)

# Structure of the data
str(plant_height)

# 3) Check whether a column or row has missing data
# Checking for missing values in columns
col_has_missing <- colSums(is.na(plant_height)) > 0

# Checking for missing values in rows
row_has_missing <- apply(plant_height, 1, function(x) any(is.na(x)))

# 4) Extract values from a column or select/add a column
# Extracting the value from plant A
plant_A_values <- plant_height$A

# Selecting A and B values
plant_A_B_values <- select(plant_height, A, B)

# Adding the value of plant E as a new column
plant_height <- mutate(plant_height, E = c(0.6, 1.2, 1.9, 2.4, 3.6))

# 5) Transform a wider table to a long format
# Using gather function from tidyr to convert to long format
plant_height_long <- gather(plant_height, key = "Treatment", value = "Height", -Day)

# 6) Visualize the data
# Plotting using ggplot2
ggplot(plant_height_long, aes(x = Day, y = Height, color = Treatment)) +
  geom_line() +
  labs(title = "Plant Height Over Time", x = "Day", y = "Height") +
  theme_minimal()

# Save the plot
ggsave("plant_height_plot.png")

# End of script