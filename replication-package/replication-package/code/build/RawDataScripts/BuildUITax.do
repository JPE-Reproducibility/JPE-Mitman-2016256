 use "${rawdata}/UI_Tax_Data_Final.dta", clear
 rename state_abr state_abbrev
 
 merge m:1 state_abbrev using "${rawdata}/state_codes"

 drop if _merge==2
drop _merge

rename state_fips fipsstate
rename year fiscal_year
destring fipsstate, replace

keep fipsstate fiscal_year UI_Tax_Receipts
save "${rawdata}/UI_Tax_Data_Fips", replace
