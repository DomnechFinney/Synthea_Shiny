fluidPage(
    titlePanel("Synthea Demo"),
    
    sidebarLayout(
        sidebarPanel(
            h4("Filters"),
            conditionalPanel("input.TABS=='Medication_treament'",
                             selectInput('Treaments',
                                         choices = sort(unique(na.omit(medications$REASONDESCRIPTION))),
                                         label = "Disorder"
                                         )
                             ),
            conditionalPanel("input.TABS=='Procedure_disorder'",
                             selectInput('Disorder',
                                         choices = sort(unique(na.omit(procedures$REASONDESCRIPTION))),
                                         label = "Cause of procedure"
                                         )
                             ),
            conditionalPanel("input.TABS=='Riskfactor_disorder'",
                             selectInput('Disorder_enc',
                                         choices = sort(unique(na.omit(encounters$REASONDESCRIPTION))),
                                         label = "condition of interest")
                             ),
            conditionalPanel("input.TABS=='map'",
                             selectInput('Encounter_reason',
                                         choices = sort(unique(na.omit(encounters$DESCRIPTION))),
                                         label = "Encounter description"
                             )
            )
        ),
        
        mainPanel(
            tabsetPanel(id = "TABS", 
                tabPanel(value = "Medication_treament",
                         title = "Common medications for disorder",
                         tableOutput("med_disorder")
                         ),
                tabPanel(value = "Procedure_disorder",
                         title = "Common procedures as treatment",
                         plotOutput("proced_disorder")
                         )
                ,
                tabPanel(value = "Riskfactor_disorder",
                         title = "Common encounters prior to first diagnosed",
                         tableOutput("prior_encounter_disorder")
                )
                ,
                tabPanel(value = "map",
                         title = "Home address of Patient",
                         leafletOutput("map", height = 800)
                )
            )
        )
    )
)