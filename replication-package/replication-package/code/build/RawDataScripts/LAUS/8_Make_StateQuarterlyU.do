* ---------------------------------------------------------------------------
* 8_Make_StateQuarterlyU.do  ->  StateQuarterlyU.dta
* State quarterly unemployment (rate state_ur_u_pre + count state_uc_u_pre,
* pre-redesign vintage), consumed by analysis/TableA2.do (the Hall-style
* alternative endogeneity test, app_tab:A-1, which uses the 2007 values).
*
* Two stages:
*   (1) raw LAUS/ladata2AllStatesU.txt (state series, unadjusted, the
*       PRE-redesign January-2015 extract -- NOT the RevisedData vintage
*       steps 6-7 use) -> monthly panel laus_state_u_preredesign
*       (LAUS/Output/).
*   (2) quarterly collapse. The DAILY benefit-weeks file is merged (1:m on
*       state-month) before collapsing, so wherever the daily file has
*       coverage (2002+) the quarterly figure is a DAY-WEIGHTED mean of the
*       monthly values, and a plain 3-month mean elsewhere.
*
* TableA2 uses only 2007 values and drops unmatched rows on merge.
* ---------------------------------------------------------------------------
clear all
set more off
do "config.do"
cap mkdir "${rawdata}/LAUS/Output"

* --- (1) monthly pre-redesign state panel ---
insheet using "${rawdata}/LAUS/ladata2AllStatesU.txt", clear
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
ren value3 state_ur_u_pre
ren value4 state_uc_u_pre
ren value5 state_e_u_pre
ren value6 state_l_u_pre

save "${rawdata}/LAUS/Output/laus_state_u_preredesign", replace

* --- (2) day-weighted quarterly collapse (via the daily benefit-weeks file) ---
gen quarter = floor((month-1)/3)+1
gen statefips=fipsstate
merge 1:m statefips year month using "${rawdata}/FullFinal_AllYears-Daily.dta"
collapse state_ur_u_pre state_uc_u_pre, by(fipsstate year quarter)
drop if fipsstate==.

save "${rawdata}/StateQuarterlyU", replace
