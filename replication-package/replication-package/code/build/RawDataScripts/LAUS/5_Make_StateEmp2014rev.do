* ---------------------------------------------------------------------------
* 5_Make_StateEmp2014rev.do  ->  StateEmp2014rev.dta
* State monthly seasonally-adjusted employment (state_e_sa_pre), merged onto
* the border panel by UIMacro_BuildData.do (prod_all = state GDP per worker).
*
* INPUT: LAUS/Output/laus_state_sa_pre.dta (step 4).
* OUTPUT: StateEmp2014rev.dta (fipsstate year month state_e_sa_pre).
* This script reads state_e_sa_pre directly from step 4's output. The build
* keeps only the 1990-2014 panel rows (it drops unmatched observations on
* merge), so rows outside that window are not consumed.
* ---------------------------------------------------------------------------
clear all
set more off
do "config.do"

use "${rawdata}/LAUS/Output/laus_state_sa_pre.dta"
keep year month fipsstate state_e_sa_pre
save "${rawdata}/StateEmp2014rev", replace
