* ---------------------------------------------------------------------------
* 1_construct_laus_2014.do  ->  LAUS/Output/laus_2014_final.dta
* County monthly LAUS panel 1990-2014 (unemployment rate/count, employment,
* labor force), the base layer of the core border-county panel.
*
* SOURCE (provided raw, LAUS/): BLS Local Area Unemployment Statistics county
*   series, post-2014-redesign vintage -- five flat extracts
*   ladata0CurrentU{90-94,95-99,00-04,05-09,10-14}.txt (series_id chars 6-10 =
*   county FIPS, chars 4-5 = area type "CN", char 20 = measure: 3 unemp rate,
*   4 unemp count, 5 employment, 6 labor force; period M01-M12, M13 = annual
*   average, dropped). Download: https://www.bls.gov/lau/.
* OUTPUT: laus_2014_final.dta, keyed fipsnumeric year month (N=965,460).
* Intermediate temp files go to LAUS/Output/.
* ---------------------------------------------------------------------------
clear all
set more off
do "config.do"
cap mkdir "${rawdata}/LAUS/Output"
cd "${rawdata}/LAUS/Output"

** First append the various input (raw) files
insheet using "${rawdata}/LAUS/ladata0CurrentU90-94.txt", clear
drop footnote*
save ladata0CurrentU_P1, replace
insheet using "${rawdata}/LAUS/ladata0CurrentU95-99.txt", clear
drop footnote*
save ladata0CurrentU_P2, replace
insheet using "${rawdata}/LAUS/ladata0CurrentU00-04.txt", clear
drop footnote*
save ladata0CurrentU_P3, replace
insheet using "${rawdata}/LAUS/ladata0CurrentU05-09.txt", clear
destring value, replace force
drop footnote*
save ladata0CurrentU_P4, replace
insheet using "${rawdata}/LAUS/ladata0CurrentU10-14.txt", clear
drop footnote*
save ladata0CurrentU_P5, replace

use ladata0CurrentU_P1, clear
erase ladata0CurrentU_P1.dta
forvalues i=2/5{
	disp(`i')
	append using ladata0CurrentU_P`i'.dta
	erase ladata0CurrentU_P`i'.dta
}
gen month = substr(period,2,2)
destring month, replace
drop if month==13		// annual average
drop period

gen fipsnumeric = substr(series_id,6,5)
destring fipsnumeric, replace

** Keep only counties
gen area_type = substr(series_id,4,2)
keep if area_type=="CN"
drop area_type

** Define variable type (unemp. rate, unemp, emp, labor)
gen var_type = substr(series_id,20,1)
destring var_type, replace

drop series_id
reshape wide value, i(fipsnumeric year month) j(var_type)
ren value3 unemp_rate_laus
ren value4 unemp_count_laus
ren value5 emp_laus
ren value6 labor_laus

la var unemp_rate_laus "Unemp. rate in LAUS"
la var unemp_count_laus "Unemp. count in LAUS"
la var emp_laus "Employment in LAUS"
la var labor_laus "Labor in LAUS"

save laus_2014_final, replace
