

fluidPage(
  navbarPage('Gun Violence in America: 2014-2017',
             tabPanel('Summary Statistics'),
             tabPanel('Calendar Map',
                      sidebarLayout(
                        sidebarPanel(width=2, 
                                     radioButtons("cal_map_stat", label = h3("Statistic"),
                                                  choices = list("Deaths" = 1, "Incidents" = 2), 
                                                  selected = 1),           
                                     selectInput('Cal_Map_Region_Lvl1', label=h4('Geographic Region'), 
                                                 choices=list('Country'=1, 'State'=2, 'Congressional District'=3)),
                                     conditionalPanel(condition = 'input.Cal_Map_Region_Lvl1 > 1',
                                                      selectInput('Cal_Map_Region_Lvl2', label=h4('State'),
                                                                  choices=state_names,
                                                                  selected=state_names[1]),
                                                      conditionalPanel(
                                                        condition = 'input.Cal_Map_Region_Lvl1 == 3',
                                                        selectInput('Cal_Map_Region_Lvl3', label=h4('Congressional District'), choices=NULL)
                                                        )
                                                      )
                                     ),
                        mainPanel(
                          titlePanel(h1(uiOutput('cal_map_header'), align='center')),
                          fluidRow(
                            column(6, plotOutput("cal_2014_map")),
                            column(6, plotOutput("cal_2015_map"))
                          ),
                          fluidRow(
                            column(6, plotOutput("cal_2016_map")),
                            column(6, plotOutput("cal_2017_map"))
                          )
                        )
                      )),
             tabPanel('Congressional District Map',
                      sidebarLayout(
                        sidebarPanel(width=2,
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
                          'main panel'
                          #plotOutput("cal_2014_map")
                        )
                      )
              )
             
  )
  
)