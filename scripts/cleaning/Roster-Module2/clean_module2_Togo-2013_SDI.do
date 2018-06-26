/*
Clean Togo-2013 Module 2 Data From SDI Survey

Author: Anna Konstantinova
Last updated: June 5, 2018
*/

*****************************************************************************
* Preliminaries
*****************************************************************************

	clear
	set more off

*****************************************************************************
* Module 2
*****************************************************************************
	
	use "$raw/SDI_Togo-2013/SDI_Togo-2013_Module2_Raw.dta", clear

	gen has_roster = 1 if m2sfq4!=.
	gen has_absentee = 1 if m2sgq3!=.
	lab var has_roster "Provider was on roster during first visit"
	lab var has_absentee "Provider was included in absenteeism survey"

	//Create unique identifier
		tostring staff_id, replace
		tostring fac_id, replace force //had label that prevents it from stringing
		gen unique_id = fac_id + "_" + staff_id
		lab var unique_id "Unique provider identifier: facility ID + provider ID"
		order unique_id fac_id staff_id

	//Create country variable
		gen country = "Togo-2013"

	//Recode gender variables
		recode m2sfq10 (2=0)
		recode m2sgq6 (2=0)

	//Recode variables with yes-no response
		recode m2sfq12 (2=0) 
		recode m2sfq13  (2=0)
		recode m2sgq7 (2=0) 
		recode m2sgq10 (2=0) 

	//Adjust variables to match Tanzania-2014 standard
		//reason for absence
			recode m2sfq14 (10=11)
			recode m2sgq8 (10=11)

	//Calculate facility absenteeism rates
		bysort fac_id: egen totsurvey = count(m2sgq3)
		replace totsurvey=. if totsurvey==0
		bysort fac_id: egen totpresent = total(m2sgq7), m
		gen absence_rate = 1 - totpresent / totsurvey
		lab var absence_rate "Absenteeism rate at facility"
		drop tot*

	compress
	saveold "$clean/SDI_Togo-2013/togo-2013_roster_clean.dta", replace v(12)
