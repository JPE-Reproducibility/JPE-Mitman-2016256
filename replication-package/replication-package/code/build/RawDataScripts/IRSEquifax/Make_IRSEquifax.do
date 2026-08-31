* ---------------------------------------------------------------------------
* Make_IRSEquifax.do  ->  IRSEquifax.dta
* Builds the IRSEquifax county income/credit file that the main build merges at
* MakeDataSetsMainPaper_v5_newvac.do (merge m:1 fipsnumeric year quarter).
*
* SOURCE (provided, citable intermediate):
*   networth_all_counties_2004q1_2012q4.dta -- the county-quarter net-worth/income
*   panel from the published replication archive for:
*     Greg Kaplan, Kurt Mitman & Giovanni L. Violante, "Non-Durable Consumption and
*     Housing Net Worth in the Great Recession: Evidence from Easily Accessible
*     Data," Journal of Public Economics.
*   (In that archive it lives in RawData/.) Its construction is documented in that
*   project's data_generation.tex + prog/ (SOI county income + IRS/Equifax credit +
*   Flow of Funds + ACS + Zillow); the underlying raw ran on the original RA's
*   machine and is not redistributed here, so we cite the published archive and ship
*   the built county panel as the input. A copy ships in ${rawdata}/.
*
* This producer is the CountyIncome subsetting step: it just subsets the
* net-worth panel to the income/housing/mortgage columns the build keeps and renames
* the county key. The ONLY column the published paper consumes is `agi` (annual IRS
* SOI county adjusted gross income, expanded across quarters) -> diff_agi, a control
* in all three tab:Endog_Vars regressions (code/analysis/Endog_Vars.do). The remaining
* columns (housing_assets*, mortgage_*, wage_income/dividends/interest/nonwage_income)
* are carried through MakeDataControls but never reach a paper artifact.
* ---------------------------------------------------------------------------
clear all
set more off
set maxvar 32767
global DATA "${rawdata}"

use "${DATA}/networth_all_counties_2004q1_2012q4.dta", clear
destring countycode, replace
rename countycode fipsnumeric
* Only agi is consumed downstream (-> diff_agi, a tab:Endog_Vars control). The full
* CountyIncome.do kept housing_as* mortgage_* nreturns wage_income dividends interest
* nonwage_income other_nonwage_income too, but those are unused downstream. Keep just
* the consumed column.
keep year quarter fipsnumeric agi
sort fipsnumeric year quarter
save "${DATA}/IRSEquifax", replace
