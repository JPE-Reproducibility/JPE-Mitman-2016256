* ---------------------------------------------------------------------------
* 4_construct_laus_state_sa_pre.do  ->  LAUS/Output/laus_state_sa_pre.dta
* State monthly LAUS panel, seasonally adjusted, pre-redesign vintage
* (1976-2014): unemployment rate/count, employment, labor force.
* Independent of steps 1-3; feeds step 5 (StateEmp2014rev).
*
* SOURCE (provided raw, LAUS/): BLS LAUS state series ladata3AllStatesS.txt
*   (post-redesign 20-char series_id format: chars 6-7 = state FIPS, char 20 =
*   measure 3/4/5/6; period M01-M12, M13 dropped). NOTE this is a different
*   extract/format from BLS_State/la.data.3.AllStatesS (13-char series_id,
*   2013-06-22 vintage) used by BLS_State/Make_StateEmp.do.
* OUTPUT: laus_state_sa_pre.dta, keyed fipsstate year month (N=24,336).
* ---------------------------------------------------------------------------
clear all
set more off
do "config.do"

** First append the various input (raw) files
insheet using "${rawdata}/LAUS/ladata3AllStatesS.txt", clear
drop footnote*

gen month = substr(period,2,2)
destring month, replace
drop if month==13		// annual average
drop period

gen fipsstate = substr(series_id,6,2)
destring fipsstate, replace

** Define variable type (unemp. rate, unemp, emp, labor)
gen var_type = substr(series_id,20,1)
destring var_type, replace

drop series_id
reshape wide value, i(fipsstate year month) j(var_type)
ren value3 state_ur_sa_pre
ren value4 state_uc_sa_pre
ren value5 state_e_sa_pre
ren value6 state_l_sa_pre

save "${rawdata}/LAUS/Output/laus_state_sa_pre", replace
