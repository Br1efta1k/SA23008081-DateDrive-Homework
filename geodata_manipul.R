#---------------------------------
#Script Name
#Purpose:homework8
#Author:  botaoyuan
#Email:  botaoyuan@foxmail.com
#Date:  2024/05/13  edit
#
#-------------------------------
cat("\014") #clears the console
rm(list = ls()) #remove all variables

# Load required libraries
library(sf)
library(terra)
library(raster)
library(elevatr)
library(dplyr)
library(gdistance)

# Full paths to shapefiles
doubs_river_path <- "/home/botaoyuan/doubs_river.shp"
doubs_point_path <- "/home/botaoyuan/doubs_point.shp"

# Load Doubs river shapefile
doubs_river <- st_read(doubs_river_path)

# Transform Doubs river to UTM coordinate system
doubs_river_utm <- st_transform(doubs_river, 32631)

# Create a 2-km buffer along the Doubs river
doubs_river_buff <- st_buffer(doubs_river_utm, dist = 2000)

# Get bounding box of the buffer
bbox <- st_bbox(doubs_river_buff)

# Download DEM based on the bounding box
elevation <- get_elev_raster(bbox, z = 10)

# Crop DEM by Doubs river buffer
doubs_dem_utm_cropped <- crop(elevation, doubs_river_buff)

# Mask DEM by Doubs river buffer
doubs_dem_utm_masked <- mask(doubs_dem_utm_cropped, doubs_river_buff)

# Compute slope
slope <- terrain(doubs_dem_utm_masked, opt = "slope")

# Compute catchment area
catchment_area <- area(doubs_dem_utm_masked)

# Extract values for points using terra::extract
doubs_pts <- st_read(doubs_point_path)
doubs_pts_utm <- st_transform(doubs_pts, 32631)

slope_values <- terra::extract(slope, doubs_pts_utm)
area_values <- terra::extract(catchment_area, doubs_pts_utm)

# Combine extracted values with point data
doubs_env_df <- cbind(doubs_pts_utm, slope_values, area_values)

# Convert to sf object
doubs_env_sf <- st_as_sf(doubs_env_df)

# Check if the file exists
if (file.exists("doubs_env.shp")) {
  # If the file exists, remove it
  file.remove("doubs_env.shp")
}
# Write the resulting sf object to shapefile
st_write(doubs_env_sf, "doubs_env.shp", overwrite = TRUE)

# Check if the file already exists
if (!file.exists("doubs_env.csv")) {
  # If the file does not exist, write the data frame to CSV
  write.csv(doubs_env_df, "doubs_env.csv", row.names = FALSE)
} else {
  # If the file exists, inform the user or handle the situation accordingly
  print("File 'doubs_env.csv' already exists. Set overwrite = TRUE to overwrite it.")
}