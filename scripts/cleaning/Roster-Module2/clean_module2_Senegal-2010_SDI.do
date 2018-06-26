/*
Clean Senegal-2010 Module 2 Data From SDI Survey

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
	
	use "$raw/SDI_Senegal-2010/SDI_Senegal-2010_Module2_Raw.dta", clear

	gen has_roster = 1 if mod1_id!=.
	gen has_absentee = 1 if mod2_id!=.
	gen has_absentee2 = 1 if mod3_id!=.
	lab var has_roster "Provider was on roster during first visit"
	lab var has_absentee "Provider was included in absenteeism survey"
	lab var has_absentee2 "Provider was included in second absenteeism survey"

	//Create unique identifier
		tostring staff_id, replace
		tostring fac_id, replace force //had label that prevents it from stringing
		gen unique_id = fac_id + "_" + staff_id
		lab var unique_id "Unique provider identifier: facility ID + provider ID"
		order unique_id fac_id staff_id

	//Create country variable
		gen country = "Senegal-2010"

	//Recode gender variables
		recode m1s2q5 (2=0)
		
	//Recode variables with yes-no response
		recode m1s2q9 (2=0) 
		recode m1s2q7 (2=0) 
		recode m2s1q3 (2=0) 
		recode m3s1q2 (2=0)
		recode m2s1q14 (2=0)
		recode m2s1q16 (2=0) 

	//Adjust variables to match Tanzania-2014 standard
		//reason for absence
			recode m1s2q10 (5=12) (6=7) (7=8) (8=9) (9=99)
			recode m3s1q3 (5=12) (6=7) (7=8) (8=9) (9=99)

	//Calculate facility absenteeism rates
		bysort fac_id: egen totsurvey = count(mod2_id)
		replace totsurvey=. if totsurvey==0
		bysort fac_id: egen totpresent = total(m2s1q3), m
		gen absence_rate = 1 - totpresent / totsurvey
		lab var absence_rate "Absenteeism rate at facility"

		bysort fac_id: egen totsurvey2 = count(mod3_id)
		replace totsurvey2=. if totsurvey2==0
		bysort fac_id: egen totpresent2 = total(m3s1q2), m
		gen absence_rate2 = 1 - totpresent2 / totsurvey2
		lab var absence_rate2 "Absenteeism rate at facility during second survey"

		drop tot*

	compress
	saveold "$clean/SDI_Senegal-2010/senegal-2010_roster_clean.dta", replace v(12)

*****************************************************************************
* Adjust weight variable
*****************************************************************************

	rename weight_m2 abs_wt
	lab var abs_wt "Health worker weight for absenteeism"

	drop weight_m1p weight_m3 strate

	compress
	saveold "$clean/SDI_Senegal-2010/senegal-2010_roster_clean.dta", replace v(12)
