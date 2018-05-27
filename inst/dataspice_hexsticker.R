#hexsticker
library(hexSticker)
library(emojifont)
library(grid)
library(png)
img <- readPNG("inst/hex/32364-hot-pepper-icon.png")

g <- rasterGrob(img, interpolate=TRUE)

plot1 <- ggplot() + 
  annotation_custom(g, xmin=-Inf, xmax=Inf, 
                    ymin=-Inf, ymax=Inf) +
  theme(plot.background = element_blank(),
        panel.background = element_blank())

p.1 <- sticker(plot1,
               package="dataspice", 
               s_x = 1, # horizontal position of subplot
               s_y = 1.1, # vertical position of subplot
               s_width = 1, # width of subplot
               s_height = 1, # height of subplot
               p_x = 1, # horizontal position of font
               p_y = .53, # vertical position of font
               p_size = 10, # font size
               p_color = "#000000", # font colour
               h_size = 7, # hexagon border size
               h_fill = "white", # hexagon fill colour
               h_color = "red",
               filename = "inst/hex/hex.jpg") # hexagon border colour
