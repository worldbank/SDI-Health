/*
Clean Togo-2013 Module 1 Data From SDI Survey

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

	use "$raw/SDI_Togo-2013/SDI_Togo-2013_Module1_Raw.dta", clear

	gen has_facility = 1 if fac_id!=.
	lab var has_facility "Facility was included in infrastructure-supplies survey"

	//Create unique identifier
		tostring fac_id, replace force
		
	//Create country variable
		gen country = "Togo-2013"

	//Adjust variables to match Tanzania-2014 standard
		//whether mobile phone is facility's or individual's
			gen m1scq18a = m1scq18
			recode m1scq18a (2/3=2)
			
			rename m1scq18 m1scq18b
			recode m1scq18b (2=1) (1=2) (3=2)

		//whether computer is facility's or individual's
			gen m1scq19a = m1scq19
			recode m1scq19a (2/3=2)
			
			rename m1scq19 m1scq19b
			recode m1scq19b (2=1) (1=2) (3=2)

		//internet variable
			recode m1scq20 (1/2=1) (3=2) 

		//whether communication equipment is available
			foreach v of varlist m1scq17 m1scq18a m1scq18b m1scq19a m1scq19b m1scq20 {
				recode `v' (2=0) (1=2)
			}

		//whether other equipment is available
			forvalues i = 1/13 {
				recode m1sdq`i'a (2=0) (1=2)
			}

		//whether certain supplies are present
			foreach v of varlist m1seq45 m1seq46 m1seq48 m1seq49 m1seq47 {
				recode `v' (1/3=1) (4/5=0)
			}

	//Recode variables
		//missing values
			ds *, has(type numeric)
			foreach v of varlist `r(varlist)' {
				recode `v' (-9=.) (-99=.) (-999=.) (-99999=.) (-8=.)
			}

		//yes-no questions
			findname, vallabeltext("Oui")
			quietly foreach v of varlist `r(varlist)' {
				recode `v' (2=0)
			}

		//observed-not observed questions
			forvalues i = 1/13 {
				recode m1sdq`i'b (3=0) (2=1) (1=2)
			}

			quietly foreach v of varlist m1seq53 m1seq62 m1seq63 m1seq64 m1seq65 m1seq66 {
				recode `v' (3=0) (2=1) (1=2)
			}

		//fridge availability
			recode m1seq51 (4=0) (3=1) (2=2) (1=3)

		//fridge temperature
			recode m1seq52 (99=.)

	compress
	saveold "$clean/SDI_Togo-2013/togo-2013_infrastructure_clean.dta", replace v(12)

*****************************************************************************
* Add weights
*****************************************************************************

	use "$raw/SDI_Togo-2013/SDI_Togo-2013_Weights.dta", clear
	gen has_weights = 1 if fac_id!=.
	lab var has_weights "Facility had weight data"

	//Create unique identifier
		tostring fac_id, replace force

	//remove replicated location variables
		drop stratum surveyed
		
	merge 1:1 fac_id using "$clean/SDI_Togo-2013/togo-2013_infrastructure_clean.dta", nogen

	compress
	saveold "$clean/SDI_Togo-2013/togo-2013_infrastructure_clean.dta", replace v(12)
