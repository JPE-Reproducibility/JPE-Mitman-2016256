

keep if county_index == 1
sort pair_id_numeric quarter_index
tsset pair_id_numeric quarter_index



foreach ind in "all"{
	gen diff_logqwiw1f_`ind'_t = diff_logqwiw1f_`ind'+diff_logui_tax_rate
	gen diff_logqwiw2f_`ind'_t = diff_logqwiw2f_`ind'+diff_logui_tax_rate
	gen diff_logqwiw3f_`ind'_t = diff_logqwiw3f_`ind'+diff_logui_tax_rate
	gen diff_logqwiw4f_`ind'_t = diff_logqwiw4f_`ind'+diff_logui_tax_rate

	by pair_id_numeric: gen did_logqwi_wage_0=diff_logqwiw1_`ind'[_n]-diff_logqwiw2_`ind'[_n-1]
	by pair_id_numeric: gen did_logqwi_wage2_0=diff_logqwiw3_`ind'[_n]-diff_logqwiw4_`ind'[_n-1]
	by pair_id_numeric: gen did_logqwi_wagef_0=diff_logqwiw1f_`ind'[_n]-diff_logqwiw2f_`ind'[_n-1]
	by pair_id_numeric: gen did_logqwi_wage2f_0=diff_logqwiw3f_`ind'[_n]-diff_logqwiw4f_`ind'[_n-1]

	by pair_id_numeric: gen did_logqwi_wagef_t_0=diff_logqwiw1f_`ind'_t[_n]-diff_logqwiw2f_`ind'_t[_n-1]
	by pair_id_numeric: gen did_logqwi_wage2f_t_0=diff_logqwiw3f_`ind'_t[_n]-diff_logqwiw4f_`ind'_t[_n-1]
	by pair_id_numeric: gen fdid_logqwi_wagef_t_0=diff_logqwiw1f_`ind'_t[_n+1]-diff_logqwiw2f_`ind'_t[_n]
	by pair_id_numeric: gen fdid_logqwi_wage2f_t_0=diff_logqwiw3f_`ind'_t[_n+1]-diff_logqwiw4f_`ind'_t[_n]

	
	by pair_id_numeric: gen fdid_logqwi_wage_0=diff_logqwiw1_`ind'[_n+1]-diff_logqwiw2_`ind'[_n]
	by pair_id_numeric: gen fdid_logqwi_wage2_0=diff_logqwiw3_`ind'[_n+1]-diff_logqwiw4_`ind'[_n]
	by pair_id_numeric: gen fdid_logqwi_wagef_0=diff_logqwiw1f_`ind'[_n+1]-diff_logqwiw2f_`ind'[_n]
	by pair_id_numeric: gen fdid_logqwi_wage2f_0=diff_logqwiw3f_`ind'[_n+1]-diff_logqwiw4f_`ind'[_n]
		
}


foreach ind in "foo" "man" "ret"{

	by pair_id_numeric: gen did_logqwi_wage_`ind'_0=diff_logqwiw1_`ind'[_n]-diff_logqwiw2_`ind'[_n-1]
	by pair_id_numeric: gen did_logqwi_wage2_`ind'_0=diff_logqwiw3_`ind'[_n]-diff_logqwiw4_`ind'[_n-1]
	by pair_id_numeric: gen did_logqwi_wagef_`ind'_0=diff_logqwiw1f_`ind'[_n]-diff_logqwiw2f_`ind'[_n-1]
	by pair_id_numeric: gen did_logqwi_wage2f_`ind'_0=diff_logqwiw3f_`ind'[_n]-diff_logqwiw4f_`ind'[_n-1]

	by pair_id_numeric: gen fdid_logqwi_wage_`ind'_0=diff_logqwiw1_`ind'[_n+1]-diff_logqwiw2_`ind'[_n]
	by pair_id_numeric: gen fdid_logqwi_wage2_`ind'_0=diff_logqwiw3_`ind'[_n+1]-diff_logqwiw4_`ind'[_n]
	by pair_id_numeric: gen fdid_logqwi_wagef_`ind'_0=diff_logqwiw1f_`ind'[_n+1]-diff_logqwiw2f_`ind'[_n]
	by pair_id_numeric: gen fdid_logqwi_wage2f_`ind'_0=diff_logqwiw3f_`ind'[_n+1]-diff_logqwiw4f_`ind'[_n]
		
}

by pair_id_numeric: gen did_logmeanwks_0 = diff_logmeanwks[_n]-diff_logmeanwks[_n-1]
by pair_id_numeric: gen did_logmeanwks = diff_logmeanwks[_n]-diff_logmeanwks[_n-1]

gen logqwi_wage=0
gen logqwi_wagef=0
gen logqwi_wage2=0
gen logqwi_wage2f=0
gen logqwi_wagef_t=0
gen logqwi_wage2f_t=0

foreach ind in "foo" "man" "ret"{
gen logqwi_wage_`ind'=0
gen logqwi_wagef_`ind'=0
gen logqwi_wage2_`ind'=0
gen logqwi_wage2f_`ind'=0


}


