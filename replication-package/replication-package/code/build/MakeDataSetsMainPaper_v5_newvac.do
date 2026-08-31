* meanwks arrives fully patched from the consolidated benefit_weeks input
* (missing->26, FullFinal totalweeks 2011m4+, TEUC +13 2002m3-2003, NJ 1996=39
* are all baked in there).
capture drop _merge

gen tag=1
/* Chicago-area counties: Cook 17031,  DeKalb 17037, DuPage 17043, Grundy 17063, Kane 17089, Kendall 17093, McHenry 17111, Will 17197*/
replace tag=0 if inlist(fipsnumeric,17031,17037,17043,17063,17089,17093,17111,17197)

sort fipsnumeric
merge m:1 fipsnumeric using ${rawdata}/LatLongData.dta
drop if _merge==2
drop _merge

sort fipsnumeric year month
merge m:1 fipsnumeric year month using ${rawdata}/QCEWAllYears_2014Q4
drop if _merge==2
drop _merge

merge m:1 fipsnumeric year quarter using ${rawdata}/QWI_2018_09_18_t
drop if _merge==2
drop _merge
rename empendall qwi_emp_end
rename emptotalall qwi_emp_tot

replace ui_tax_rate = 1+ui_tax_rate 
replace qcew_ui_tax_rate = 1+qcew_ui_tax_rate 

gen qwi_wtot_all_t = qwi_wtot_all*ui_tax_rate
gen qcew_wage_tot_t = qcew_wage_tot*qcew_ui_tax_rate
gen qwi_wpay_all = payrollall/qwi_emp_tot
gen qwi_wpay_all_t = qwi_wpay_all*ui_tax_rate
gen qwi_wnhf_all_t = qwi_wnhf_all*ui_tax_rate

replace latitude=latitude*0.017453
replace longitude=longitude*0.017453
sort pair_id_numeric year month county_index 
by pair_id_numeric year month: gen dist=acos(sin(latitude[1])*sin(latitude[2])+cos(latitude[1])*cos(latitude[2])*cos(longitude[2]-longitude[1]))*6371*0.621371

sort year month

merge m:1 year month using ${rawdata}/jolts2013.dta
drop if _merge==2
drop _merge
rename jolts_agg_seprate_q seprate
replace seprate=0.1 if seprate==.

merge m:1 fipsstate year month using ${rawdata}/SNAP_Policy_Database_Processed_2018_premerge
drop if _merge==2
drop _merge
replace bbce_asset2018=0 if bbce_asset2018==-9

gen tempval2=0
replace tempval2=meanwks if year==2013 & month==12
bys fipsnumeric: egen wks2013=max(tempval2)
*rename totalweeks wks2013

gen logwks=ln(meanwks)
** Difference across counties
sort pair_id_numeric year month county_index
foreach var of varlist meanwks* logwks wks2013{
	by pair_id_numeric year month: gen diff_`var' = `var'[1] - `var'[2]
}
sort pair_id_numeric county_index year month 
foreach var of varlist meanwks* logwks wks2013{
	by pair_id_numeric county_index: gen did_`var' = diff_`var'[_n] - diff_`var'[_n-1]
}

gen tempval7=-100
replace tempval7=did_meanwks if year==2014 & month==1
by pair_id_numeric: egen dwks2013=max(tempval7)

gen tempval8=-100
replace tempval8=did_logwks if year==2014 & month==1
by pair_id_numeric: egen logdwks2013=max(tempval8)

// gen bgroups=0
// replace bgroups=1 if logdwks2013>0
// gen county_index2=bgroups*(county_index*-1+3)+(1-bgroups)*county_index
//
// replace county_index=county_index2

/*
gen logemp_laus=ln(emp_laus)
sort pair_id_numeric fipsnumeric year month
by pair_id_numeric fipsnumeric: gen tdiff_logemp3=logemp_laus[_n]-logemp_laus[_n-11]
by pair_id_numeric fipsnumeric: gen tdiff_logemp4=logemp_laus[_n]-logemp_laus[_n-12]
bys county_index: su tdiff_logemp3 if year==2014 & month==11
bys county_index: su tdiff_logemp4 if year==2013 & month==12
stop
*/

