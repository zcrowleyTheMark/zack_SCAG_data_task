## SCAG Data Recoding variables for use in ACS PUMS Analysis:
## 
## Zack Crowley
## 2/15/24
## 
# Set R chunk options:
## Set default options for R code chunks:
knitr::opts_chunk$set(
    echo = FALSE, 
    warning = FALSE, 
    message = FALSE,
    rows.print = 20 # display 20 rows inline and in document
    # fig.width = 6.5,
    # fig.height = 4
)
# Prevents sci notation and sets the output of decimals to 4 (0.0000), suppresses warnings/info for tidyverse:
options(scipen = 999,
        tidyverse.quiet = TRUE,
        dplyr.summarise.inform = FALSE,
        pillar.print_min = 40
)

# Un-comment next two lines to install/update all necesary packages:
# install.packages("remotes") # first install remotes to use update_packages()
# remotes::update_packages(c("here", "rstudioapi", "magrittr", "spatstat", "readxl", "openxlsx2", "data.table", "tidycensus", "tidyverse")) # un-comment to install/update all packages

# Set here() location- working directory will be based on the project folder that this Rmd file is inside of currently:
here::i_am("SCAG_data_task_ZC.Rmd")

# Load libraries:
library(here) # package to manage file paths
# library(fs)  # package to work with system file paths
# library(tools) # another package to work with system file paths
library(rstudioapi) # package accessing Rstudio API 
library(magrittr) # pipe function package
# library(janitor) # package for functions that help clean data
library(spatstat) # package for weighted.median() function
library(readxl) # reading excel files
library(openxlsx2) # writing excel files and manipulating excel workbooks.
library(data.table) # package for data manipulation and reads in large files faster using fread()
library(tidycensus) # API for US Census- can access ACS PUMS directly from API- key set in .Renviron- to see use: usethis::edit_r_environ()
library(tidyverse) # package loads all tidyverse packages like dplyr, tidyselect, stringR, etc.


#### Data Dictionaries ----
### 2021 ACS: 
## Get data dictionary as tibble from tidycensus for 2021:
# pums_vars_acs5 <- pums_variables %>%
#   filter(year == 2021, survey == "acs5")
# # person level
# pums_vars_acs5_person <- pums_variables %>%
#   filter(year == 2021, survey == "acs5", level == "person")
# # housing level:
# pums_vars_acs5_housing <- pums_variables %>%
#    filter(year == 2021, survey == "acs5", level == "housing")
# 
# # Write out data dicts for all vars, person and housing vars:
# write_csv(pums_vars_acs5, "data_dicts_ACS_PUMS/pums_vars_acs5.csv")
# write_csv(pums_vars_acs5_person, "data_dicts_ACS_PUMS/pums_vars_acs5_person.csv")
# write_csv(pums_vars_acs5_housing, "data_dicts_ACS_PUMS/pums_vars_acs5_housing.csv")
# 
# Read in data dicts from person and housing level data:
pums_vars_acs5 <- read_csv("data_dicts_ACS_PUMS/pums_vars_acs5.csv")
pums_vars_acs5_person <- read_csv("data_dicts_ACS_PUMS/pums_vars_acs5_person.csv")
pums_vars_acs5_housing <- read_csv("data_dicts_ACS_PUMS/pums_vars_acs5_housing.csv")

### 2022 ACS: Needed to scrape from website 
# library(rvest) # package for webscraping
# # Pull data dictionary from 2018-2022 ACS PUMS from website that has the data dict in a html table:
# acs_data_dict_22 <- "https://api.census.gov/data/2022/acs/acs5/pums/variables.html" %>% 
#   read_html() %>%
#   html_element("table") %>% 
#   html_table(convert = TRUE) %>% 
#   janitor::clean_names() 
# 
# # Drop first row- was incorrectly pulled in from footer of table ("525 variables") :
# acs_data_dict_22 <- acs_data_dict_22 %>% filter(name != "525 variables")
# 
# # write to csv called "acs_data_dict_22.csv:
# acs_data_dict_22 %>% write_csv(file = "data_dicts_ACS_PUMS/acs_data_dict_22.csv")

# Read in acs_data_dict_22
pums_vars_acs5_22 <- read_csv("data_dicts_ACS_PUMS/acs_data_dict_22.csv")


