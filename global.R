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
#cd_map_states = 

map_colors = c('blue','red','green')
names(map_colors) = c('D','R','UR')
cd_map_color_scale = scale_fill_manual(name = "Party",values = map_colors)

gv_cal_data = gv_data %>% group_by(., date=Date) %>% summarise(., tot_killed=sum(n_killed), n_incidents=n())

gv_year_state = gv_data %>% 
  group_by(., Year, State) %>% 
  summarise(., tot_shootings=n(), 
            tot_killed=sum(n_killed), 
            tot_injured=sum(n_injured),
            tot_participants=sum(n_participants),
            tot_victims=sum(n_victims),
            tot_suspects=sum(n_suspects))


