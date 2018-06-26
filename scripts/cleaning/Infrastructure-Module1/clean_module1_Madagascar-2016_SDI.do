/*
Clean Madagascar-2016 Module 1 Data From SDI Survey

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

	use "$raw/SDI_Madagascar-2016/SDI_Madagascar-2016_Module1_Raw.dta", clear

	gen has_facility = 1 if fac_id!=.
	lab var has_facility "Facility was included in infrastructure-supplies survey"

	//Create unique identifier
		tostring fac_id, replace 	
		
	//Create country variable
		gen country = "Madagascar-2016"

	//Adjust variables to match Tanzania-2014 standard
		//drop label on whether drugs are available variables
			foreach v of varlist m1seqa_? m1seqa_?? {
				lab val `v' .
			}

		//drop label on vaccine variables
			foreach v of varlist m1seq61 m1seq62 m1seq63 m1seq64 m1seq65 m1seq66 m1seq67 m1seq68 {
				lab val `v' .
			}

	//Recode variables
		//missing values
			ds *, has(type numeric)
			foreach v of varlist `r(varlist)' {
				recode `v' (-9=.) (-99=.) (-999=.) (-99999=.)
			}

		//yes-no questions
			findname, vallabeltext("oui")
			quietly foreach v of varlist `r(varlist)' {
				recode `v' (2=0)
			}

			recode m1seq49b (2=0)
			recode m1seq49a (1/2=1) (3=0)

			foreach v of varlist m1seq50 m1seq5b m1seq51a m1seq5c m1seq52a m1seq52b m1seq52c m1seq53 m1seq53a m1seq53b m1seq53c m1seq5e m1seq55 m1seq74 {
				recode `v' (2=0)
			}

		//observed-not observed questions
			recode m1scq24 (3=0) (2=1) (1=2)
			
			findname, vallabeltext("oui (observe)")
			quietly foreach v of varlist `r(varlist)' {
				recode `v' (3=0) (2=1) (1=2)
			}

			quietly foreach v of varlist m1seq59  m1seq69  m1seq70  m1seq71  m1seq72  m1seq73 {
				recode `v' (3=0) (2=1) (1=2)
			}

		//fridge availability
			recode m1seq57 (4=0) (3=1) (2=2) (1=3)

		//fridge power source 
			recode m1seq60 (99=9)

		//fridge temperature 
			recode m1seq58 (99=.)
	
	compress
	saveold "$clean/SDI_Madagascar-2016/madagascar-2016_infrastructure_clean.dta", replace v(12)

*****************************************************************************
* Add weights
*****************************************************************************

	use "$raw/SDI_Madagascar-2016/SDI_Madagascar-2016_Weights.dta", clear
	gen has_weights = 1 if fac_id!=.
	lab var has_weights "Facility had weight data"

	//Create unique identifier
		tostring fac_id, replace 

	//remove replicated location variables
		drop id11 province id1 id2 factype owner hhrwt
		 
	merge 1:1 fac_id using "$clean/SDI_Madagascar-2016/madagascar-2016_infrastructure_clean.dta", nogen

	compress
	saveold "$clean/SDI_Madagascar-2016/madagascar-2016_infrastructure_clean.dta", replace v(12)
	