################# Setup file paths ----
# Set up all file paths:
# file path for all raw data:
data_fp <- here('data')
# list.files(data_fp)

### IMPORTS filepaths ---- 
# file path for 2021 5-year ACS PUMS Data:
acs_2021_fp <- here(data_fp, '2017_2021_ACS_PUMS')
# list.files(acs_2021_fp) 

# file path for 2021 person level data
person_2021_fp <- here(acs_2021_fp, "csv_pca", "psam_p06.csv")

# file path for 2021 household level data
hh_2021_fp <- here(acs_2021_fp, "csv_hca", "psam_h06.csv")

# Set up file path for 2022 5-year ACS PUMS Data:
acs_2022_fp <- here(data_fp, '2018_2022_ACS_PUMS')
# list.files(acs_2022_fp)

# file path for 2022 person level data
person_2022_fp <- here(acs_2022_fp, "csv_pca", "psam_p06.csv")

# file path for 2022 household level data
hh_2022_fp <- here(acs_2022_fp, "csv_hca", "psam_h06.csv")

### CLEAN DATA filepaths ---- 
# File paths and directories for clean data- 
# Creates a new folder called "clean_data" if it doesn't already exist in working directory:
if (!dir.exists("clean_data")) {dir.create("clean_data")}
# file path for clean_data
clean_data_fp <- here("clean_data")
# list.files(clean_data_fp)

# Clean 21 data
# Creates a new folder called "acs_data_21" (if it doesn't already exist in working directory)- this will be where the clean data for the 2021 ACS will be stored:
if (!dir.exists(here(clean_data_fp, "acs_data_21"))) {dir.create(here(clean_data_fp, "acs_data_21"))}
# file path for clean_data acs_data_21
acs_data_21_fp <- here(clean_data_fp, "acs_data_21")

# Clean 22 data
# Creates a new folder called "acs_data_22" (if it doesn't already exist in working directory)- this will be where the clean data for the 2022 ACS will be stored:
if (!dir.exists(here(clean_data_fp, 'acs_data_22'))) {dir.create(here(clean_data_fp, 'acs_data_22'))}
# file path for clean_data acs_data_22
acs_data_22_fp <- here(clean_data_fp, "acs_data_22")

# Clean ACS API data
# Creates a new folder called "acs_api" (if it doesn't already exist in working directory)- this will be where the clean data for API datawill be stored:
if (!dir.exists(here(clean_data_fp, 'acs_api'))) {dir.create(here(clean_data_fp, 'acs_api'))}
# file path for clean_data acs_data_22
acs_api_fp <- here(clean_data_fp, "acs_api")

### OUTPUTS filepaths ---- 
# output folder
# Creates a new folder called "output" (if it doesn't already exist in working directory)- this will be where the outputs from the R script will be stored:
if (!dir.exists(here('output'))) {dir.create(here('output'))}
# file path for clean_data acs_data_22
output_fp <- here("output")

# Creates a new folder called "acs_api" (if it doesn't already exist in working directory)- this will be where the individual tables for 
# the tabbed output from the R script will be stored as separate .csv's:
if (!dir.exists(here(output_fp, 'tables'))) {dir.create(here(output_fp, 'tables'))}
# file path for clean_data acs_data_22
tables_fp <- here(output_fp, 'tables')

### Read in dataset -----

# 2017-2021 ACS PUMS merged data
# If you want to use 2017-2021 ACS PUMS merged data use the next line otherwise comment out/don't run the next line and go the next line:
# Read in merged ACS data SCAG from 2017-2021:
# ca_pums_scag <- read_csv(here(acs_data_21_fp, "merged_acs_data_scag.csv"), show_col_types = FALSE)

# 2018-2022 ACS PUMS merged data
# Un-comment the next line (and comment out the above line)if you want to use the merged 2018-2022 ACS PUMS data file
# Read in merged ACS data SCAG from 2018-2022:
# ca_pums_scag <- read_csv(here(acs_data_22_fp, "merged_acs_22_scag.csv"), show_col_types = FALSE)

### Recode/Create New Variables for analysis -----

# Year of ACS- Pull out the first 4 digits from SERIALNO, which is the year of ACS for that observation:
ca_pums_scag <- ca_pums_scag %>% mutate(year = as.numeric(str_extract(SERIALNO, "\\d{4}")))

