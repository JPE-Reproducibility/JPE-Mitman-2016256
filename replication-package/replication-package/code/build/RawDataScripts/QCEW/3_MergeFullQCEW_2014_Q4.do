clear all
set mem 1g
set matsize 11000
set maxvar 30000
set seed 5
set more off, perm
cap log close
set logtype text


global maindirectory "${rawdata}/"

global sep="/"

cap mkdir "${rawdata}/QCEW/Output"
cd "${rawdata}/QCEW/Output"

use "${rawdata}/QCEW_County_2014_total.dta"

rename emp qcew_emp_tot
gen qcew_wage_tot=avg_wkly_wage
drop avg_wkly_wage total_qtrly_wages
sort fipsnumeric year month
merge 1:1 fipsnumeric year month using "${rawdata}/QCEW_County_2014_private.dta"

rename emp qcew_emp
gen qcew_wage=avg_wkly_wage
drop avg_wkly_wage total_qtrly_wages

append using QCEWAllYears

drop _merge
save "${rawdata}/QCEWAllYears_2014Q4", replace
