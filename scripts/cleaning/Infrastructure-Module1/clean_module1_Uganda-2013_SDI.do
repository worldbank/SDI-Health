/*
Clean Uganda-2013 Module 1 Data From SDI Survey

Author: Anna Konstantinova
Last updated: May 3rd, 2018
*/

*****************************************************************************
* Preliminaries 
*****************************************************************************

	clear
	set more off

*****************************************************************************
* Module 1
*****************************************************************************

	use "$raw/SDI_Uganda-2013/SDI_Uganda-2013_Module1_Raw.dta", clear

	gen has_facility = 1 if fac_id!=.
	lab var has_facility "Facility was included in infrastructure-supplies survey"

	//Create unique identifier
		tostring fac_id, replace 
		
	//Create country variable
		gen country = "Uganda-2013"

	//Adjust variables to match Tanzania-2014 standard
		//whether mobile phone is facility's or individual's
			rename h1sb51 h1sb51a
			gen h1sb51b = h1sb51a

		//whether communication equipment is functioning
			foreach v of varlist h1sb50 h1sb51a h1sb51b h1sb52 h1sb53 h1sb54 {
				recode `v' (2=0) (1=2)
			}

		//whether test kits are present and functioning
			foreach v of varlist h1sc67a h1sc67b h1sc69a h1sc69b h1sc66a h1sc66b h1sc70a h1sc70b h1sc68a h1sc68b {
				recode `v' (1/2=1) (3=0)
				local vlab : value label `v'
				lab drop `vlab'
			}

		//whether certain supplies are present
			foreach v of varlist h1sd119 h1sd120 h1sd124 h1sd121 h1sd122 {
				recode `v' (1/3=1) (4/6=0)
			}

		//measles vaccine
			drop h1sd78 //removing the one that isn't part of vaccine section

		//has vaccines
			foreach v of varlist h1sd109 h1sd110 h1sd111 h1sd112 h1sd113 {
				recode `v' (7=.)
			}

	//Recode variables
		//missing values
			ds *, has(type numeric)
			foreach v of varlist `r(varlist)' {
				recode `v' (-9=.) (-99=.) (-999=.) (-99999=.) (-8=.)
			}

		//yes-no questions
			findname, vallabeltext("Yes")
			quietly foreach v of varlist `r(varlist)' {
				recode `v' (2=0)
			}

		//observed-not observed questions
			findname, vallabeltext("Yes (observed)")
			quietly foreach v of varlist `r(varlist)' {
				recode `v' (3=0) (2=1) (1=2)
			}

			quietly foreach v of varlist h1sd114 h1sd115 h1sd116 h1sd117 h1sd118 {
				recode `v' (3=0) (2=1) (1=2) (4/5=.)
			}

		//fridge availability
			recode h1sd105 (3=0) (2=2) (1=3)

	compress
	saveold "$clean/SDI_Uganda-2013/uganda-2013_infrastructure_clean.dta", replace v(12)

*****************************************************************************
* Add weights
*****************************************************************************

	use "$raw/SDI_Uganda-2013/SDI_Uganda-2013_Weights.dta", clear
	gen has_weights = 1 if fac_id!=.
	lab var has_weights "Facility had weight data"

	//Create unique identifier
		tostring fac_id, replace 

	//remove replicated location variables
		drop countycode districtcode parishcode subcountycode region
		
	merge 1:1 fac_id using "$clean/SDI_Uganda-2013/uganda-2013_infrastructure_clean.dta", nogen

	compress
	saveold "$clean/SDI_Uganda-2013/uganda-2013_infrastructure_clean.dta", replace v(12)
