## ACS PUMS API Calls
## 
## Zack Crowley
## 2/15/24
## 
## API Calls using tidycensus package:
## 
## 
## ```{r setup, include=FALSE}
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


## ### CA ACS PUMS Data from 2017-2021- 5 year ACS- Census API Call: 
    
# pums_vars_acs5_22 <- pums_variables %>% filter(year == 2022, survey == "acs5")
# # List of vars to get from ACS PUMS 
# vars_list_pums <- c("PUMA","RELSHIPP","SEX", "AGEP", "HHT", "HISP", "RAC1P", "ENG", "NATIVITY", "DIS", "SCHL", "ESR", "JWMNP", "JWTRNS",  
#                     "TEN", "KIT", "PLM", "WAGP", "WKHP", "ADJINC", "HINCP", "VEH", 
#                     "RMSP", "NP", "GRPIP", "OCPIP", "POVPIP", "HICOV")
# # Return tibble of var_code and var_label for vars_list_pums, arrange by order of vars_list_pums: 
# pums_data_desc <- pums_vars_acs5 %>%  
#             distinct(var_code, var_label, data_type, level) %>%  
#             filter(var_code %in% vars_list_pums) %>% 
#             mutate(var_code =  factor(var_code, levels = vars_list_pums)) %>% 
#             arrange(var_code)
# # List of vars and labels: 
# #   var_code  var_label                                                                                                                                   data_type   level   
# #    <fct>    <chr>                                                                                                                                         <chr>     <chr>   
# #  1 PUMA     Public use microdata area code (PUMA) based on 2010 Census definition (areas with population of 100,000 or more, use with ST for unique code) chr       NA      
# #  2 RELSHIPP Relationship to reference person                                                                                                              chr       person  
# #  3 SEX      Sex                                                                                                                                           chr       person  
# #  4 AGEP     Age                                                                                                                                           num       person  
# #  5 HHT      Household/family type                                                                                                                         chr       housing 
# #  6 HISP     Recoded detailed Hispanic origin                                                                                                              chr       person  
# #  7 RAC1P    Recoded detailed race code                                                                                                                    chr       person  
# #  8 ENG      Ability to speak English                                                                                                                      chr       person  
# #  9 NATIVITY Nativity                                                                                                                                      chr       person  
# # 10 DIS      Disability recode                                                                                                                             chr       person  
# # 11 SCHL     Educational attainment                                                                                                                        chr       person  
# # 12 ESR      Employment status recode                                                                                                                      chr       person  
# # 13 JWMNP    Travel time to work                                                                                                                           num       person  
# # 14 JWTRNS   Means of transportation to work                                                                                                               chr       person  
# # 15 TEN      Tenure                                                                                                                                        chr       housing 
# # 16 KIT      Complete kitchen facilities                                                                                                                   chr       housing 
# # 17 PLM      Complete plumbing facilities                                                                                                                  chr       housing 
# # 18 WAGP     Wages or salary income past 12 months (use ADJINC to adjust WAGP to constant dollars)                                                         num       person  
# # 19 WKHP     Usual hours worked per week past 12 months                                                                                                    num       person  
# # 20 ADJINC   Adjustment factor for income and earnings dollar amounts (6 implied decimal places)                                                           chr       housing 
# # 21 HINCP    Household income (past 12 months, use ADJINC to adjust HINCP to constant dollars)                                                             num       housing 
# # 22 VEH      Vehicles (1 ton or less) available                                                                                                            chr       housing 
# # 23 RMSP     Number of rooms                                                                                                                               num       housing 
# # 24 NP       Number of persons associated with this housing record                                                                                         num       housing 
# # 25 GRPIP    Gross rent as a percentage of household income past 12 months                                                                                 num       housing 
# # 26 OCPIP    Selected monthly owner costs as a percentage of household income during the past 12 months                                                    num       housing 
# # 27 POVPIP   Income-to-poverty ratio recode                                                                                                                num       person 
# # Vector of PUMA codes to get from CA- ACS PUMS API Call below: 
# puma_codes_scag <- c("02500", "03701", "03702", "03703", "03704", "03705", "03706", "03707", "03708", "03709", "03710", "03711", "03712", "03713",  
#                      "03714", "03715", "03716", "03717", "03718", "03719", "03720", "03721", "03722", "03723", "03724", "03725", "03726", "03727",  
#                      "03728", "03729", "03730", "03731", "03732", "03733", "03734", "03735", "03736", "03737", "03738", "03739", "03740", "03741",  
#                      "03742", "03743", "03744", "03745", "03746", "03747", "03748", "03749", "03750", "03751", "03752", "03753", "03754", "03755",  
#                      "03756", "03757", "03758", "03759", "03760", "03761", "03762", "03763", "03764", "03765", "03766", "03767", "03768", "03769",  
#                      "05901", "05902", "05903", "05904", "05905", "05906", "05907", "05908", "05909", "05910", "05911", "05912", "05913", "05914",  
#                      "05915", "05916", "05917", "05918", "06501", "06502", "06503", "06504", "06505", "06506", "06507", "06508", "06509", "06510",  
#                      "06511", "06512","06513", "06514", "06515", "07101", "07102", "07103", "07104", "07105", "07106", "07107", "07108", "07109",  
#                      "07110", "07111", "07112", "07113", "07114", "07115", "11101", "11102", "11103", "11104", "11105", "11106")
# ### 
# # Run API call to get all California ACS PUMS data from 2017-2021- 5 year ACS: CA FIPS is 06- took about 8 minutes to download API call. 
# ca_pums <- get_pums( 
#   variables = vars_list_pums, 
#   state = "CA", # California 
#   puma = puma_codes_scag, 
#   survey = "acs5", # acs5 is the 5 year ACS PUMS 
#   year = 2021, # Gets 2017-2021 ACS PUMS if acs5 set in survey option. 
#   recode = TRUE, # recode variable values using Census data dictionary and creates a new *_label column for each variable that is recoded. 
#   show_call  = TRUE # If TRUE, display call made to Census API. 
# )
# # API CALL: Census API call: https://api.census.gov/data/2021/acs/acs5/pums?get=SERIALNO%2CSPORDER%2CWGTP%2CPWGTP%2CPUMA%2CRELSHIPP%2CSEX%2CAGEP%2CHHT%2CHISP%2CRAC1P%2CENG%2CNATIVITY%2CDIS%2CSCHL%2CESR%NP%2CJWTRNS%2CTEN%2CKIT%2CPLM%2CWAGP%2CWKHP%2CADJINC%2CVEH%2CRMSP%2CNP%2CGRPIP%2COCPIP%2CPOVPIP&ucgid=0400000US06
# # Write out to .csv for the raw data from API call to folder named "clean_data": 1826332 obs. with 49 variables 
# # write_csv(ca_pums, here(acs_api_fp, "ca_pums_raw.csv"))
# ###  
# #Read in saved API call data: 
# ca_pums <- read_csv(here(acs_api_fp, "ca_pums_raw.csv"))
# # Set cols to numeric that ended up as characters, change order of vars: 
# ca_pums <- ca_pums %>% mutate(across(PUMA:RAC1P, ~ as.numeric(.))) %>%  
#     relocate(c("PUMA", "ST", "SPORDER", "SEX", "AGEP","HHT", "HISP","RAC1P", "ENG", "NATIVITY", "DIS", "SCHL","ESR"), .after = SERIALNO)
# # Filter data to only PUMAs that we need for SCAG Region:  
# # *------ PUMA 2010 -----------------------------------; 
# # if 		  puma  =2500 then county=25; *Imperial; 
# # if 3701<= puma <=3799 then county=37; *Los Angeles; 
# # if 5901<= puma <=5999 then county=59; *Orange; 
# # if 6501<= puma <=6599 then county=65; *Riverside ; 
# # if 7101<= puma <=7199 then county=71; *San Bernardino; 
# # if 11101<= puma <=11199 then county=111; *Ventura;
# # SCAG County list- need to conver PUMA codes to county and then filter whole raw ACS PUMS data set to only these counties: 
# scag_county_list <- c("Imperial",  
#                       "Los Angeles", 
#                       "Orange", 
#                       "Riverside", 
#                       "San Bernardino",  
#                       "Ventura") 
# # Mutate/case_when to replicate SAS code above for creating "county" var-  
# # Create county variable with SCAG counties and filter to only those rows in SCAG Counties using scag_county_list from above: 
# ca_pums_scag <- ca_pums %>% mutate(county = case_when(PUMA == 2500 ~ "Imperial", # 25 prefix 
#                                       PUMA >= 3701 & PUMA <= 3799 ~ "Los Angeles", # 37 prefix 
#                                       PUMA >= 5901 & PUMA <= 5999 ~ "Orange", # 59 prefix 
#                                       PUMA >= 6501 & PUMA <= 6599 ~ "Riverside", # 65 prefix 
#                                       PUMA >= 7101 & PUMA <= 7199 ~ "San Bernardino", # 71 prefix 
#                                       PUMA >= 11101 & PUMA <= 11199 ~ "Ventura" # 111 prefix 
#                                                     )) %>%  
#                             filter(county %in% scag_county_list) %>% relocate("county", .after = ST) 
# # Write out data filtered to only SCAG counties to folder named "clean_data": 879241 obs. with 49 variables 
# # write_csv(ca_pums_scag, here(acs_api_fp, "ca_pums_scag.csv"))
# # # Read in SCAG county data from ca_pums_scag.csv: 
# ca_pums_scag <- read_csv(here(acs_api_fp, "ca_pums_scag.csv")) 
# #  
# # # Set a list of names of the columns from API call: 
# # vars_ca_pums_scag <- names(ca_pums_scag)
# # Remove all large datasets, leave ca_pums_scag 
# # rm(merged_data,merged_data_scag,housing_data,person_data,ca_pums) 


