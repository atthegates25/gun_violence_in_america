
function(input, output, session) {

  ########################################################################################################################  
  ######## CALENDAR PLOT START
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

    if (input$cal_plot_rm_outliers) {
      pctile_value = input$cal_plot_outl_cap/100
    } else {
      pctile_value = 1
    }
    
    if (cal_plot_column() == 'tot_kill_per_1m') {
      gv_data_disp %>% 
        group_by(., date=Date, State_ID, CD_ID) %>% 
        summarise(., tot_killed=sum(n_killed), n_incidents=n(), Population=mean(Pop)) %>% 
        group_by(., date) %>% 
        summarise(., tot_kill_per_1m=(sum(tot_killed)/sum(Population))*1000000,num_incidents=sum(n_incidents)) %>%
        filter(., tot_kill_per_1m <= quantile(tot_kill_per_1m, pctile_value))
    } else {
      gv_data_disp %>% 
        group_by(., date=Date, State_ID, CD_ID) %>% 
        summarise(., tot_killed=sum(n_killed), n_incidents=n(), Population=mean(Pop)) %>% 
        group_by(., date) %>% 
        summarise(., tot_kill_per_1m=(sum(tot_killed)/sum(Population))*1000000,num_incidents=sum(n_incidents)) %>%
        filter(., num_incidents <= quantile(num_incidents, pctile_value))
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
  ######## CALENDAR PLOT END
  ########################################################################################################################  

  #_______________________________________________________________________________________________________________________
  #_______________________________________________________________________________________________________________________
  
  ########################################################################################################################  
  ######## CONGRESSIONAL DISTRICT MAP START
  ########################################################################################################################  
  
  
  gv_summary = reactive({
    gv_data %>% filter(., Year==input$CD_Map_Year_CheckGroup) %>% group_by(., State_ID, CD_ID, Party) %>% summarise(., tot_killed=sum(n_killed_per_100k))
  })

  map_data_app = reactive({
    merge(map_data(), gv_summary(), by=c('State_ID', 'CD_ID'), all.x=T) %>% arrange(., Party, State_ID, CD_ID, Order)
  })

  cd_map_data = reactive({
    switch(input$cd_map_year,
           '2014'=cd_map_2014, '2015'=cd_map_2015, '2016'=cd_map_2016,'2017'=cd_map_2017)
  })
  
  output$cd_map = renderPlot(

    #map_data_app$Party = as.factor(map_data_app$Party),
    ggplot(map_data_app(), aes(x=Long,y=Lat)) + 
      geom_polygon(aes(group=Group,fill=Party, alpha=tot_killed)) + 
      coord_map() +
      cd_map_color_scale + 
      theme_bw()
  )
}