sort fipsstate year month
merge m:1 fipsstate year month using RawDataScripts/LAUS_Additivity/Output/additivity.dta
drop _merge

replace tag=0 if fipsstate==11		/* for DC */
replace tag=0 if fipsnumeric==6037	/* Los Angeles (shouldn't be in the border sample, but to be safe) */

/* Chicago-Joliet-Naperville consists of the following counties:*/
/* Chicago-area counties: Cook 17031,  DeKalb 17037, DuPage 17043, Grundy 17063, Kane 17089, Kendall 17093, McHenry 17111, Will 17197*/
replace tag=0 if inlist(fipsnumeric,17031,17037,17043,17063,17089,17093,17111,17197)

/* Detrpit-Warren-Livonia consists of the following counties:*/
/* Lapeer 26087, Livingston 26093, Macomb 26099, Oakland 26125, St. Clair 17163, Wayne 26163*/
replace tag=0 if inlist(fipsnumeric,26093,26099,26125,17163,26163)
replace tag=0 if fipsnumeric==36061		/* New York City */

/* Cleveland-Elyria-Mentor county consists of*/
/* Cuyahoga 39035, Geauga 39055, Lake 39085, Lorain 39093, and Medina 39103*/
replace tag=0 if inlist(fipsnumeric,39035,39055,39085,39093,39103)

/* Seattle-Bellevue-Everett county consists of King 53033 and Snohomish 53061 counties*/
replace tag=0 if inlist(fipsnumeric,53033,53061)

// gen unemp_add=unemp_rate_laus/unempratio if tag==1
gen unemphb_count=unemp_count
replace unemphb_count=unemp_count/unempratio if tag==1

gen emp_add=emp_laus
replace emp_add=emp_laus/empratio if tag==1

gen labor_add=unemphb_count+emp_add
gen unemp_add=unemphb_count/labor_add*100

* Vacancy source switch. Default = the real HWOL file (PROPRIETARY, cannot be
* redistributed). To build a SHIPPABLE, synthetic-vacancy CurrentData,
* first run code/build/Make_Synthetic_Vacancies.do, then set, before the build:
*     global vacfile "${rawdata}/new_vac_synthetic.dta"
* (the synthetic file has the same fipsnumeric/year/month schema). Results built on
* the synthetic file are demonstrative, not the published estimates.
if "${vacfile}"=="" global vacfile "${synthetic}/new_vac_synthetic.dta"
merge m:1 fipsnumeric year month using "${vacfile}"

drop _merge

collapse year quarter fipsnumeric fipsstate unemp_add unemp_rate_laus unemp_count_laus sepall sepbegall sepbegrall emp*laus labor*laus meanwks* seprate dist wks2013 qcew* qwi* ui_tax_rate diff_wks2013 total_vac* state_qcew* state_unemp* xstate* state_e* bbce*, ///
	by(pair_id_numeric county_index quarter_index)

sort fipsnumeric year quarter
* cbsacode (county->CBSA, for samecbsa) + state employment (emp_state_sa/_u, for prod_all_old
* and emp_share), from the cbsacode crosswalk + the BLS state-employment producer:
merge m:1 fipsnumeric using ${rawdata}/cbsacode_xwalk
drop if _merge==2
drop _merge
merge m:1 fipsstate year quarter using ${rawdata}/state_emp_quarterly
drop if _merge==2
drop _merge

* State-policy controls (sbsi/sbtc/bhi/judicial + property/sales/income/corp/total taxes) --
* from the Make_StatePolicies_{Indices,Taxes} producers:
merge m:1 fipsstate year quarter using ${rawdata}/StatePolicies_indices
drop if _merge==2
drop _merge
merge m:1 fipsstate year quarter using ${rawdata}/StatePolicies_taxes
drop if _merge==2
drop _merge

capture drop awardamount
merge m:1 fipsnumeric year quarter using ${rawdata}/spending_data
drop if _merge==2
drop _merge

