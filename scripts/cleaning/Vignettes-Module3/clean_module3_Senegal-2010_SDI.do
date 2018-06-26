/*
Clean Senegal-2010 Module 3 Data From SDI Survey

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

	use "$raw/SDI_Senegal-2010/SDI_Senegal-2010_Module3_Raw.dta", clear

	gen has_vignette = 1
	lab var has_vignette "Provider completed vignette module"

	//Create unique identifier
		tostring staff_id, replace
		tostring fac_id, replace
		gen unique_id = fac_id + "_" + staff_id
		lab var unique_id "Unique provider identifier: facility ID + provider ID"
		order unique_id fac_id staff_id

	//Create country variable
		gen country = "Senegal-2010"

	//Adjust non-vignette variables
		recode m5s6q5 (2=0) //gender

	//Recode values that were answered "No" 
		findname, vallabeltext("Oui")
		quietly foreach v of varlist `r(varlist)' {
			recode `v' (2=0)
		}

		//Recode for additional variables that didn't have a value label
			foreach v of varlist m5s5q6_04 m5s5q4_06 m5s5q4_04 m5s5q3_06 m5s5q3_05 m5s2q3_03 m5s1q5_05 m5s1q4_05 m5s1q4_01  m5s1q3_04 m5s1q2_09 {
				recode `v' (2=0)
			}

	//Adjust variables to match Tanzania-2014 vignette standard
		//Malaria: History: Shiver and sweat
			rename m5s1q1_07 m5s1q1_07a
			gen m5s1q1_07b = m5s1q1_07a
			lab val m5s1q1_07b VG_C1_7 

		//Malaria: Test: Blood slide and rapid diagnostic test for malaria
			rename m5s1q3_01 m5s1q3_01a
			gen m5s1q3_01b = m5s1q3_01a
			lab val m5s1q3_01b VG_C1_25

		//Malaria: Diagnosis: Other
			gen m5s1q4_06 = 1 if m5s1q4_a1!="" | m5s1q4_a2!="" | m5s1q4_a3!="" | m5s1q4_a4!="" | m5s1q4_a5!=""
			replace m5s1q4_06 = 0 if m5s1q4_a1=="" & m5s1q4_a2=="" & m5s1q4_a3=="" & m5s1q4_a4=="" & m5s1q4_a5==""

		//Malaria: Treatment: Iron and iron+folic acid
			rename m5s1q5_04 m5s1q5_04a
			gen m5s1q5_04b = m5s1q5_04a
			lab val m5s1q5_04b VG_C1_37

		//Diarrhea: History: Cough and difficulty breathing
			rename m5s2q1_11 m5s2q1_11a
			gen m5s2q1_11b = m5s2q1_11a
			lab val m5s2q1_11b VG_C2_11

		//Diarrhea: Test: Stool for rota/adeno virus and stool for ova and cyst
			rename m5s2q3_01 m5s2q3_01a
			gen m5s2q3_01b = m5s2q3_01a
			lab val m5s2q3_01b VG_C2_21

		//Diarrhea: Diagnosis: Other
			gen m5s2q4_06 = 1 if m5s2q4_a1!="" | m5s2q4_a2!="" | m5s2q4_a3!="" | m5s2q4_a4!="" | m5s2q4_a5!=""
			replace m5s2q4_06 = 0 if m5s2q4_a1=="" & m5s2q4_a2=="" & m5s2q4_a3=="" & m5s2q4_a4=="" & m5s2q4_a5==""

		//Pneumonia: Test: Blood slide and rapid diagnostic test for malaria
			rename m5s3q3_03 m5s3q3_03a
			gen m5s3q3_03b = m5s3q3_03a
			lab val m5s3q3_03b VG_C3_17

		//Pneumonia: Diagnosis: Other
			gen m5s3q4_06 = 1 if m5s3q4_a1!="" | m5s3q4_a2!="" | m5s3q4_a3!="" | m5s3q4_a4!="" | m5s3q4_a5!=""
			replace m5s3q4_06 = 0 if m5s3q4_a1=="" & m5s3q4_a2=="" & m5s3q4_a3=="" & m5s3q4_a4=="" & m5s3q4_a5==""

		//PID: Diagnosis: Other
			gen m5s4q4_07 = 1 if m5s4q4_a1!="" | m5s4q4_a2!="" | m5s4q4_a3!="" | m5s4q4_a4!="" | m5s4q4_a5!=""
			replace m5s4q4_07 = 0 if m5s4q4_a1=="" & m5s4q4_a2=="" & m5s4q4_a3=="" & m5s4q4_a4=="" & m5s4q4_a5==""

		//TB: History: Chest pain and difficulty breathing
			rename m5s5q1_04 m5s5q1_04a
			gen m5s5q1_04b = m5s5q1_04a
			lab val m5s5q1_04b VG_C5_A4

		//TB: Test: Full blood count and hemoglobin
			egen m5s5q3_0456 = anymatch(m5s5q3_04 m5s5q3_05 m5s5q3_06), val(1)
			replace m5s5q3_0456 = 3 if m5s5q3_0456==0 & (m5s5q3_04==3 | m5s5q3_05==3 | m5s5q3_06==3)
			lab val m5s5q3_0456 VG_C5_20

		//TB: Diagnosis: Other
			gen m5s5q4_07 = 1 if m5s5q4_a1!="" | m5s5q4_a2!="" | m5s5q4_a3!="" | m5s5q4_a4!="" | m5s5q4_a5!=""
			replace m5s5q4_07 = 0 if m5s5q4_a1=="" & m5s5q4_a2=="" & m5s5q4_a3=="" & m5s5q4_a4=="" & m5s5q4_a5==""

	//Identify whether vignette was skipped
		foreach x in "1" "2" "3" "4" "5" {
			ds m5s`x'q*, has(type numeric)
			local vl "`r(varlist)'"
			egen did_v`x' = anycount(`vl'), val(1 8)
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
			foreach v of varlist m5s5q6_04 m5s5q4_06 m5s5q4_04 m5s5q3_06 m5s5q3_05 m5s2q3_03 m5s1q5_05 m5s1q4_05 m5s1q4_01  m5s1q3_04 m5s1q2_09 {
				recode `v' (3=.a)
			}

	//Remove observations that are missing all vignettes
		egen number_missing = anycount(missing_v*), val(1)
 		tab number_missing //3 are missing all vignettes
 		drop if number_missing==5

	//Recode observations in missing vignettes from no to missing and finished vignettes from missing to no
		foreach x in "1" "2" "3" "4" "5"{
			ds m5s`x'q*, has(type numeric)
			local vl "`r(varlist)'"
			foreach var of var `vl' {
				replace `var' = . if `var' == 0 & missing_v`x' == 1
				replace `var' = 0 if `var' ==. & missing_v`x' == 0
			}
		}

	compress
	saveold "$clean/SDI_Senegal-2010/senegal-2010_vignettes_clean.dta", replace v(12)

*****************************************************************************
* Adjust weight variable
*****************************************************************************

	rename weight_m5 vign_wt
	lab var vign_wt "Health worker weight for vignettes"

	drop strate

	compress
	saveold "$clean/SDI_Senegal-2010/senegal-2010_vignettes_clean.dta", replace v(12)
