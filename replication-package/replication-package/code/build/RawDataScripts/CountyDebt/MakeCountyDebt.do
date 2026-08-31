* ---------------------------------------------------------------------------
* MakeCountyDebt.do  ->  county_debt.dta  (county debt-to-income controls)
* Raw: NY Fed Consumer Credit Panel / Equifax county debt-to-income (public-use),
*      household-debt-by-county.csv (ships in this folder).
* ---------------------------------------------------------------------------
cd ${code}/build/RawDataScripts/CountyDebt
import delimited "household-debt-by-county.csv", encoding(ISO-8859-1) clear

rename qtr quarter
rename area_fips fipsnumeric
rename low  dti_low
rename high dti_high
gen dti_mean = (dti_high+dti_low)/2

save "${rawdata}/county_debt.dta", replace
