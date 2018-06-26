/*
Clean Nigeria-2013 Module 1 Data From SDI Survey

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

	use "$raw/SDI_Nigeria-2013/SDI_Nigeria-2013_Module1_Raw.dta", clear

	gen has_facility = 1 if fac_id!=.
	lab var has_facility "Facility was included in infrastructure-supplies survey"

	//Create unique identifier
		tostring fac_id, replace 
		
	//Create country variable
		gen country = "Nigeria-2013"

	//Adjust variables to match Tanzania-2014 standard
		//whether communication equipment is functioning
			foreach v of varlist m1scq14b m1scq15b m1scq16b m1scq17b m1scq18b m1scq19b {
				recode `v' (2=0) (1=2)
			}

		//whether other equipment is functioning
			forvalues i = 1/11 {
				recode m1sdq`i'b (2=0) (1=2)
			}

		//male and female condoms
			rename m1seq32 m1seq32a
			gen m1seq32b = m1seq32a

		//whether certain supplies are present
			foreach v of varlist m1seq31 m1seq32a m1seq32b {
				recode `v' (1/3=1) (4/5=0)
			}

		//whether vaccines are available
			foreach v of varlist m1seq46 m1seq47 m1seq48 m1seq51 m1seq50 m1seq49 m1seq52 m1seq53 {
				recode `v' (1=1) (2=4) (3=5)
			}

	//Recode variables
		//missing values
			ds *, has(type numeric)
			foreach v of varlist `r(varlist)' {
				recode `v' (-9=.) (-99=.) (-999=.) (-99999=.)
			}

		//yes-no questions
			findname, vallabeltext("Yes")
			quietly foreach v of varlist `r(varlist)' {
				recode `v' (2=0)
			}

		//observed-not observed questions
			recode m1scq31 (3=0) (2=1) (1=2)
			
			findname, vallabeltext("Yes(Observed)")
			quietly foreach v of varlist `r(varlist)' {
				recode `v' (3=0) (2=1) (1=2)
			}

			findname, vallabeltext("Yes (observed)")
			quietly foreach v of varlist `r(varlist)' {
				recode `v' (3=0) (2=1) (1=2)
			}

			quietly foreach v of varlist m1seq54 m1seq55 m1seq56 m1seq57 m1seq58 {
				recode `v' (3=0) (2=1) (1=2)
			}

		//fridge availability
			recode m1seq33 (3=0) (2=2) (1=3)

	compress
	saveold "$clean/SDI_Nigeria-2013/nigeria-2013_infrastructure_clean.dta", replace v(12)

*****************************************************************************
* Add weights
*****************************************************************************

	use "$raw/SDI_Nigeria-2013/SDI_Nigeria-2013_Weights.dta", clear
	gen has_weights = 1 if fac_id!=.
	lab var has_weights "Facility had weight data"

	//Create unique identifier
		tostring fac_id, replace 
	
	merge 1:1 fac_id using "$clean/SDI_Nigeria-2013/nigeria-2013_infrastructure_clean.dta", nogen

	compress
	saveold "$clean/SDI_Nigeria-2013/nigeria-2013_infrastructure_clean.dta", replace v(12)
