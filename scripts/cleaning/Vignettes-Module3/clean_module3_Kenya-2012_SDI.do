/*
Clean Kenya-2012 Module 3 Data From SDI Survey

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
	
	use "$raw/SDI_Kenya-2012/SDI_Kenya-2012_Module3_Raw.dta", clear

	gen has_vignette = 1
	lab var has_vignette "Provider completed vignette module"

	//Create unique identifier
		tostring staff_id, replace
		gen unique_id = fac_id + "_" + staff_id
		lab var unique_id "Unique provider identifier: facility ID + provider ID"
		order unique_id fac_id staff_id

	//Create country variable
		gen country = "Kenya-2012"

	//Rename variables
		qui foreach var of varlist q* {
			local newname = substr("`var'", 1, 4)

			//Check if about enumerator
				local isenum = substr("`var'", -14, 4)
				if "`isenum'" == "code" local newname = "`var'"
				if "`isenum'" == "name" local newname = "`var'"

			//Check if its a note
				local isnote = substr("`var'", 6, 4)
				if "`isnote'" == "note" local newname = "`var'"

			//Check if its refusal
				local isrefusal = substr("`var'", 6, 7)
				if "`isrefusal'" == "refusal" local newname = "`var'"

			//Other rules
				local isb = substr("`var'", 5, 1)
				if "`isb'" == "b" local newname = substr("`var'", 1, 5)

				local is_ = substr("`var'", 5, 3)
				if "`is_'" == "_a_" local newname = substr("`var'", 1, 6)
				if "`is_'" == "_b_" local newname = substr("`var'", 1, 6)

			rename `var' `newname'
		}

	//Recode values that were answered "No" 
		findname, vallabeltext("YES")
		quietly foreach v of varlist `r(varlist)' {
			recode `v' (2=0)
		}

		//Recode for additional variables that didn't have a value label
			recode q230 (2=0) 
			recode q196 (2=0)
			recode q197 (2=0) 
			recode q258 (2=0) 

	//Adjust variables to match Tanzania-2014 vignette standard
		//Pneumonia: History: Blood in sputum and color of sputum
			rename q185 q185a
			gen q185b = q185a
			lab val q185b Q185_BLOOD_IN_SPUTUM

		//Pneumonia: Treatment: Antipyretics and paracetamol
			rename q213_a q213_aa
			gen q213_ab = q213_aa
			lab val q213_ab Q213_A_GIVE_ANTIPYRETICS_E_G

		//Pneumonia: Education: Return if child worsens and return if danger signs
			rename q218 q218a
			gen q218b = q218a
			lab val q218b Q218_INSTRUCT_PARENT_TO_RETURN

		//TB: History: Chest pain and difficulty breathing 
			rename q269 q269a
			gen q269b = q269a
			lab val q269b Q269_CHEST_PAIN_BREATHING_DIFFIE

		//TB: History: Fever and fever pattern
			rename q270 q270a
			gen q270b = q270a
			lab val q270b Q270_PRESENCE_OF_FEVER_AND_PATTP

		//TB: Test: Full blood count and hemoglobin
			egen q297298 = anymatch(q297 q298), val(1)
			replace q297298 = .a if q297298==0 & (q297==.a | q298==.a)
			lab val q297298 Q297_HAEMOGRAM_FULL_BLOOD_COUNV

	 	//Malaria: History: Shiver and sweat
	 		rename q313 q313a
	 		gen q313b = q313a
	 		lab val q313b Q313_SHIVER_OR_SWEAT

	 	//PPH: History: Placenta praevia and placental abruption
		 	rename q367 q367a
		 	gen q367b = q367a
		 	lab val q367b Q367_PLACENTA_PRAEVIA_ABRUPTIOP

		//PPH: PPH: Treatment: Prostaglandins and misoprostol
			rename q391 q391a
			gen q391b = q391a
			lab val q391b Q391_GIVE_PROSTAGLANDINS

	//Identify whether vignette was skipped
		local vlv1 = ""
		forvalues i = 135/181 {
			foreach x of var q`i'* {
				local newvar `x'
				local vlv1 = "`vlv1' `newvar'"
			}
		}

		local vlv2 = ""
		forvalues i = 182/218 {
			foreach x of var q`i'* {
				local newvar `x'
				local vlv2 = "`vlv2' `newvar'"
			}
		}

		local vlv3 = ""
		forvalues i = 219/264 {
			foreach x of var q`i'* {
				local newvar `x'
				local vlv3 = "`vlv3' `newvar'"
			}
		}

		local vlv4 = ""
		forvalues i = 265/310 {
			foreach x of var q`i'* {
				local newvar `x'
				local vlv4 = "`vlv4' `newvar'"
			}
		}

		local vlv5 = ""
		forvalues i = 311/354 {
			foreach x of var q`i'* {
				local newvar `x'
				local vlv5 = "`vlv5' `newvar'"
			}
		}

		local vlv6 = ""
		forvalues i = 355/393 {
			foreach x of var q`i'* {
				local newvar `x'
				local vlv6 = "`vlv6' `newvar'"
			}
		}

		local vlv7 = ""
		forvalues i = 394/411 {
			foreach x of var q`i'* {
				local newvar `x'
				local vlv7 = "`vlv7' `newvar'"
			}
		}

		lab def missinglab 0 "Did vignette" 1 "Skipped vignette"
		foreach x in "1" "2" "3" "4" "5" "6" "7" {
			ds `vlv`x'', has(type numeric)
			local vl "`r(varlist)'"
			egen did_v`x' = anycount(`vl'), val(1 3)

			gen missing_v`x' = 1 if did_v`x' == 0
			replace missing_v`x' = 0 if missing_v`x' == .
			lab val missing_v`x' missinglab
			
			drop did_v`x'
 		}

 	//Recode values that were answered "After" 
		findname, vallabeltext("YES")
		quietly foreach v of varlist `r(varlist)' {
			recode `v' (3=.a)
		}

		//Recode for additional variables that didn't have a value label
			recode q230 (3=.a)
			recode q196 (3=.a)
			recode q197 (3=.a)
			recode q258 (3=.a)

	//Remove observations that are missing all vignettes
 		egen number_missing = anycount(missing_v*), val(1)
 		tab number_missing //none are missing all
 		drop if number_missing==7

	//Recode observations in missing vignettes from no to missing and finished vignettes from missing to no
		foreach x in "1" "2" "3" "4" "5" "6" "7" {
			ds `vlv`x'', has(type numeric)
			local vl "`r(varlist)'"
			foreach var of var `vl' {
				replace `var' = . if `var' == 0 & missing_v`x' == 1
				replace `var' = 0 if `var' ==. & missing_v`x' == 0
			}
		}

	compress
	saveold "$clean/SDI_Kenya-2012/kenya-2012_vignettes_clean.dta", replace v(12)
