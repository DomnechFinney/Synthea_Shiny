
function(input, output, session) {
    
    medication_by_treatment_react = reactive({
        medications %>%
            filter(REASONDESCRIPTION == input$Treaments)
        
    })
    procedure_by_treatment_react = reactive({
        procedures %>%
            filter(REASONDESCRIPTION == input$Disorder)
        
    })
    
    
    
    # Common medication by disorder
    output$med_disorder <- renderTable({
        medication_by_treatment_react() %>%
            group_by(DESCRIPTION) %>%
            summarise(Medication = n()) %>%
            arrange(desc(Medication))
    })
    
    # Common procedure by disorder
    output$proced_disorder <- renderTable({
        procedure_by_treatment_react() %>%
            group_by(DESCRIPTION) %>%
            summarise(Procedures = n()) %>%
            arrange(desc(Procedures))
        
    })
    
    
    paient_diagnosis_first_date <- reactive({
        encounters %>%
            filter(REASONDESCRIPTION == input$Disorder_enc) %>%
            group_by(PATIENT) %>%
            arrange(START_POSIX) %>%
            slice(1) %>%
            select(PATIENT, diagnosis_date = START_POSIX)

    })
    encounters_prior_to_diagnosis <- reactive({
        
        
        temp1 = encounters %>%
            left_join(.,
                      paient_diagnosis_first_date(),
                      by=c("PATIENT"="PATIENT"))
        
        temp2 = temp1 %>%
            filter(START_POSIX<diagnosis_date) %>%
            group_by(DESCRIPTION) %>%
            summarise(Encounter_reason= n()) %>%
            arrange(desc(Encounter_reason))

    })
    
    # Common encounter reasons prior to diagnosis
    output$prior_encounter_disorder <- renderTable({
        # paient_diagnosis_first_date()
        encounters_prior_to_diagnosis()
    })
    
    
    
    output$map = renderLeaflet({
        dynamic_encounter_data = encounter_patient %>%
            filter(DESCRIPTION == input$Encounter_reason) %>%
            mutate(count = 1)
        
        
        leaflet(dynamic_encounter_data
                ) %>%
            addProviderTiles("CartoDB.Positron") %>%  # Base map
            addHeatmap(
                lng = ~LON, 
                lat = ~LAT, 
                intensity = ~count,  # Use `count` for heat intensity
                blur = 20,           # Blurring of points
                max = 1,            # Maximum intensity
                radius = 15          # Radius of each point
            )
    })
    
}