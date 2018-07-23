

fluidPage(
  navbarPage('Gun Violence in America: 2014-2017',
             tabPanel('Summary Statistics'),
             tabPanel('Calendar Map'),
             tabPanel('Congressional District Map',
                      sidebarLayout(
                        sidebarPanel(
                          #checkboxGroupInput('CD_Map_Year_CheckGroup', label = h4('Select years to display'),
                          selectInput('CD_Map_Year_CheckGroup', label = h4('Select years to display'),
                                             choices=c(2014, 2015, 2016, 2017)),
                          selectInput('CD_Map_Region_Lvl1', label=h4('Geographic Region'), 
                                      choices=list('Country'=1, 'State'=2, 'Congressional District'=3)),
                          conditionalPanel(
                            condition = 'input.CD_Map_Region_Lvl1 > 1',
                            selectInput('CD_Map_Region_Lvl2', label=h4('State'), 
                                        choices=state_names,
                                        selected=state_names[1]),
                            conditionalPanel(
                              condition = 'input.CD_Map_Region_Lvl1 == 3',
                              #replace with renderUI output?
                              selectInput('CD_Map_Region_Lvl3', label=h4('Congressional District'), choices=NULL)
                            )
                          )
                      ),
                        mainPanel(
                          'main panel',
                          plotOutput("cd_map")
                        )
                      ))
  )
  
)