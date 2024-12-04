fluidPage(
    titlePanel("Synthea Demo"),
    
    sidebarLayout(
        sidebarPanel(
            h4("Filters"),
            conditionalPanel("input.TABS=='Medication_treament'",
                             selectInput('Treaments',
                                         choices = sort(unique(na.omit(medications$REASONDESCRIPTION))),
                                         label = "Treament"
                                         )
                             ),
            conditionalPanel("input.TABS=='Procedure_disorder'",
                             selectInput('Disorder',
                                         choices = sort(unique(na.omit(procedures$REASONDESCRIPTION))),
                                         label = "Disorder"
                                         )
                             ),
            conditionalPanel("input.TABS=='Riskfactor_disorder'",
                             selectInput('Disorder_enc',
                                         choices = sort(unique(na.omit(encounters$REASONDESCRIPTION))),
                                         label = "Encounter reason")
                             ),
            conditionalPanel("input.TABS=='map'",
                             selectInput('Encounter_reason',
                                         choices = sort(unique(na.omit(encounters$DESCRIPTION))),
                                         label = "Encounter reason"
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
                         title = "Common procedure for disorder",
                         tableOutput("proced_disorder")
                         )
                ,
                tabPanel(value = "Riskfactor_disorder",
                         title = "Common encounters prior to disorder",
                         tableOutput("prior_encounter_disorder")
                )
                ,
                tabPanel(value = "map",
                         title = "Home address of Patient",
                         leafletOutput("map")
                )
            )
        )
    )
)