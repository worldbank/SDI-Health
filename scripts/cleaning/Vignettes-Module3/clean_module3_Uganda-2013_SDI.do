/*
Clean Uganda-2013 Module 3 Data From SDI Survey

Author: Anna Konstantinova
Last updated: May 27th, 2018
*/

*****************************************************************************
* Preliminaries
*****************************************************************************

	clear
	set more off

*****************************************************************************
* Module 3 - Vignettes 
*****************************************************************************

	use "$raw/SDI_Uganda-2013/SDI_Uganda-2013_Module3_Raw.dta", clear

	gen has_vignette = 1
	lab var has_vignette "Provider completed vignette module"

	//Create unique identifier
		tostring staff_id, replace
		tostring fac_id, replace
		gen unique_id = fac_id + "_" + staff_id
		lab var unique_id "Unique provider identifier: facility ID + provider ID"
		order unique_id fac_id staff_id

	//Create country variable
		gen country = "Uganda-2013"

	//Rename variables
		rename *, lower

	//Recode values that were answered "No" 
		findname, vallabeltext("Yes")
		quietly foreach v of varlist `r(varlist)' {
			recode `v' (2=0) 
		}

		//Recode for additional variables that didn't have a value label
			recode h3se42 (2=0)

	//Adjust variables to match Tanzania-2014 vignette standard
		//Pneumonia: History: blood in sputum and color of sputum 
			rename h3sc4 h3sc4a
			gen h3sc4b = h3sc4a
			lab var h3sc4b MC4

		//Pneumonia: Treatment: Antipyretics and paracetamol
			rename h3sc36 h3sc36a
			gen h3sc36b = h3sc36a
			lab var h3sc36b MC36

		//Pneumonia: Education: Return if child worsens or danger signs
			rename h3sc42 h3sc42a
			gen h3sc42b = h3sc42a
			lab var h3sc42b MC42

		//TB: History: difficulty breathing and chest pain
			rename h3se5 h3se5a
			gen h3se5b = h3se5a
			lab var h3se5b ME5

		//TB: History: Fever and fever pattern
			rename h3se6 h3se6a
			gen h3se6b = h3se6a
			lab var h3se6b ME6

		//TB: Test: Full blood count and hemoglobin
			egen h3se3637 = anymatch(h3se36 h3se37), val(1)
			replace h3se3637 = 3 if h3se3637==0 & (h3se36==3 | h3se37==3)
			lab var h3se3637 ME36

	 	//Malaria: History: Shiver and sweat
	 		rename h3sf3 h3sf3a
	 		gen h3sf3b = h3sf3a
			lab var h3sf3b MF3

	 	//Malaria: Test: Full blood count and hemoglobin
	 		rename h3sf33 h3sf33a
	 		gen h3sf33b = h3sf33a
			lab var h3sf33b MF33

	 	//PPH: History: Placenta praevia and placental abruption
		 	rename h3sg13 h3sg13a
		 	gen h3sg13b = h3sg13a
			lab var h3sg13b MG13

		//PPH: Treatment: Prostaglandins and misoprostol
			rename h3sg43 h3sg43a
			gen h3sg43b = h3sg43a
			lab var h3sg43b MG43

	//Identify whether vignette was skipped
		foreach x in "b" "c" "d" "e" "f" "g" "i" {
			ds h3s`x'*, has(type numeric)
			local vl "`r(varlist)'"
			egen did_v`x' = anycount(`vl'), val(1 3)
			gen missing_v`x' = 1 if did_v`x' == 0
			replace missing_v`x' = 0 if missing_v`x' == .
			drop did_v`x'
 		}

 	//Recode values that were answered "After" 
		findname, vallabeltext("Yes")
		quietly foreach v of varlist `r(varlist)' {
			recode `v' (3=.a)
		}

		//Recode for additional variables that didn't have a value label
			recode h3se42 (3=.a)

	//Remove observations that are missing all vignettes
 		egen number_missing = anycount(missing_v*), val(1)
 		tab number_missing //1 is missing all vignettes
 		drop if number_missing==7

	 //Recode observations in missing vignettes from no to missing and completed vignettes from missing to no
	 	foreach x in "b" "c" "d" "e" "f" "g" "i" {
			ds h3s`x'*, has(type numeric)
			local vl "`r(varlist)'"
			foreach var of var `vl' {
				replace `var' = . if `var' == 0 & missing_v`x' == 1
				replace `var' = 0 if `var' == . & missing_v`x' == 0
			}
		}
	
	compress
	saveold "$clean/SDI_Uganda-2013/uganda-2013_vignettes_clean.dta", replace v(12)
