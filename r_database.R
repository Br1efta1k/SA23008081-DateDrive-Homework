# Load required packages
library(reticulate)
library(rdataretriever)
library(RSQLite)
library(ade4)

# Set reticulate to use the Python environment
use_python("/usr/bin/python3") # Your Python3 path

# Load the Doubs dataset from the ade4 package
data("toxicity", package = "ade4")

# Convert Doubs dataset to a data frame
toxicity_df <- as.data.frame("toxicity")

# Connect to the SQLite database
conn <- dbConnect(SQLite(), "RSQLite_database.db")

# Upload Doubs dataset into a schema of SQLite
dbWriteTable(conn, "toxicity", toxicity_df, overwrite = TRUE)

# Close the database connection
dbDisconnect(conn)