#hexsticker
library(hexSticker)
library(grid)
library(png)
library(emojifont)
library(tidyverse)
img <- readPNG("inst/hex/32364-hot-pepper-icon.png")

g <- rasterGrob(img, interpolate=TRUE)

dat <- data.frame(a=c(0,0.5,1,1.5,2), b=c(2,1.5,1,0.5,0))

plot1 <- ggplot()+
  geom_point(data=mtcars, aes(x=mpg,y=disp))+
  geom_line(data=mtcars, aes(x=mpg, y=disp))+
  geom_smooth(data=mtcars, aes(x=mpg, y=disp))+
  annotation_custom(g, xmin=-Inf, xmax=Inf, 
                    ymin=-Inf, ymax=Inf)+
  theme(panel.background = element_rect(fill=NA),
        panel.grid.major = element_line(color="black"),
        panel.grid.minor = element_line(color="black"),
        axis.title = element_blank(),
        axis.text = element_blank())


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


