/*
Clean Nigeria-2013 Module 3 Data From SDI Survey

Author: Anna Konstantinova
Last updated: May 27th, 2018
*/

*****************************************************************************
* Preliminaries 
*****************************************************************************

	clear
	set more off

*****************************************************************************
* Module 3 
*****************************************************************************

	use "$raw/SDI_Nigeria-2013/SDI_Nigeria-2013_Module3_Raw.dta", clear

	gen has_vignette = 1
	lab var has_vignette "Provider completed vignette module"

	//Create unique identifier
		tostring staff_id, replace
		tostring fac_id, replace
		gen unique_id = fac_id + "_" + staff_id
		lab var unique_id "Unique provider identifier: facility ID + provider ID"
		order unique_id fac_id staff_id

	//Create country variable
		gen country = "Nigeria-2013"

	//Rename variables
		rename *a *

	//Adjust non-vignette variables
		replace m3sa1q11=. if m3sa1q11==0 //medical education

	//Recode values that were answered "No" 
		findname, vallabeltext("Yes")
		quietly foreach v of varlist `r(varlist)' {
			recode `v' (2=0)
		}

		//Recode for additional variables that had different response
			recode m3sdq8 (8=.)

	//Adjust variables to match Tanzania-2014 vignette standard
		//Pneumonia: History: Blood in sputum and color of sputum
			rename m3sdq4 m3sdq4a
			gen m3sdq4b = m3sdq4a
			lab val m3sdq4b M3SDQ4A

		//TB: History: Difficulty breathing and chest pain 
			rename m3sfq5 m3sfq5a
			gen m3sfq5b = m3sfq5a
			lab val m3sfq5b M3SFQ5A

		//TB: History: Fever and fever pattern
			rename m3sfq7 m3sfq7a
			gen m3sfq7b = m3sfq7a
			lab val m3sfq7b M3SFQ7A

		//TB: Test: Full blood count and hemoglobin
			egen m3sfq3435 = anymatch(m3sfq34 m3sfq35), val(1)
			replace m3sfq3435 = 3 if m3sfq3435==0 & (m3sfq34==3 | m3sfq35==3)
			lab val m3sfq3435 M3SFQ34A
			
	 	//Malaria: History: Shiver and sweat 
			rename m3sgq3 m3sgq3a
			gen m3sgq3b = m3sgq3a	
			lab val m3sgq3b M3SGQ3A

		//Malaria: Test: Full blood count and hemoglobin
			rename m3sgq31 m3sgq31a
			gen m3sgq31b = m3sgq31a
			lab val m3sgq31b M3SGQ31A

	 	//PPH: History: Placenta praevia and placental abruption
			rename m3shq13 m3shq13a
			gen m3shq13b = m3shq13a
			lab val m3shq13b M3SHQ13A

		//PPH: Treatment: Prostaglandins and misoprostol
			rename m3shq36 m3shq36a
			gen m3shq36b = m3shq36a	
			lab val m3shq36b M3SHQ36A
	
	//Capture whether vignette was skipped
		foreach x in "c" "d" "e" "f" "g" "h" "i" {
			ds m3s`x'q*, has(type numeric)
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

 	//Remove observations that are missing all vignettes
 		egen number_missing = anycount(missing_v*), val(1)
 		tab number_missing
 		drop if number_missing==7

 	//Recode observations in answered vignettes from missing to no or skipped vignette from 0 to .
		foreach x in "c" "d" "e" "f" "g" "h" "i" {
			foreach var of var m3s`x'q* {
				replace `var' = 0 if `var' == . & missing_v`x' == 0
				replace `var' = . if `var' == 0 & missing_v`x' == 1
			}
		}
	
	compress
	saveold "$clean/SDI_Nigeria-2013/nigeria-2013_vignettes_clean.dta", replace v(12)
