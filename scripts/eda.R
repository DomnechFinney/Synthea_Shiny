source('global.R')


# Age Distribution --------------------------------------------------------


hist(patients$age)


# Gender Distribution -----------------------------------------------------


table(patients$GENDER, useNA = "ifany")



# Disorder Distribution --------------------------------------------------


##create population by disorder
disorder_population = conditions %>%
  filter(grepl("(disorder)", DESCRIPTION, ignore.case = TRUE)) %>%
  group_by(DESCRIPTION) %>%
  summarise(disorder_pop = n_distinct(PATIENT))


print(disorder_population %>%
        arrange(desc(disorder_pop)), n=20)



# Medication Distribution -------------------------------------------------


##create population by medication
medication_population = medications %>%
  group_by(DESCRIPTION) %>%
  summarise(medication_pop = n_distinct(PATIENT))


print(medication_population %>%
        arrange(desc(medication_pop)), n=20)



# Trend in medical procedures over time. ----------------------------------




all_procedures <- procedures %>%
  mutate(start_date = as.Date(START),         
         year_month = floor_date(start_date, "month")) %>% 
  group_by(year_month) %>% 
  summarise(procedure_count = n()) %>%
  ungroup()

# Plot the trend
ggplot(all_procedures, aes(x = year_month, y = procedure_count)) +
  geom_line(color = "skyblue", size = 1.2) +
  geom_point(color = "darkblue", size = 2) +
  labs(title = "Trend of Procedures Over Time",
       x = "Month",
       y = "Unique Patient Count") +
  theme_minimal(base_size = 14) +  
  theme(axis.text.x = element_text(angle = 45, hjust = 1))




# Identify top 5 most common descriptions
top_procedures <- procedures %>%
  count(DESCRIPTION, sort = TRUE) %>%  
  slice_head(n = 5) %>%                 
  pull(DESCRIPTION)                   


by_procedure <- procedures %>%
  filter(DESCRIPTION %in% top_procedures) %>%
  mutate(start_date = as.Date(START),
         year = floor_date(start_date, "year")) %>%
  group_by(year, DESCRIPTION) %>%
  summarise(procedure_count = n()) %>%
  ungroup()

p = ggplot(by_procedure,
           aes(x = year,
               y = procedure_count,
               color = as.factor(DESCRIPTION))) +
  geom_line(size = 1.2) +
  labs(title = "Trend of Procedures by Reasoncode Over Time",
       x = "Year", y = "Frequency / year", color = "Procedure Name")
ggplotly(p)






# Filter and identify top 5 most common descriptions
top_reasons <- procedures %>%
  filter(!is.na(REASONDESCRIPTION)) %>%
  count(REASONDESCRIPTION, sort = TRUE) %>%  # Count occurrences of each description
  slice_head(n = 5) %>%                      # Select the top 5 descriptions
  pull(REASONDESCRIPTION)                    # Extract the names of the top 5


trend_data_reason <- procedures %>%
  filter(REASONDESCRIPTION %in% top_reasons) %>%
  mutate(start_date = as.Date(START),          # Convert `start` to Date format
         year = floor_date(start_date, "year")) %>%  # Group by month
  group_by(year, REASONDESCRIPTION) %>%
  summarise(procedure_count = n()) %>%
  ungroup()

p = ggplot(trend_data_reason,
       aes(x = year,
           y = procedure_count,
           color = as.factor(REASONDESCRIPTION))) +
  geom_line(size = 1.2) +
  labs(title = "Trend of Procedures by Reasoncode Over Time",
       x = "Year", y = "Frequency / year", color = "Procedure Name") #+
  # theme_minimal(base_size = 14) %>%
  ggplotly(p)


#Disorder by Gender
table(Patient_conditions$DESCRIPTION,
      Patient_conditions$GENDER)



# Statistical Analysis ----------------------------------------------------

##INCOME
summary(patients$INCOME)
sd(patients$INCOME)
boxplot(patients$INCOME, 
        main = "Boxplot of Income", 
        ylab = "Value", 
        col = "lightblue", 
        border = "blue")
# high positively skewed data with some large value outliers.
hist(patients$INCOME)

boxplot(patients$INCOME[patients$INCOME<400000], 
        main = "Boxplot of Income, removing outlier", 
        ylab = "Value", 
        col = "lightblue", 
        border = "blue")
hist(patients$INCOME[patients$INCOME<400000])
# still positively skewed, bimodal normal distribution under 400k income.



## Age
summary(patients$age)
sd(patients$age)
boxplot(patients$age, 
        main = "Boxplot of Age", 
        ylab = "Value", 
        col = "lightblue", 
        border = "blue")
hist(patients$age)
# appears to be bimodal normal distribution


## encounters
summary(Patient_encounters$count)
sd(Patient_encounters$count)

hist(Patient_encounters$count)
boxplot(Patient_encounters$count, 
        main = "Boxplot of Encounter count", 
        ylab = "Value", 
        col = "lightblue", 
        border = "blue")
# Highly positively skewed data
# Would be poison distribution

hist(Patient_encounters$count[Patient_encounters$count<125])
boxplot(Patient_encounters$count[Patient_encounters$count<125], 
        main = "Boxplot of Encounter count", 
        ylab = "Value", 
        col = "lightblue", 
        border = "blue")
# Still positively skewed data under 125. 
