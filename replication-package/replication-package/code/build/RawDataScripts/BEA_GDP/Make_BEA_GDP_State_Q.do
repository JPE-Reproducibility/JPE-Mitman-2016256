* ---------------------------------------------------------------------------
* Make_BEA_GDP_State_Q.do  ->  BEA_GDP_State_Q.dta
* Quarterly real GDP by state (all industries + private industries), 2005Q1-2016Q1,
* for the state productivity controls (prod_all / prod_priv / prod_all_qcew and the
* diff_logstate_gdp_all growth adjustment) in the main build.
*
* SOURCE (provided raw): BEA prototype quarterly real GDP-by-state,
*   BEA_GDP/qgsp_all_R.csv (July-2016 download of the "Real GDP by state"
*   component; GeoFIPS x industry wide, columns 2005Q1 - 2016Q1; the last rows
*   of the CSV are footnotes, dropped by the count>=1441 line).
*   industryid 1 = "All industry total", 2 = "Private industries".
* OUTPUT: BEA_GDP_State_Q.dta -- fipsstate x quarter panel (50 states + DC +
*   the 8 BEA regions) with state_gdp_all and state_gdp_priv.
* ---------------------------------------------------------------------------
clear all
set more off
do "config.do"

insheet using "${rawdata}/BEA_GDP/qgsp_all_R.csv", comma

destring geofips, replace
gen count=_n
drop if count>=1441
destring geofips, replace

drop if geofips==0
rename geofips fipsstate
replace fipsstate=floor(fipsstate/1000)

keep if inlist(industryid,1,2)

gen gdptype=0
replace gdptype=1 if industryid==2

rename q1 v9
rename q2 v10
rename q3 v11
rename q4 v12

local i="1"
foreach num of numlist 9/53 {
        rename v`num' y`i'
        destring y`i', replace
	  local i=`i'+1
        }

keep y* fipsstate gdptype
reshape long y, i(fipsstate gdptype) j(time)

gen year=2005+floor((time-1)/4)
gen quarter=mod((time-1),4)+1

reshape wide y, i(fipsstate time) j(gdptype)
rename y0 state_gdp_all
rename y1 state_gdp_priv

save "${rawdata}/BEA_GDP_State_Q.dta", replace
