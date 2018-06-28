# SDI-Health

A short description of the data and materials contained in this repository follows:

### Deidentified Raw Data
The data provided in the "rawData" folder has been deidentified. The administrative regions in which the health facilities are located have been encoded. GPS coordinates are not available in this dataset. The following set of variables was recoded to prevent identification:
- *publicprivate*:  for-profit and non-profit private facilities were grouped under the heading "private"
- *ruralurban*:  urban and semi-urban were grouped under the heading "urban"
- *facility_level*:  facilities were reclassified as "hospitals", "health centers", and "health posts"
- *provider_cadre*:  providers were reclassified as "doctors", "clinical officers", "nurses", and "other"
- *provider_mededuc*:  medical education attainment was reclassified as "advanced", "diploma", "certificate", and "none"
- *provider_educ*:  general education attainment was reclassified as "primary", "secondary", and "post-secondary"

In addition, the following set of variables were removed from the data to prevent possible identification of the facility:
-	Date of visit
-	Questions related to finances and staff salaries
-	Questions related to access or distance to district headquarters or other hospital
-	Questions related to days and hours of operation and catchment area
-	Whether maternity waiting center or delivery room are present
-	Availability of emergency obstetric care, c-section services, blood transfusion, and surgery
-	Questions related to number of patient beds, hospitalizations, maternal and neonatal deaths or complications, and transfers for maternal cases
- Question related to power sources, water sources, toilet infrastructure, and presence of ambulances

### Cleaning code
In the "scripts/cleaning" folders, the do-files for cleaning each of the modules are saved under separate folders: "Infrastructure-Module1", "Roster-Module2", and "Vignettes-Module3". In each do-file, the following set of actions are executed:
- Variables are recoded for consistency with the value label that will be applied during the harmonization step (see metadata files for lists of these value labels).
- Variables are created, combined, or modified to align with the Tanzania-2014 benchmark survey. 
- Variables are checked to confirm that all missing values are coded as missing.
- Survey weights are added to the module 1 datasets.
- Indicator variables related to the module are created.

### Metadata Files
The metaData folder contains excel files for each of the three modules (vignettes, absenteeism, infrastructure) for each of the 10 surveys that have occured to date. There is also a template for each module that can be used to build a metadata file for future surveys. Each excel file contains all of the variables that have ever been included in the survey instrument to-date and specifies whether those variables were included in the given country survey. 

On each sheet, the first column, "rename" specifies the name the variable should have in the final harmonized dataset. The second column, "varlab", specifies the variable's label. The third column, "varname", specifies the name the variable had in the raw data. The fourth column, "vallab", specifies whether a particular value label should be attached to the variable. In the vignettes metadata files, there is an additional "notes" column where differences across instruments as compared to the Tanzania-2014 benchmark are described.

This information is used to harmonize the data in the final step of the cleaning process.

### Harmonized data
In the "scripts/harmonization" folder, there are three do-files, each responsible for harmonizing one module of the SDI survey. These do-files produce country specific data files that contain renamed, harmonized variables. The do-files also produce a single data file where all country datasets have been appended.  

### Using the data
Should you use this data for analysis, we recommend including this repository in your analysis repository as a submodule using the Git command:
```git submodule add https://github.com/worldbank/SDI-Health.git SDI-Health```

In this way, Git will associate your analysis with a specific commit of the data respository. The commit used in your analysis respository can be updated using the Git command: 
```git submodule update```


Data prepared and do-files written by Anna Konstantinova and Benjamin Daniels, with support from Jishnu Das, Waly Wane, Christophe Rockmore, and Matthew Collins.
