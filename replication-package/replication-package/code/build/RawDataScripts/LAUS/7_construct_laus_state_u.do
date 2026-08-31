* ---------------------------------------------------------------------------
* 7_construct_laus_state_u.do  ->  laus_state_u.dta
* State monthly LAUS panel, NOT seasonally adjusted (unemployment rate/count,
* employment, labor force), 1976-2014. Feeds Make_PlaceboWeeksData.do (the
* state_unemp_rate_u variant of the placebo extension trigger).
*
* SOURCE (provided raw, LAUS/RevisedData/): ladata2AllStatesU.txt, the
*   DECEMBER-2015 revised download (state series, unadjusted, 1976-2015;
*   same vintage as step 6's file, NOT the Sept-2014 batch).
* OUTPUT: laus_state_u.dta, keyed fipsstate year month.
* ---------------------------------------------------------------------------
clear all
set more off
do "config.do"

insheet using "${rawdata}/LAUS/RevisedData/ladata2AllStatesU.txt", clear
drop footnote*

gen month = substr(period,2,2)
destring month, replace
drop if month==13		// annual average
drop period

gen fipsstate = substr(series_id,6,2)
destring fipsstate, replace

gen var_type = substr(series_id,20,1)
destring var_type, replace

drop series_id
reshape wide value, i(fipsstate year month) j(var_type)
ren value3 state_unemp_rate_u
ren value4 state_unemp_count_u
ren value5 state_emp_u
ren value6 state_labor_u

save "${rawdata}/laus_state_u", replace
