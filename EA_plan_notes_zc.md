---
title: "EA Tech Support Plan and Docs"
author: "Zack Crowley"
date: "1/23/24"
output: html_document
---


### Main Data Files: 
- **2017-2021 ACS raw PUMS data**- download these two zip files: `csv_pca.zip` (person-level for CA) and `csv_hca.zip` (household-level for CA), extract both and then use the respective csv files in each folder: `psam_p06.csv` (person-level for CA) and `psam_h06.csv` (household-level for CA) from [US Census ACS PUMS 2017-2021](https://www2.census.gov/programs-surveys/acs/data/pums/2021/5-Year/) which was saved in [data folder here](../data)  
- **2017-2021 ACS raw PUMS data**- download these two zip files: `csv_pca.zip` (person-level for CA) and `csv_hca.zip` (household-level for CA), extract both and then use the respective csv files in each folder: `psam_p06.csv` (person-level for CA) and `psam_h06.csv` (household-level for CA) from [US Census ACS PUMS 2018-2022](https://www2.census.gov/programs-surveys/acs/data/pums/2022/5-Year/)
  - NOTES for using 2022 data: - Has PUMA's for 2010 census for years 2018-2021, the observations from 2022 have PUMA's from the 2020 census- some of which may be new but are still within each SCAG county since the prefix of each PUMA remains the same.
  

--- 

### Docs received from Annaleigh at SCAG from [Temp-Equity Analysis](https://scag.sharepoint.com/sites/PublicLibrary/Shared%20Documents/Forms/AllItems.aspx?id=%2Fsites%2FPublicLibrary%2FShared%20Documents%2FEquity%20Working%20Group%2FTemp%2DEquity%20Analysis&p=true&ga=1):
- the SAS script that we have (in case it is helpful to you)
- the intermediate files that we received from the staff that ran the SAS script (2023_Equity Indicators_ACS1721_...)
- the list of figures/tables that we'd like to be a part of the baseline conditions section with the county-level data visualizations (2023 Equity indicators, note you can filter by Data Source [PUMS] and Table/Figure numbers in Column K)
  - One note is that the demographics (Historical Demographic Trends) section of the Equity analysis didn't have the same visualizations that the Baseline Conditions Reports had, so we would like to have the option to separate some of these out into new visualizations (maybe this is the purpose of having the "raw" data file!)

### SCAG expectations/deliverables:
  - Develop script (in R) for compiling necessary "raw" data points from baseline conditions report into one document to provide flexibility in what data gets visualized/how the dashboard is structured
  - Develop script (either incorporated in the first, or separate) to create a document (that can be opened in Excel) with one tab for each of the designated topic areas indicated by SCAG
  - Develop separate "walk-through" documentation to show how to run the script(s) for future updates (or prior years)
  
### Deliverables:
  - Script(s)
  - Documentation
  - "raw" data set for 2021 5-year ACS
  - "tabbed" data set for 2021 5-year ACS

--- 

### Updated list of tables and figures that need to be included in the "tabbed" data set (for 2021 5-year ACS):

For the demographics charts (instead of Figure 2, and Tables 7-10), I'm looking for something more like the tables from the [Racial Equity Baseline Conditions Report (REBCR)](https://scag.ca.gov/sites/main/files/file-attachments/2022racialequitybaselineconditionsreport_final.pdf) under the demographics/economy sections (starting on PDF page 8). I added new documents to the [Temp-Equity Analysis](https://scag.sharepoint.com/sites/PublicLibrary/Shared%20Documents/Forms/AllItems.aspx?id=%2Fsites%2FPublicLibrary%2FShared%20Documents%2FEquity%20Working%20Group%2FTemp%2DEquity%20Analysis&p=true&ga=1) folder (1_Demographics_Figures and 5_Economy_Figures) from the REBCR. They're not clean by any means, but its reflective of what we have for the tabs we have for the Equity Analysis. See full list of charts for demographics below.

### New list is:
- Figures 5-7, 19-22, 28, and 39-41
- Tables 9-10
- Demographics charts/tables (from Racial Equity Baseline Conditions Report (REBCR))
  - Total Population
  - Race/Ethnicity Distribution
  - Age Distribution (Youth, Older Adults)
  - Single Parent Households (REBCR has - female-headed)
  - Limited English Proficiency
  - People with Disabilities
  - National Origin
  - Educational Attainment (REBCR Economy section)
  - Median Household Income (REBCR Economy section)
  - Poverty (REBCR Economy section)
  
### Figures/Tables with Descriptions (23 total to replicate): 

*Green color indicates figure is completed in tabbed excel output, red indicates issues or notes with data*

##### Equity Analysis Technical Report Figures (13 total to replicate- 13 Complete): 

- <span style="color: green;">**Figure 5.** Workers who Commute by Walk, Bike, or Public Transit by Race and Ethnicity</span> 
  - *NOTE Figure 5: Taken from all non-home workers and did not include taxi or ferry- based on values/calculations from excel figure file*
- <span style="color: green;">**Figure 6.** Householders without a Vehicle by Race and Ethnicity</span>
- <span style="color: green;">**Figure 7.** Workers’ Commute Times (Minutes) by Mode and Race and Ethnicity</span> 
- <span style="color: red;">**Table 9. Transportation Mode Usage by Income Quintile in the SCAG Region (Source: 2017 NHTS, income quintiles calculated by SCAG) *NOT SURE IF WE CAN DO WITH ACS PUMS</span>
- <span style="color: red;">**Table 10. Transportation Mode Usage by Race and Ethnicity in the SCAG Region (Source: 2017 NHTS) *NOT SURE IF WE CAN DO WITH ACS PUMS</span>
- <span style="color: green;">**Figure 19.** Renters and Homeowners Experiencing Housing Cost Burden by Race and Ethnicity</span>
- <span style="color: green;">**Figure 20.** People Living in Households Without Kitchen and Plumbing Facilities by Race and Ethnicity
  - <span style="color: red;">*NOTE: Some numbers off by 0.01%, Could we get the full SAS html output to review the raw numbers from SCAG.*<span style="color: green;">
- <span style="color: green;">**Figure 21.** Households with Severe Overcrowding by Race and Ethnicity</span>
- <span style="color: green;">**Figure 22.** Homeownership by Race and Ethnicity</span>
- <span style="color: green;">**Figure 28.** People without Health Insurance by Race and Ethnicity</span>
- <span style="color: green;">**Figure 39.** Median Hourly Wage by Race and Ethnicity</span>
- <span style="color: green;">**Figure 40.** Unemployment by Race and Ethnicity</span>
- <span style="color: green;">**Figure 41.** Working Poor by Race and Ethnicity</span>
  - NOTE: Figure 41 is working poor using person-level weights- poverty below in REBCR demographics is household poverty (both same measure if 0<= POVPIP <200) using housing level weights.

##### Demographics charts/tables to produce based on figures from Racial Equity Baseline Conditions Report (REBCR)- (which were ACS 2016-2020 and 10 total to replicate)

  - **Total Population**- By county and whole SCAG Region
  - **Race/Ethnicity Distribution**- By county and whole SCAG Region- same racial categories as in EA Report.
  - **Age Distribution (Youth, Older Adults)**- Same as in REBCR with three groups being: <18 years, 18 - 64 years, 65+ years- break down by county and whole SCAG Region
  - **Single Parent Households** (REBCR has - female-headed) If variable HHT2 is Male or Female head of household head with children < 18, include single-parent HHs broken down by *gender* of head of household. By county and whole SCAG Region
  - **Limited English Proficiency**- variable named ENG has 4 categories- If ENG is "not well" or "not at all", so the groups are: Not at all/not well vs well/very well. By county and whole SCAG Region
  - **People with Disabilities**- DIS == "with disability" (1) By county and whole SCAG Region
  - **National Origin**- variable name NATIVITY- Percent foreign born? If NATIVITY == "Foreign Born". By county and whole SCAG Region
  - **Educational Attainment** (REBCR Economy section)- Filter to people over 25, these 6 categories: "LESS THAN HS DIPLOMA", "HS DIPLOMA", "SOME 
  COLLEGE", "AA DEGREE", "BA DEGREE", "MA DEGREE". By race and also report the whole SCAG Region
  - **Median Household Income** (REBCR Economy section) By race and also report the whole SCAG Region
  - **Poverty** (REBCR Economy section) variable name POVPIP- income to poverty ratio, if 0<= POVPIP <200 then pov=1; if POVPIP>=200 then pov=2. If households lived below 200 percent of the poverty line. By race and also report the whole SCAG Region, do not include 'people of color' category.
  
  - notes also found in this Google doc: https://docs.google.com/document/d/1szSsAiYopeeOHjl3hnwSLl8afTc8LS16HEcws6sHdfI/edit

--- 

#### Notes on ACS PUMS merge and weights:

#### [Merging PUMS Person and Housing Files](PUMS_docs/2022ACS_PUMS_User_Guide.pdf) 

- Below are instructions for concatenating the two 1-year “a” and “b” PUMS files to create a single national file. The code is in italics and uses SAS programming code1. See section X (below) for a link to open-source software (R and Python) that may be used to work with PUMS files.

- Concatenate the person-level files using the set statement:

```SAS
  data population;
  set psam_pusa psam_pusb;
  run;
```

- Concatenate the household-level files using the set statement:

```SAS
  data housing;
  set psam_husa psam_husb;
  run;
```

Some data users will need to use household and person items together. For instance, in order to analyze how the number of rooms in a home varies by a person’s age, merge the household and person files together using the serial number variable (SERIALNO).

- First make sure the files are sorted by SERIALNO.

```SAS
  proc sort data=population; by serialno;
  run;

  proc sort data=housing;
  by serialno; run;
```

- Then merge the two files together using SERIALNO as a merge key. Note that in SAS, the ‘in=’ option will allow you to identify records from a specific file. The line ‘if pop’ retains only records from the population file.

```SAS
  data combined;
  merge population (in=pop) housing; 
  by serialno;
  if pop;
  run;
```

You do not need to merge the files unless the estimates you wish to create require a merge. Note that there are many estimates that may be tabulated from the person file and from the household file without any merging. The suggested merge will create a person level file, so that the estimate of persons may be tallied within categories from the household file and **the person weights should be used for such tallies**.

Note also that the housing unit record files contain vacant housing units. There are no population records for these housing units.

##### [PUMS Weighting Variables](PUMS_docs/2022ACS_PUMS_User_Guide.pdf) 
The ACS PUMS is a weighted sample. Weighting variables must be used in order to calculate estimates which represent the actual population. Weighting variables are also needed to generate accurate measures of uncertainty, such as the standard error or margin of error. The PUMS files include both population weights (in the Person files) and household weights (located in the Housing files). Population weights should be used to generate statistics about individuals, and household weights should be used to generate statistics about housing units or households. The weighting variables are described briefly below.

- <u>PWGTP</u>: Person weight for generating statistics on individuals (such as age). PWGTP1-PWGTP80: Replicate Person weighting variables, used for generating the
standard error and margin of error for person characteristics.
- <u>WGTP</u>: Housing unit weight for generating statistics on housing units and households (such as household income).
- <u>WGTP1-WGTP80</u>: Replicate Housing Unit weighting variables, used for generating the standard error and margin of error for housing unit and household characteristics.

 The PUMS Weighting variables (PWGTP and WGTP) may both be used to generate PUMS estimates. They are also used in the generalized variance formulas (GVF) method for calculating standard errors using the design factors. Replicate weights may only be used to calculate standard errors and margins of error using the successive difference replication (SDR) method. The SDR method may also be referred to as direct standard errors.

##### Note on Income Quintile: from Equity Analysis Paper
Table 5. Income Quintile Distribution for SCAG Growth Forecasting Data (2011 Constant Dollars) 

|  Quintile   |       Range         |
|:------------|:-------------------:| 
| Quintile 1  | $0 to $19,585       |
| Quintile 2  | $19,586 to $43,990  |
| Quintile 3  | $43,991 to 73,717   |
| Quintile 4  | $73,718 to $121,205 |
| Quintile 5  | $121,206 and up     |

* Source: SCAG 2023 processed from U.S. Census Bureau ACS PUMS 2016-2020
