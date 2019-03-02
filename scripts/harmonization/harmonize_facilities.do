/*
Harmonize SDI Facility Data

Author: Anna Konstantinova
Last edited: March 2nd, 2019
*/

****************************************************************************
* Create standardized facilities datasets – using INFRASTRUCTURE CODEBOOKS
****************************************************************************

	foreach place in $theCountries {

		use "$clean/SDI_`place'/`place'_infrastructure_clean.dta", clear

		//Modify facility general characteristics variables
			preserve
				import excel using "$metadata/`place'_infrastructure_codebook.xlsx", firstrow sheet("General") clear
				tab vallab
				if `r(N)'==0 local haslab = ""
				if `r(N)'>0 local haslab = "vallab"
			restore

			applyCodebook using "$metadata/`place'_infrastructure_codebook.xlsx", varlab rename `haslab' sheet("General")

		//Modify infrastructure-services variables
			applyCodebook using "$metadata/`place'_infrastructure_codebook.xlsx", varlab rename vallab sheet("Infrastructure")

		//Modify drugs-supplies-tests-vaccines variables
			applyCodebook using "$metadata/`place'_infrastructure_codebook.xlsx", varlab rename vallab sheet("Drugs-Vaccines")

		//Remove unwanted variables
			cap drop q? q??
			cap drop id?? id?a m0* m1*
			cap drop m1*
			cap drop m0* m1*
			cap drop h1*
			cap drop m1*
			cap drop mod?_id

		//Change variable order
			order *, alpha
			order country facility_id

		//Save file
			compress
			saveold "$harmonized/SDI_`place'_Facility.dta", replace v(12)
	}
	
****************************************************************************
* Append country datasets together
****************************************************************************
	
	clear

	foreach place in $theCountries {
		append using "$harmonized/SDI_`place'_Facility.dta" 
		}
		
	//Create numeric country identifier
		encode country, gen(countrycode)
		order country countrycode facility_id

	//Save file
		compress
		saveold "$harmonized/SDI_AllCountries_Facility.dta", replace v(12)
		