gen temp_share=0
replace temp_share=emp_laus/emp_state_u if year==2012 & quarter==4 
bys pair_id_numeric: egen emp_share=max(temp_share)
drop temp_share
gen temp_share=0
sort year quarter pair_id_numeric county_index
by year quarter pair_id_numeric: replace temp_share=1 if cbsacode[1]==cbsacode[2]
gen temp_share2=0
replace temp_share2=1 if temp_share==1 & year==2012 & quarter==4
bys pair_id_numeric: egen samecbsa=max(temp_share2)
drop temp_share*
* Industry-composition distance (tab:Benefits_on_unemp Col 6): the l2-distance between the
* two border counties' sample-average private-nonfarm industry employment shares, built from
* BEA CA25N (RawDataScripts/BEA_Industry/Make_IndustryShares.do).
merge m:1 fipsnumeric using ${rawdata}/bea_industry_shares
drop if _merge==2
drop _merge
sort pair_id_numeric quarter_index county_index
gen double __ss=0
gen int __nn=0
foreach yy of numlist 100 200 300 400 500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 {
	by pair_id_numeric quarter_index: replace __ss = __ss + (sh`yy'[1]-sh`yy'[2])^2 if !missing(sh`yy'[1]) & !missing(sh`yy'[2])
	by pair_id_numeric quarter_index: replace __nn = __nn + 1 if !missing(sh`yy'[1]) & !missing(sh`yy'[2])
}
gen industry=sqrt(__ss) if __nn>0
drop __ss __nn sh100-sh1900
* Col-6 subsample flag: the 50% of border pairs with the most similar industrial
* composition (l2 <= median over all border pairs), per the paper.
preserve
bys pair_id_numeric: keep if _n==1
qui _pctile industry if !missing(industry), p(50)
local indmed=r(r1)
restore
gen byte industry_low = (industry<=`indmed') if !missing(industry)

merge m:1 fipsstate year quarter using ${rawdata}/BEA_GDP_State_Q.dta

drop if _merge==2
drop _merge

* Quarterly benefit-weeks series from the single consolidated benefit_weeks
* input: the perfect-foresight series (pf_meanwks -> meanwks_pf) plus the
* rec2001/vintage historical patch series used further below. The columns are
* quarter-constant in the monthly file, so one row per state-quarter is kept
* and merged at exact values.
preserve
use fipsstate year quarter rec2001_meanwks2 vintage_meanwks pf_meanwks using ${rawdata}/benefit_weeks, clear
bys fipsstate year quarter: keep if _n==1
tempfile wksq
save `wksq'
restore
merge m:1 fipsstate year quarter using `wksq'
drop if _merge==2
drop _merge
rename pf_meanwks meanwks_pf

gen prod_all = state_gdp_all/state_e_sa_pre
gen prod_all_old = state_gdp_all/emp_state_sa
*gen prod_allq = state_gdp_all/state_qcew_emp_tot
gen prod_priv = state_gdp_priv/state_qcew_emp
gen prod_all_qcew = state_gdp_all/state_qcew_emp_tot

sort pair_id_numeric county_index year quarter
by pair_id_numeric county_index: gen prod_allq = (prod_all[_n]+prod_all[_n+1])/2

gen vacrate1=total_vacancies_county/labor_laus

* vacrate2 (vacancies / employment) is the PUBLISHED Vacancies/Tightness measure.
* Built from the same synthetic ${vacfile} as vacrate1/tight1, so no real HWOL
* vacancy data enters the build.
gen vacrate2=total_vacancies_county/emp_laus

gen tight1=total_vacancies_county/unemp_count_laus

// gen qwi_emp_av=(qwi_emp+qwi_emp_end)/2

drop time

** Now, generate the time variable
gen time=ym(year,quarter)
format %tq time
order pair_id_numeric fipsnumeric year quarter time

// gen qwi_emp_nont1=qwi_emp_art+empcon+emprea+empedu+emphea+qwi_emp_foo+qwi_emp_ret
// gen qwi_emp_trade1=emptra+qwi_emp_man+empwho
//
// gen qwi_emp_nont2=qwi_emp_art+empcon+emprea+qwi_emp_foo+qwi_emp_ret
// gen qwi_emp_trade2=emptra+qwi_emp_man+empwho

* empinf
// gen qwi_emp_share1=qwi_emp_nont1/qwi_emp_trade1
// gen qwi_emp_share2=qwi_emp_nont2/qwi_emp_trade2

gen mopair=0
replace mopai=1 if fipsstate==29
bys pair_id_numeric time: egen ifmo=max(mopair)

// gen katrinapair=0
// replace katrinapair=1 if fipsstate==22
// bys pair_id_numeric time: egen ifkat=max(katrinapair)
//
// gen arkansas=0
// replace arkansas=1 if fipsstate==5
// bys pair_id_numeric time: egen akpair=max(arkansas)
//
// *replace county_index=3 if county_index==1 & ifkat==1 & akpair==1
//
// gen miss=0
// replace miss=1 if fipsstate==28
// bys pair_id_numeric time: egen mipair=max(miss)
//
// gen georgia=0
// replace georgia=1 if fipsstate==13
// bys pair_id_numeric time: egen gapair=max(georgia)
//
// gen ncpair=0
// replace ncpair=1 if fipsstate==37
// bys pair_id_numeric time: egen ifnc=max(ncpair)
//
// *replace county_index=3 if county_index==1 & ifnc==1 & gapair==1
//
//
// gen del=0
// replace del=1 if fipsstate==10
// bys pair_id_numeric time: egen delpair=max(del)
//
// gen pa=0
// replace pa=1 if fipsstate==42
// bys pair_id_numeric time: egen papair=max(pa)
//
//
// gen njpair=0
// replace njpair=1 if fipsstate==34
// bys pair_id_numeric time: egen ifnj=max(njpair)
//
// gen drop2014pair=0
// replace drop2014pair=1 if inlist(fipsstate,12,13,20,37)
// bys pair_id_numeric: egen ifdrop2014=max(drop2014pair)
//
// gen drop2014pair2=0
// replace drop2014pair2=1 if inlist(fipsstate,12,13,20,37,8,22,24,25,26,53)
// bys pair_id_numeric: egen ifdrop2014_2=max(drop2014pair2)

*replace county_index=3 if county_index==1 & ifnj==1 & delpair==1

/*
** Difference across counties
sort pair_id_numeric time county_index
foreach var of varlist wks2013{
	by pair_id_numeric time: gen diff_`var' = `var'[1] - `var'[2]
}

gen bgroups=0
replace bgroups=1 if diff_wks2013<0
gen county_index2=bgroups*(county_index*-1+3)+(1-bgroups)*county_index
rena

replace county_index=county_index2
*/

sort pair_id_numeric quarter_index county_index

by pair_id_numeric quarter_index: egen pair_emp = sum(qwi_emp)
by pair_id_numeric quarter_index: egen pair_emp_end = sum(qwi_emp_end)
by pair_id_numeric quarter_index: egen pair_emp_tot = sum(qwi_emp_tot)
by pair_id_numeric quarter_index: egen pair_sepbeg_count = sum(sepbegall)
by pair_id_numeric quarter_index: egen pair_septot_count = sum(sepall)

foreach var of varlist emp_laus meanwks* unemp_rate_laus labor_laus unemp_count_laus qcew* qwif* qwi_* prod_all sepall sepbegall ui_tax_rate{
	bys fipsnumeric year: egen `var'_an=mean(`var')
