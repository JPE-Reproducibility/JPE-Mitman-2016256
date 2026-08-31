* ---------------------------------------------------------------------------
* Make_StatePolicies_Indices.do  ->  StatePolicies_indices.dta
* Builds the four state-policy controls in StatePolicies that feed the Controls IFE
* experiment (code/exporters/OutputDataSetsUIMacro_Controls.do) and code/analysis/Table1_OLS_Controls.do:
*   sbsi     Small Business & Entrepreneurship Council Survival Index   (annual, 2005-2012)
*   bhi      Beacon Hill Institute State Competitiveness Index (score)  (annual, 2005-2012)
*   sbtc     Tax Foundation State Business Tax Climate Index            (quarterly, see below)
*   judicial judicial-foreclosure-state flag (0/1)                      (time-invariant)
*
* No build file existed; reconstructed from the raw (all in this folder):
*   Judicial.csv                      State,Judicial(0/1)
*   SBSI_Data.csv                     State, abbrev, then columns 2012..2005 (descending)
*   BHI_Data_2005-2012-Scoreonly.csv  state(abbrev), 2012_score..2005_score (descending)
*   SBTC_Data_Scoreonly.csv           abbrev + 32 values, NO header. The 32 columns are
*                                     QUARTERS descending from 2013Q2 to 2005Q3 (qid 8054..8023);
*                                     each annual SBTC index spans Y-1 Q3 .. Y Q2 (the index
*                                     updates at Q3), so within an index-year the 4 quarter
*                                     values repeat. (The ".._Scoreonly 2.ods" is the headered version.)
*
* AK (2) and HI (15) are dropped (no Alaska/Hawaii border pairs).
* ---------------------------------------------------------------------------
clear all
set more off
do "config.do"
global RAW "${code}/build/RawDataScripts/StatePolicies"

* ---- state abbreviation -> FIPS crosswalk ----
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

* ---- judicial (time-invariant) ----
insheet using "${RAW}/Judicial.csv", names clear
rename state abb
merge m:1 abb using `xwalk', keep(match) nogen
keep fipsstate judicial
tempfile jud
save `jud'

* ---- sbsi (auto-insheet: v1 name, v2 abbrev, v3..v10 = 2012..2005) ----
insheet using "${RAW}/SBSI_Data.csv", clear
drop in 1
rename v2 abb
forvalues c=3/10 {
    local yr = 2012 - (`c'-3)
    rename v`c' sbsi`yr'
    destring sbsi`yr', replace force
}
keep abb sbsi*
merge m:1 abb using `xwalk', keep(match) nogen
reshape long sbsi, i(fipsstate) j(year)
tempfile sbsi
save `sbsi'

* ---- bhi (insheet,names: state, _score(=2012), v3..v9 = 2011..2005) ----
insheet using "${RAW}/BHI_Data_2005-2012-Scoreonly.csv", names clear
rename state abb
rename _score bhi2012
destring bhi2012, replace force
forvalues c=3/9 {
    local yr = 2011 - (`c'-3)
    rename v`c' bhi`yr'
    destring bhi`yr', replace force
}
keep abb bhi*
merge m:1 abb using `xwalk', keep(match) nogen
reshape long bhi, i(fipsstate) j(year)
tempfile bhi
save `bhi'

* ---- sbtc (no header: 32 cols = quarters descending from 2013Q2 to 2005Q3) ----
insheet using "${RAW}/SBTC_Data_Scoreonly.csv", clear
rename v1 abb
reshape long v, i(abb) j(pos)            // pos = 2..33
gen qid     = 8054 - (pos-2)             // 8054 = 2013*4+2 (2013Q2)
gen quarter = mod(qid-1,4)+1
gen year    = (qid-quarter)/4
rename v sbtc
destring sbtc, replace force
merge m:1 abb using `xwalk', keep(match) nogen
keep fipsstate year quarter sbtc
keep if inrange(year,2005,2012)
tempfile sbtc
save `sbtc'

* ---- assemble at fipsstate x year x quarter (2005-2012) ----
use `sbsi', clear
expand 4
bys fipsstate year: gen quarter = _n
merge m:1 fipsstate year using `bhi', nogen
merge 1:1 fipsstate year quarter using `sbtc', nogen
merge m:1 fipsstate using `jud', nogen
drop if inlist(fipsstate,2,15)           // no Alaska/Hawaii border pairs
* DC (11) is not classified for these state-policy indices (every index missing for DC,
* all years); the on-hand SBSI_Data.csv / Judicial.csv include DC, so blank it. (DC pairs ARE in the
* sample, so this keeps the Controls-experiment sample identical.)
foreach v of varlist sbsi sbtc bhi judicial {
    replace `v'=. if fipsstate==11
}
keep fipsstate year quarter sbsi sbtc bhi judicial
order fipsstate year quarter sbsi sbtc bhi judicial
sort fipsstate year quarter
save "${rawdata}/StatePolicies_indices", replace
