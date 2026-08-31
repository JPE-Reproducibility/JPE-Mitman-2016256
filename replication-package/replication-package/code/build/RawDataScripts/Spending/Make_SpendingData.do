* ---------------------------------------------------------------------------
* Make_SpendingData.do  ->  spending_data.dta
* County x quarter federal ARRA (Recovery Act) award spending, FY2009-FY2012,
* for the awardamount / diff_logawardamount stimulus-spending control in the
* main build.
*
* SOURCE (provided raw, SpendingData/):
*   cumulativenationalsummary_feb17_2009_dec31_2012.csv -- Recovery.gov
*     cumulative national summary of ARRA awards (Feb 17 2009 - Dec 31 2012):
*     one row per award, with local_amount and the place-of-performance ZIP
*     (pop_postal_cd) and fiscal year/quarter.
*   ZiptoCounty.csv -- Missouri Census Data Center geocorr ZCTA->county
*     crosswalk with population allocation factors (afact).
* OUTPUT: spending_data.dta -- awardamount by fipsnumeric year quarter
*   (award dollars allocated from ZIP to county in proportion to afact;
*   fiscal quarters mapped to calendar quarters via the mid-quarter month).
* The ZIP-to-county allocation uses a deterministic numbering of the expanded
* crosswalk: `county` is included in the sort/by groups so each (zcta5,county)
* row is unique and every county receives all 4 years x 4 quarters. (Numbering
* by `by zcta5 afact: gen fiscal_year=_n` instead would be nondeterministic
* when two counties in a zip share the same afact -- 8,650 such groups -- as
* Stata's unstable sort breaks the tie differently each run and silently drops
* allocations.) Stable pre-collapse sorts pin the float summation order. The
* expanded crosswalk intermediate is written to SpendingData/Output/.
* ---------------------------------------------------------------------------
clear all
set more off
do "config.do"
cap mkdir "${rawdata}/SpendingData/Output"

insheet using "${rawdata}/SpendingData/cumulativenationalsummary_feb17_2009_dec31_2012.csv", clear
keep award_key fiscal_year fiscal_qtr local_amount pop_postal_cd
destring  award_key fiscal_year fiscal_qtr, replace

rename pop_postal_cd recipient_zip_code
replace recipient_zip_code=subinstr(recipient_zip_code,"-","",.)
replace recipient_zip_code=subinstr(recipient_zip_code," ","",.)
*destring recipient_zip_code, force gen(zip_code_t1)
gen strlen=strlen(recipient_zip_code)
replace recipient_zip_code="" if strlen<=3 & strlen>1
replace recipient_zip_code="" if strlen==6|strlen==7
replace recipient_zip_code="" if strlen>9

replace recipient_zip_code="0" + recipient_zip_code if strlen==8|strlen==4

gen zipcode=substr(recipient_zip_code,1,5)

drop if local_amount=="General Services"
destring local_amount, replace
keep local_amount zipcode fiscal_year fiscal_qtr
sort fiscal_year fiscal_qtr zipcode, stable
collapse (sum) local_amount, by(fiscal_year fiscal_qtr zipcode)
drop if zipcode==""
d
preserve
insheet using "${rawdata}/SpendingData/ZiptoCounty.csv", clear names
drop if county=="county"
expand 4
sort zcta5 county afact
by zcta5 county afact: gen fiscal_year=_n
replace fiscal_year=2009 if fiscal_year==1
replace fiscal_year=2010 if fiscal_year==2
replace fiscal_year=2011 if fiscal_year==3
replace fiscal_year=2012 if fiscal_year==4
expand 4
sort zcta5 county afact fiscal_year
by zcta5 county afact fiscal_year : gen fiscal_qtr=_n

sort zcta5 fiscal_year fiscal_qtr, stable
save "${rawdata}/SpendingData/Output/ZiptoCounty", replace
restore

rename zipcode zcta5
sort zcta5 fiscal_year fiscal_qtr, stable
merge 1:m zcta5 fiscal_year fiscal_qtr using "${rawdata}/SpendingData/Output/ZiptoCounty"
count if _merge==3
drop if _merge==2

drop if _merge==1
destring afact, replace
gen awardamount=local_amount*afact
keep awardamount fiscal_year fiscal_qtr county zcta5
sort fiscal_year fiscal_qtr county zcta5, stable
collapse (sum) awardamount, by(fiscal_year fiscal_qtr county)



gen month=2 if fiscal_qtr==1
replace month=5 if fiscal_qtr==2
replace month=8 if fiscal_qtr==3
replace month=11 if fiscal_qtr==4
gen day=15
tostring day month fiscal_year, replace
gen date=month+"/"+day+"/"+fiscal_year
gen time=date(date,"MDY",2020)
replace time=qofd(time)
format %tq time
drop month day date
move time fiscal_qtr
destring fiscal_year, replace

ren fiscal_year year
ren fiscal_qtr quarter
destring county, gen(fipsnumeric)
drop time county

save "${rawdata}/spending_data.dta", replace
