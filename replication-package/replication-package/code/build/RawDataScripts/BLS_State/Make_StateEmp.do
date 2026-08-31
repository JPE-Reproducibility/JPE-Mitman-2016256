* ---------------------------------------------------------------------------
* Make_StateEmp.do  ->  state_emp_quarterly.dta
* State quarterly employment (seasonally adjusted + unadjusted), for emp_share
* (tab:Benefits_on_unemp Col 5) and prod_all_old (Table1_OLS).
*
* SOURCE (provided raw): BLS Local Area Unemployment Statistics state series,
*   la.data.2.AllStatesU (unadjusted) + la.data.3.AllStatesS (seasonally adjusted),
*   BLS_State/ (2013-06-22 vintage). series_id chars 6-7 = state FIPS, char 13 =
*   measure (5 = employment); period M01-M12.
* OUTPUT: state_emp_quarterly.dta, keyed fipsstate year quarter, with emp_state_sa, emp_state_u.
* ---------------------------------------------------------------------------
clear all
set more off
do "config.do"
local BLS "${rawdata}/BLS_State"

* --- unadjusted state employment (measure 5) ---
insheet using "`BLS'/la.data.2.AllStatesU", clear
keep if substr(series_id,13,1)=="5"
gen fipsstate = substr(series_id,6,2)
replace fipsstate = "72" if fipsstate=="43"          // BLS code 43 = Puerto Rico -> FIPS 72
gen month = real(substr(period,2,2))
drop if month==13 | missing(month)                   // M13 = annual avg
destring value, replace force
rename value emp_state_u
keep fipsstate year month emp_state_u
tempfile u
save `u'

* --- seasonally adjusted state employment (measure 5) ---
insheet using "`BLS'/la.data.3.AllStatesS", clear
keep if substr(series_id,13,1)=="5"
gen fipsstate = substr(series_id,6,2)
replace fipsstate = "72" if fipsstate=="43"
gen month = real(substr(period,2,2))
drop if month==13 | missing(month)
destring value, replace force
rename value emp_state_sa
keep fipsstate year month emp_state_sa
merge 1:1 fipsstate year month using `u', nogen

* --- collapse to quarterly mean (matches the original construction) ---
gen quarter = floor((month-1)/3)+1
destring fipsstate, replace
collapse (mean) emp_state_sa emp_state_u, by(fipsstate year quarter)
label data "BLS LAUS state quarterly employment (SA + unadjusted), 2013-06-22 vintage"
save "${rawdata}/state_emp_quarterly.dta", replace
di "state_emp_quarterly: N=" _N