# Code county as a factor variable:
ca_pums_scag <- ca_pums_scag %>% mutate(county = factor(county, levels = c("Imperial", "Los Angeles", "Orange", "Riverside", "San Bernardino", "Ventura")))

# Race and Ethnicity: named var "race" for brevity:
# Create "race" var based on the following conditions for 6 total categories, and convert to factor: 
# If HISP is NOT equal to 1, then  "Hispanic/Latino"
# For the rest- if HISP is equal to 1 and
# If RAC1P = 1 "White", If RAC1P = 2 "Black", If RAC1P = 6 or 7 "Asian/Pacific Islander", If If RAC1P = 3,4 or 5  "Native American", If RAC1P = 8 or 9 "Multiracial/Other":
ca_pums_scag <- ca_pums_scag %>% mutate(race = factor(case_when(HISP != 1  ~ "Hispanic/Latino",
                                                                HISP == 1 & RAC1P == 1 ~ "White", 
                                                                HISP == 1 & RAC1P == 2 ~ "Black", 
                                                                HISP == 1 & RAC1P %in% c(6,7) ~ "Asian/Pacific Islander", 
                                                                HISP == 1 & RAC1P %in% c(3:5) ~ "Native American", 
                                                                HISP == 1 & RAC1P %in% c(8,9) ~ "Multiracial/Other"
), levels = c("Asian/Pacific Islander", "Black", "Hispanic/Latino", "Multiracial/Other", "Native American", "White"))
) 

# Age Categories: named var "age_3_cat"
# Create "age_3_cat" var based on the following conditions for 3 total categories, and convert to factor: 
# If AGEP < 18 "<18 years", If AGEP is greater than or equal to 18 and less than or equal to 64 "18 - 64 years", If AGEP > 64 ~ "65+ years"
ca_pums_scag <- ca_pums_scag %>% mutate(age_3_cat = factor(case_when(AGEP < 18  ~ "<18 years",
                                                                     AGEP %in% c(18:64) ~ "18 - 64 years",
                                                                     AGEP > 64 ~ "65+ years"
), levels = c("<18 years", "18 - 64 years","65+ years"))
) 
# Household Income (different adjustments of income for 2017-21 ACS data and 2018-22 ACS data):
# ADJINC has 6 implied decimal places so need to divide it by 1000000 to get the inflation adjustment for today's dollar values:
ca_pums_scag <- ca_pums_scag %>% mutate(housing_income = HINCP * (ADJINC/1000000))


# Education Categories: named var "edu"
# Create "edu" var based on the following conditions for 6 total categories, and convert to factor: 
# If SCHL is greater than or equal to 1 and less than or equal 15) "Less than HS Diploma", If SCHL is equal to 16 or 17 "HS Diploma", If SCHL is equal to 18 or 19 "Some College", 
# If SCHL equal to 20 "AA Degree", If SCHL equal to 21 "BA degree", If SCHL equal to 22, 23 or 24 "MA degree or higher":
ca_pums_scag <- ca_pums_scag %>% mutate(edu = factor(case_when(SCHL %in% c(1:15)  ~ "Less than HS Diploma",
                                                               SCHL %in% c(16:17) ~ "HS Diploma",
                                                               SCHL %in% c(18:19) ~ "Some College",
                                                               SCHL == 20 ~ "AA Degree",
                                                               SCHL == 21 ~ "BA degree",
                                                               SCHL %in% c(22:24) ~ "MA degree or higher"
), 
levels = c("Less than HS Diploma", "HS Diploma", "Some College", "AA Degree", "BA degree", "MA degree or higher"))
)

# Homeownership: named var "own_home" 
# Create "own_home" var based on the following conditions for 2 total categories, and convert to factor: 
# If TEN is in (1 2) then "Homeowner"; If TEN in (3 4) then "Non-Homeowner";
ca_pums_scag <- ca_pums_scag %>% mutate(own_home = factor(case_when(TEN %in% c(1:2) ~ "Homeowner",
                                                                    TEN %in% c(3:4) ~ "Non-Homeowner"), 
                                                          levels = c("Homeowner", "Non-Homeowner"))
)


