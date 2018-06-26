/*
Clean Kenya-2012 Module 2 Data From SDI Survey

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

	use "$raw/SDI_Kenya-2012/SDI_Kenya-2012_Module2_Raw.dta", clear

	gen has_roster = 1 if staff_id!=.
	gen has_absentee = 1 if q116b!=.
	lab var has_roster "Provider was on roster during first visit"
	lab var has_absentee "Provider was included in absenteeism survey"

	//Create unique identifier
		tostring staff_id, replace
		tostring fac_id, replace force //had label that prevents it from stringing
		gen unique_id = fac_id + "_" + staff_id
		lab var unique_id "Unique provider identifier: facility ID + provider ID"
		order unique_id fac_id staff_id

	//Create country variable
		gen country = "Kenya-2012"

	//Rename variables
		qui foreach var of varlist q* {
			local newname = substr("`var'", 1, 4)

			//Other option
				local isb = substr("`var'", 6, 1)
				if "`isb'" == "b" local newname = "`var'"

			rename `var' `newname'
		}

	//Recode gender variables
		recode q111 (2=0)
		recode q118 (2=0)

	//Recode variables with yes-no response
		recode q114 (2=0) (99=.) 
		recode q113 (2=0) (99=.)
		recode q122 (2=0) 
		recode q119 (2=0) 

	//Adjust variables to match Tanzania-2014 standard
		//reason for absence
			recode q115 (5=12) (6=10) (10=99) (77=.) (88=.) (99=.)
			recode q120 (5=12) (6=10) (10=99) (77=.) (88=.) (99=.)

		//current activity
			recode q121 (1=1) (4/7=1) (8=2) (2/3=3) (12=3) (16=3) (9=4) (11=4) (15=4) (10=5) (13/14=9) (17=9) (77=.) (88=.) (99=.)

	//Calculate facility absenteeism rates
		bysort fac_id: egen totsurvey = count(q116)
		replace totsurvey=. if totsurvey==0
		bysort fac_id: egen totpresent = total(q119), m
		gen absence_rate = 1 - totpresent / totsurvey
		lab var absence_rate "Absenteeism rate at facility"
		drop tot*

	compress
	saveold "$clean/SDI_Kenya-2012/kenya-2012_roster_clean.dta", replace v(12)

