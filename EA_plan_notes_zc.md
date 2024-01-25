---
title: "EA Tech Support Plan and Docs"
author: "Zack Crowley"
date: "1/23/24"
output: html_document
---


### Main Data Files: 
- ACS raw PUMS data: download the two files (sas_csv and sas_csv) from [US Census ACS PUMS](https://www2.census.gov/programs-surveys/acs/data/pums/2021/5-Year/) which was saved in [data folder here](../data)  

--- 

### Docs received from Annaleigh at SCAG from [Temp-Equity Analysis](https://scag.sharepoint.com/sites/PublicLibrary/Shared%20Documents/Forms/AllItems.aspx?id=%2Fsites%2FPublicLibrary%2FShared%20Documents%2FEquity%20Working%20Group%2FTemp%2DEquity%20Analysis&p=true&ga=1):
- the SAS script that we have (in case it is helpful to you)
- the intermediate files that we received from the staff that ran the SAS script (2023_Equity Indicators_ACS1721_...)
- the list of figures/tables that we'd like to be a part of the baseline conditions section with the county-level data visualizations (2023 Equity indicators, note you can filter by Data Source [PUMS] and Table/Figure numbers in Column K)
  - One note is that the demographics (Historical Demographic Trends) section of the Equity analysis didn't have the same visualizations that the Baseline Conditions Reports had, so we would like to have the option to separate some of these out into new visualizations (maybe this is the purpose of having the "raw" data file!)

### SCAG expectations/deliverables:
  - Develop script (in R) for compiling necessary "raw" data points from baseline conditions report into one document to provide flexibility in what data gets visualized/how the dashboard is structured
  - Develop script (either incorporated in the first, or separate) to create a document (that can be opened in Excel) with one tab for each of the designated topic areas indicated by SCAG
  - Develop "walk-through" documentation to show how to run the script(s) for future updates (or prior years)
  
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
  
### Figures/Tables with Descriptions:
- Figure 5. Workers who Commute by Walk, Bike, or Public Transit by Race and Ethnicity
- Figure 6. Householders without a Vehicle by Race and Ethnicity
- Figure 7. Workers’ Commute Times (Minutes) by Mode and Race and Ethnicity
- Table 9. Transportation Mode Usage by Income Quintile in the SCAG Region (Source: 2017 NHTS, income quintiles calculated by SCAG) *NOT SURE IF WE CAN DO WITH ACS PUMS
- Table 10. Transportation Mode Usage by Race and Ethnicity in the SCAG Region (Source: 2017 NHTS) *NOT SURE IF WE CAN DO WITH ACS PUMS
- Figure 19. Renters and Homeowners Experiencing Housing Cost Burden by Race and Ethnicity
- Figure 20. People Living in Households Without Kitchen and Plumbing Facilities by Race and Ethnicity
- Figure 21. Households with Severe Overcrowding by Race and Ethnicity
- Figure 22. Homeownership by Race and Ethnicity
- Figure 28. People without Health Insurance by Race and Ethnicity
- Figure 39. Median Hourly Wage by Race and Ethnicity
- Figure 40. Unemployment by Race and Ethnicity
- Figure 41. Working Poor by Race and Ethnicity
- *Repeted from above: Demographics charts/tables (from Racial Equity Baseline Conditions Report (REBCR))
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
