
set more off
// drop if year<2005 | (year>2010 & year<2011) | year>2012

sort pair_id_numeric quarter_index county_index
foreach var of varlist agi dti_*{
by pair_id_numeric quarter_index: gen diff_`var'=log(`var'[1])-log(`var'[2])
}

sort pair_id_numeric county_index quarter_index  
by pair_id_numeric county_index: gen fhfa_g=log(hpi_fhfa[_n])-log(hpi_fhfa[_n-4])

sort pair_id_numeric quarter_index county_index 

by pair_id_numeric quarter_index: gen diff_fhfa_lev=log(hpi_fhfa[1])-log(hpi_fhfa[2])
by pair_id_numeric quarter_index: gen diff_fhfa=fhfa_g[1]-fhfa_g[2]
by pair_id_numeric quarter_index: gen diff_elas=elasticity[1]-elasticity[2]
by pair_id_numeric quarter_index: gen diff_wharton=WRLURI[1]-WRLURI[2]
by pair_id_numeric quarter_index: gen diff_sepbegrall=sepbegrall[1]-sepbegrall[2]

by pair_id_numeric quarter_index: gen diff_bartik_state=bartik_state[1]-bartik_state[2]
by pair_id_numeric quarter_index: gen diff_bartik_hinter=bartik_hinter[1]-bartik_hinter[2]
by pair_id_numeric quarter_index: gen diff_bartik_county=bartik_county[1]-bartik_county[2]

by pair_id_numeric quarter_index: gen diff_jfr1=f_cl_q[1]-f_cl_q[2]
by pair_id_numeric quarter_index: gen diff_jfr2=f_cl2_q[1]-f_cl2_q[2]
by pair_id_numeric quarter_index: gen diff_jfr3=f_cl[1]-f_cl[2]
by pair_id_numeric quarter_index: gen diff_jfr4=f_cl2[1]-f_cl2[2]

keep if county_index==1
duplicates drop pair_id_numeric time, force
foreach var of varlist 																		///
																											///
	qdk1_logunemp_rate_laus   diff_logmeanwks_pf											///																			///
																									///
	diff_logmeanwks qdk1_logunemp_add{ ///
	
	qui bys pair_id_numeric fipsnumeric: egen nmissing=count(`var')
	by pair_id_numeric: egen nmissing2=min(nmissing)
	qui tab nmissing
	drop if nmissing2==0
	qui drop nmissing nmissing2

}

gen id=pair_id_numeric
xtset id time

