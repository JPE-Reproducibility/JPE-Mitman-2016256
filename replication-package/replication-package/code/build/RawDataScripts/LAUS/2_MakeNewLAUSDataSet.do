* ---------------------------------------------------------------------------
* 2_MakeNewLAUSDataSet.do  ->  LAUS/Output/NewLAUSData2014_final.dta
* Adds state aggregates (state_unemp, state_labor, leave-out xstate_unemp) to
* the county LAUS panel and merges the benefit-weeks series (meanwks), with
* the 2014 state-level statutory patches applied inline.
*
* INPUTS: LAUS/Output/laus_2014_final.dta (step 1);
*   Fullbenefits_MeanWks_Update.dta (PROVIDED benefit-weeks intermediate --
*   state x month mean weeks of UI eligibility).
* OUTPUT: NewLAUSData2014_final.dta (county x month with meanwks).
* (The commented-out additivity/claims merges are preserved from the
* original construction.)
* ---------------------------------------------------------------------------
clear all
set more off
do "config.do"

use "${rawdata}/LAUS/Output/laus_2014_final.dta"

gen fipsstate=floor(fipsnumeric/1000)

bys fipsstate year month: egen state_unemp=sum(unemp_count_laus)
bys fipsstate year month: egen state_labor=sum(labor_laus)
bys fipsnumeric year month: gen xstate_unemp=(state_unemp-unemp_count_laus)/(state_labor-labor_laus)

/*
** Merge in the additivity factor from the BLS
sort fipsstate year month
merge m:1 fipsstate year month using additivity.dta
drop _merge

** Merge in continuing claims data
sort fipsnumeric year month
merge 1:1 fipsnumeric year month using claims.dta
drop _merge
*/


** Merge in weeks
sort fipsstate year month
merge m:1 fipsstate year month using "${rawdata}/Fullbenefits_MeanWks_Update.dta"
drop _merge

*keep if inlist(fipsstate,13,37,45,47,51)
replace meanwks=26 if year==2014
replace meanwks=19 if fipsstate==37 & (year==2014 | (year==2013 & month>5))
replace meanwks=20 if inlist(fipsstate,20,26,29,45) & (year==2014)
replace meanwks=25 if fipsstate==5 & (year==2014)
replace meanwks=16 if fipsstate==12 & (year==2014)
replace meanwks=18 if fipsstate==13 & (year==2014)
replace meanwks=30 if fipsstate==25 & (year==2014)
replace meanwks=28 if fipsstate==30 & (year==2014)

save "${rawdata}/LAUS/Output/NewLAUSData2014_final", replace
