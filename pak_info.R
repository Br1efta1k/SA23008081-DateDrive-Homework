# Load necessary library
library(devtools)

# Install the devtools package if not already installed
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Check if tidyverse is installed
if (!requireNamespace("tidyverse", quietly = TRUE)) {
  # Install tidyverse package
  devtools::install.packages("tidyverse")
}

# Load the tidyverse package
library(tidyverse)

# Access the package's functions
# For example, let's use the ggplot function
# Create a simple scatter plot
ggplot(mpg, aes(x = displ, y = hwy)) +
  geom_point()

# Get help documentation for a function
# For example, let's get help for the ggplot function
?ggplot

# Alternatively, you can use the following command to get help
#help("ggplot")

# Save the plot to a file
ggsave("scatter_plot.png")

# Print message indicating successful completion
cat("All tasks completed successfully!\n")
