/*
Clean Mozambique-2014 Module 3 Data From SDI Survey

Author: Anna Konstantinova
Last updated: May 28th, 2018
*/

*****************************************************************************
* Preliminaries 
*****************************************************************************

	clear
	set more off

*****************************************************************************
* Module 3 
*****************************************************************************

	use "$raw/SDI_Mozambique-2014/SDI_Mozambique-2014_Module3_Raw.dta", clear

	gen has_vignette = 1
	lab var has_vignette "Provider completed vignette module"

	//Create unique identifier
		tostring staff_id, replace
		tostring fac_id, replace
		gen unique_id = fac_id + "_" + staff_id
		lab var unique_id "Unique provider identifier: facility ID + provider ID"
		order unique_id fac_id staff_id

	//Create country variable
		gen country = "Mozambique-2014"

	//Adjust non-vignette variables
		replace m3skq3=. if m3skq3==-8 //frequency obgyn
		replace m3skq1=. if m3skq1==-8 //frequency pediatrics
		replace m3sbq8=. if m3sbq8==99 //medical education

	//Recode values that were answered "No" 
		findname, vallabeltext("Yes")
		quietly foreach v of varlist `r(varlist)' {
			recode `v' (2=0)
		}

		//Recode for additional variables that didn't have a value label
			recode m3siq49 (2=0)
			recode m3siq46 (2=0)
			recode m3sbq10 (2=0)

	//Adjust variables to match Tanzania-2014 vignette standard
		//Malaria: Test: Hemoglobin and full blood count
			rename m3shq49 m3shq49a
			gen m3shq49b = m3shq49a
			lab val m3shq49b M3SDQ2_01

	//Capture whether vignette was skipped
		foreach z in "d" "e" "f" "g" "h" "i" "j" {
			ds m3s`z'q*, has(type numeric)
			local vl "`r(varlist)'"
			egen did_v`z' = anycount(`vl'), val(1 3)
			gen missing_v`z' = 1 if did_v`z' == 0
			replace missing_v`z' = 0 if missing_v`z' == .
			drop did_v`z'
 		}

 	//Recode values that were answered "After" 
		findname, vallabeltext("Yes")
		quietly foreach v of varlist `r(varlist)' {
			recode `v' (3=.a)
		}

		//Recode for additional variables that didn't have a value label
			recode m3siq49 (3=.a)
			recode m3siq46 (3=.a)

	//Remove observations that are missing all vignettes
 		egen number_missing = anycount(missing_v*), val(1)
 		tab number_missing 
 		drop if number_missing==7

	 //Recode observations in missing vignettes from no to missing
		foreach x in "d" "e" "f" "g" "h" "i" "j" {
			ds m3s`x'q*, has(type numeric)
			local vl "`r(varlist)'"
			foreach var of var `vl' {
				replace `var' = . if `var' == 0 & missing_v`x' == 1
				replace `var' = 0 if `var' == . & missing_v`x' == 0
			}
		}

	compress
	saveold "$clean/SDI_Mozambique-2014/mozambique-2014_vignettes_clean.dta", replace v(12)