foreach var of varlist logqwi_wage*  {
forvalues y=1/12{
	local x=`y'-1
	by pair_id_numeric: gen did_`var'_`y' = did_`var'_`x'+did_`var'_0[_n+`y']
	by pair_id_numeric: gen fdid_`var'_`y' = fdid_`var'_`x'+fdid_`var'_0[_n+`y']
	
	
}
}

drop logqwi_wage*

foreach var of varlist logqcew_wage_tot logqwi_wtot_all logqwi_wnhf_all{
gen pv_`var'_0 = diff_`var'
forvalues y=1/12{
	local x=`y'-1
	by pair_id_numeric: gen pv_`var'_`y' = pv_`var'_`x'+(1-seprate)*0.99*diff_`var'[_n+`y']
}
}

foreach var of varlist logqcew_wage_tot logqwi_wtotf_* logqwi_wnhf_*{
 by pair_id_numeric: gen dpv_`var'_0 = diff_`var'[_n]-diff_`var'[_n-1]
forvalues y=1/12{
	local x=`y'-1
	by pair_id_numeric: gen dpv_`var'_`y' = dpv_`var'_`x'+(1-seprate)*0.99*(diff_`var'[_n+`y']-diff_`var'[_n-1])
}
}

// gen logqwi_wnhf_all_t=0
foreach var of varlist logqcew_wage_tot* logqwi_wtot_all* logqwi_wnhf_all* logqwi_wpay_all* logmeanwks{
gen kmean_`var'_0 = diff_`var'
forvalues y=1/12{
	local x=`y'-1
	local z=`y'+1
	by pair_id_numeric: gen kmean_`var'_`y' = (`y'*kmean_`var'_`x'+diff_`var'[_n+`y'])/`z'
}
}

// drop logqwi_wnhf_all_t



// foreach var of varlist logqcew_wage_tot logqwi_wtot_all logqwi_wnhf_all{
// gen pv0_`var' = diff_`var'
// forvalues y=1/12{
// 	gen pv`y'_`var' = diff_`var'
// 	forvalues x=1/`y'{
// 		by pair_id_numeric: replace pv`y'_`var'  = pv`y'_`var' +(1-seprate)*0.99*diff_`var'[_n+`x']
// 	}
//
// }
// }



gen pv_stayers_0 = diff_logqwiw2f_all
forvalues y=1/12{
	local x=`y'-1
	by pair_id_numeric: gen pv_stayers_`y' = pv_stayers_`x'+(1-seprate)*0.99*(diff_logqwiw2f_all+fdid_logqwi_wagef_`x')

}

gen dpv_stayers_0 = diff_logqwiw2f_all
forvalues y=1/12{
	local x=`y'-1
	by pair_id_numeric: gen dpv_stayers_`y' = dpv_stayers_`x'+(1-seprate)*0.99*(diff_logqwiw2f_all+fdid_logqwi_wagef_`x'-did_logqwi_wagef_0)

}

foreach ind in "foo" "ret" "man"{

gen pv_stayers_`ind'_0 = diff_logqwiw2f_`ind'
forvalues y=1/12{
	local x=`y'-1
	by pair_id_numeric: gen pv_stayers_`ind'_`y' = pv_stayers_`ind'_`x'+(1-seprate)*0.99*(diff_logqwiw2f_`ind'+fdid_logqwi_wagef_`ind'_`x')

}

gen dpv_stayers_`ind'_0 = diff_logqwiw2f_`ind'
forvalues y=1/12{
	local x=`y'-1
	by pair_id_numeric: gen dpv_stayers_`ind'_`y' = dpv_stayers_`ind'_`x'+(1-seprate)*0.99*(diff_logqwiw2f_`ind'+fdid_logqwi_wagef_`ind'_`x'-did_logqwi_wagef_`ind'_0)

}
}


forvalues j=1/12{
	by pair_id_numeric: gen U_`j' =  diff_logunemp_rate_laus[_n+`j'] - diff_logunemp_rate_laus[_n]
	by pair_id_numeric: gen QCW_`j' =  diff_logqcew_wage_tot[_n+`j'-1] - diff_logqcew_wage_tot[_n-1] 
	by pair_id_numeric: gen ben_`j' =  diff_logmeanwks[_n+`j'-1] - diff_logmeanwks[_n-1] 
	by pair_id_numeric: gen NW_`j' =  diff_logqwi_wnhf_all[_n+`j'-1] - diff_logqwi_wnhf_all[_n-1] 
	by pair_id_numeric: gen NWt_`j' =  diff_logqwi_wnhf_all_t[_n+`j'-1] - diff_logqwi_wnhf_all_t[_n-1] 
	by pair_id_numeric: gen QWITot_`j' =  diff_logqwi_wtot_all[_n+`j'-1] - diff_logqwi_wtot_all[_n-1]
	by pair_id_numeric: gen QWIPay_`j' =  diff_logqwi_wpay_all[_n+`j'-1] - diff_logqwi_wpay_all[_n-1]
	by pair_id_numeric: gen QCWt_`j' =  diff_logqcew_wage_tot_t[_n+`j'-1] - diff_logqcew_wage_tot_t[_n-1] 
	by pair_id_numeric: gen QWITott_`j' =  diff_logqwi_wtot_all_t[_n+`j'-1] - diff_logqwi_wtot_all_t[_n-1]
	by pair_id_numeric: gen QWIPayt_`j' =  diff_logqwi_wpay_all_t[_n+`j'-1] - diff_logqwi_wpay_all_t[_n-1]	
	
}


foreach ind in "foo" "ret" "man"{ 
forvalues j=1/12{
	by pair_id_numeric: gen NW_`ind'_`j' =  diff_logqwi_wnhf_`ind'[_n+`j'-1] - diff_logqwi_wnhf_`ind'[_n-1] 
	by pair_id_numeric: gen QWITot_`ind'_`j' =  diff_logqwi_wtot_`ind'[_n+`j'-1] - diff_logqwi_wtot_`ind'[_n-1]
}
}

