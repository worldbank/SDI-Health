/*
Clean Tanzania-2016 Module 3 Data From SDI Survey

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

	use "$raw/SDI_Tanzania-2016/SDI_Tanzania-2016_Module3_Raw.dta", clear

	gen has_vignette = 1
	lab var has_vignette "Provider completed vignette module"

	//Create unique identifier
		tostring staff_id, replace
		tostring fac_id, replace
		gen unique_id = fac_id + "_" + staff_id
		lab var unique_id "Unique provider identifier: facility ID + provider ID"
		order unique_id fac_id staff_id

	//Create country variable
		gen country = "Tanzania-2016"

	//Adjust non-vignette variables
		replace m3siq5=. if m3siq5==-9 //number of years working

	//Recode values that were answered "No" 
		findname, vallabeltext("Yes")
		quietly foreach v of varlist `r(varlist)' {
			recode `v' (2=0)
		}

		//Recode for additional variables that didn't have a value label
			recode m3sgq46 (2=0)
			recode m3shq22 (2=0)
			recode m3saq15 (2=0)

	//Adjust variables to match Tanzania-2014 vignette standard
		//Asphyxia: Diagnosis: Neonatal asphyxia and birth asphyxia
			egen m3shq2929a = anymatch(m3shq29 m3shq29a), val(1)
			replace m3shq2929a = 3 if m3shq2929a==0 & (m3shq29==3 | m3shq29a==3)
			lab val m3shq2929a M3SHQ29

	//Capture whether vignette was skipped
		foreach z in "b" "c" "d" "e" "f" "g" "h" {
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
			recode m3sgq46 (3=.a)
			recode m3shq22 (3=.a)

	//Remove observations that are missing all vignettes
 		egen number_missing = anycount(missing_v*), val(1)
 		tab number_missing 
 		drop if number_missing==7

	 //Recode observations in missing vignettes from no to missing
		foreach x in "b" "c" "d" "e" "f" "g" "h" {
			ds m3s`x'q*, has(type numeric)
			local vl "`r(varlist)'"
			foreach var of var `vl' {
				replace `var' = . if `var' == 0 & missing_v`x' == 1
				replace `var' = 0 if `var' == . & missing_v`x' == 0
			}
		}

	compress
	saveold "$clean/SDI_Tanzania-2016/tanzania-2016_vignettes_clean.dta", replace v(12)
