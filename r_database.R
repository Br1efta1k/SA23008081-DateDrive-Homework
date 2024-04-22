# Load required packages

library(DBI)   # Interface for database communication

library(RPostgres)  # PostgreSQL driver

library(RSQLite)  # SQLite driver

library(ade4)  # For Doubs dataset



# Step 1: Load the Doubs dataset

data(doubs, package = "ade4")



# Unpack the dataset into individual data frames

species <- doubs$fish  # Species data

environment <- doubs$env  # Environmental data

site_info <- doubs$xy # geographical information

countryname_info <- doubs$species #the fish name in different country


# Step 2: Connect to the PostgreSQL database

# Replace with your PostgreSQL connection details

pg_conn <- dbConnect(
  
  RPostgres::Postgres(),
  
  user = "admin", 
  
  password = "admin", 
  
  dbname = "postgres", 
  
  host = "127.0.0.1", 
  
  port = 5432
  
  )



# Step 3: Write data frames to the PostgreSQL database within the schema

# Write species data to the PostgreSQL

dbWriteTable(pg_conn, "species", species, overwrite = TRUE)

# Write environmental data to the PostgreSQL

dbWriteTable(pg_conn, "environment", environment, overwrite = TRUE)

# Write geographical data to the PostgreSQL

dbWriteTable(pg_conn, "site_info", site_info, overwrite = TRUE)

# Write name data to the PostgreSQL

dbWriteTable(pg_conn, "countryname_info", countryname_info, overwrite = TRUE)

# Step 4: Disconnect from the PostgreSQL database

dbDisconnect(pg_conn)



# If you prefer to use SQLite, you can use the following code:

# Step 2: Connect to the SQLite database (file-based)

sqlite_conn <- dbConnect(RSQLite::SQLite(), dbname = "sqlite3-database1-intensive")



# Write the same data to SQLite

dbWriteTable(sqlite_conn, "species", species, overwrite = TRUE)


dbWriteTable(sqlite_conn, "environment", environment, overwrite = TRUE)


dbWriteTable(pg_conn, "site_info", site_info, overwrite = TRUE)


dbWriteTable(pg_conn, "countryname_info", countryname_info, overwrite = TRUE)

# Disconnect from SQLite

dbDisconnect(sqlite_conn)



# Save this script as r_database.R