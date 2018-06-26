/*
Master file for creating vignette data from SDIs

Author: Anna Konstantinova
Last edited: May 3rd, 2018
*/

****************************************************************************
* Options
****************************************************************************

* Enter the path to the root directory: 

	global root ///
		"C:\Users\annak\Box Sync\WB Work\WB Github Repo"

* Enter the list of countries to analyze: 
	
	global theCountries ///
		`" "Kenya-2012" "Madagascar-2016" "Nigeria-2013" "Tanzania-2014" "Tanzania-2016" "Uganda-2013" "Mozambique-2014" "Niger-2015" "Senegal-2010" "Togo-2013" "'
		

****************************************************************************
*  Step 1. Setup –– DO NOT EDIT BELOW THIS LINE
****************************************************************************
	
	qui {

		clear all
		set more off
		
		cap cd "$root"
			if _rc!=0 noi di as err "Please enter machine-specific root folder in SDI Master Do-file!"

		global do "$root/scripts"	
		
		global raw "$root/rawData"
		global clean "$root/cleanData"
		global metadata "$root/metaData"
		global harmonized "$root/harmonizedData"

		cap ssc install findname
		cap net install "https://raw.githubusercontent.com/worldbank/stata/master/wb_git_install/wb_git_install.pkg"
		cap wb_git_install applyCodebook 
		qui do "$do/ado/applyCodebook.ado"
	}

****************************************************************************
*  Step 2.  Clean SDI data according to instructions in MANUAL
****************************************************************************

	foreach place in $theCountries {
		
		display "Cleaning `place'..."
		qui do "$do/cleaning/Infrastructure-Module1/clean_module1_`place'_SDI.do"
		qui do "$do/cleaning/Roster-Module2/clean_module2_`place'_SDI.do"
		qui do "$do/cleaning/Vignettes-Module3/clean_module3_`place'_SDI.do"
		display "`place' data cleaned!"
		
		}

****************************************************************************
*  Step 3.  Harmonize modules
****************************************************************************

	qui do "$do/harmonization/harmonize_vignettes.do"
	qui do "$do/harmonization/harmonize_absenteeism.do"
	qui do "$do/harmonization/harmonize_facilities.do"

	clear

* Have a lovely day!
