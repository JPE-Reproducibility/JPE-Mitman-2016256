* ---------------------------------------------------------------------------
* Process_SNAP_Policy_Database.do  ->  SNAP_Policy_Database_Processed_2018_premerge.dta
*
* Builds the SNAP broad-based-categorical-eligibility controls the build merges:
* bbce2018 / bbce_asset2018 -> diff_bbce_asset2018, used in the Controls IFE experiment
* (code/exporters/OutputDataSetsUIMacro_Controls.do) and code/analysis/Table1_OLS_Controls.do.
*
* Raw (public): USDA SNAP Policy Database, SNAP_Policy_Database.csv (state x month).
*
* NOTE: this replaces the former SNAPspend2018 / BuildSNAP.do path -- that was SNAP
* *spending*, which fed only snap/logsnap/diff_logsnap and is never consumed (removed
* from the build). The SNAP *policy* DB (this file) is the one that feeds the paper.
* ---------------------------------------------------------------------------
clear all
set more off

global RAW "${code}/build/RawDataScripts/SNAP/SNAP_Policy_Database.csv"
global OUT "${rawdata}"

insheet using "${RAW}", clear

rename state_fips fipsstate
rename state_pc   state
rename statename  state_name

gen year  = int(yearmonth/100)
gen month = yearmonth - year*100
drop yearmonth

* the build consumes only the BBCE subset (the full processed DB is not needed downstream)
keep fipsstate year month bbce bbce_asset
rename bbce       bbce2018
rename bbce_asset bbce_asset2018

save "${OUT}/SNAP_Policy_Database_Processed_2018_premerge", replace
