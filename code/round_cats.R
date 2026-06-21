
# Load packages -----------------------------------------------------------

library(here)
library(tidyverse)
library(ggforce)
library(magick)
library(pracma)


# Functions ---------------------------------------------------------------

# Get roundness of polygon (1 is a perfect circle)
get_roundness <- function(area, perimeter) {
  (4 * pi * area) / perimeter^2
}

# Get Euclidean distance between 2D points
euc_dist <- function(x1, x2, y1, y2) {
  sqrt((x2 - x1)^2 + (y2 - y1)^2)
}



# Read data ---------------------------------------------------------------

# Read image
cat_img <- 
  image_read("figs/round_cat.png") |> 
  image_raster(tidy = F)

# Read cat polygon coordinates
cat_coords <- 
  read_csv("data/round_cat.csv")



# Calculate metrics -------------------------------------------------------

# Area
cat_area <- 
  abs(polyarea(cat_coords$x, cat_coords$y))

# Perimeter
cat_perimeter <- 
  sum(
    euc_dist(
      cat_coords$x[1:57], 
      cat_coords$x[2:58], 
      cat_coords$y[1:57], 
      cat_coords$y[2:58]
      )
    )

# Polygon center
cat_center <- 
  poly_center(cat_coords$x, cat_coords$y)

# Roundness
cat_roundness <- 
  get_roundness(cat_area, cat_perimeter)

# Mean radius from center
cat_radius <- 
  mean(
    euc_dist(cat_coords$x, 
             cat_center[1],
             cat_coords$y, 
             cat_center[2])
  )

# Perfect circle of equal area to cat polygon
perfect_circle <- 
  tibble(x = cat_center[1],
         y = cat_center[2],
         r = sqrt(cat_area / pi))



# Plot roundness ----------------------------------------------------------

# Cat polygon
cat_coords |> 
  ggplot() +
  annotation_raster(cat_img, xmin = 0, xmax = 1000, ymin = 0, ymax = 1000) +
  geom_polygon(aes(x, y), 
               color = "gold", fill = NA, linewidth = 1) +
  scale_x_continuous(limits = c(0, 1000)) +
  scale_y_continuous(limits = c(0, 1000)) +
  coord_equal() +
  theme_void()

ggsave(here("figs/cat.png"), width = 5, height = 5, units = "in")


# Cat polygon with midpoint
cat_coords |> 
  ggplot() +
  annotation_raster(cat_img, xmin = 0, xmax = 1000, ymin = 0, ymax = 1000) +
  annotate("point", x = cat_center[1], y = cat_center[2], 
           color = "gold", size = 3) +
  geom_polygon(aes(x, y), 
               color = "gold", fill = NA, linewidth = 1) +
  scale_x_continuous(limits = c(0, 1000)) +
  scale_y_continuous(limits = c(0, 1000)) +
  coord_equal() +
  theme_void()

ggsave(here("figs/cat_midpoint.png"), width = 5, height = 5, units = "in")


# Cat polygon with perfect circle
cat_coords |> 
  ggplot() +
  annotation_raster(cat_img, xmin = 0, xmax = 1000, ymin = 0, ymax = 1000) +
  annotate("point", x = cat_center[1], y = cat_center[2], 
           color = "white", size = 3) +
  geom_polygon(aes(x, y), 
               color = "gold", fill = NA, linewidth = 1) +
  geom_circle(data = perfect_circle, aes(x0 = x, y0 = y, r = r), 
              color = "white", linewidth = 1, linetype = 2) +
  annotate("segment", 
           x = cat_center[1], xend = cat_center[1], 
           y = cat_center[2], yend = cat_center[2] + cat_radius,
           color = "white", linetype = 3) +
  annotate("segment", 
           x = cat_center[1], xend = cat_center[1] + cat_radius, 
           y = cat_center[2], yend = cat_center[2],
           color = "white", linetype = 3) +
  scale_x_continuous(limits = c(0, 1000)) +
  scale_y_continuous(limits = c(0, 1000)) +
  coord_equal() +
  theme_void()

ggsave(here("figs/cat_overlay.png"), width = 5, height = 5, units = "in")


# Cat with perfect circle
cat_coords |> 
  ggplot() +
  annotation_raster(cat_img, xmin = 0, xmax = 1000, ymin = 0, ymax = 1000) +
  geom_circle(data = perfect_circle, aes(x0 = x, y0 = y, r = r), 
              color = "white", linewidth = 2, linetype = 1) +
  scale_x_continuous(limits = c(0, 1000)) +
  scale_y_continuous(limits = c(0, 1000)) +
  coord_equal() +
  theme_void()

ggsave(here("figs/cat_perfect.png"), width = 5, height = 5, units = "in")
