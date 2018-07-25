library(shiny)
library(data.table)
library(tidyverse)
library(openair)
library(stats)

gv_data = data.frame(fread('./data/gv_data_final.txt'))
gv_data$Date = as.POSIXct(gv_data$Date, format='%Y-%m-%d',tz='UTC')
cd_map_2014 = data.frame(fread('./data/cd_map_2014.txt'))
cd_map_2015 = data.frame(fread('./data/cd_map_2015.txt'))
cd_map_2016 = data.frame(fread('./data/cd_map_2016.txt'))
cd_map_2017 = data.frame(fread('./data/cd_map_2017.txt'))
state_cd_master = data.frame(fread('./data/state_cd_master.txt'))
state_names = unique(state_cd_master$State)

map_colors = c('blue','red','green')
names(map_colors) = c('D','R','UR')
cd_map_color_scale = scale_fill_manual(name = "Party",values = map_colors)

