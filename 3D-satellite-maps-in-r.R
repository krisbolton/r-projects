#  
# Visualise The Cullin, Isle of Skye, Scotland
# This code follows Tyle Morgan-Wall's tutorial on the subject
# I expanded on his tutorial to include instructions for people new to R and R Studio on Mac/Windows.
# See his tutorial at: https://www.tylermw.com/a-step-by-step-guide-to-making-3d-maps-with-satellite-imagery-in-r
# See my contribution at: https://krisbolton.com/3D-maps-with-satellite-imagery-in-r
#

# Install packages
install.packages(c("rayshader", "raster", "sp", "magick", "rgdal", "Rcpp"))

# Declare packages
library(rayshader)
library(sp)
library(raster)
library(scales)
library(magrittr)
library(magick)
library(rgdal)
library(Rcpp)

# Place the elevation data into two variables (the area of interest is within two grid areas).
elevation = raster::raster("~/Downloads/N57W006.hgt")
elevation2 = raster::raster("~/Downloads/N42W007.hgt")

# Merge elevation data into one variable
skye_elevation = raster::merge(elevation1, elevation2)
skypen_elevation = elevation

# Plot the elevation data (open the plots tab in R studio)
height_shade(raster_to_matrix(skye_elevation)) %>%
  plot_map()

# Red, green, blue color channel files for the satellite imagery downloaded in earlier steps
skye_r = raster::raster("~/Downloads/B4.TIF")
skye_g = raster::raster("~/Downloads/B3.TIF")
skye_b = raster::raster("~/Downloads/B2.TIF")

# Create rgb variable containing each channel
skye_rgb = raster::stack(skye_r, skye_g, skye_b)

# Render satellite image from skye_rgb variable
raster::plotRGB(skye_rgb, scale=255^2)

# Apply gamma to reduce the darkness of the resulting image
skye_rgb_corrected = sqrt(raster::stack(skye_r, skye_g, skye_b))

# Render corrected satellite image
raster::plotRGB(skye_rgb_corrected)

# View data about the red channel and elevation data
raster::crs(skye_r)
raster::crs(skye_elevation)
crs(skye_r)

# The coordinate system for the elevation and image data are not the same
# We transform the elevation data to UTM coordinates
skye_elevation_utm = raster::projectRaster(skye_elevation, crs = crs(skye_r), method = "bilinear")

# We store this transformed elevation data in a new variable
crs(skye_elevation_utm)

# Crop the image to the desired area of interest
bottom_left = c(y=-8.937782, x=41.099287)
top_right   = c(y=-8.314980, x=42.410606)

extent_latlong = sp::SpatialPoints(rbind(bottom_left, top_right), proj4string=sp::CRS("+proj=longlat +ellps=WGS84 +datum=WGS84"))
extent_utm = sp::spTransform(extent_latlong, raster::crs(skye_elevation_utm))

e = raster::extent(extent_utm)
e

# Crop the image and elevation data
skye_rgb_cropped = raster::crop(skye_rgb_corrected, e)
elevation_cropped = raster::crop(skye_elevation_utm, e)

names(skye_rgb_cropped) = c("r","g","b")

# Convert the elevation data to a matrix for the rayshader function
skye_r_cropped = rayshader::raster_to_matrix(skye_rgb_cropped$r)
skye_g_cropped = rayshader::raster_to_matrix(skye_rgb_cropped$g)
skye_b_cropped = rayshader::raster_to_matrix(skye_rgb_cropped$b)

skye_matrix = rayshader::raster_to_matrix(elevation_cropped)

skye_rgb_array = array(0,dim=c(nrow(skye_r_cropped),ncol(skye_r_cropped),3))

skye_rgb_array[,,1] = skye_r_cropped/255 #Red layer
skye_rgb_array[,,2] = skye_g_cropped/255 #Blue layer
skye_rgb_array[,,3] = skye_b_cropped/255 #Green layer

skye_rgb_array = aperm(skye_rgb_array, c(2,1,3))

# Render the new area
plot_map(skye_rgb_array)

# Increase the contrast to improve image quality
skye_rgb_contrast = scales::rescale(skye_rgb_array,to=c(0,1))

# Render improved contrast image
plot_map(skye_rgb_contrast)

# Generate the 3D model of the location
plot_3d(skye_rgb_contrast, skye_matrix, windowsize = c(1100,900), zscale = 15, shadowdepth = -50,
        zoom=0.5, phi=45,theta=-45,fov=70, background = "#F2E1D0", shadowcolor = "#523E2B")
render_snapshot(title_text = "Isle of Skye, United Kingdom | Imagery: Landsat 8 | DEM: 30m SRTM",
                title_bar_color = "#1f5214", title_color = "white", title_bar_alpha = 1)

