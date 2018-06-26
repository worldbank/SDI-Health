/*
Clean Togo-2013 Module 3 Data From SDI Survey

Author: Anna Konstantinova
Last updated: May 27th, 2018
*/

*****************************************************************************
********************************Preliminaries********************************
*****************************************************************************

	clear
	set more off

*****************************************************************************
* Module 3 - Vignettes 
*****************************************************************************

	use "$raw/SDI_Togo-2013/SDI_Togo-2013_Module3_Raw.dta", clear

	gen has_vignette = 1
	lab var has_vignette "Provider completed vignette module"

	//Create unique identifier
		tostring staff_id, replace
		tostring fac_id, replace force //has value label that prevents stringing
		gen unique_id = fac_id + "_" + staff_id
		lab var unique_id "Unique provider identifier: facility ID + provider ID"
		order unique_id fac_id staff_id

	//Create country variable
		gen country = "Togo-2013"

	//Recode values that were answered "No" 
		findname, vallabeltext("Oui")
		quietly foreach v of varlist `r(varlist)' {
			recode `v' (2=0) 
		}

		//Recode for additional variables that didn't have a value label
			recode m3snq15 (2=0) 
			recode m3snq17 (2=0) 
			recode m3snq18 (2=0) 
			recode m3smq65 (2=0) 
			recode m3smq49 (2=0) 
			recode m3smq38 (2=0) 
			recode m3siq42 (2=0) 
			recode m3siq43 (2=0) 

	//Adjust variables to match Tanzania-2014 vignette standard
		//Diabetes: Education: Avoid smoking and drinking
			rename m3skq54 m3skq54a
			gen m3skq54b = m3skq54a
			lab val m3skq54b M3SKQ54

		//TB: History: difficulty breathing and chest pain
			rename m3slq5 m3slq5a
			gen m3slq5b = m3slq5a
			lab val m3slq5b M3SLQ5

		//TB: History: Fever and fever pattern
			rename m3slq6 m3slq6a
			gen m3slq6b = m3slq6a
			lab val m3slq6b M3SLQ6

		//TB: Treatment: Combination therapy treatment and 6 month duration
			rename m3slq40 m3slq40a
			gen m3slq40b = m3slq40a
			lab val m3slq40b M3SLQ40

	 	//Malaria: History: Shiver and sweat
	 		rename m3smq4 m3smq4a
	 		gen m3smq4b = m3smq4a
			lab val m3smq4b M3SMQ4

	 	//PPH: History: Placenta praevia and placental abruption
		 	rename m3snq18 m3snq18a
		 	gen m3snq18b = m3snq18a
			lab val m3snq18b M3SNQ18

		//PPH: Treatment: Prostaglandins and misoprostol
			rename m3snq48 m3snq48a
			gen m3snq48b = m3snq48a
			lab val m3snq48b M3SNQ48

	//Identify whether vignette was skipped
		foreach x in "i" "j" "k" "l" "m" "n" "o" {
			ds m3s`x'q*, has(type numeric)
			local vl "`r(varlist)'"
			egen did_v`x' = anycount(`vl'), val(1 3)
			gen missing_v`x' = 1 if did_v`x' == 0
			replace missing_v`x' = 0 if missing_v`x' == .
			drop did_v`x'
 		}

 	//Recode values that were answered "After" 
		findname, vallabeltext("Oui")
		quietly foreach v of varlist `r(varlist)' {
			recode `v' (3=.a)
		}

		//Recode for additional variables that didn't have a value label
			recode m3snq15 (3=.a)
			recode m3snq17 (3=.a)
			recode m3snq18a (3=.a)
			recode m3snq18b (3=.a)
			recode m3smq65 (3=.a)
			recode m3smq49 (3=.a)
			recode m3smq38 (3=.a)
			recode m3siq42 (3=.a)
			recode m3siq43 (3=.a)

	//Remove observations that are missing all vignettes
 		egen number_missing = anycount(missing_v*), val(1)
 		tab number_missing //none are missing all
 		drop if number_missing==7

	 //Recode observations in missing vignettes from no to missing and completed vignettes from missing to no
	 	foreach x in "i" "j" "k" "l" "m" "n" "o" {
			ds m3s`x'q*, has(type numeric)
			local vl "`r(varlist)'"
			foreach var of var `vl' {
				replace `var' = . if `var' == 0 & missing_v`x' == 1
				replace `var' = 0 if `var' == . & missing_v`x' == 0
			}
		}
	
	compress
	saveold "$clean/SDI_Togo-2013/togo-2013_vignettes_clean.dta", replace v(12)
