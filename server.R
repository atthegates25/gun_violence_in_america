
function(input, output, session) {

  ########################################################################################################################  
  ######## CALENDAR PLOT
  ########################################################################################################################  
  
  # update list of available Congressional Districts for calendar plot if applicable
  observe({
    cal_plot_cd_list = unique(state_cd_master[state_cd_master$State==input$Cal_Plot_Region_Lvl2,'CD_ID'])
    updateSelectizeInput(
      session, "Cal_Plot_Region_Lvl3",
      choices = cal_plot_cd_list)
  })

  # update calendar plot section title as needed
  output$cal_plot_header = renderUI({
    if (input$cal_plot_stat=='1') {
      prefix = 'Number of Deaths per 1m Residents in '
    } else {
      prefix = 'Number of Incidents in '
    }
    if (input$Cal_Plot_Region_Lvl1==1) {
      suffix = 'the United States'
    } else {
      if (input$Cal_Plot_Region_Lvl1==2) {
        suffix = input$Cal_Plot_Region_Lvl2
      } else {
        suffix = paste(input$Cal_Plot_Region_Lvl2,' District ', input$Cal_Plot_Region_Lvl3, sep='')
      }
    }
    paste(prefix,suffix,sep='')
  })
  
  # update column to use based on user's chosen statistic
  cal_plot_column = reactive({
    switch(input$cal_plot_stat,'1'='tot_kill_per_1m', '2'='num_incidents')
  })

  #update data set used for calendar map based on user inputs
  cal_plot_data_set = reactive({
    if (input$Cal_Plot_Region_Lvl1==1) { # by country
      gv_data_disp = gv_data
    } else {
      if (input$Cal_Plot_Region_Lvl1==2) { # by state
        gv_data_disp = gv_data %>% filter(., State==input$Cal_Plot_Region_Lvl2)
      } else { # by congressional district
        gv_data_disp = gv_data %>% filter(., State==input$Cal_Plot_Region_Lvl2 & CD_ID==input$Cal_Plot_Region_Lvl3)
      }
    }

    if (input$cal_plot_rm_outl) {
      pctile_level = .999
    } else {
      pctile_level = 1
    }

    if (cal_plot_column() == 'tot_kill_per_1m') {
      gv_data_disp %>% 
        group_by(., date=Date, State_ID, CD_ID) %>% 
        summarise(., tot_killed=sum(n_killed), n_incidents=n(), Population=mean(Pop)) %>% 
        group_by(., date) %>% 
        summarise(., tot_kill_per_1m=(sum(tot_killed)/sum(Population))*1000000,num_incidents=sum(n_incidents)) %>%
        filter(., tot_kill_per_1m <= quantile(tot_kill_per_1m, pctile_level))
    } else {
      gv_data_disp %>% 
        group_by(., date=Date, State_ID, CD_ID) %>% 
        summarise(., tot_killed=sum(n_killed), n_incidents=n(), Population=mean(Pop)) %>% 
        group_by(., date) %>% 
        summarise(., tot_kill_per_1m=(sum(tot_killed)/sum(Population))*1000000,num_incidents=sum(n_incidents)) %>%
        filter(., num_incidents <= quantile(num_incidents, pctile_level))
    }
  })

  # update maximum for shading scale of calendar map based on user inputs
  cal_plot_shade_scale = reactive({
    max_value = cal_plot_data_set() %>% select(., cal_plot_column()) %>% max(.)
    min_value = 0
    c(min_value, max_value)
  })
    
  # update 2014 calendar plot
  output$cal_plot_2014 = renderPlot(
    calendarPlot(cal_plot_data_set(), pollutant = cal_plot_column(), year = 2014,  cols = c('white','pink', 'red'), main='2014', w.shift=1, limits=cal_plot_shade_scale())
  )
  # update 2015 calendar plot
  output$cal_plot_2015 = renderPlot(
    calendarPlot(cal_plot_data_set(), pollutant = cal_plot_column(), year = 2015,  cols = c('white','pink', 'red'), main='2015', w.shift=1, limits=cal_plot_shade_scale())
  )
  # update 2016 calendar plot
  output$cal_plot_2016 = renderPlot(
    calendarPlot(cal_plot_data_set(), pollutant = cal_plot_column(), year = 2016,  cols = c('white','pink', 'red'), main='2016', w.shift=1, limits=cal_plot_shade_scale())
  )
  # update 2017 calendar plot
  output$cal_plot_2017 = renderPlot(
    calendarPlot(cal_plot_data_set(), pollutant = cal_plot_column(), year = 2017,  cols = c('white','pink', 'red'), main='2017', w.shift=1, limits=cal_plot_shade_scale())
  )
  
  ########################################################################################################################  
  ######## CONGRESSIONAL DISTRICT MAP
  ########################################################################################################################  

  # update CD Map  section title as needed
  output$cd_map_header = renderUI({
    paste('Number of Deaths per 1m Residents in ',as.character(input$cd_map_year),sep='')
  })

  # filter gv data based on user input
  gv_summary = reactive({
    gv_data %>% 
      filter(., Year==input$cd_map_year) %>% 
      group_by(., State_ID, CD_ID, Party) %>% 
      summarise(., tot_kill_per_1m=(sum(n_killed)/mean(Pop))*1000000)
  })

  # choose map data based on year selected
  cd_map_data = reactive({
    if (input$cd_map_year==2014) {
      cd_map_2014
    } else if (input$cd_map_year==2015) {
      cd_map_2015
    } else if (input$cd_map_year==2016) {
      cd_map_2016
    } else if (input$cd_map_year==2017) {
      cd_map_2017
    }
  })
  
  # merge gv and map data
  cd_map_data_app = reactive({
    merge(cd_map_data(), gv_summary(), by=c('State_ID', 'CD_ID'), all.x=T) %>% arrange(., Party, State_ID, CD_ID, Order)
  })

  # create map
  output$cd_map = renderPlot(

    ggplot(cd_map_data_app(), aes(x=Long,y=Lat)) + 
      geom_polygon(aes(group=Group,fill=Party, alpha=tot_kill_per_1m)) + 
      coord_map() +
      color_scale + 
      theme(line=element_blank(),
            axis.line = element_blank(),
            axis.text = element_blank(), 
            axis.title = element_blank(),
            panel.background = element_rect(fill='white')) +
      scale_alpha(guide='none')
  )
}
