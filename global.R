library(tidyverse)
library(shiny)
library(magrittr)
library(lubridate)
library(reshape2)
library(Hmisc)
library(leaflet)
library(leaflet.extras)


load("data/temp_data.RData")

encounter_patient = left_join(encounters,
                              patients,
                              by = c("PATIENT"= "Id"))