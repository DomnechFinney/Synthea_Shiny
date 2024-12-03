library(tidyverse)

# Medications --------------------------------------------------------------

medications <- read_csv("data/medications.csv", 
                        col_types = cols(START = col_character(), 
                                         STOP = col_character(),
                                         CODE = col_integer(), 
                                         BASE_COST = col_number(),
                                         PAYER_COVERAGE = col_number(), 
                                         DISPENSES = col_integer(),
                                         TOTALCOST = col_number(), 
                                         REASONCODE = col_integer()))
sort(sapply(medications, function(x) sum(is.na(x))),decreasing = F)
# STOP       REASONCODE  REASONDESCRIPTION 
# 245              1271              1271 
duplicates <- medications[duplicated(medications), ]
nrow(duplicates) #0

#check CODE is primary key
duplicates <- medications[duplicated(medications$CODE), ] 
nrow(duplicates) #5489
# Code is not primary key, need to use Start and End Time when joining.


# Encounters --------------------------------------------------------------

encounters <- read_csv("data/encounters.csv", 
                       col_types = cols(START = col_character(), 
                                        STOP = col_character(),
                                        CODE = col_character(), 
                                        BASE_ENCOUNTER_COST = col_number(), 
                                        TOTAL_CLAIM_COST = col_number(), 
                                        PAYER_COVERAGE = col_number(),
                                        REASONCODE = col_number())) %>%
  mutate(
    START_POSIX = as.POSIXct(START, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
    STOP_POSIX = as.POSIXct(STOP, format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"),
  )



sort(sapply(encounters, function(x) sum(is.na(x))),decreasing = F)
#  REASONDESCRIPTION          REASONCODE 
#              2436                2483 
duplicates <- encounters[duplicated(encounters), ]
nrow(duplicates) #0

#check Id is primary key
duplicates <- encounters[duplicated(encounters$Id), ] 
nrow(duplicates) #0
# Id is primary key



# Patients ----------------------------------------------------------------


patients <- read_csv("data/patients.csv", 
                     col_types = cols(BIRTHDATE = col_date(format = "%Y-%m-%d"), 
                                      DEATHDATE = col_date(format = "%Y-%m-%d"), 
                                      FIPS = col_integer(), ZIP = col_integer(), 
                                      LAT = col_number(), LON = col_number(), 
                                      HEALTHCARE_EXPENSES = col_number(), 
                                      HEALTHCARE_COVERAGE = col_number(), 
                                      INCOME = col_integer()))

sort(sapply(patients, function(x) sum(is.na(x))),decreasing = F)
# MIDDLE             DRIVERS              PREFIX            PASSPORT                FIPS             MARITAL              MAIDEN 
# 17                  22                  27                  31                  35                  42                  78 
# DEATHDATE          SUFFIX 
# 100                 106 

duplicates <- patients[duplicated(patients), ]
nrow(duplicates) #0

#check Id is primary key
duplicates <- patients[duplicated(patients$Id), ] 
nrow(duplicates) #0



# Conditions --------------------------------------------------------------

conditions <- read_csv("data/conditions.csv", 
                       col_types = cols(SYSTEM = col_skip(), 
                                        CODE = col_character()))
sort(sapply(conditions, function(x) sum(is.na(x))),decreasing = F)
# STOP 
# 891
duplicates <- conditions[duplicated(conditions), ]
nrow(duplicates) #0

#check CODE is primary key
duplicates <- conditions[duplicated(conditions$CODE), ] 
nrow(duplicates) #0
# Code is not primary key, need to use Start and End Time when joining.


# Procedures --------------------------------------------------------------

procedures <- read_csv("data/procedures.csv", 
                       col_types = cols(SYSTEM = col_skip(), 
                                        BASE_COST = col_number())
                       )

sort(sapply(procedures, function(x) sum(is.na(x))),decreasing = F)
# REASONCODE 
# 8645 
# REASONDESCRIPTION 
# 8645 

duplicates <- procedures[duplicated(procedures), ]
nrow(duplicates) #0

#check CODE is primary key
duplicates <- procedures[duplicated(procedures$CODE), ] 
nrow(duplicates) #0
# Code is not primary key, need to use Start and End Time when joining.


# Check time span
hist(procedures$START, breaks = 100)
procedures = procedures %>%
  filter(START > '2000-01-01')


# enrich Data -------------------------------------------------------------

encounters = encounters %>%
  mutate(encounter_los_hours = ceiling(as.numeric(difftime(STOP_POSIX, START_POSIX, units = "hours"))),
         encounter_los_days = ceiling(as.numeric(difftime(STOP_POSIX, START_POSIX, units = "days")))
         )

patients = patients %>%
  mutate(age = ifelse(
           is.na(DEATHDATE),                                  
           as.numeric(floor(difftime(Sys.Date(), BIRTHDATE, units = "days") / 365.25)), # Age at current date
           as.numeric(floor(difftime(DEATHDATE, BIRTHDATE, units = "days") / 365.25))    # Age at death
         ),
         age_group=case_when(age<17 ~ "0-16",
                             age<30 ~ "17-29",
                             age<40 ~ "30-39",
                             age<50 ~ "40-49",
                             age<60 ~ "50-59",
                             age<70 ~ "60-69",
                             age<80 ~ "70-79",TRUE ~ "80+"
           ),
         age_group = factor(age_group, levels = c("0-16", "17-29", "30-39", "40-49", "50-59", "60-69", "70-79", "80+"))
         )




# Patient aggregation -----------------------------------------------------

Patient_conditions = left_join(patients,
                               conditions %>%
                                 filter(grepl("(disorder)", DESCRIPTION, ignore.case = TRUE)),
                               by=c("Id"="PATIENT"))

Patient_condition_freq = Patient_conditions %>%
  group_by(DESCRIPTION) %>%
  summarise(Frequency = n(), .groups = "drop")

ranked_conditions <- Patient_condition_freq %>%
  group_by(DESCRIPTION) %>%
  arrange(desc(Frequency), DESCRIPTION) %>% # Sort by frequency, then alphabetically
  mutate(Rank = row_number()) %>%
  ungroup()


sort(table(Patient_conditions$DESCRIPTION),decreasing = T)

Patient_encounters = left_join(patients,
                               encounters %>%
                                 group_by(PATIENT) %>%
                                 summarise(count=n()),
                               by = c('Id'='PATIENT')
                               )


# Save output -------------------------------------------------------------


save.image("data/temp_data.RData")