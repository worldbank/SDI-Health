/*
Clean Niger-2015 Module 2 Data From SDI Survey

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
	
	use "$raw/SDI_Niger-2015/SDI_Niger-2015_Module2_Raw.dta", clear

	gen has_roster = 1 if staff_id!=.
	gen has_absentee = 1 if m2sbq3!=.
	lab var has_roster "Provider was on roster during first visit"
	lab var has_absentee "Provider was included in absenteeism survey"

	//Create unique identifier
		tostring staff_id, replace
		tostring fac_id, replace
		gen unique_id = fac_id + "_" + staff_id
		lab var unique_id "Unique provider identifier: facility ID + provider ID"
		order unique_id fac_id staff_id

	//Create country variable
		gen country = "Niger-2015"

	//Recode gender variables
		recode m2saq10 (2=0)
		recode m2sbq8 (2=0)

	//Recode variables with yes-no response
		recode m2saq12 (2=0) 
		recode m2saq13 (2=0)
		recode m2sbq10 (2=0) 
		recode m2sbq13 (2=0) (-3=.a) 

	//Adjust other variables for missing values
		foreach v of varlist m2sbq9 m2sbq7 m2sbq6 m2sbq5 {
			recode `v' (-9=.)
		}

	//Adjust variables to match Tanzania-2014 standard
		//current activity
			recode m2sbq12 (6=9)

	//Calculate facility absenteeism rates
		bysort fac_id: egen totsurvey = count(m2sbq3)
		replace totsurvey=. if totsurvey==0
		bysort fac_id: egen totpresent = total(m2sbq10), m
		gen absence_rate = 1 - totpresent / totsurvey
		lab var absence_rate "Absenteeism rate at facility"
		drop tot*

	compress
	saveold "$clean/SDI_Niger-2015/niger-2015_roster_clean.dta", replace v(12)
