/*
Clean Tanzania-2016 Module 1 Data From SDI Survey

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

	use "$raw/SDI_Tanzania-2016/SDI_Tanzania-2016_Module1_Raw.dta", clear

	gen has_facility = 1 if fac_id!=.
	lab var has_facility "Facility was included in infrastructure-supplies survey"

	//Create unique identifier
		tostring fac_id, replace 
		
	//Create country variable
		gen country = "Tanzania-2016"

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

			recode m1seq49_b (2=0)
			recode m1seq49_a (1/2=1) (3=0)

		//observed-not observed questions
			recode m1scq24 (3=0) (2=1) (1=2)
			
			findname, vallabeltext("Yes (observed)")
			quietly foreach v of varlist `r(varlist)' {
				recode `v' (3=0) (2=1) (1=2)
			}

			quietly foreach v of varlist m1seq59  m1seq69  m1seq70  m1seq71  m1seq72  m1seq73 {
				recode `v' (3=0) (2=1) (1=2)
			}

		//fridge availability
			recode m1seq57 (4=0) (3=1) (2=2) (1=3)
	
	compress
	saveold "$clean/SDI_Tanzania-2016/tanzania-2016_infrastructure_clean.dta", replace v(12)

*****************************************************************************
* Add weights
*****************************************************************************

	use "$raw/SDI_Tanzania-2016/SDI_Tanzania-2016_Weights.dta", clear
	gen has_weights = 1 if fac_id!=.
	lab var has_weights "Facility had weight data"

	//Create unique identifier
		tostring fac_id, replace 

	//remove replicated location variables
		drop region district ward weight hhrwt owner_new powner_new strata type urban s2014 s2016
		 
	merge 1:1 fac_id using "$clean/SDI_Tanzania-2016/tanzania-2016_infrastructure_clean.dta", nogen
	drop if has_weights==1 & (has_facility==. | has_facility==0)

	compress
	saveold "$clean/SDI_Tanzania-2016/tanzania-2016_infrastructure_clean.dta", replace v(12)