### CA ACS PUMS Data from 2018-2022- 5 year ACS- Census API Call:

# # TODO: NEED TO UPDATE this section once census API is working again.  
# # List of vars to get from ACS PUMS 
# vars_list_pums_22 <- c("PUMA10", "PUMA20", "RELSHIPP","SEX", "AGEP", "HHT", "HISP", "RAC1P", "ENG", "NATIVITY", "DIS", "SCHL", "ESR", "JWMNP", "JWTRNS",  
#                     "TEN", "KIT", "PLM", "WAGP", "WKHP", "ADJINC", "HINCP", "VEH", 
#                     "RMSP", "NP", "GRPIP", "OCPIP", "POVPIP", "HICOV") 
# # Check that all vars from 21 are in 22 data: 
# # read in acs_data_dict_22 
# acs_data_dict_22 <- read_csv(file = "data_dicts_ACS_PUMS/acs_data_dict_22.csv") 
# needed_vars_acs_data_dict_22 <- acs_data_dict_22 %>% filter(name %in% vars_list_pums_22)
# # Return tibble of var_code and var_label for vars_list_pums, arrange by order of vars_list_pums: 
# # pums_data_desc <- pums_vars_acs5_22 %>%  
# #             distinct(var_code, var_label, data_type, level) %>%  
# #             filter(var_code %in% vars_list_pums) %>% 
# #             mutate(var_code =  factor(var_code, levels = vars_list_pums)) %>% 
# #             arrange(var_code)
# ###### List of vars and labels: 
# #   var_code  var_label                                                                                                                                   data_type   level   
# #    <fct>    <chr>                                                                                                                                         <chr>     <chr>   
# #  1 PUMA     Public use microdata area code (PUMA) based on 2010 Census definition (areas with population of 100,000 or more, use with ST for unique code) chr       NA      
# #  2 RELSHIPP Relationship to reference person                                                                                                              chr       person  
# #  3 SEX      Sex                                                                                                                                           chr       person  
# #  4 AGEP     Age                                                                                                                                           num       person  
# #  5 HHT      Household/family type                                                                                                                         chr       housing 
# #  6 HISP     Recoded detailed Hispanic origin                                                                                                              chr       person  
# #  7 RAC1P    Recoded detailed race code                                                                                                                    chr       person  
# #  8 ENG      Ability to speak English                                                                                                                      chr       person  
# #  9 NATIVITY Nativity                                                                                                                                      chr       person  
# # 10 DIS      Disability recode                                                                                                                             chr       person  
# # 11 SCHL     Educational attainment                                                                                                                        chr       person  
# # 12 ESR      Employment status recode                                                                                                                      chr       person  
# # 13 JWMNP    Travel time to work                                                                                                                           num       person  
# # 14 JWTRNS   Means of transportation to work                                                                                                               chr       person  
# # 15 TEN      Tenure                                                                                                                                        chr       housing 
# # 16 KIT      Complete kitchen facilities                                                                                                                   chr       housing 
# # 17 PLM      Complete plumbing facilities                                                                                                                  chr       housing 
# # 18 WAGP     Wages or salary income past 12 months (use ADJINC to adjust WAGP to constant dollars)                                                         num       person  
# # 19 WKHP     Usual hours worked per week past 12 months                                                                                                    num       person  
# # 20 ADJINC   Adjustment factor for income and earnings dollar amounts (6 implied decimal places)                                                           chr       housing 
# # 21 HINCP    Household income (past 12 months, use ADJINC to adjust HINCP to constant dollars)                                                             num       housing 
# # 22 VEH      Vehicles (1 ton or less) available                                                                                                            chr       housing 
# # 23 RMSP     Number of rooms                                                                                                                               num       housing 
# # 24 NP       Number of persons associated with this housing record                                                                                         num       housing 
# # 25 GRPIP    Gross rent as a percentage of household income past 12 months                                                                                 num       housing 
# # 26 OCPIP    Selected monthly owner costs as a percentage of household income during the past 12 months                                                    num       housing 
# # 27 POVPIP   Income-to-poverty ratio recode                                                                                                                num       person 
# # Vector of PUMA codes to get from CA- ACS PUMS API Call below: 
# puma_codes_scag <- c("02500", "03701", "03702", "03703", "03704", "03705", "03706", "03707", "03708", "03709", "03710", "03711", "03712", "03713",  
#                      "03714", "03715", "03716", "03717", "03718", "03719", "03720", "03721", "03722", "03723", "03724", "03725", "03726", "03727",  
#                      "03728", "03729", "03730", "03731", "03732", "03733", "03734", "03735", "03736", "03737", "03738", "03739", "03740", "03741",  
#                      "03742", "03743", "03744", "03745", "03746", "03747", "03748", "03749", "03750", "03751", "03752", "03753", "03754", "03755",  
#                      "03756", "03757", "03758", "03759", "03760", "03761", "03762", "03763", "03764", "03765", "03766", "03767", "03768", "03769",  
#                      "05901", "05902", "05903", "05904", "05905", "05906", "05907", "05908", "05909", "05910", "05911", "05912", "05913", "05914",  
#                      "05915", "05916", "05917", "05918", "06501", "06502", "06503", "06504", "06505", "06506", "06507", "06508", "06509", "06510",  
#                      "06511", "06512","06513", "06514", "06515", "07101", "07102", "07103", "07104", "07105", "07106", "07107", "07108", "07109",  
#                      "07110", "07111", "07112", "07113", "07114", "07115", "11101", "11102", "11103", "11104", "11105", "11106")
# ### 
# # Run API call to get all California ACS PUMS data from 2018-2022- 5 year ACS: CA FIPS is 06- took about 8 minutes to download API call. 
# ca_pums_22 <- get_pums( 
#   variables = vars_list_pums_22, 
#   state = "CA", # California 
#   puma = puma_codes_scag, 
#   survey = "acs5", # acs5 is the 5 year ACS PUMS 
#   year = 2022, # Gets 2018-2022 ACS PUMS if acs5 set in survey option. 
#   recode = TRUE, # recode variable values using Census data dictionary and creates a new *_label column for each variable that is recoded. 
#   show_call  = TRUE # If TRUE, display call made to Census API. 
# )
# # API CALL: Census API call: https://api.census.gov/data/2021/acs/acs5/pums?get=SERIALNO%2CSPORDER%2CWGTP%2CPWGTP%2CPUMA%2CRELSHIPP%2CSEX%2CAGEP%2CHHT%2CHISP%2CRAC1P%2CENG%2CNATIVITY%2CDIS%2CSCHL%2CESR%NP%2CJWTRNS%2CTEN%2CKIT%2CPLM%2CWAGP%2CWKHP%2CADJINC%2CVEH%2CRMSP%2CNP%2CGRPIP%2COCPIP%2CPOVPIP&ucgid=0400000US06
# # Write out to .csv for the raw data from API call to folder named "clean_data": 1826332 obs. with 49 variables 
# # write_csv(ca_pums, here(acs_api_fp, "ca_pums_raw.csv"))
# ###  
# #Read in saved API call data: 
# # ca_pums <- read_csv(here(acs_api_fp, "ca_pums_raw.csv"))
# # Set cols to numeric that ended up as characters, change order of vars: 
# ca_pums <- ca_pums %>% mutate(across(PUMA:RAC1P, ~ as.numeric(.))) %>%  
#     relocate(c("PUMA", "ST", "SPORDER", "SEX", "AGEP","HHT", "HISP","RAC1P", "ENG", "NATIVITY", "DIS", "SCHL","ESR"), .after = SERIALNO)
# # Filter data to only PUMAs that we need for SCAG Region:  
# # *------ PUMA 2010 -----------------------------------; 
# # if 		  puma  =2500 then county=25; *Imperial; 
# # if 3701<= puma <=3799 then county=37; *Los Angeles; 
# # if 5901<= puma <=5999 then county=59; *Orange; 
# # if 6501<= puma <=6599 then county=65; *Riverside ; 
# # if 7101<= puma <=7199 then county=71; *San Bernardino; 
# # if 11101<= puma <=11199 then county=111; *Ventura;
# # SCAG County list- need to conver PUMA codes to county and then filter whole raw ACS PUMS data set to only these counties: 
# scag_county_list <- c("Imperial",  
#                       "Los Angeles", 
#                       "Orange", 
#                       "Riverside", 
#                       "San Bernardino",  
#                       "Ventura") 
# # Mutate/case_when to replicate SAS code above for creating "county" var-  
# # Create county variable with SCAG counties and filter to only those rows in SCAG Counties using scag_county_list from above: 
# ca_pums_scag <- ca_pums %>% mutate(county = case_when(PUMA == 2500 ~ "Imperial", # 25 prefix 
#                                       PUMA >= 3701 & PUMA <= 3799 ~ "Los Angeles", # 37 prefix 
#                                       PUMA >= 5901 & PUMA <= 5999 ~ "Orange", # 59 prefix 
#                                       PUMA >= 6501 & PUMA <= 6599 ~ "Riverside", # 65 prefix 
#                                       PUMA >= 7101 & PUMA <= 7199 ~ "San Bernardino", # 71 prefix 
#                                       PUMA >= 11101 & PUMA <= 11199 ~ "Ventura" # 111 prefix 
#                                                     )) %>%  
#                             filter(county %in% scag_county_list) %>% relocate("county", .after = ST) 
# # Write out data filtered to only SCAG counties to folder named "clean_data": 879241 obs. with 49 variables 
# # write_csv(ca_pums_scag, here(acs_api_fp, "ca_pums_scag.csv"))
# # # Read in SCAG county data from ca_pums_scag.csv: 
# # ca_pums_scag <- read_csv(here(acs_api_fp, "ca_pums_scag.csv")) 
# #  
# # # Set a list of names of the columns from API call: 
# # vars_ca_pums_scag <- names(ca_pums_scag)
# # Remove all large datasets, leave ca_pums_scag 
# # rm(merged_data,merged_data_scag,housing_data,person_data,ca_pums) 


