/*
Clean Niger-2015 Facility 1 Data From SDI Survey

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

	use "$raw/SDI_Niger-2015/SDI_Niger-2015_Module1_Raw.dta", clear

	gen has_facility = 1 if fac_id!=.
	lab var has_facility "Facility was included in infrastructure-supplies survey"

	//Create unique identifier
		tostring fac_id, replace 
		
	//Create country variable
		gen country = "Niger-2015"

	//Adjust variables to match Tanzania-2014 standard
		//whether certain supplies are present
			foreach v of varlist m1seq50 m1seq51 m1seq51a m1seq52 m1seq52a m1seq52b m1seq52c m1seq53 m1seq53a m1seq53b {
				recode `v' (1/3=1) (4/5=0)
			}

	//Recode variables
		//missing values
			ds *, has(type numeric)
			foreach v of varlist `r(varlist)' {
				recode `v' (-9=.) (-99=.) (-999=.) (-9999=.) (-99999=.) 
			}

		//yes-no questions
			findname, vallabeltext("Oui")
			quietly foreach v of varlist `r(varlist)' {
				recode `v' (2=0)
			}

			recode m1seq53c (1/2=1) (3=0)

			foreach v of varlist m1seq50 m1seq51 m1seq51a m1seq52 m1seq52a m1seq52b m1seq52c m1seq53 m1seq53a m1seq53b {
				recode `v' (2=0)
			}

		//observed-not observed questions
			recode m1scq24 (3=0) (2=1) (1=2)

			quietly forvalues i = 26/33 {
				recode m1scq`i'_a (3=0) (2=1) (1=2)
				recode m1scq`i'_f (3=0) (2=1) (1=2)
			}

			quietly forvalues i = 1/13 {
				recode m1sdq`i'a (3=0) (2=1) (1=2)
				recode m1sdq`i'b1 (3=0) (2=1) (1=2)
			}

			quietly foreach v of varlist m1sdq8aa m1sdq8ab m1sdq8ba m1sdq8bb {
				recode `v' (3=0) (2=1) (1=2)
			}
			
			quietly foreach v of varlist m1seq59 m1seq67 m1seq68 m1seq69 m1seq70 m1seq71 {
				recode `v' (3=0) (2=1) (1=2)
			}

		//fridge availability
			recode m1seq57 (4=0) (3=1) (2=2) (1=3)

		//fridge temp (farenheit to celsius)
			replace m1seq58 = (m1seq58-32)*5/9

		//fridge power source 
			recode m1seq60 (99=9)
	
	compress
	saveold "$clean/SDI_Niger-2015/niger-2015_infrastructure_clean.dta", replace v(12)

*****************************************************************************
* Add weights
*****************************************************************************

	use "$raw/SDI_Niger-2015/SDI_Niger-2015_Weights.dta", clear
	gen has_weights = 1 if fac_id!=.
	lab var has_weights "Facility had weight data"

	//Create unique identifier
		tostring fac_id, replace 

	//remove replicated location variables
		drop strate cluster gestion cluster_fpc abs_info ftype moh_type public factype rural

	//remove unnecessary weight data
		drop know_b know_c know_d know_e know_f know_g know_h know_i know_j
		
	merge 1:1 fac_id using "$clean/SDI_Niger-2015/niger-2015_infrastructure_clean.dta", nogen

	compress
	saveold "$clean/SDI_Niger-2015/niger-2015_infrastructure_clean.dta", replace v(12)
