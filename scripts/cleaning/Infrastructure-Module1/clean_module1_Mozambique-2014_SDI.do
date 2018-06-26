/*
Clean Mozambique-2014 Module 1 Data From SDI Survey

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

	use "$raw/SDI_Mozambique-2014/SDI_Mozambique-2014_Module1_Raw.dta", clear

	gen has_facility = 1 if fac_id!=.
	lab var has_facility "Facility was included in infrastructure-supplies survey"

	//Create unique identifier
		tostring fac_id, replace 
		
	//Create country variable
		gen country = "Mozambique-2014"

	//Adjust variables to match Tanzania-2014 standard
		//whether communication equipment is functioning
			foreach v of varlist m1scq26_f m1scq27_f m1scq28_f m1scq29_f m1scq30_f m1scq31_f m1scq32_f {
				recode `v' (2=0) (1=2)
			}

		//whether other equipment is available
			foreach v of varlist m1sdq?a m1sdq??a {
				recode `v' (2=0) (1=2)
			}

		//whether other equipment is functioning
			forvalues i = 1/13 {
				gen m1sdq`i'b1_a = .
				replace m1sdq`i'b1_a=0 if m1sdq`i'b1==2
				replace m1sdq`i'b1_a = 2 if m1sdq`i'b1==1 & m1sdq`i'b2==1 //functioning and functioning observed
				replace m1sdq`i'b1_a = 1 if m1sdq`i'b1==1 & m1sdq`i'b2==2  //functioning but functioning not observed
				drop m1sdq`i'b1
				rename m1sdq`i'b1_a m1sdq`i'b1
			}

		//whether certain supplies are present
			foreach v of varlist m1seq50 m1seq51 m1seq52 m1seq53 {
				recode `v' (1/3=1) (4/5=0)
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
			recode m1scq24 (3=0) (2=1) (1=2)
			
			findname, vallabeltext("Sim (observado)")
			quietly foreach v of varlist `r(varlist)' {
				recode `v' (3=0) (2=1) (1=2)
			}

			quietly foreach v of varlist m1seq59  m1seq69  m1seq70  m1seq71  m1seq72  m1seq73 {
				recode `v' (3=0) (2=1) (1=2)
			}

		//fridge availability
			recode m1seq57 (4=0) (3=1) (2=2) (1=3)
		
	compress
	saveold "$clean/SDI_Mozambique-2014/mozambique-2014_infrastructure_clean.dta", replace v(12)


