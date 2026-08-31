global direc "${rawdata}/"
use ${rawdata}/QCEWAllYears_2014Q4, clear


* the from-raw QCEWAllYears carries fipsnumeric only; derive the state FIPS
cap confirm variable fipsstate
if _rc gen fipsstate = floor(fipsnumeric/1000)

* state monthly QCEW employment aggregates (consumed by the build's prod_priv /
* prod_all_qcew; matches the shipped panel cell-exactly)
bys fipsstate year month: egen state_qcew_emp     = sum(qcew_emp)
bys fipsstate year month: egen state_qcew_emp_tot = sum(qcew_emp_tot)

gen fiscal_quarter = quarter-2
replace fiscal_quarter = 3 if quarter==1
replace fiscal_quarter = 4 if quarter==2
gen fiscal_year = year
replace fiscal_year = fiscal_year+1 if quarter==3 | quarter==4

bys fipsstate fiscal_year: egen state_qcew_wagetot=sum(qcew_wage)

merge m:1 fipsstate fiscal_year using ${rawdata}/UI_Tax_Data_Fips.dta
drop if _merge==2
drop _merge

gen qcew_ui_tax_rate = 1000*UI_Tax_Receipts/state_qcew_wagetot

save ${rawdata}/QCEWAllYears_2014Q4, replace
