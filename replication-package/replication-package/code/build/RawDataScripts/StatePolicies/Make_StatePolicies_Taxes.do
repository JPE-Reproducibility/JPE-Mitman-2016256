* ---------------------------------------------------------------------------
* Make_StatePolicies_Taxes.do  ->  StatePolicies_taxes.dta
* Builds the five state-tax-revenue columns carried in StatePolicies.dta:
*   property       state property-tax collections          (T01)
*   general_sales  general sales & gross-receipts taxes     (T09)
*   income         individual income taxes                  (T40)
*   corp_income    corporation net income taxes             (T41)
*   total          total state taxes                        (Total Taxes)
* These feed the Controls IFE experiment (code/exporters/OutputDataSetsUIMacro_Controls.do),
* which consumes diff_logtotal_gdp / diff_logincome_gdp / diff_loggeneral_sales_gdp.
*
* SOURCE (provided Census intermediate, in ${rawdata}/):
*   IouriiStateTax.dta -- the U.S. Census Bureau "Quarterly Summary of State & Local
*   Tax Revenue", long form (per_name x geo_code x dt_desc x val). We use:
*     cat_desc == "Table 3 - Latest State Tax Collections by State and Type of Tax"
*   which gives state-by-tax-type QUARTERLY collections ($ thousands, not seasonally
*   adjusted), geo_code = state postal abbreviation, per_name = "Q<q><yyyy>" (e.g.
*   "Q12008" = 2008Q1). Spans 1994Q1-2013Q1 for these five types x 49 states.
*   (The companion IouriiStateFinances.dta is the ANNUAL state-finances file and lacks
*    a property-tax column, so it is not used here.)
*
* Coverage / edge handling:
*   - AK (2) / HI (15) dropped (no Alaska/Hawaii border pairs).
*   - DC (11) tax nulled: IouriiStateTax carries DC, but DC is excluded from these
*     state-policy controls (DC tax all missing); DC pairs ARE
*     in the sample, so the row stays with tax blanked -- same treatment as the indices.
*   - keep year<=2012: the analysis panel ends 2012Q4; this trims the lone 2013Q1 quarter.
* ---------------------------------------------------------------------------
clear all
set more off
do "config.do"
global DATA "${rawdata}"

* ---- state abbreviation -> FIPS crosswalk (AK/HI kept here, dropped below) ----
clear
input str2 abb fipsstate
"AL" 1
"AK" 2
"AZ" 4
"AR" 5
"CA" 6
"CO" 8
"CT" 9
"DE" 10
"DC" 11
"FL" 12
"GA" 13
"HI" 15
"ID" 16
"IL" 17
"IN" 18
"IA" 19
"KS" 20
"KY" 21
"LA" 22
"ME" 23
"MD" 24
"MA" 25
"MI" 26
"MN" 27
"MS" 28
"MO" 29
"MT" 30
"NE" 31
"NV" 32
"NH" 33
"NJ" 34
"NM" 35
"NY" 36
"NC" 37
"ND" 38
"OH" 39
"OK" 40
"OR" 41
"PA" 42
"RI" 44
"SC" 45
"SD" 46
"TN" 47
"TX" 48
"UT" 49
"VT" 50
"VA" 51
"WA" 53
"WV" 54
"WI" 55
"WY" 56
end
tempfile xwalk
save `xwalk'

* ---- long-form Census tax revenue -> wide tax columns ----
use "${DATA}/IouriiStateTax.dta", clear
keep if cat_desc=="Table 3 - Latest State Tax Collections by State and Type of Tax"
keep if inlist(dt_desc,"T01 Property Taxes","T09 General Sales and Gross Receipts Taxes","T40 Individual Income Taxes","T41 Corporation Net Income Taxes","Total Taxes")
gen quarter = real(substr(per_name,2,1))
gen year    = real(substr(per_name,3,4))
gen str12 tag = ""
replace tag="property"      if dt_desc=="T01 Property Taxes"
replace tag="general_sales" if dt_desc=="T09 General Sales and Gross Receipts Taxes"
replace tag="income"        if dt_desc=="T40 Individual Income Taxes"
replace tag="corp_income"   if dt_desc=="T41 Corporation Net Income Taxes"
replace tag="total"         if dt_desc=="Total Taxes"
rename geo_code abb
merge m:1 abb using `xwalk', keep(match) nogen     // drops "US" (national) etc.
keep fipsstate year quarter tag val
reshape wide val, i(fipsstate year quarter) j(tag) string
rename val* *

* ---- coverage / edge handling ----
drop if inlist(fipsstate,2,15)                     // no Alaska/Hawaii border pairs
foreach v of varlist property general_sales income corp_income total {
    replace `v'=. if fipsstate==11                 // DC excluded from these controls
}
keep if year<=2012                                 // the shipped panel ends 2012Q4

order fipsstate year quarter property general_sales income corp_income total
sort fipsstate year quarter
save "${DATA}/StatePolicies_taxes", replace
