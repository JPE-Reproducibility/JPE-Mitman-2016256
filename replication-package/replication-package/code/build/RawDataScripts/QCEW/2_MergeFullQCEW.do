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

use "${rawdata}/QCEW_Historical_County_total.dta"

rename emp qcew_emp_tot
gen qcew_wage_tot=avg_wkly_wage
drop avg_wkly_wage total_qtrly_wages
sort fipsnumeric year month
merge 1:1 fipsnumeric year month using "${rawdata}/QCEW_Historical_County_private.dta"

rename emp qcew_emp
gen qcew_wage=avg_wkly_wage
drop avg_wkly_wage total_qtrly_wages

save vintageqcew.dta, replace

clear

use "${rawdata}/QCEW/Output/qcew.dta", clear

	forvalues x=1/3{
		gen qcew_emp`x'=qcew_priv_empm`x'
		gen qcew_emp_tot`x'=qcew_all_empm`x'

	}

	rename qtr quarter
	rename fips fipsnumeric
	rename qcew_all_wkly_wage qcew_wage_tot
	rename qcew_priv_wkly_wage qcew_wage
	keep fipsnumeric year quarter qcew_emp* qcew_wage*
	reshape long qcew_emp qcew_emp_tot, i(fipsnumeric year quarter) j(month)
	replace month=(quarter-1)*3+month


append using vintageqcew.dta

drop _merge
* 2014 comes from the refresh files appended in step 3; the shipped panel spans
* 1975-2014 with one row per county-month, so the 2014-2015 rows built from the
* allhlcn raws are dropped here
drop if year>=2014

save QCEWAllYears, replace
