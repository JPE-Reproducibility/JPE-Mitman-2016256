**********************************************************************************************
* UIMacro_BuildData_Synthetic.do
*
* Builds a SHIPPABLE, synthetic-vacancy vintage of the master datasets, identical to
* UIMacro_BuildData.do except that the proprietary HWOL county vacancies are replaced
* by the public-data synthetic stand-in (code/build/Make_Synthetic_Vacancies.do ->
* new_vac_synthetic.dta) via the ${vacfile} switch in MakeDataSetsMainPaper_v5_newvac.do.
*
* Output vintage = "SYNTH": UIMacro_RevisionData_SYNTH.dta, UIMacro_DataControls_SYNTH.dta.
* (Results built on these are DEMONSTRATIVE for vacancy-dependent tables/figures,
* because the proprietary vacancy data cannot be redistributed.) Run
* Make_Synthetic_Vacancies.do first.
*
* The build's `clear all` wipes pre-set globals, so the synthetic settings are baked in
* here rather than passed from a wrapper. ProcessedWages is rebuilt here too: wages are
* vacancy-independent, but the file carries forward RevisionData columns, so building it
* from the SYNTH (not real-HWOL) RevisionData keeps the whole processed set HWOL-free.
**********************************************************************************************
clear all
drop _all
set matsize 11000
set maxvar 32767
set more off, perm

do "config.do"
global direc = "${root_dropbox}/"
global today = "SYNTH"
global vacfile = "${rawdata}/new_vac_synthetic.dta"   // synthetic vacancies
cd ${code}/build

capture log close
log using BuildMacroData_${today}.log, replace

use ${rawdata}/NewLAUSBorderData2014_final24Nov16

* benefit weeks: single consolidated provided input (benefit_weeks.dta);
* monthly meanwks fully patched, quarterly columns merged post-collapse
* inside MakeDataSetsMainPaper.
drop meanwks
merge m:1 fipsstate year month using ${rawdata}/benefit_weeks, keepusing(meanwks)
capture drop _merge

merge m:1 fipsstate year month using ${rawdata}/StateEmp2014rev
drop if _merge==2
capture drop _merge

do MakeDataSetsMainPaper_v5_newvac

save ${processed}/UIMacro_RevisionData${today}.dta, replace

preserve
do MakeDataControls.do
save "${processed}/UIMacro_DataControls${today}.dta", replace
restore

* Wages too: rebuild ProcessedWages from the synthetic RevisionData. Wages are
* vacancy-independent, but ProcessedWages carries forward RevisionData columns -- so
* building it from the synthetic (not real-HWOL) RevisionData keeps the entire shipped
* processed set free of any proprietary HWOL-derived values.
do MakeWageData.do
save "${processed}/ProcessedWages${today}.dta", replace

log close
