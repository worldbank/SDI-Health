/*
Harmonize SDI Vignette Data

Author: Anna Konstantinova
Last edited: March 2nd, 2019
*/

****************************************************************************
* Create standardized vignette datasets – using VIGNETTE CODEBOOKS
****************************************************************************

	foreach place in $theCountries {

		display "Standardizing `place' vignettes..."

		use "$clean/SDI_`place'/`place'_vignettes_clean.dta", clear
		
		//Modify provider level characteristics data
			applyCodebook using "$metadata/`place'_vignettes_codebook", varlab rename vallab sheet("General")

		//Set which vignettes are present in which country datasets
			local diseases = ""
			foreach v of varlist skip_* {
				local theDisease = subinstr("`v'", "skip_", "", .)
				local theDisease = proper("`theDisease'")
				if strlen("`theDisease'")<=4 local theDisease = upper("`theDisease'")
				local diseases = `" "`theDisease'" `diseases' "'
			}

		//Modify each vignette
			foreach disease in  `diseases' {
				applyCodebook using "$metadata/`place'_vignettes_codebook", varlab rename vallab sheet("`disease'")
				local lowerdisease = lower("`disease'")
				foreach x in "history" "exam" "test" "diag" "treat" "educate" "refer" "action" "stop" "failed" {
					cap rename `x'* `lowerdisease'_`x'*
				}
			}

		//Remove unwanted variables
			cap drop q* 
			cap drop m3* 
			cap drop id*
			cap drop h3*
			cap drop mod5_id m5* m1*
			cap drop sequence
			cap drop fanamarihana*

		//Create additional identifier
			gen survey_id = country + "_" + unique_id

		//Change variable order
			order *, alpha
			order survey_id country unique_id facility_id provider_id

		//Save file
			compress
			saveold "$harmonized/SDI_`place'_Vignettes.dta", replace v(12)

		display "Finished `place'"

	}
	
****************************************************************************
* Append country datasets together
****************************************************************************
	
	clear

	foreach place in $theCountries {
		append using "$harmonized/SDI_`place'_Vignettes.dta" , force
		}
		
	//Create numeric country identifier
		encode country, gen(countrycode)
		order survey_id country countrycode unique_id facility_id provider_id

	//Save file
		compress
		saveold "$harmonized/SDI_AllCountries_Vignettes.dta", replace v(12)
		
