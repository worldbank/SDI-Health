/*
Clean Senegal-2010 Data From SDI Survey

Author: Anna Konstantinova
Last updated: June 6, 2018
*/

*****************************************************************************
* Preliminaries 
*****************************************************************************

	clear
	set more off

*****************************************************************************
* Module 1
*****************************************************************************

	use "$raw/SDI_Senegal-2010/SDI_Senegal-2010_Module1_Raw.dta", clear

	gen has_facility = 1 if fac_id!=.
	lab var has_facility "Facility was included in infrastructure-supplies survey"

	//Create unique identifier
		tostring fac_id, replace 
		
	//Create country variable
		gen country = "Senegal-2010"

	//Adjust variables to match Tanzania-2014 standard
		//phone - land line, mobile owned by facility or mobile owned by individual
			gen m1s1q13b_a = m1s1q13b
			recode m1s1q13b_a (1=1) (2/3=2)

			gen m1s1q13b_b = m1s1q13b
			recode m1s1q13b_b (2=1) (1=2) (3=2)

			rename m1s1q13b m1s1q13b_c
			recode m1s1q13b_c (3=1) (1/2=2)

			foreach v of varlist m1s1q13b_a m1s1q13b_b m1s1q13b_c {
				recode `v' (2=0) (1=2)
			}

		//whether other equipment is available
			foreach x in "i" "ii" "iii" "iv" "v" "vi" "vii" "viii" {
				gen m1s3q1_`x'a = .
				replace m1s3q1_`x'a = 2 if m1s3q1_`x'>0 & m1s3q1_`x'!=.
				replace m1s3q1_`x'a = 0 if m1s3q1_`x'==0
			}

			gen m1s3q1_xa = .
			replace m1s3q1_xa = 1 if m1s3q1_x>0 & m1s3q1_x!=.
			replace m1s3q1_xa = 0 if m1s3q1_x==0 	

		//whether drug is available
			foreach v of varlist m1s3q2_* {
				recode `v' (1=1) (2=4) (3=5)
			}

		//DPT or pentavalent
			rename m1s3q6_ii m1s3q6_iia
			gen m1s3q6_iib = m1s3q6_iia

		//whether vaccine is available
			foreach v of varlist m1s3q6_* {
				recode `v' (1=1) (2=4) (3=5)
			}			

	//Recode variables
		//missing values
			ds *, has(type numeric)
			foreach v of varlist `r(varlist)' {
				recode `v' (-9=.) (-99=.) (-999=.) (-99999=.)
			}

		//yes-no questions
			recode m1s3q4 (2=0)
			recode m1s3q5 (2=0)
			recode m1s3q2_xvi (2=0)

	compress
	saveold "$clean/SDI_Senegal-2010/senegal-2010_infrastructure_clean.dta", replace v(12)

*****************************************************************************
* Adjust weight variable
*****************************************************************************

	drop strate

	compress
	saveold "$clean/SDI_Senegal-2010/senegal-2010_infrastructure_clean.dta", replace v(12)