# Means of transportation to work for Workers who Commute by Walk, Bike, or Public Transit: named var "walk_bike_public_transport": 
# Create "walk_bike_public_transport" var based on the following conditions for 2 total categories, and convert to factor: 
# If JWTRNS is eqaul to any of the following 2,3,4,5,9, or 10 then "Walk/Bike/Public"; otherwise "Other Transport":
ca_pums_scag <- ca_pums_scag %>% mutate(walk_bike_public_transport = factor(case_when(JWTRNS %in% c(2:5,9,10)  ~ "Walk/Bike/Public",
                                                                                      TRUE ~ "Other Transport"), levels = c("Walk/Bike/Public", "Other Transport"))
) 
# Means of transportation to work: named var "all_transport"- Public, Private or Other 
# Create "all_transport" var based on the following conditions for 3 total categories, and convert to factor: 
#  Workers who Commute by bus, rail, taxi, or ferry: coded level "Public": JWTRNS %in% c(2:7)
#  Workers who Commute by Car or Motorcycle: coded level "Private": JWTRNS %in% c(1,8)
#  Workers who Commute by Walk, Bike, or Other: coded level "Other": JWTRNS %in% c(9,10,12)
ca_pums_scag <- ca_pums_scag %>% mutate(all_transport = factor(case_when(JWTRNS %in% c(1,8) ~ "Private",
                                                                         JWTRNS %in% c(2:7) ~  "Public",
                                                                         JWTRNS %in% c(9,10,12) ~ "Other"
), levels = c("Other", "Public","Private"))
) 

# Poverty - Create "poverty" var based on the following conditions for 2 total categories, and convert to factor: 
# If POVPIP less than 200 then "Yes"; otherwise "No"
# If poverty == "Yes", the HH income is below 200 percent of the poverty line:
ca_pums_scag <- ca_pums_scag %>% mutate(poverty = factor(case_when(POVPIP %in% c(0:199) ~ "Yes",
                                                                   POVPIP >= 200 ~ "No",), levels = c("Yes","No"))
)

# Housing and Renter Burden: Two variables
# Housing Burden is named "housing_burden" coded "Yes" if 
# Homeowner, owner costs as a percentage of household income (housing cost burden) 30% or more (OCPIP), and 200 below percent poverty line (POVPIP):
# own_home == "Homeowner" & OCPIP >= 30 & POVPIP %in% c(0:199) Then "Yes"; otherwise "No"
# Renter Burden is named "renter_burden" coded "Yes" if 
# Rent a home, Gross rent as a percentage of household income (Rent burden) 30% or more (GRPIP) and 200 below percent poverty line (POVPIP):
# own_home == "Non-Homeowner" & GRPIP >= 30 & POVPIP %in% c(0:199) Then "Yes"; otherwise "No"
# Housing and Rent burdens: variable for homeowner burden named: "housing_burden"; variable for homeowner burden named: "renter_burden"
ca_pums_scag <- ca_pums_scag %>% mutate(housing_burden = factor(case_when(own_home == "Homeowner" & OCPIP >= 30 & POVPIP %in% c(0:199) ~ "Yes",
                                                                          TRUE ~ "No",), levels = c("Yes","No")),
                                        renter_burden = factor(case_when(own_home == "Non-Homeowner" & GRPIP >= 30 & POVPIP %in% c(0:199) ~ "Yes",
                                                                         TRUE ~ "No",), levels = c("Yes","No"))
) 


# No kitchen and no plumbing facilities in home: named var "no_kitchen_plumbing"
# Create "no_kitchen_plumbing" var based on the following conditions for 2 total categories, and convert to factor: 
# If KIT == 2 AND PLM == 2 then "Yes"; KIT == 1 OR PLM == 1 then "No"
ca_pums_scag <- ca_pums_scag %>% mutate(no_kitchen_plumbing = factor(case_when(KIT == 2 & PLM == 2 ~ "Yes",
                                                                               KIT == 1 | PLM == 1 ~ "No",), levels = c("Yes","No"))
)

### 
# Overcrowding of households: defined as "severe overcrowding is measured as the percentage of householders that have more than 1.5 persons per room"
# named variable: "overcrowded" if "Yes", greater than or equal to 1.5 people per room, "No" otherwise. 
# First define the number of occupants/number or rooms and name "crowd" if RMSP is greater than 0- NP/RMSP = "crowd", if "crowd is greater than or equal to 1.5 then "overcrowded" = "Yes" and "No" if less than 1.5:
ca_pums_scag <- ca_pums_scag %>% mutate(crowd = case_when(RMSP > 0  ~ NP/RMSP,
                                                          TRUE ~ NA),
                                        overcrowded = factor(case_when(crowd >= 1.5  ~ "Yes",
                                                                       crowd < 1.5 ~ "No"), levels = c("Yes","No"))
) 

