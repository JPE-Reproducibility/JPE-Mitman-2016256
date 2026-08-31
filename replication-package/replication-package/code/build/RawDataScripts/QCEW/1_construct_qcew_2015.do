pause off
global direc "${rawdata}/QCEW/"
*forvalues yr=2014/2014{
forvalues yr=1990/2015{
	if (`yr'<2000){
		local t = `yr' - 1900
	}
	else{
		local t = `yr' - 2000
	}

	global filename = "allhlcn`t'"
	if (`yr'>=2000 & `yr'<=2009){
		global filename = "allhlcn0`t'"
	}

	forvalues qtr = 1/4{
		qui cd "${rawdata}/QCEW/`yr'_all_county_high_level"
		disp as text "Year=" as result `yr' as text "  Quarter=" as result `qtr'
		** Read in the data
		if( `yr'<2014){
			qui import excel using ${filename}`qtr'.xls, sheet(US_St_Cn_MSA) clear
		}
		else{
			qui import excel using ${filename}`qtr'.xlsx, sheet(US_St_Cn_MSA) clear
		}


		** Rename variables
		if `yr'<2010{
			qui drop T-Z
			qui drop if _n==1
			qui ren A fips
			qui ren B sectorcode
			qui ren C naics
			qui ren D year
			qui ren E qtr
			qui ren F areatype
			qui ren G state
			qui ren H area
			qui ren I sector
			qui ren J industry
			qui ren K status
			qui la var L "Establishment count"
			qui ren L nest
			qui ren M empm1
			qui ren N empm2
			qui ren O empm3
			qui ren P total_wage
			qui ren Q wkly_wage
			qui ren R locquotm3
			qui ren S locquottotal
		}
		else{
			qui capture noisily drop V-Z
			qui drop if _n==1
			qui drop B C
			qui ren A fips
			qui ren D sectorcode
			qui ren E naics
			qui ren F year
			qui ren G qtr
			qui ren H areatype
			qui ren I state
			qui ren J area
			qui ren K sector
			qui ren L industry
			qui ren M status
			qui la var N "Establishment count"
			qui ren N nest
			qui ren O empm1
			qui ren P empm2
			qui ren Q empm3
			qui ren R total_wage
			qui ren S wkly_wage
			qui ren T locquotm3
			qui ren U locquottotal
		}

		** Only keep counties (drop MSAs and the like)
		qui gen check=substr(fips,1,1)
		qui gen check2=substr(fips,-3,3)
		qui drop if check=="U" | check=="C" | check2=="000"
		qui drop check*
		qui destring fips, replace

		** Only keep total covered and private AND only total
		qui destring sectorcode, replace
		qui drop if sectorcode~=0 & sectorcode~=5
		qui drop if sectorcode==5 & industry~="Total, all industries"

		** Destring the relevant variables
		foreach var of varlist naics year qtr nest empm* total_wage wkly_wage locquot*{
			qui destring `var', replace
			}
		qui drop naics areatype state area industry sector status
		qui order fips year qtr sectorcode
		qui sort fips year qtr

		** Save data in separate files for total and total private
		cap mkdir "${rawdata}/QCEW/Output"
		qui cd "${rawdata}/QCEW/Output"
		preserve
			qui keep if sectorcode==0
			qui save ${filename}`qtr'_total, replace
		restore
		preserve
			qui keep if sectorcode==5
			qui save ${filename}`qtr'_priv, replace
		restore

	}

}


** Now append the files
drop _all
forvalues yr=1990/2015{
	if (`yr'<2000){
		local t = `yr' - 1900
	}
	else{
		local t = `yr' - 2000
	}

	global filename = "allhlcn`t'"
	if (`yr'>=2000 & `yr'<=2009){
		global filename = "allhlcn0`t'"
	}

	forvalues qtr = 1/4{
		disp as text "Year=" as result `yr' as text "  Quarter=" as result `qtr'
		** Read in the data
		append using ${filename}`qtr'_total
		erase ${filename}`qtr'_total.dta
	}
}
drop sectorcode
ren total_wage wage
foreach var of varlist empm* wage wkly_wage nest{
	ren `var' qcew_all_`var'
}
drop loc*
save qcew_total, replace


drop _all
forvalues yr=1990/2015{
	if (`yr'<2000){
		local t = `yr' - 1900
	}
	else{
		local t = `yr' - 2000
	}

	global filename = "allhlcn`t'"
	if (`yr'>=2000 & `yr'<=2009){
		global filename = "allhlcn0`t'"
	}

	forvalues qtr = 1/4{
		disp as text "Year=" as result `yr' as text "  Quarter=" as result `qtr'
		** Read in the data
		append using ${filename}`qtr'_priv
		erase ${filename}`qtr'_priv.dta
	}
}
drop sectorcode
ren total_wage wage
foreach var of varlist empm* wage wkly_wage nest{
	ren `var' qcew_priv_`var'
}
drop loc*
save qcew_priv, replace

merge 1:1 fips year qtr using qcew_total
drop if _merge~=3
drop _merge

save qcew, replace
