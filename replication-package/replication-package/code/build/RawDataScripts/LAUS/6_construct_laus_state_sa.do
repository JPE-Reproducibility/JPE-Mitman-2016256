* ---------------------------------------------------------------------------
* 6_construct_laus_state_sa.do  ->  laus_state_sa.dta
* State monthly LAUS panel, seasonally adjusted (unemployment rate/count,
* employment, labor force), 1976-2014. Feeds Make_PlaceboWeeksData.do (the
* state_unemp_rate_sa extension trigger of the placebo benefit schedule).
* Independent of the other LAUS chains (same raw download batch).
*
* SOURCE (provided raw, LAUS/RevisedData/): ladata3AllStatesS.txt, the
*   DECEMBER-2015 revised download (1976-2015; the 2015 LAUS re-benchmark
*   revised the whole SA history, so this is a DIFFERENT vintage from the
*   Sept-2014 extract step 4 uses -- both ship). Chars 6-7 = state FIPS,
*   char 20 = measure; M13 dropped.
* OUTPUT: laus_state_sa.dta, keyed fipsstate year month.
* ---------------------------------------------------------------------------
clear all
set more off
do "config.do"

insheet using "${rawdata}/LAUS/RevisedData/ladata3AllStatesS.txt", clear
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
ren value3 state_unemp_rate_sa
ren value4 state_unemp_count_sa
ren value5 state_emp_sa
ren value6 state_labor_sa

save "${rawdata}/laus_state_sa", replace
