
# Load packages -----------------------------------------------------------

library(here)
library(tidyverse)
library(sf)
library(ggforce)



# Functions ---------------------------------------------------------------

# Get roundness of polygon (1 is a perfect circle)
get_roundness <- function(area, perimeter) {
  (4 * pi * area) / perimeter^2
}



# Read data ---------------------------------------------------------------

# Read coordinates
cat_polygon <- 
  read_csv(here("data/round_cat.csv")) |> 
  st_as_sf(coords = c("x", "y")) |> 
  summarize(geometry = st_combine(geometry)) |> 
  st_cast("POLYGON") 

# Read image
cat_img <- 
  image_read("figs/round_cat.png") |> 
  image_raster(tidy = F)



# Calculate measurements --------------------------------------------------

# Area
cat_sf_area <- 
  cat_polygon |> 
  st_area()

# Perimeter
cat_sf_perimeter <- 
  cat_polygon |> 
  st_perimeter()

# Center
cat_sf_center <- 
  cat_polygon |> 
  st_centroid()

# Inscribed circle
cat_sf_inscribed <- 
  cat_polygon |> 
  st_geometry() |> 
  st_inscribed_circle(nQuadSegs = 100)

# Circumscribed circle
cat_sf_circumscribed <- 
  cat_polygon |> 
  st_geometry() |> 
  st_minimum_bounding_circle(nQuadSegs = 1e6)

# Roundness (ratio between circle radii)
cat_sf_roundness <- 
  sqrt(st_area(cat_sf_inscribed[1]) / pi) / 
  sqrt(st_area(cat_sf_circumscribed) / pi)



# Plot data ---------------------------------------------------------------

# Cat with ISO roundness circles
ggplot() +
  annotation_raster(cat_img, xmin = 0, xmax = 1000, ymin = 0, ymax = 1000) +
  geom_sf(data = cat_sf_inscribed, 
          color = "white", linewidth = 1.5) +
  geom_sf(data = cat_sf_inscribed, 
          color = "black", linewidth = .75, linetype = 2) +
  geom_sf(data = cat_sf_circumscribed, 
          color = "white", linewidth = 1.5) +
  geom_sf(data = cat_sf_circumscribed, 
          color = "black", linewidth = .75, linetype = 2) +
  scale_x_continuous(limits = c(0, 1000)) +
  scale_y_continuous(limits = c(0, 1000)) +
  coord_sf() +
  theme_void()

ggsave(here("figs/cat_ratio.png"), width = 5, height = 5, units = "in")
