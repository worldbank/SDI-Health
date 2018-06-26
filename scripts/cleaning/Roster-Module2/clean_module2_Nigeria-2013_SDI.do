/*
Clean Nigeria-2013 Module 2 Data From SDI Survey

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

	use "$raw/SDI_Nigeria-2013/SDI_Nigeria-2013_Module2_Raw.dta", clear

	gen has_roster = 1 if staff_id!=.
	gen has_absentee = 1 if m2sbq2!=.
	lab var has_roster "Provider was on roster during first visit"
	lab var has_absentee "Provider was included in absenteeism survey"

	//Create unique identifier
		tostring staff_id, replace
		tostring fac_id, replace force //had label that prevents it from stringing
		gen unique_id = fac_id + "_" + staff_id
		lab var unique_id "Unique provider identifier: facility ID + provider ID"
		order unique_id fac_id staff_id

	//Create country variable
		gen country = "Nigeria-2013"

	//Recode gender variables
		recode m2saq6 (2=0)
		recode m2sbq4 (2=0)

	//Recode variables with yes-no response
		recode m2saq9 (2=0) 
		recode m2saq8 (2=0)
		recode m2sbq8 (2=0) 
		recode m2sbq11 (2=0) 

	//Adjust other variables for missing values
		foreach v of varlist m2saq5 {
			recode `v' (0=.)
		}

		recode m2sbq12 (3=.) (7=.)

	//Adjust variables to match Tanzania-2014 standard
		//reason for absence
			recode m2saq10 (5=12) (6=10) (10=99)
			recode m2sbq9 (5=12) (6=10) (10=99)

		//current activity
			recode m2sbq10 (1=1) (4/7=1) (8=2) (2/3=3) (12=3) (16=3) (9=4) (11=4) (15=4) (10=5) (13/14=9) (17=9)

	//Calculate facility absenteeism rates
		bysort fac_id: egen totsurvey = count(m2sbq2)
		replace totsurvey=. if totsurvey==0
		bysort fac_id: egen totpresent = total(m2sbq8), m
		gen absence_rate = 1 - totpresent / totsurvey
		lab var absence_rate "Absenteeism rate at facility"
		drop tot*

	compress
	saveold "$clean/SDI_Nigeria-2013/nigeria-2013_roster_clean.dta", replace v(12)
