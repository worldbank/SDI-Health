/*
Clean Niger-2015 Module 3 Data From SDI Survey

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

	use "$raw/SDI_Niger-2015/SDI_Niger-2015_Module3_Raw.dta", clear

	gen has_vignette = 1
	lab var has_vignette "Provider completed vignette module"

	//Create unique identifier
		tostring staff_id, replace
		tostring fac_id, replace
		gen unique_id = fac_id + "_" + staff_id
		lab var unique_id "Unique provider identifier: facility ID + provider ID"
		order unique_id fac_id staff_id

	//Create country variable
		gen country = "Niger-2015"

	//Adjust non-vignette variables
		replace m3skq5a=. if m3skq5a==-9 //frequency other consultation
		replace m3skq3a=. if m3skq3a==-9 //frequency anc
		replace m3skq4a=. if m3skq4a==-9 //frequency adult
		replace m3skq2a=. if m3skq2a==-9 //frequency obgyn
		replace m3skq1a=. if m3skq1a==-9 //frequency pediatrics
		replace m3skq6=. if m3skq6==-9 //number of years working

	//Recode values that were answered "No" 
		findname, vallabeltext("Oui")
		quietly foreach v of varlist `r(varlist)' {
			recode `v' (2=0)
		}

		//Recode for additional variables that didn't have a value label
			foreach v of varlist m3sjq90 m3sjq87 m3sjq84 m3sjq15 m3siq157 m3siq61 m3siq60 m3siq59 m3siq58 m3siq56 m3siq52 m3siq50 m3sfq38 m3scq45d {
				recode `v' (2=0)
			}
			recode m3saq15 (2=0)

	//Adjust variables to match Tanzania-2014 vignette standard
		//Malaria: Test: Sickle cell anemia
			egen m3sfq5657 = anymatch(m3sfq56 m3sfq57), val(1)
			replace m3sfq5657 = 3 if m3sfq5657==0 & (m3sfq56==3 | m3sfq57==3)
			lab val m3sfq5657 M3SFQ56

	//Capture whether vignette was skipped
		foreach z in "b" "c" "d" "e" "f" "g" "h" "i" "j" {
			ds m3s`z'q*, has(type numeric)
			local vl "`r(varlist)'"
			egen did_v`z' = anycount(`vl'), val(1 3)
			gen missing_v`z' = 1 if did_v`z' == 0
			replace missing_v`z' = 0 if missing_v`z' == .
			drop did_v`z'
 		}

 	//Recode values that were answered "After" 
		findname, vallabeltext("Oui")
		quietly foreach v of varlist `r(varlist)' {
			recode `v' (3=.a)
		}

		//Recode for additional variables that didn't have a value label
			foreach v of varlist m3sjq90 m3sjq87 m3sjq84 m3sjq15 m3siq157 m3siq61 m3siq60 m3siq59 m3siq58 m3siq56 m3siq52 m3siq50 m3sfq38 m3scq45d {
				recode `v' (3=.a)
			}

	//Remove observations that are missing all vignettes
 		egen number_missing = anycount(missing_v*), val(1)
 		tab number_missing 
 		drop if number_missing==7

	 //Recode observations in missing vignettes from no to missing
		foreach x in "b" "c" "d" "e" "f" "g" "h" "i" "j" {
			ds m3s`x'q*, has(type numeric)
			local vl "`r(varlist)'"
			foreach var of var `vl' {
				replace `var' = . if `var' == 0 & missing_v`x' == 1
				replace `var' = 0 if `var' == . & missing_v`x' == 0
			}
		}

	compress
	saveold "$clean/SDI_Niger-2015/niger-2015_vignettes_clean.dta", replace v(12)
