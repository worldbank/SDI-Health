/*
Harmonize SDI Roster-Absenteeism Data

Author: Anna Konstantinova
Last edited: March 2nd, 2019
*/

****************************************************************************
* Create standardized roster-absenteeism datasets – using ROSTER CODEBOOKS
****************************************************************************

	foreach place in $theCountries {

		use "$clean/SDI_`place'/`place'_roster_clean.dta", clear
		
		//Modify provider level characteristics data
			applyCodebook using "$metadata/`place'_roster_codebook", varlab rename vallab

		//Remove unwanted variables
			cap drop q*
			cap drop id m2* suite60
			cap drop m2*
			cap drop mod* m3* m1*
			cap drop h2*

		//Create additional identifier
			gen survey_id = country + "_" + unique_id

		//Change variable order
			order *, alpha
			order survey_id country unique_id facility_id provider_id

		//Save file
			compress
			saveold "$harmonized/SDI_`place'_Absenteeism.dta", replace v(12)

	}
	
****************************************************************************
* Append country datasets together
****************************************************************************
	
	clear

	foreach place in $theCountries {
		append using "$harmonized/SDI_`place'_Absenteeism.dta" 
		}
		
	//Create numeric country identifier
		encode country, gen(countrycode)
		order survey_id country countrycode unique_id facility_id provider_id

	//Save file
		compress
		saveold "$harmonized/SDI_AllCountries_Absenteeism.dta", replace v(12)
		
