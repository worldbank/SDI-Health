/*
Clean Uganda-2013 Module 2 Data From SDI Survey

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
	
	use "$raw/SDI_Uganda-2013/SDI_Uganda-2013_Module2_Raw.dta", clear

	gen has_roster = 1 if staff_id!=.
	gen has_absentee = 1 if h2b211!=.
	lab var has_roster "Provider was on roster during first visit"
	lab var has_absentee "Provider was included in absenteeism survey"

	//Create unique identifier
		tostring staff_id, replace
		tostring fac_id, replace force //had label that prevents it from stringing
		gen unique_id = fac_id + "_" + staff_id
		lab var unique_id "Unique provider identifier: facility ID + provider ID"
		order unique_id fac_id staff_id

	//Create country variable
		gen country = "Uganda-2013"

	//Recode gender variables
		recode h2sa204 (2=0)
		recode h2b213 (2=0)

	//Recode variables with yes-no response
		recode h2sa207 (2=0) 
		recode h2sa206 (2=0)
		recode h2b214 (2=0) (4/5=.)
		recode h2b217 (2=0) (0=.)

	//Adjust variables to match Tanzania-2014 standard
		//reason for absence
			recode h2b215 (5=12) (6=10)
			recode h2sa208 (5=12) (6=10)

		//current activity
			recode h2b216 (1=1) (4/7=1) (17=1) (8=2) (2/3=3) (12=3) (16=3) (9=4) (11=4) (15=4) (10=5) (13/14=9) (18=9)

	//Calculate facility absenteeism rates
		bysort fac_id: egen totsurvey = count(h2b211)
		replace totsurvey=. if totsurvey==0
		bysort fac_id: egen totpresent = total(h2b214), m
		gen absence_rate = 1 - totpresent / totsurvey
		lab var absence_rate "Absenteeism rate at facility"
		drop tot*

	compress
	saveold "$clean/SDI_Uganda-2013/uganda-2013_roster_clean.dta", replace v(12)
