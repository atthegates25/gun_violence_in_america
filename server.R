
function(input, output, session) {
  
  # update list of available Congressional Districts if applicable
  observe({
    cal_map_cd_list = unique(state_cd_master[state_cd_master$State==input$Cal_Map_Region_Lvl2,'CD_ID'])
    updateSelectizeInput(
      session, "Cal_Map_Region_Lvl3",
      choices = cal_map_cd_list)
  })
  output$cal_map_header = renderUI({
    if (input$cal_map_stat=='1') {
      prefix = 'Number of Deaths per 1m Residents for '
    } else {
      prefix = 'Number of Incidents for '
    }
    if (input$Cal_Map_Region_Lvl1==1) {
      suffix = 'the United States'
    } else {
      if (input$Cal_Map_Region_Lvl1==2) {
        suffix = input$Cal_Map_Region_Lvl2
      } else {
        suffix = paste(input$Cal_Map_Region_Lvl2,'\'s District ', input$Cal_Map_Region_Lvl3, sep='')
      }
    }
    paste(prefix,suffix,sep='')
  })
  map_data = reactive({
    switch(input$CD_Map_Year_CheckGroup,
           '2014'=cd_map_2014, '2015'=cd_map_2015, '2016'=cd_map_2016,'2017'=cd_map_2017)
  })
  cal_map_column = reactive({
    switch(input$cal_map_stat,'1'='tot_kill_per_1m', '2'='num_incidents')
  })
  #update data used for calendar map based on user inputs
  cal_map_data_set = reactive({
    if (input$Cal_Map_Region_Lvl1==1) { # by country
      gv_data_disp = gv_data
    } else {
      if (input$Cal_Map_Region_Lvl1==2) { # by state
        gv_data_disp = gv_data %>% filter(., State==input$Cal_Map_Region_Lvl2)
      } else { # by congressional district
        gv_data_disp = gv_data %>% filter(., State==input$Cal_Map_Region_Lvl2 & CD_ID==input$Cal_Map_Region_Lvl3)
      }
    }
    gv_data_disp %>% 
      group_by(., date=Date, State_ID, CD_ID) %>% 
      summarise(., tot_killed=sum(n_killed), n_incidents=n(), Population=mean(Pop)) %>% 
      group_by(., date) %>% 
      summarise(., tot_kill_per_1m=(sum(tot_killed)/sum(Population))*1000000,num_incidents=sum(n_incidents))
  })
  output$cal_2014_map = renderPlot(
    calendarPlot(cal_map_data_set(), pollutant = cal_map_column(), year = 2014,  cols = c('white','pink', 'red'), main='2014', w.shift=1)
  )
  output$cal_2015_map = renderPlot(
    calendarPlot(cal_map_data_set(), pollutant = cal_map_column(), year = 2015,  cols = c('white','pink', 'red'), main='2015', w.shift=1)
  )
  output$cal_2016_map = renderPlot(
    calendarPlot(cal_map_data_set(), pollutant = cal_map_column(), year = 2016,  cols = c('white','pink', 'red'), main='2016', w.shift=1)
  )
  output$cal_2017_map = renderPlot(
    calendarPlot(cal_map_data_set(), pollutant = cal_map_column(), year = 2017,  cols = c('white','pink', 'red'), main='2017', w.shift=1)
  )
  
  gv_summary = reactive({
    gv_data %>% filter(., Year==input$CD_Map_Year_CheckGroup) %>% group_by(., State_ID, CD_ID, Party) %>% summarise(., tot_killed=sum(n_killed_per_100k))
  })

  map_data_app = reactive({
    merge(map_data(), gv_summary(), by=c('State_ID', 'CD_ID'), all.x=T) %>% arrange(., Party, State_ID, CD_ID, Order)
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
