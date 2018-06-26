/*
Clean Tanzania-2016 Module 2 Data From SDI Survey

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

	use "$raw/SDI_Tanzania-2016/SDI_Tanzania-2016_Module2_Raw.dta", clear

	gen has_roster = 1 if m2saq4!=.
	gen has_absentee = 1 if m2sbq3!=.
	lab var has_roster "Provider was on roster during first visit"
	lab var has_absentee "Provider was included in second absenteeism survey"

	//Create unique identifier
		tostring staff_id, replace
		tostring fac_id, replace
		gen unique_id = fac_id + "_" + staff_id
		lab var unique_id "Unique provider identifier: facility ID + provider ID"
		order unique_id fac_id staff_id

	//Create country variable
		gen country = "Tanzania-2016"

	//Recode gender variables
		recode m2saq10 (2=0) (-9=.)
		recode m2sbq9 (2=0) (-9=.)

	//Recode variables with yes-no response
		recode m2saq12 (2=0) (-9=.)
		recode m2saq13 (2=0) (-9=.)
		recode m2sbq11 (2=0) (-9=.)
		recode m2sbq14 (2=0) (-9=.)

	//Adjust other variables for missing values
		foreach v of varlist m2saq11 m2sbq10 m2saq9 m2sbq7 m2saq8 m2sbq6 m2saq7 m2sbq5 {
			recode `v' (-9=.)
		}

	//Calculate facility absenteeism rates
		bysort fac_id: egen totsurvey = count(m2sbq3)
		replace totsurvey=. if totsurvey==0
		bysort fac_id: egen totpresent = total(m2sbq11), m
		gen absence_rate = 1 - totpresent / totsurvey
		lab var absence_rate "Absenteeism rate at facility"
		drop tot*

	compress
	saveold "$clean/SDI_Tanzania-2016/tanzania-2016_roster_clean.dta", replace v(12)
