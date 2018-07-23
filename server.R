
function(input, output, session) {
  observe({
    cd_list = unique(state_cd_master[state_cd_master$State==input$CD_Map_Region_Lvl2,'CD_ID'])
    updateSelectizeInput(
      session, "CD_Map_Region_Lvl3",
      choices = cd_list)
  })

  output$cd_map = renderPlot(
    map_data = switch(input$CD_Map_Year_CheckGroup,
                     2014=cd_map_2014, 2015=cd_map_2015, 2016=cd_map_2016,2017=cd_map_2017),

    if (input$CD_Map_Region_Lvl1==1) {
      gv_summary = gv_data %>% filter(., Year==input$CD_Map_Year_CheckGroup) %>% group_by(., State_ID, CD_ID, Party) %>% summarise(., tot_killed=sum(n_killed_per_100k))
      map_data_app = merge(map_data, gv_summary, by=c('State_ID', 'CD_ID'), all.x=T) %>% arrange(., Party, State_ID, CD_ID, Order)
      
      #map2014_data_app$Party = as.factor(map2014_data_app$Party)
      ggplot(map_data_app, aes(x=Long,y=Lat)) + 
        geom_polygon(aes(group=Group,fill=Party, alpha=tot_killed)) + 
        coord_map() +
        cd_map_color_scale + 
        theme_bw()
    }
  )
}
