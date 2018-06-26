/*
Clean Kenya-2012 Module 1 Data From SDI Survey

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

	use "$raw/SDI_Kenya-2012/SDI_Kenya-2012_Module1_Raw.dta", clear

	gen has_facility = 1 if fac_id!=""
	lab var has_facility "Facility was included in infrastructure-supplies survey"

	//Create unique identifier
		tostring fac_id, replace 
		
	//Create country variable
		gen country = "Kenya-2012"

	//Rename variables
		rename q60_sphygmonometer_availabli q60_sphygmonometer_available
		rename q60_sphygmonometer_functionink q60_sphygmonometer_functioning

		qui foreach var of varlist q* {

			if substr("`var'", 3, 1)=="_" local newname = substr("`var'", 1, 2)
			if substr("`var'", 4, 1)=="_" local newname = substr("`var'", 1, 3)
			if substr("`var'", 5, 1)=="_" local newname = substr("`var'", 1, 4)

			//Exceptions
				local isavail = substr("`var'", -9, 9)
				if "`isavail'" == "available" local newname = "`newname'a"

				local isfunc = substr("`var'", -11, 11)
				if "`isfunc'" == "functioning" local newname = "`newname'b"

			rename `var' `newname'
		}

		rename q46b q46
		rename q49b q59

	//Adjust variables to match Tanzania-2014 standard
		//whether cell phone is facility's or individual's
			gen q47a = q47b
			lab val q47a Q47_FAC_CELLPHONE_FUNCTIONING

		//whether communication equipment is functioning
			foreach v of varlist q46 q47a q47b q59 q48 q50 {
				recode `v' (2=0) (1=2)
			}

		//whether certain supplies are present
			foreach v of varlist q105 q106 {
				recode `v' (1/2=1) (3=0) (77=.)
			}

	//Recode variables
		//missing values
			ds *, has(type numeric)
			foreach v of varlist `r(varlist)' {
				recode `v' (-9=.) (-99=.) (-999=.) (-99999=.) (-8=.) (99=.)
			}

		//yes-no questions
			findname, vallabeltext("YES")
			quietly foreach v of varlist `r(varlist)' {
				recode `v' (2=0)
			}

		//observed-not observed questions
			findname, vallabeltext("YES (OBSERVED)")
			quietly foreach v of varlist `r(varlist)' {
				recode `v' (3=0) (2=1) (1=2)
			}

			quietly foreach v of varlist q100 q101 q102 q103 q104 {
				recode `v' (3=0) (2=1) (1=2)
			}

		//fridge availability
			recode q93 (3=0) (1=3) (2=2)

	compress
	saveold "$clean/SDI_Kenya-2012/kenya-2012_infrastructure_clean.dta", replace v(12)

*****************************************************************************
* Add weights
*****************************************************************************

	use "$raw/SDI_Kenya-2012/SDI_Kenya-2012_Weights.dta", clear
	gen has_weights = 1 if fac_id!=""
	lab var has_weights "Facility had weight data"

	//Create unique identifier
		tostring fac_id, replace 

	//remove replicated location variables
		drop btHSSF countycode
		
	merge 1:1 fac_id using "$clean/SDI_Kenya-2012/kenya-2012_infrastructure_clean.dta", nogen

	compress
	saveold "$clean/SDI_Kenya-2012/kenya-2012_infrastructure_clean.dta", replace v(12)