// 	replace `var'_an=`var' if year<2014
}

foreach var of varlist pair_emp pair_emp_tot pair_sep* {
	bys pair_id_numeric year: egen `var'_an=mean(`var')
// 	replace `var'_an=`var' if year<2014
}

gen pair_sepr_beg = pair_sepbeg_count/(pair_emp)
gen pair_sepr_tot = pair_septot_count/(pair_emp_tot)

gen pair_sepr_beg_an = pair_sepbeg_count_an/(pair_emp_an)
gen pair_sepr_tot_an = pair_septot_count_an/(pair_emp_tot_an)

su pair_sepr_beg_an if year==2005, d 
gen r_med=inrange(pair_sepr_beg_an,0,`r(p50)') if year==2005
bys pair_id_numeric: egen sepbegtype=min(r_med)

drop r_med

su pair_sepr_tot_an if year==2005, d 
gen r_med=inrange(pair_sepr_tot_an,0,`r(p50)') if year==2005
bys pair_id_numeric: egen septype=min(r_med)

gen tight2=vacrate2/unemp_rate_laus

merge m:1 fipsnumeric year quarter using ${rawdata}/quarterly_f.dta
drop if _merge==2
drop _merge

** Log values
foreach y of varlist emp_laus* meanwks* unemp* labor_laus* qcew* qwi* vacrate* tight* property general_sales income corp_income total prod* state_qcew* state_unemp* xstate* awardamount state_gdp_all ui_tax_rate ///
    f_cl2_q{
	gen log`y' = ln(`y')
}

replace logawardamount=0 if logawardamount==.
replace loggeneral_sales =0 if loggeneral_sales ==.
replace logincome =0 if logincome ==.
replace logcorp_income =0 if logcorp_income ==.

** Difference across counties
sort pair_id_numeric time county_index
foreach var of varlist logemp_laus* logawardamount logmeanwks* logunemp* loglabor_laus* logqcew* logqwi* logstate_qcew* logstate_unemp* logxstate* logvacrate* logtight* logstate_gdp_all logui_tax_rate ///
logproperty loggeneral_sales logincome logcorp_income logtotal bbce* bhi sbsi sbtc logprod* judicial logf_cl*{
	by pair_id_numeric time: gen diff_`var' = `var'[1] - `var'[2]
}

foreach var of varlist diff_logproperty diff_loggeneral_sales diff_logincome diff_logcorp_income diff_logtotal diff_logawardamount{
	gen `var'_gdp = `var' - diff_logstate_gdp_all

}

** t+k values
sort pair_id_numeric county_index time
foreach var of varlist logemp_laus* logmeanwks* logunemp* loglabor_laus* logqcew_emp logqcew_emp_tot logqcew_wage logqcew_wage_tot logqwi*all* logvacrate* logtight* logf_cl*{
	forvalues y=1/8{
	by pair_id_numeric county_index: gen f`y'_`var'=diff_`var'[_n+`y']
}
}
** Quasi-difference k
foreach var of varlist logemp_laus* logmeanwks* logunemp* loglabor_laus* logqcew_emp logqcew_emp_tot logqcew_wage logqcew_wage_tot logqwi*all* logvacrate* logtight* logf_cl*{
	forvalues y=1/8{
	by pair_id_numeric county_index: gen qdk`y'_`var'=diff_`var'-((0.99*(1-seprate[_n+`y'-1]))^`y')*f`y'_`var'
	// Normalize QWI separation rates to the JOLTS mean (see paper appendix on
	// alternative separation measures). pair_sepr_tot is scaled by 1.706 and
	// pair_sepr_beg by 1.353 so that the average QWI-based separation rate
	// matches the JOLTS quarterly separation rate.
	by pair_id_numeric county_index: gen qdsk`y'_`var'=diff_`var'-((0.99*(1-pair_sepr_tot[_n+`y'-1]/1.706))^`y')*f`y'_`var'
	by pair_id_numeric county_index: gen qdsbk`y'_`var'=diff_`var'-((0.99*(1-pair_sepr_beg[_n+`y'-1]/1.353))^`y')*f`y'_`var'
}
}

sort pair_id_numeric county_index time
// drop *qwi*_ret
foreach ind in "all"{

	by pair_id_numeric county_index: gen did_logqwi_wage=diff_logqwiw1_`ind'[_n]-diff_logqwiw2_`ind'[_n-1]
	by pair_id_numeric county_index: gen did_logqwi_wage2=diff_logqwiw3_`ind'[_n]-diff_logqwiw4_`ind'[_n-1]
	by pair_id_numeric county_index: gen did_logqwi_wagef=diff_logqwiw1f_`ind'[_n]-diff_logqwiw2f_`ind'[_n-1]
	by pair_id_numeric county_index: gen did_logqwi_wage2f=diff_logqwiw3f_`ind'[_n]-diff_logqwiw4f_`ind'[_n-1]

}

foreach ind in "foo" "man" "ret"{

	by pair_id_numeric county_index: gen did_logqwi_wage_`ind'=diff_logqwiw1_`ind'[_n]-diff_logqwiw2_`ind'[_n-1]
	by pair_id_numeric county_index: gen did_logqwi_wage2_`ind'=diff_logqwiw3_`ind'[_n]-diff_logqwiw4_`ind'[_n-1]
	by pair_id_numeric county_index: gen did_logqwi_wagef_`ind'=diff_logqwiw1f_`ind'[_n]-diff_logqwiw2f_`ind'[_n-1]
	by pair_id_numeric county_index: gen did_logqwi_wage2f_`ind'=diff_logqwiw3f_`ind'[_n]-diff_logqwiw4f_`ind'[_n-1]

}

* Historical logmeanwks patches from the consolidated benefit_weeks columns
* (merged above with the PF series): 1999-2004 from the 2001-recession
* schedule, pre-1995 from the vintage weeks. The renames reproduce the
* original meanwks2 / (vintage) meanwks columns of the master datasets.
rename rec2001_meanwks2 meanwks2
gen logmeanwks2=log(meanwks2)
replace logmeanwks=logmeanwks2 if year<2005 & year>1998

drop meanwks
rename vintage_meanwks meanwks

replace logmeanwks = log(meanwks) if year<1995 | logmeanwks==.

capture drop diff_logmeanwks
sort pair_id_numeric quarter_index county_index
by pair_id_numeric quarter_index: gen diff_logmeanwks = logmeanwks[1]-logmeanwks[2]

merge m:1 fipsnumeric using ${rawdata}/housing_elasticity
drop _merge

merge m:1 fipsnumeric year quarter using ${rawdata}/IRSEquifax.dta
drop _merge

merge m:1 fipsnumeric year quarter using ${rawdata}/county_debt.dta
drop _merge

merge m:1 fipsnumeric year quarter using ${rawdata}/bartik_shocks
drop if _merge==2
drop _merge

merge m:1 fipsnumeric year using ${rawdata}/NewFHFA_2018_07_26
drop if _merge==2
drop _merge
rename fhfa_hpi hpi_fhfa

bys pair_id_numeric: egen st_min=min(fipsstate)
by  pair_id_numeric: egen st_max=max(fipsstate)
egen bordersegment=group(st_min st_max)

drop if pair_id_numeric==.

sort pair_id_numeric quarter_index county_index  

by pair_id_numeric quarter_index: gen other_county_u = unemp_rate_laus[2]

* Sort the data by panel ID and time variable
sort pair_id_numeric quarter_index

* Option 2: Manual calculation
* First demean the variables within each pair
by pair_id_numeric: egen mean_u1 = mean(unemp_rate_laus) if year>=1996 & year<=2000 & county_index==1
by pair_id_numeric: egen mean_u2 = mean(other_county_u) if year>=1996 & year<=2000 & county_index==1
gen d1=0
gen d2=0
replace d1 = unemp_rate_laus - mean_u1 if year>=1996 & year<=2000 & county_index==1
replace d2 = other_county_u - mean_u2 if year>=1996 & year<=2000 & county_index==1

* Calculate correlation components
gen prod = d1*d2
by pair_id_numeric: egen sum_prod = sum(prod)
by pair_id_numeric: egen sum_sq1 = sum(d1*d1)
by pair_id_numeric: egen sum_sq2 = sum(d2*d2)

* Calculate correlation
gen pair_corr = sum_prod/sqrt(sum_sq1*sum_sq2)

* Clean up intermediate variables if desired
drop mean_u1 mean_u2 d1 d2 prod sum_prod sum_sq1 sum_sq2

