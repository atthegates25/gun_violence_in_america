

fluidPage(
  navbarPage(
    'Gun Violence in America: 2014-2017',
    tabPanel(
      'Calendar Plot',
      sidebarLayout(
        sidebarPanel(
          width=2,

          # allow user to choose metric to display
          radioButtons(
            "cal_plot_stat", label = h3("Statistic"),
            choices = list("Deaths" = 1, "Incidents" = 2), selected = 1),           
          
          # allow user to select the geographic area for which to display the data
          selectInput(
            'Cal_Plot_Region_Lvl1', label=h4('Geographic Region'), 
            choices=list('Country'=1, 'State'=2, 'Congressional District'=3)),

          # if user chooses to display the results at the State or Congressional District level, show appropriate dropdowns
          # show drop down for State if applicable
          conditionalPanel(
            condition = 'input.Cal_Plot_Region_Lvl1 > 1',
            selectInput('Cal_Plot_Region_Lvl2', label=h4('State'), choices=state_names, selected=state_names[1]),
            
            # show drop down for Congressional District if applicable
            conditionalPanel(
              condition = 'input.Cal_Plot_Region_Lvl1 == 3',
              selectInput('Cal_Plot_Region_Lvl3', label=h4('Congressional District'), choices=NULL))
          ),
          
          # allow user to remove outliers
          checkboxInput("cal_plot_rm_outl", label = "Remove Outliers", value = FALSE)
        ),
        mainPanel(
          titlePanel(h1(uiOutput('cal_plot_header'), align='center')),
          fluidRow(
            column(6, plotOutput("cal_plot_2014")),
            column(6, plotOutput("cal_plot_2015"))
          ),
          fluidRow(
            column(6, plotOutput("cal_plot_2016")),
            column(6, plotOutput("cal_plot_2017"))
          )
        )
      )
    ),
    tabPanel(
      'Congressional District Map',
      sidebarLayout(
        sidebarPanel(
          width=2,
          
          # allow user to select the year for which to display the data
          sliderInput("cd_map_year", label = h3("Year"), min = 2014,
                      max = 2017, step = 1, value = 2014, ticks = F, sep='',
                      animate = animationOptions(interval = 2000, loop = FALSE, playButton = NULL,
                                                 pauseButton = NULL))
        ),
        mainPanel(
          titlePanel(h1(uiOutput('cd_map_header'), align='center')),
          fluidRow(
            column(12, plotOutput("cd_map", height='600px'))
          )
        )
      )
    )
  )
)