## Hourly wage: variable named "hourly_wage"
# First, adjust the wages with the Adjust Income for the correct year named "wage";
# Second, get the weekly wages by dividing by 52 named "weekly_wage", then divide by WKHP (usual hours worked per week)
# Finally: get hourly wage by dividing weekly_wage by WKHP (usual hours worked per week) if  WKHP > 0: 
# HINCP * (ADJINC/1000000)
# ca_pums_scag <- ca_pums_scag %>% mutate(wage = case_when(ADJINC == 1117630 ~ WAGP * 1.011189 * 1.10526316, # 2017 Adjust Income
#                                                          ADJINC == 1093093 ~ WAGP * 1.013097 * 1.07896160, # 2018 Adjust Income
#                                                          ADJINC == 1070512 ~ WAGP * 1.010145 * 1.05976096, # 2019 Adjust Income
#                                                          ADJINC == 1053131 ~ WAGP * 1.006149 * 1.04669465, # 2020 Adjust Income
#                                                          ADJINC == 1029928 ~ WAGP * 1.029928 * 1.00000000, # 2021 Adjust Income
#                                         ),
#                         weekly_wage = wage/52,
#                         hourly_wage = if_else(WKHP > 0,weekly_wage/WKHP, NA_real_)
#                         )
ca_pums_scag <- ca_pums_scag %>% mutate(hourly_wage = if_else(WKHP > 0, ((WAGP * (ADJINC/1000000))/52)/WKHP, NA_real_)
)

# Unemployment -named variable "unemployed"- if "Yes", unemployed, "No" otherwise. 
# Unemployment -named variable "unemployed"- if ESR (Employment status recode) == 3 then "Yes" (unemployed), or "No" otherwise if ESR does not equal 3 and set as a factor. 
ca_pums_scag <- ca_pums_scag %>% mutate(unemployed = factor(case_when(ESR == 3  ~ "Yes",
                                                                      ESR != 3 ~ "No"), levels = c("Yes","No"))
)
###
# Single Parent Households by gender: Use HHT2 to create new variable named "single_hh"
# If HHT2 == 06	Female householder, no spouse/partner present, with children of the householder less than 18
# # Then single_hh == "female_hh"
# If HHT2 == 10	 Male householder, no spouse/partner present, with children of the householder less than 18
# Then single_hh == "male_hh"
# Otherwise, single_hh == "cohabit_or_nokids"
ca_pums_scag <- ca_pums_scag %>% mutate(single_hh = factor(case_when(HHT2 == 6  ~ "female_hh",
                                                                     HHT2 == 10  ~ "male_hh",
                                                                     HHT2 %in% c(1:5,7:9,11:12) ~ "cohabit_or_nokids"
), levels = c("female_hh", "male_hh","cohabit_or_nokids"))
)

# Limited English Proficiency: New variable named "lep"
# lep == "limited_english_proficiency" if ENG == 3 | if ENG == 4
# lep == "english_proficient" if ENG == 3 | if ENG == 4
# lep == "<5yos_or_no_eng" if is.na(ENG) or TRUE
ca_pums_scag <- ca_pums_scag %>% mutate(lep = factor(case_when(ENG %in% c(3:4) ~ "limited_english_proficiency",
                                                               ENG %in% c(1:2) ~ "english_proficient",
                                                               TRUE ~ "<5yos_or_no_eng"),
                                                     levels = c("limited_english_proficiency","english_proficient","<5yos_or_only_eng")
)
)

# Set up county and race levels to use to convert each to factors and arrange tables, append 7th category to each for totals for SCAG:
# county_levels: 
county_levels <- c("Imperial", "Los Angeles", "Orange", "Riverside", "San Bernardino", "Ventura", "SCAG")

# race_levels: 
race_levels <-  c("Asian/Pacific Islander", "Black", "Hispanic/Latino", "Multiracial/Other", "Native American", "White", "All Races")


