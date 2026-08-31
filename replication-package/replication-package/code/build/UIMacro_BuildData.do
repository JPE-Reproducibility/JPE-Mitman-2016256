**********************************************************************************************
* UIMacro_BuildData.do -- build the master datasets (data/processed) from data/raw.
* Run from the `code/` directory:  do "config.do"  then  do "build/UIMacro_BuildData.do"
* (this file re-sources config after `clear all`). The vacancy file defaults to the public
* synthetic stand-in via config (${vacfile}); the Data Editor swaps in real HWOL to reproduce
* the published vacancy numbers. See build/SYNTHETIC_VACANCY_PATH.md.
**********************************************************************************************
clear all
drop _all
set matsize 11000
set maxvar 32767
set more off, perm

do "config.do"                 // sets ${rawdata} ${processed} ${vacfile} ... (run from code/)
cd "${code}/build"             // so the relative `do MakeDataSetsMainPaper`/etc. below resolve

capture log close
log using "${output}/logs/BuildMacroData.log", replace

use "${rawdata}/NewLAUSBorderData2014_final24Nov16"

* Benefit weeks: ONE consolidated provided input (benefit_weeks.dta). Its
* monthly meanwks already carries every inline patch
* the build previously applied (missing->26, FullFinal totalweeks for 2011m4+,
* TEUC +13 for 2002m3-2003m12, NJ 1996m6-11 =39); the quarterly rec2001/
* vintage/pf columns are merged after the quarterly collapse inside
* MakeDataSetsMainPaper.
drop meanwks
merge m:1 fipsstate year month using "${rawdata}/benefit_weeks", keepusing(meanwks)
capture drop _merge

merge m:1 fipsstate year month using "${rawdata}/StateEmp2014rev"
drop if _merge==2
capture drop _merge

do MakeDataSetsMainPaper_v5_newvac


save "${processed}/UIMacro_RevisionData.dta", replace

preserve
do MakeDataControls.do
save "${processed}/UIMacro_DataControls.dta", replace

restore

do MakeWageData.do
save "${processed}/ProcessedWages.dta", replace

log close
