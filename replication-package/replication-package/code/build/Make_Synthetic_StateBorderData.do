* ---------------------------------------------------------------------------
* Make_Synthetic_StateBorderData.do  ->  synthetic StateMonthlyBorderData
*
* The Missouri tightness figures (code/analysis/MO_Tightness_Figures.do) read a
* STATE-level border panel whose only proprietary column is total_vacancies_state
* (state-aggregated HWOL vacancies); the rest (state_labor_sa, state_unemp_count_sa,
* state_l_u_post, meanwks, pop) is public state LAUS/BLS data. The county-level
* synthetic path (Make_Synthetic_Vacancies.do -> new_vac_synthetic.dta) does not
* cover this state aggregate, so this builds the missing piece the easy way:
* sum the synthetic COUNTY vacancies to the state level and splice them in for
* total_vacancies_state. Result is fully shippable (public state columns + synthetic
* vacancies) and DEMONSTRATIVE (the synthetic county panel covers border counties,
* so the state sum is a partial-but-consistent stand-in -- fine, it is synthetic).
*
* Output: synthetic-data/StateMonthlyBorderData_synthetic.dta. Run
* Make_Synthetic_Vacancies.do first. Then run MO_Tightness_Figures.do with
*   global statefile "${synthetic}/StateMonthlyBorderData_synthetic.dta"
* ---------------------------------------------------------------------------

do "config.do"
* NOTE: regenerating this synthetic state panel needs the real (proprietary) StateMonthlyBorderData_2018_07_25.dta
* for its PUBLIC state-LAUS columns. It is NOT shipped; the synthetic OUTPUT is provided in synthetic-data/.
* Place the real panel in ${synthetic}/ to regenerate.
global proprietary "${synthetic}/"

set more off, perm

* --- synthetic county vacancies -> quarterly mean per county -> sum to state ---
use "${synthetic}/new_vac_synthetic.dta", clear
gen quarter = floor((month-1)/3)+1
collapse (mean) total_vacancies_county, by(fipsnumeric year quarter)   // monthly -> quarterly mean
gen fipsstate = floor(fipsnumeric/1000)
collapse (sum) syn_total_vacancies_state=total_vacancies_county, by(fipsstate year quarter)
tempfile synstate
save "`synstate'"

* --- real state border panel: keep the public columns, swap in synthetic vacancies ---
use "${proprietary}StateMonthlyBorderData_2018_07_25.dta", clear
drop total_vacancies_state
merge m:1 fipsstate year quarter using "`synstate'"
drop if _merge==2
drop _merge
rename syn_total_vacancies_state total_vacancies_state

label data "SYNTHETIC StateMonthlyBorderData (public state cols + summed synthetic county vacancies)"
save "${synthetic}/StateMonthlyBorderData_synthetic.dta", replace
