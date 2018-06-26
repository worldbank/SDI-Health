/*
Clean Madagascar-2016 Module 3 Data From SDI Survey

Author: Anna Konstantinova
Last updated: May 3rd, 2018
*/

*****************************************************************************
* Preliminaries 
*****************************************************************************

	clear
	set more off

*****************************************************************************
* Module 3 
*****************************************************************************

	use "$raw/SDI_Madagascar-2016/SDI_Madagascar-2016_Module3_Raw.dta", clear

	gen has_vignette = 1
	lab var has_vignette "Provider completed vignette module"

	//Create unique identifier
		tostring staff_id, replace
		tostring fac_id, replace force //has facility name label
		gen unique_id = fac_id + "_" + staff_id
		lab var unique_id "Unique provider identifier: facility ID + provider ID"
		order unique_id fac_id staff_id

	//Create country variable
		gen country = "Madagascar-2016"

	//Recode values that were answered "No" 
		findname, vallabeltext("oui")
		quietly foreach v of varlist `r(varlist)' {
			recode `v' (2=0)
		}

		//Recode for additional variables that didn't have a value label
		recode m35q69 (2=0)
		recode m32q54 (2=0)
		recode m36q50 (2=0)
		recode m31q62 (2=0)
		recode m32q53 (2=0)

	//Capture whether vignette was skipped
		foreach z in "1" "2" "3" "4" "5" "6" "7" {
			ds m3`z'q*, has(type numeric)
			local vl "`r(varlist)'"
			egen did_v`z' = anycount(`vl'), val(1 3)
			gen missing_v`z' = 1 if did_v`z' == 0
			replace missing_v`z' = 0 if missing_v`z' == .
			drop did_v`z'
 		}

 	//Recode values that were answered "No" 
		findname, vallabeltext("oui")
		quietly foreach v of varlist `r(varlist)' {
			recode `v' (3=.a)
		}

		//Recode for additional variables that didn't have a value label
		recode m35q69 (3=.a)
		recode m32q54 (3=.a)
		recode m36q50 (3=.a)
		recode m31q62 (3=.a)
		recode m32q53 (3=.a)

	//Remove observations that are missing all vignettes
 		egen number_missing = anycount(missing_v*), val(1)
 		tab number_missing
 		drop if number_missing==7

	 //Recode observations in answered vignettes from missing to no
		foreach x in "1" "2" "3" "4" "5" "6" "7" {
			foreach var of var m3`x'q* {
				replace `var' = 0 if `var' == . & missing_v`x' == 0
				replace `var' = . if `var' == 0 & missing_v`x' == 1
			}
		}

	compress
	saveold "$clean/SDI_Madagascar-2016/madagascar-2016_vignettes_clean.dta", replace v(12)
